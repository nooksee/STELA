<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\AdminForums;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\AdminLayout;
use NukeCE\Security\Csrf;
use NukeCE\Security\AuthGate;

final class AdminForumsModule implements ModuleInterface
{
    public function getName(): string { return 'admin_forums'; }

    public function handle(array $params): void
    {
        Csrf::ensureSession();
        // Defense in depth (Router also gates admin_*)
        AuthGate::requireAdminOrRedirect();

        $root = defined('NUKECE_ROOT') ? NUKECE_ROOT : dirname(__DIR__, 2);
        require_once $root . '/includes/admin_ui.php';
        include_once $root . '/includes/header.php';

        AdminUi::header('Forums Admin', [
            '/admin' => 'Dashboard',
            '/admin.php?op=logout' => 'Logout',
        ]);

        AdminUi::groupStart('Routing & Safety', 'Keep users inside the wrapper. Safe rewrite mode prevents fall-out.');

        $cfg = $this->loadAppConfig();
        $dataDir = (string)($cfg['data_dir'] ?? (defined('NUKECE_ROOT') ? NUKECE_ROOT . '/data' : __DIR__ . '/../../data'));
        if (!is_dir($dataDir)) @mkdir($dataDir, 0755, true);

        $stateFile = rtrim($dataDir, '/\\') . '/forums_rewrite.json';
        $state = $this->loadState($stateFile);

        $legacyBase = (defined('NUKECE_ROOT') ? NUKECE_ROOT : dirname(__DIR__, 2)) . '/legacy/modules/Forums';

        // Discover legacy scripts (root-level only)
        $scripts = [];
        if (is_dir($legacyBase)) {
            foreach (glob($legacyBase . '/*.php') ?: [] as $f) {
                $scripts[] = basename($f);
            }
            sort($scripts, SORT_NATURAL | SORT_FLAG_CASE);
        }

        $saved = false;
        $testInput = '';
        $testHtmlInput = '';
        $testHtml = '';

        if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'POST') {
            $token = $_POST['_csrf'] ?? null;
            if (!Csrf::validate(is_string($token) ? $token : null)) {
                $testHtml = "<div class='err'>CSRF validation failed.</div>";
            } else {
                $action = (string)($_POST['action'] ?? 'save');

                if ($action === 'save') {
                    $safe = isset($_POST['safe_rewrite']) && $_POST['safe_rewrite'] === '1';
                    $deny_add = $this->parseLines($_POST['denylist_add'] ?? '');
                    $deny_remove = $this->parseLines($_POST['denylist_remove'] ?? '');
                    $regex_add = $this->parseLines($_POST['denylist_regex_add'] ?? '');
                    $allow_paths = $this->parseLines($_POST['allow_paths'] ?? '');
                    $deny_paths_add = $this->parseLines($_POST['deny_paths_add'] ?? '');

                    $state = [
                        'safe_rewrite' => $safe,
                        'denylist_add' => $deny_add,
                        'denylist_remove' => $deny_remove,
                        'denylist_regex_add' => $regex_add,
                        'allow_paths' => $allow_paths,
                        'deny_paths_add' => $deny_paths_add,
                    ];
                    $this->saveState($stateFile, $state);
                    $saved = true;
                } elseif ($action === 'autotune') {
                    // Run the same tuner logic used by the installer
                    $testHtml = $this->runAutoTune($legacyBase, $stateFile);
                    $state = $this->loadState($stateFile);
                } elseif ($action === 'test_html') {
                    $testHtmlInput = is_string($_POST['test_html'] ?? null) ? (string)$_POST['test_html'] : '';
                    $testHtml = $this->renderHtmlSnippetTest($legacyBase, $state, $testHtmlInput);
                } elseif ($action === 'test') {
                    $testInput = is_string($_POST['test_url'] ?? null) ? (string)$_POST['test_url'] : '';
                    $testHtml = $this->renderTestResult($legacyBase, $state, $testInput);
                }
            }
        }
echo "<div class='card'>";
        echo "<h1 class='h1'>Forums Admin</h1>";
        echo "<h2 style='margin:0 0 10px 0;font-size:16px;opacity:.9;'>Routing &amp; Safety</h2><div style='margin:0 0 10px 0;opacity:.85'><small>Forums files installer: <code>php install/setup_forums_download.php</code></small></div>";
        if ($saved) echo "<div class='ok' style='margin:10px 0;'>Saved.</div>";

        $csrf = htmlspecialchars(Csrf::token(), ENT_QUOTES, 'UTF-8');

        $safe = !empty($state['safe_rewrite']);
        $deny_add = $this->linesToText($state['denylist_add'] ?? []);
        $deny_remove = $this->linesToText($state['denylist_remove'] ?? []);
        $regex_add = $this->linesToText($state['denylist_regex_add'] ?? []);

        $allow_paths = $this->linesToText($state['allow_paths'] ?? []);
        $deny_paths_add = $this->linesToText($state['deny_paths_add'] ?? []);

        echo "<form method='post' action='/index.php?module=admin_forums'>";
        echo "<input type='hidden' name='_csrf' value='{$csrf}'>";
        echo "<input type='hidden' name='action' value='save'>";

        echo "<div class='card' style='margin:10px 0;'>";
        echo "<label style='display:flex;gap:10px;align-items:center;'>";
        echo "<input type='checkbox' name='safe_rewrite' value='1' ".($safe ? "checked" : "").">";
        echo "<b>Safe rewrite mode</b> <span style='opacity:.75'>(only rewrite links proven to exist on disk)</span>";
        echo "</label>";
        echo "</div>";

        echo "<div class='grid'>";
        echo $this->textareaCard("Denylist additions (exact filenames)", "denylist_add", $deny_add, "One filename per line, e.g. suspicious.php");
        echo $this->textareaCard("Denylist removals (allow exact filenames)", "denylist_remove", $deny_remove, "One filename per line, e.g. nukebb.php");
        echo $this->textareaCard("Denylist regex additions", "denylist_regex_add", $regex_add, "One regex per line, e.g. /^tool_/i");
        echo $this->textareaCard("Allow paths (subfolders)", "allow_paths", $allow_paths, "One relative path per line, e.g. mods/example.php");
        echo $this->textareaCard("Deny paths (subfolders)", "deny_paths_add", $deny_paths_add, "One relative path per line, e.g. mods/admin_tool.php");
        echo "</div>";

        echo "<div style='margin-top:12px;display:flex;gap:10px;align-items:center;flex-wrap:wrap;'>";
        echo "<button class='btn' type='submit'>Save</button>
        </form>
        <form method='post' action='/index.php?module=admin_forums' style='margin-top:10px;'>
        <input type='hidden' name='_csrf' value='{$csrf}'>
        <input type='hidden' name='action' value='autotune'>
        <button class='btn2' type='submit'>Strict auto-tune (default-deny)</button>
        </form>
        <form method='post' action='/index.php?module=admin_forums'>
        <input type='hidden' name='_csrf' value='{$csrf}'>
        <input type='hidden' name='action' value='save'>";
        echo "<small>Stored in <code>data/forums_rewrite.json</code></small>";
        echo "</div>";

        echo "</form>";

        echo "<hr style='border:none;border-top:1px solid #eee;margin:18px 0;'>";

        // Test rewrite tool
        echo "<h2 style='margin:0 0 8px 0;font-size:16px;'>Test rewrite</h2>";
        echo "<p style='margin:0 0 10px 0;opacity:.8'>Paste a legacy URL (or path) like <code>viewtopic.php?t=123</code> or <code>images/logo.png</code>. This reports what the wrapper would do.</p>";

        echo "<form method='post' action='/index.php?module=admin_forums' style='display:grid;gap:10px;'>";
        echo "<input type='hidden' name='_csrf' value='{$csrf}'>";
        echo "<input type='hidden' name='action' value='test'>";
        echo "<div style='display:flex;gap:10px;align-items:center;flex-wrap:wrap;'>";
        echo "<input name='test_url' value='".htmlspecialchars($testHtmlInput, ENT_QUOTES, "UTF-8")."' style='min-width:320px;flex:1;padding:10px;border:1px solid #ccc;border-radius:10px;font-family:ui-monospace, SFMono-Regular, Menlo, monospace;font-size:12px;' placeholder='viewtopic.php?t=123'>";
        echo "<button class='btn' type='submit'>Test</button>";
        echo "</div>";
        echo "</form>";

echo "<div style='margin-top:14px;'></div>";
echo "<h3 style='margin:0 0 8px 0;font-size:15px;'>Bulk test HTML snippet</h3>";
echo "<p style='margin:0 0 10px 0;opacity:.8'>Paste a chunk of legacy-rendered HTML. We will list every <code>href</code>, <code>action</code>, and <code>src</code> we find, and show what would be rewritten (or blocked) under current rules.</p>";

echo "<form method='post' action='/index.php?module=admin_forums' style='display:grid;gap:10px;'>";
echo "<input type='hidden' name='_csrf' value='{$csrf}'>";
echo "<input type='hidden' name='action' value='test_html'>";
echo "<textarea name='test_html' rows='10' style='width:100%;font-family:ui-monospace, SFMono-Regular, Menlo, monospace;font-size:12px;padding:10px;border:1px solid #ccc;border-radius:10px;' placeholder='<a href=&quot;viewtopic.php?t=1&quot;>...'>".htmlspecialchars($testHtmlInput, ENT_QUOTES, "UTF-8")."</textarea>";
echo "<div><button class='btn' type='submit'>Analyze snippet</button></div>";
echo "</form>";

        if ($testHtml !== '') {
            echo "<div class='card' style='margin-top:10px;'>";
            echo $testHtml;
            echo "</div>";
        }

        echo "<hr style='border:none;border-top:1px solid #eee;margin:18px 0;'>";

        echo "<h2 style='margin:0 0 8px 0;font-size:16px;'>Detected legacy entry scripts</h2>";
        echo "<p style='margin:0 0 10px 0;opacity:.8'>Root-level scripts under <code>legacy/modules/Forums/*.php</code>.</p>";

        echo "<div class='card'>";
        if (!$scripts) {
            echo "<small>No scripts found. Is the legacy Forums folder present?</small>";
        } else {
            $ov = $this->compileOverrideState($state);
            echo "<table width='100%' cellpadding='6' cellspacing='0' style='border-collapse:collapse;'>";
            echo "<tr style='background:#f4f4f4'><th align='left'>Script</th><th align='left'>Override</th></tr>";
            foreach ($scripts as $fn) {
                $ovStatus = $ov[$fn] ?? 'default';
                echo "<tr style='border-top:1px solid #eee;'><td><code>".htmlspecialchars($fn, ENT_QUOTES,'UTF-8')."</code></td><td>".$this->badge($ovStatus)."</td></tr>";
            }
            echo "</table>";
        }
        echo "</div>";

        echo "</div>"; // outer card
        AdminUi::groupEnd();
        AdminUi::footer();
        include_once $root . '/includes/footer.php';
}

    private function textareaCard(string $title, string $name, string $value, string $hint): string
    {
        $t = htmlspecialchars($title, ENT_QUOTES, 'UTF-8');
        $n = htmlspecialchars($name, ENT_QUOTES, 'UTF-8');
        $h = htmlspecialchars($hint, ENT_QUOTES, 'UTF-8');
        $v = htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
        return "<div class='card'>
            <h3 style='margin:0 0 8px 0;font-size:15px'>{$t}</h3>
            <textarea name='{$n}' rows='10' style='width:100%;font-family:ui-monospace, SFMono-Regular, Menlo, monospace;font-size:12px;padding:10px;border:1px solid #ccc;border-radius:10px;'>{$v}</textarea>
            <div style='margin-top:6px;opacity:.75'><small>{$h}</small></div>
        </div>";
    }

    private function loadAppConfig(): array
    {
        $cfgFile = realpath(__DIR__ . '/../../config/config.php');
        if ($cfgFile && is_file($cfgFile)) {
            $cfg = include $cfgFile;
            return is_array($cfg) ? $cfg : [];
        }
        return [];
    }

    private function loadState(string $file): array
    {
        if (!is_file($file)) {
            return [
                'safe_rewrite' => true,
                'denylist_add' => [],
                'denylist_remove' => [],
                'denylist_regex_add' => [],
                'allow_paths' => [],
                'deny_paths_add' => [],
            ];
        }
        $raw = @file_get_contents($file);
        $j = $raw ? json_decode($raw, true) : null;
        if (!is_array($j)) $j = [];
        return [
            'safe_rewrite' => array_key_exists('safe_rewrite', $j) ? (bool)$j['safe_rewrite'] : true,
            'denylist_add' => is_array($j['denylist_add'] ?? null) ? $j['denylist_add'] : [],
            'denylist_remove' => is_array($j['denylist_remove'] ?? null) ? $j['denylist_remove'] : [],
            'denylist_regex_add' => is_array($j['denylist_regex_add'] ?? null) ? $j['denylist_regex_add'] : [],
            'allow_paths' => is_array($j['allow_paths'] ?? null) ? $j['allow_paths'] : [],
            'deny_paths_add' => is_array($j['deny_paths_add'] ?? null) ? $j['deny_paths_add'] : [],
        ];
    }

    private function saveState(string $file, array $state): void
    {
        @file_put_contents($file, json_encode($state, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT), LOCK_EX);
    }

    private function parseLines($text): array
    {
        if (!is_string($text)) return [];
        $lines = preg_split('/\r\n|\r|\n/', $text) ?: [];
        $out = [];
        foreach ($lines as $ln) {
            $ln = trim($ln);
            if ($ln === '') continue;
            $out[] = $ln;
        }
        return array_values(array_unique($out));
    }

    private function linesToText($arr): string
    {
        if (!is_array($arr)) return '';
        return implode("\n", array_map('strval', $arr));
    }

    private function compileOverrideState(array $state): array
    {
        $out = [];
        $add = $state['denylist_add'] ?? [];
        $rem = $state['denylist_remove'] ?? [];
        if (is_array($add)) foreach ($add as $x) if (is_string($x)) $out[$x] = 'denied';
        if (is_array($rem)) foreach ($rem as $x) if (is_string($x)) $out[$x] = 'allowed';
        return $out;
    }

    private function badge(string $status): string
    {
        if ($status === 'allowed') return "<span class='badge ok'>allowed</span>";
        if ($status === 'denied') return "<span class='badge bad'>denied</span>";
        return "<span class='badge'>default</span>";
    }

    private function renderTestResult(string $legacyBase, array $state, string $input): string
    {
        $input = trim($input);
        if ($input === '') return "<small>No input.</small>";

        // Normalize: strip scheme+host and leading slashes
        $input = preg_replace('/^[a-z]+:\/\/[^\/]+/i', '', $input) ?? $input;
        $input = ltrim($input, '/');

        $safe = !empty($state['safe_rewrite']);

        // Asset path?
        if (preg_match('/^(images|templates|theme|mods|album_mod|cache)\//i', $input)) {
            $disk = rtrim($legacyBase, '/\\') . '/' . $input;
            $exists = is_file($disk) || is_dir($disk);
            $allowed = (!$safe) || $exists;

            $out  = "<div><b>Type:</b> asset</div>";
            $out .= "<div><b>Exists on disk:</b> " . ($exists ? "yes" : "no") . "</div>";
            $out .= "<div><b>Safe mode allows rewrite:</b> " . ($allowed ? "yes" : "no") . "</div>";
            if ($allowed) {
                $out .= "<div><b>Rewritten URL:</b> <code>/legacy/modules/Forums/" . htmlspecialchars($input, ENT_QUOTES, 'UTF-8') . "</code></div>";
            }
            return $out;
        }

        $parts = explode('?', $input, 2);
        $script = $parts[0];
        $query = $parts[1] ?? '';

        if (!preg_match('/\.php$/i', $script)) {
            return "<div><b>Type:</b> unknown</div><div><small>Input is not a *.php script or known asset path.</small></div>";
        }

        $exists = is_file(rtrim($legacyBase, '/\\') . '/' . $script);

        $deny = $this->isDeniedForTest($script, $state);
        $safeAllows = (!$safe) || $exists;
        $wouldRewrite = (!$deny) && $safeAllows;

        $key = strtolower(preg_replace('/[^a-z0-9_]/i','_', str_replace('/','__', preg_replace('/\.php$/i','',$script))));

        $out  = "<div><b>Type:</b> script</div>";
        $out .= "<div><b>Script:</b> <code>" . htmlspecialchars($script, ENT_QUOTES, 'UTF-8') . "</code></div>";
        $out .= "<div><b>Exists on disk:</b> " . ($exists ? "yes" : "no") . "</div>";
        $out .= "<div><b>Denied by rules:</b> " . ($deny ? "yes" : "no") . "</div>";
        $out .= "<div><b>Safe mode allows rewrite:</b> " . ($safeAllows ? "yes" : "no") . "</div>";
        $out .= "<div><b>Would rewrite:</b> " . ($wouldRewrite ? "yes" : "no") . "</div>";

        if ($wouldRewrite) {
            $url = "/index.php?module=forums&file=" . rawurlencode($key);
            if ($query !== '') $url .= "&" . $query;
            $out .= "<div><b>Rewritten URL:</b> <code>" . htmlspecialchars($url, ENT_QUOTES, 'UTF-8') . "</code></div>";
        }

        return $out;
    }

    private function isDeniedForTest(string $filename, array $state): bool
{
    $rel = str_replace('\','/',$filename);
    $low = strtolower($rel);

    $denyNames = [
        'common.php','config.php','extension.inc','functions.php','db.php','session.php',
        'install.php','upgrade.php','admin.php','phpinfo.php','contributor.php',
        'redirect.php','nukebb.php',
    ];

    $denyRegex = [
        '/^admin/i','/^install/i','/^upgrade/i','/phpinfo/i','/backup|restore/i',
    ];

    $add = is_array($state['denylist_add'] ?? null) ? $state['denylist_add'] : [];
    $remove = is_array($state['denylist_remove'] ?? null) ? $state['denylist_remove'] : [];
    $regexAdd = is_array($state['denylist_regex_add'] ?? null) ? $state['denylist_regex_add'] : [];

    $denyPaths = is_array($state['deny_paths_add'] ?? null) ? $state['deny_paths_add'] : [];
    $allowPaths = is_array($state['allow_paths'] ?? null) ? $state['allow_paths'] : [];

    // Subpath exact denies
    foreach ($denyPaths as $dp) {
        if (is_string($dp) && strtolower(str_replace('\','/',$dp)) === $low) return true;
    }

    // If it's a subpath script and not in allow_paths, we treat it as denied in strict model
    if (strpos($rel, '/') !== false) {
        $allowed = false;
        foreach ($allowPaths as $ap) {
            if (is_string($ap) && strtolower(str_replace('\','/',$ap)) === $low) { $allowed = true; break; }
        }
        return !$allowed;
    }

    foreach ($remove as $r) {
        if (is_string($r) && strtolower($r) === $low) return false;
    }
    foreach ($add as $a) {
        if (is_string($a) && strtolower($a) === $low) return true;
    }
    foreach ($regexAdd as $rx) {
        if (!is_string($rx) || trim($rx) === '') continue;
        $pat = trim($rx);
        if (stripos($pat, 'regex:') === 0) $pat = substr($pat, 6);
        if ($pat[0] !== '/') $pat = '/' . str_replace('/', '\/', $pat) . '/i';
        if (@preg_match($pat, $filename) && preg_match($pat, $filename)) return true;
    }

    if (in_array($low, array_map('strtolower', $denyNames), true)) return true;
    foreach ($denyRegex as $pat) if (preg_match($pat, $filename)) return true;

    return false;
}
        foreach ($add as $a) {
            if (is_string($a) && strtolower($a) === $low) return true;
        }
        foreach ($regexAdd as $rx) {
            if (!is_string($rx) || trim($rx) === '') continue;
            $pat = trim($rx);
            if (stripos($pat, 'regex:') === 0) $pat = substr($pat, 6);
            // accept /.../i or plain
            if ($pat[0] !== '/') {
                $pat = '/' . str_replace('/', '\/', $pat) . '/i';
            }
            if (@preg_match($pat, $filename) && preg_match($pat, $filename)) return true;
        }

        if (in_array($low, array_map('strtolower', $denyNames), true)) return true;
        foreach ($denyRegex as $pat) if (preg_match($pat, $filename)) return true;

        return false;
    }
private function runAutoTune(string $legacyBase, string $stateFile): string
{
    if (!is_dir($legacyBase)) {
        return "<div class='err'>Legacy forum folder not found: <code>" . htmlspecialchars($legacyBase, ENT_QUOTES, 'UTF-8') . "</code></div>";
    }

    $dataDir = dirname($stateFile);
    @mkdir($dataDir, 0755, true);

    // Root scripts
    $rootFiles = glob(rtrim($legacyBase, '/\\') . '/*.php') ?: [];
    $rootNames = array_map('basename', $rootFiles);
    sort($rootNames, SORT_NATURAL | SORT_FLAG_CASE);

    $explicitRootAllow = [
        'index.php','viewforum.php','viewtopic.php','posting.php','profile.php','search.php',
        'privmsg.php','login.php','memberlist.php','groupcp.php','faq.php','modcp.php',
        'viewonline.php','recent.php','statistics.php','merge.php','uacp.php','usercp_confirm.php',
        'show_post.php','viewpost_reports.php','attach_rules.php',
        'album.php','album_cat.php','album_comment.php','album_comment_delete.php','album_comment_edit.php',
        'album_cp.php','album_delete.php','album_edit.php','album_page.php','album_personal.php',
        'album_personal_index.php','album_pic.php','album_rate.php','album_thumbnail.php','album_upload.php',
    ];

    $safeSubdirs = ['mods','album_mod','arcade','games','kb','downloads','download','links','calendar','portal'];
    $safePrefixes = ['arcade','ibproarcade','games','kb','download','downloads','links','calendar','portal','shop','donate'];
    $denyPrefixes = ['admin','install','upgrade','backup','restore','config','phpinfo','db','common','shell','cron','task','schema','migrate'];

    // Root allow
    $allowRoot = [];
    $lowerExplicit = array_map('strtolower', $explicitRootAllow);

    foreach ($rootNames as $fn) {
        $lfn = strtolower($fn);
        $base = strtolower(pathinfo($fn, PATHINFO_FILENAME));

        if (in_array($lfn, $lowerExplicit, true)) { $allowRoot[] = $fn; continue; }

        $blocked = false;
        foreach ($denyPrefixes as $pfx) { if (strpos($base, $pfx) === 0) { $blocked = true; break; } }
        if ($blocked) continue;

        foreach ($safePrefixes as $pfx) { if (strpos($base, strtolower($pfx)) === 0) { $allowRoot[] = $fn; break; } }
    }

    $allowRoot = array_values(array_unique($allowRoot));
    sort($allowRoot, SORT_NATURAL | SORT_FLAG_CASE);
    $allowSet = array_fill_keys(array_map('strtolower', $allowRoot), true);

    $denyAdd = [];
    foreach ($rootNames as $fn) if (!isset($allowSet[strtolower($fn)])) $denyAdd[] = $fn;
    sort($denyAdd, SORT_NATURAL | SORT_FLAG_CASE);

    // Subpath allow/deny
    $allowPaths = [];
    $denyPathsAdd = [];

    foreach ($safeSubdirs as $sub) {
        $dir = rtrim($legacyBase, '/\\') . '/' . $sub;
        if (!is_dir($dir)) continue;

        $rii = new \RecursiveIteratorIterator(
            new \RecursiveDirectoryIterator($dir, \FilesystemIterator::SKIP_DOTS),
            \RecursiveIteratorIterator::SELF_FIRST
        );

        foreach ($rii as $file) {
            if (!$file->isFile()) continue;
            $ext = strtolower((string)$file->getExtension());
            if ($ext !== 'php') continue;

            $abs = (string)$file->getPathname();
            $baseLegacy = rtrim(str_replace('\\','/',$legacyBase), '/') . '/';
            $absNorm = str_replace('\\','/',$abs);
            $rel = (strpos($absNorm, $baseLegacy) === 0) ? substr($absNorm, strlen($baseLegacy)) : basename($absNorm);
            $rel = str_replace('\\','/',$rel);
            if ($rel === '' || strpos($rel, '..') !== false) continue;

            // Depth cap (deeper nested mod folders supported)
            if (substr_count($rel, '/') > 6) continue;

            $segments = explode('/', strtolower($rel));
            $base = strtolower(pathinfo($rel, PATHINFO_FILENAME));
            $isIndex = (strtolower(basename($rel)) === 'index.php');

            // Segment deny
            $segBlocked = false;
            foreach ($segments as $seg) {
                foreach ($denyPrefixes as $pfx) {
                    if (strpos($seg, $pfx) === 0) { $segBlocked = true; break 2; }
                }
            }
            if ($segBlocked) { $denyPathsAdd[] = $rel; continue; }

            // Base deny
            $blocked = false;
            foreach ($denyPrefixes as $pfx) { if (strpos($base, $pfx) === 0) { $blocked = true; break; } }
            if ($blocked) { $denyPathsAdd[] = $rel; continue; }

            // Determine safe
            $isSafe = false;
            foreach ($safePrefixes as $pfx) { if (strpos($base, strtolower($pfx)) === 0) { $isSafe = true; break; } }
            if (!$isSafe && $isIndex) $isSafe = true;

            $segmentSafe = false;
            foreach ($segments as $seg) {
                foreach ($safePrefixes as $pfx) {
                    if ($seg === strtolower($pfx)) { $segmentSafe = true; break 2; }
                }
            }
            if (!$isSafe && $segmentSafe && $isIndex) $isSafe = true;

            if ($isSafe) $allowPaths[] = $rel;
            else $denyPathsAdd[] = $rel;
        }
    }

    $allowPaths = array_values(array_unique($allowPaths));
    sort($allowPaths, SORT_NATURAL | SORT_FLAG_CASE);
    $denyPathsAdd = array_values(array_unique($denyPathsAdd));
    sort($denyPathsAdd, SORT_NATURAL | SORT_FLAG_CASE);

    $state = [
        'safe_rewrite' => true,
        'denylist_add' => $denyAdd,
        'denylist_remove' => $allowRoot,
        'allow_paths' => $allowPaths,
        'deny_paths_add' => $denyPathsAdd,
        'denylist_regex_add' => [],
                'allow_paths' => [],
                'deny_paths_add' => [],
        'generated_at' => gmdate('c'),
        'mode' => 'strict_default_deny_with_subpaths',
        'notes' => 'STRICT auto-tune (default-deny). Root scripts denied except allowlist. Subfolder scripts allowed only when explicitly computed safe.',
    ];

    @file_put_contents($stateFile, json_encode($state, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT), LOCK_EX);

    return "<div class='ok'>Strict auto-tune complete. Root allow <b>" . count($allowRoot) . "</b>, root deny <b>" . count($denyAdd) . "</b>, subpath allow <b>" . count($allowPaths) . "</b>. Wrote <code>data/forums_rewrite.json</code>.</div>";
}

    $dataDir = dirname($stateFile);
    @mkdir($dataDir, 0755, true);

    $files = glob(rtrim($legacyBase, '/\') . '/*.php') ?: [];
    $names = array_map('basename', $files);
    sort($names, SORT_NATURAL | SORT_FLAG_CASE);

    $explicitAllow = [
        'index.php','viewforum.php','viewtopic.php','posting.php','profile.php','search.php',
        'privmsg.php','login.php','memberlist.php','groupcp.php','faq.php','modcp.php',
        'viewonline.php','recent.php','statistics.php','merge.php','uacp.php','usercp_confirm.php',
        'show_post.php','viewpost_reports.php','attach_rules.php',
        'album.php','album_cat.php','album_comment.php','album_comment_delete.php','album_comment_edit.php',
        'album_cp.php','album_delete.php','album_edit.php','album_page.php','album_personal.php',
        'album_personal_index.php','album_pic.php','album_rate.php','album_thumbnail.php','album_upload.php',
    ];

    $safePrefixes = ['arcade','ibproarcade','games','kb','download','downloads','links','calendar','portal','shop','donate'];
    $denyPrefixes = ['admin','install','upgrade','backup','restore','config','phpinfo','db','common','shell','cron','task','schema','migrate'];

    $lowerExplicit = array_map('strtolower', $explicitAllow);
    $allow = [];

    foreach ($names as $fn) {
        $lfn = strtolower($fn);
        $base = strtolower(pathinfo($fn, PATHINFO_FILENAME));

        if (in_array($lfn, $lowerExplicit, true)) {
            $allow[] = $fn;
            continue;
        }

        $blocked = false;
        foreach ($denyPrefixes as $pfx) {
            if (strpos($base, $pfx) === 0) { $blocked = true; break; }
        }
        if ($blocked) continue;

        foreach ($safePrefixes as $pfx) {
            if (strpos($base, strtolower($pfx)) === 0) { $allow[] = $fn; break; }
        }
    }

    $allow = array_values(array_unique($allow));
    sort($allow, SORT_NATURAL | SORT_FLAG_CASE);
    $allowSet = array_fill_keys(array_map('strtolower', $allow), true);

    $denyAdd = [];
    foreach ($names as $fn) {
        if (!isset($allowSet[strtolower($fn)])) $denyAdd[] = $fn;
    }
    sort($denyAdd, SORT_NATURAL | SORT_FLAG_CASE);

    $state = [
        'safe_rewrite' => true,
        'denylist_add' => $denyAdd,
        'denylist_remove' => $allow,
        'denylist_regex_add' => [],
                'allow_paths' => [],
                'deny_paths_add' => [],
        'generated_at' => gmdate('c'),
        'mode' => 'strict_default_deny',
        'notes' => 'STRICT auto-tune (default-deny). All forum root scripts denied except computed allowlist.',
    ];

    @file_put_contents($stateFile, json_encode($state, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT), LOCK_EX);

    return "<div class='ok'>Strict auto-tune complete. Allowing <b>" . count($allow) . "</b> scripts; denying <b>" . count($denyAdd) . "</b>. Wrote <code>data/forums_rewrite.json</code>.</div>";
}

}
