\
<?php
declare(strict_types=1);

/**
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 *
 * Targeted provenance repair tool.
 *
 * Usage:
 *   php tools/provenance/repair.php --upstream=tools/provenance/upstream --dry-run=1
 *   php tools/provenance/repair.php --upstream=tools/provenance/upstream
 *
 * Put upstream sources in:
 *   tools/provenance/upstream/ravennuke/
 *   tools/provenance/upstream/evolution/
 *   tools/provenance/upstream/phpnuke/
 *
 * What it does:
 * - Finds PHP files in this project that appear to have a modern nukeCE header but lack legacy attribution.
 * - Attempts to locate a matching upstream file by relative path OR by strong similarity hash of the body (ignoring header).
 * - If a match is found and upstream has a recognizable attribution header, it prepends a restored attribution block.
 *
 * Safety:
 * - Only restores headers when similarity is high AND the current file is missing upstream attribution.
 * - Never overwrites existing upstream attribution blocks.
 */

final class ProvenanceRepair
{
    private string $root;
    private string $upstreamRoot;
    private bool $dryRun;

    public function __construct(string $root, string $upstreamRoot, bool $dryRun)
    {
        $this->root = rtrim($root, '/');
        $this->upstreamRoot = rtrim($upstreamRoot, '/');
        $this->dryRun = $dryRun;
    }

    public function run(): int
    {
        $targets = $this->findTargets();
        $report = [];
        foreach ($targets as $rel) {
            $curPath = $this->root . '/' . $rel;
            $cur = @file_get_contents($curPath);
            if ($cur === false) continue;

            $match = $this->findUpstreamMatch($rel, $cur);
            if (!$match) continue;

            [$upPath, $upText, $project] = $match;
            $upHeader = $this->extractAttributionHeader($upText);
            if ($upHeader === null) continue;

            // Avoid duplicating if the file already includes key upstream tokens.
            if (stripos($cur, 'Francisco Burzi') !== false || stripos($cur, 'RavenNuke') !== false || stripos($cur, 'Nuke Evolution') !== false) {
                continue;
            }

            $new = $upHeader . "\n\n" . $cur;
            $report[] = [
                'file' => $rel,
                'upstream' => $project . ':' . $upPath,
            ];

            if (!$this->dryRun) {
                file_put_contents($curPath, $new);
            }
        }

        $this->writeReport($report);
        echo "Provenance repair: " . count($report) . " file(s) " . ($this->dryRun ? "would be updated" : "updated") . PHP_EOL;
        return 0;
    }

    private function findTargets(): array
    {
        $out = [];
        $it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($this->root, FilesystemIterator::SKIP_DOTS));
        foreach ($it as $file) {
            /** @var SplFileInfo $file */
            if (!$file->isFile()) continue;
            if (strtolower($file->getExtension()) !== 'php') continue;

            $rel = ltrim(str_replace($this->root, '', $file->getPathname()), '/');
            if (str_starts_with($rel, 'vendor/') || str_starts_with($rel, 'legacy/') || str_starts_with($rel, 'forums/')) continue;
            if (str_starts_with($rel, 'tools/')) continue;

            $txt = @file_get_contents($file->getPathname());
            if ($txt === false) continue;

            $head = implode("\n", array_slice(preg_split("/\r\n|\n|\r/", $txt), 0, 50));
            // Target: files that have our standard header but not explicit legacy authors/licenses.
            if (stripos($head, 'PHP-Nuke CE') !== false &&
                stripos($head, 'Copyright') === false &&
                stripos($head, 'Francisco') === false &&
                stripos($head, 'GPL') === false &&
                stripos($head, 'GNU') === false) {
                // Avoid obviously new modules where upstream attribution is not appropriate.
                if (preg_match('#^modules/(admin_|reference|content|users|editor)/#', $rel)) continue;
                $out[] = $rel;
            }
        }
        return $out;
    }

    private function findUpstreamMatch(string $rel, string $curText): ?array
    {
        $candidates = [];

        $projects = ['ravennuke','evolution','phpnuke'];
        foreach ($projects as $proj) {
            $base = $this->upstreamRoot . '/' . $proj;
            if (!is_dir($base)) continue;

            // Path-based guesses (common layouts)
            $pathGuesses = [
                $base . '/' . $rel,
                $base . '/html/' . $rel,
                $base . '/nuke/' . $rel,
            ];
            foreach ($pathGuesses as $g) {
                if (is_file($g)) {
                    $up = @file_get_contents($g);
                    if ($up !== false) {
                        $score = $this->similarity($curText, $up);
                        $candidates[] = [$g, $up, $proj, $score];
                    }
                }
            }
        }

        if (!$candidates) return null;

        usort($candidates, fn($a,$b) => $b[3] <=> $a[3]);
        [$bestPath, $bestText, $proj, $score] = $candidates[0];

        // Require strong similarity so we don't misattribute.
        if ($score < 0.92) return null;

        return [$bestPath, $bestText, $proj];
    }

    private function similarity(string $a, string $b): float
    {
        $aBody = $this->stripLeadingComments($a);
        $bBody = $this->stripLeadingComments($b);

        // Hash-based fast check
        if (sha1($aBody) === sha1($bBody)) return 1.0;

        similar_text($aBody, $bBody, $pct);
        return $pct / 100.0;
    }

    private function stripLeadingComments(string $txt): string
    {
        $lines = preg_split("/\r\n|\n|\r/", $txt);
        $out = [];
        $inBlock = false;
        $started = false;

        foreach ($lines as $line) {
            if (!$started) {
                $trim = ltrim($line);
                if ($trim === '' || str_starts_with($trim, '<?php')) continue;

                if (str_starts_with($trim, '/*')) { $inBlock = true; continue; }
                if ($inBlock) {
                    if (str_contains($trim, '*/')) { $inBlock = false; continue; }
                    continue;
                }
                if (str_starts_with($trim, '//') || str_starts_with($trim, '#')) continue;

                // first real code line
                $started = true;
            }
            $out[] = $line;
        }
        return implode("\n", $out);
    }

    private function extractAttributionHeader(string $txt): ?string
    {
        // Return the first block comment that contains strong attribution tokens.
        if (!preg_match('#\A\s*<\?php\s*(/\*.*?\*/)#s', $txt, $m)) return null;
        $block = $m[1];

        $tokens = ['PHP-Nuke','Francisco','RavenNuke','Nuke Evolution','GNU','GPL','Copyright'];
        $hits = 0;
        foreach ($tokens as $t) {
            if (stripos($block, $t) !== false) $hits++;
        }
        if ($hits < 2) return null;

        // Append a restoration note (kept short, non-invasive)
        $note = "\n *\n * Upstream attribution restored by nukeCE provenance tool.\n";
        if (str_contains($block, '*/')) {
            $block = preg_replace('#\*/\s*$#', $note . " */", $block);
        }
        return $block;
    }

    private function writeReport(array $items): void
    {
        $dir = $this->root . '/docs';
        if (!is_dir($dir)) @mkdir($dir, 0775, true);

        $path = $dir . '/PROVENANCE_REPAIR_REPORT.md';
        $lines = [];
        $lines[] = "# Provenance Repair Report";
        $lines[] = "";
        $lines[] = "This report is generated by `tools/provenance/repair.php`.";
        $lines[] = "";
        $lines[] = "- Mode: " . ($this->dryRun ? "dry-run" : "write");
        $lines[] = "- Timestamp: " . date('c');
        $lines[] = "";

        if (!$items) {
            $lines[] = "_No changes._";
        } else {
            $lines[] = "| File | Upstream match |";
            $lines[] = "|---|---|";
            foreach ($items as $it) {
                $lines[] = "| `" . $it['file'] . "` | `" . $it['upstream'] . "` |";
            }
        }
        file_put_contents($path, implode("\n", $lines) . "\n");
    }
}

function arg(string $name, ?string $default=null): ?string {
    global $argv;
    foreach ($argv as $a) {
        if (str_starts_with($a, "--{$name}=")) return substr($a, strlen($name)+3);
    }
    return $default;
}

$root = dirname(__DIR__, 2);
$up = arg('upstream', $root . '/tools/provenance/upstream');
$dry = arg('dry-run', '0') === '1';

$tool = new ProvenanceRepair($root, $up, $dry);
exit($tool->run());
