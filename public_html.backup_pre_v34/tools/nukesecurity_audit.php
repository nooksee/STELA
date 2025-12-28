<?php
declare(strict_types=1);

/**
 * NukeSecurity integration audit (Gold Certification helper)
 * Run: php tools/nukesecurity_audit.php
 *
 * Outputs:
 * - entrypoints found
 * - entrypoints missing SecurityGate / guardRequest
 * - likely state-changing files
 * - state-changing files missing NukeSecurity::log
 */
final class NsecAudit
{
    private string $root;

    private array $entryCandidates = [
        'index.php','modules.php','admin.php','forums.php','cron.php','backend.php','rss.php','xmlrpc.php'
    ];

    public function __construct(string $root)
    {
        $this->root = rtrim($root, "/\\");
    }

    public function run(): void
    {
        $entrypoints = $this->discoverEntrypoints();
        $this->printSection("ENTRYPOINTS FOUND", $entrypoints);

        $missingGate = [];
        foreach ($entrypoints as $f) {
            $code = @file_get_contents($f) ?: '';
            if (!$this->hasGateOrGuard($code)) {
                $missingGate[] = $f;
            }
        }
        $this->printSection("ENTRYPOINTS MISSING SecurityGate / guardRequest()", $missingGate);

        $stateChangers = $this->findStateChangers();
        $this->printSection("LIKELY STATE-CHANGING FILES (need audit logs)", $stateChangers);

        $missingLogs = [];
        foreach ($stateChangers as $f) {
            $code = @file_get_contents($f) ?: '';
            if (!$this->hasAuditLog($code)) {
                $missingLogs[] = $f;
            }
        }
        $this->printSection("STATE-CHANGERS WITH NO NukeSecurity::log()", $missingLogs);

        $this->printFooter();
    }

    private function discoverEntrypoints(): array
    {
        $hits = [];

        foreach ($this->entryCandidates as $c) {
            $p = $this->root . '/' . $c;
            if (is_file($p)) $hits[] = $p;
        }

        foreach (['admin','modules'] as $dir) {
            $p = $this->root . '/' . $dir;
            if (!is_dir($p)) continue;

            $it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($p));
            foreach ($it as $fi) {
                if (!$fi->isFile()) continue;
                $path = $fi->getPathname();
                if (!str_ends_with($path, '.php')) continue;

                $base = basename($path);
                if ($dir === 'admin' && preg_match('~^admin_.*\.php$~', $base)) {
                    $hits[] = $path;
                }
                if ($dir === 'modules' && $base === 'index.php') {
                    $hits[] = $path;
                }
            }
        }

        $hits = array_values(array_unique($hits));
        sort($hits);
        return $hits;
    }

    private function hasGateOrGuard(string $code): bool
    {
        return (bool)(
            str_contains($code, "includes/security_gate.php") ||
            str_contains($code, 'NukeSecurity::guardRequest')
        );
    }

    private function hasAuditLog(string $code): bool
    {
        return (bool) str_contains($code, 'NukeSecurity::log(');
    }

    private function findStateChangers(): array
    {
        $suspects = [];
        foreach (['admin','modules','includes'] as $dir) {
            $p = $this->root . '/' . $dir;
            if (!is_dir($p)) continue;

            $it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($p));
            foreach ($it as $fi) {
                if (!$fi->isFile()) continue;
                $f = $fi->getPathname();
                if (!str_ends_with($f, '.php')) continue;

                $code = @file_get_contents($f);
                if (!is_string($code)) continue;

                $signals = [
                    'INSERT INTO','UPDATE ','DELETE FROM','REPLACE INTO',
                    'move_uploaded_file','chmod(','unlink(','copy(','rename(',
                ];
                foreach ($signals as $s) {
                    if (str_contains($code, $s)) { $suspects[] = $f; break; }
                }
            }
        }
        $suspects = array_values(array_unique($suspects));
        sort($suspects);
        return $suspects;
    }

    private function printSection(string $title, array $items): void
    {
        echo "\n==== {$title} ====\n";
        if (!$items) { echo "(none)\n"; return; }
        foreach ($items as $i) echo $i . "\n";
    }

    private function printFooter(): void
    {
        echo "\n==== NEXT STEP ====\n";
        echo "1) Add SecurityGate include to any missing entrypoints.\n";
        echo "2) Add NukeSecurity::log() to state-changers missing logs.\n";
        echo "3) Re-run until clean.\n";
    }
}

$root = realpath(__DIR__ . '/..') ?: getcwd();
(new NsecAudit($root))->run();
