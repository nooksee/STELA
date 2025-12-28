<?php
declare(strict_types=1);

namespace NukeCE\Modules\Forums;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Layout;
use NukeCE\Core\Maintenance;
use NukeCE\Editor\EditorService;

final class ForumsModule implements ModuleInterface
{
    private string $legacyBase;
    private bool $safeRewrite = true;
    /** @var array<string,string> key => relative script path (e.g. viewtopic.php or mods/example.php) */
    private array $scriptMap = [];
    private array $appConfig = [];
    private array $override = [];

    public function __construct()
    {
        $this->legacyBase = dirname(__DIR__, 2) . '/legacy/modules/Forums';
        $this->appConfig = $this->loadAppConfig();
        $this->override = $this->loadRewriteOverride();

        if (array_key_exists('safe_rewrite', $this->override)) {
            $this->safeRewrite = (bool)$this->override['safe_rewrite'];
        }

        $this->scriptMap = $this->discoverScripts();
    }

    public function getName(): string
    {
        return 'forums';
    }

    public function handle(array $params): void
    {
        $cfgFile = dirname(__DIR__, 2) . '/config/config.php';
        $cfg = is_file($cfgFile) ? (array)include $cfgFile : [];
        if (isset($cfg['forums_enabled']) && !$cfg['forums_enabled']) {
            \NukeCE\Core\Layout::page('Forums', function () {
                echo '<h1>Forums</h1><div class="card" style="padding:14px"><b>Forums are disabled.</b></div>';
            }, ['module'=>'forums']);
            return;
        }

        // Request override for debugging
        if (isset($_GET['safe']) && $_GET['safe'] === '0') {
            $this->safeRewrite = false;
        }

        $fileKey = $_GET['file'] ?? 'index';
        if (!is_string($fileKey) || $fileKey === '') $fileKey = 'index';
        $fileKey = strtolower(preg_replace('/[^a-z0-9_]/i', '', $fileKey));
        if (!isset($this->scriptMap[$fileKey])) $fileKey = 'index';

        $relScript = $this->scriptMap[$fileKey] ?? 'index.php';
        $legacyPath = rtrim($this->legacyBase, '/\\') . '/' . $relScript;

        if (!is_file($legacyPath)) {
            http_response_code(404);
            echo "<h1>Forums</h1><p>Missing legacy script: " . htmlspecialchars($relScript, ENT_QUOTES, 'UTF-8') . "</p>";
            echo "<p>Hint: run <code>php install/setup_forums_download.php</code> and then <code>php install/setup_forums_tune.php</code>.</p>";
            return;
        }

        ob_start();
        include $legacyPath;
        $raw = (string)ob_get_clean();

        $body = $this->stripForumHtml($raw);
        $body = $this->rewriteLegacyLinks($body);
        [$body, $needsEditorAssets] = $this->applyEditorEnhancements($body);
        Layout::page('Forums', function () use ($body, $needsEditorAssets) {
            if ($needsEditorAssets) { EditorService::assets(); }
            echo $body;
        }, ['module' => 'forums']);
        return;
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

    private function loadRewriteOverride(): array
    {
        $dataDir = $this->appConfig['data_dir'] ?? (defined('NUKECE_ROOT') ? NUKECE_ROOT . '/data' : (__DIR__ . '/../../data'));
        $file = rtrim((string)$dataDir, '/\\') . '/forums_rewrite.json';
        if (!is_file($file)) return [];
        $raw = @file_get_contents($file);
        $j = $raw ? json_decode($raw, true) : null;
        return is_array($j) ? $j : [];
    }

    /** @return array{denyNames: array<int,string>, denyRegex: array<int,string>, denyPaths: array<int,string>, allowPaths: array<int,string>} */
    private function policy(): array
    {
        $denyNames = [
            'common.php','config.php','extension.inc','functions.php','db.php','session.php',
            'install.php','upgrade.php','admin.php','phpinfo.php','contributor.php',
            'redirect.php','nukebb.php',
        ];

        $denyRegex = [
            'regex:/^admin/i',
            'regex:/^install/i',
            'regex:/^upgrade/i',
            'regex:/phpinfo/i',
            'regex:/backup|restore/i',
        ];

        $denyPaths = [];
        $allowPaths = [];

        // Config overrides (optional)
        $forumsCfg = $this->appConfig['forums'] ?? [];
        $cfgAdd = is_array($forumsCfg['denylist_add'] ?? null) ? $forumsCfg['denylist_add'] : [];
        $cfgRemove = is_array($forumsCfg['denylist_remove'] ?? null) ? $forumsCfg['denylist_remove'] : [];
        $cfgRegex = is_array($forumsCfg['denylist_regex_add'] ?? null) ? $forumsCfg['denylist_regex_add'] : [];
        $cfgAllowPaths = is_array($forumsCfg['allow_paths'] ?? null) ? $forumsCfg['allow_paths'] : [];
        $cfgDenyPaths = is_array($forumsCfg['deny_paths_add'] ?? null) ? $forumsCfg['deny_paths_add'] : [];

        // UI overrides
        $uiAdd = is_array($this->override['denylist_add'] ?? null) ? $this->override['denylist_add'] : [];
        $uiRemove = is_array($this->override['denylist_remove'] ?? null) ? $this->override['denylist_remove'] : [];
        $uiRegex = is_array($this->override['denylist_regex_add'] ?? null) ? $this->override['denylist_regex_add'] : [];
        $uiAllowPaths = is_array($this->override['allow_paths'] ?? null) ? $this->override['allow_paths'] : [];
        $uiDenyPaths = is_array($this->override['deny_paths_add'] ?? null) ? $this->override['deny_paths_add'] : [];

        $add = array_merge($cfgAdd, $uiAdd);
        $remove = array_merge($cfgRemove, $uiRemove);
        $regexAdd = array_merge($cfgRegex, $uiRegex);

        $allowPaths = array_values(array_unique(array_filter(array_merge($cfgAllowPaths, $uiAllowPaths), 'is_string')));
        $denyPaths = array_values(array_unique(array_filter(array_merge($cfgDenyPaths, $uiDenyPaths), 'is_string')));

        // Remove exact-name denies
        $denyNames = array_values(array_filter($denyNames, function($n) use ($remove){
            foreach ($remove as $r) {
                if (is_string($r) && strtolower($r) === strtolower($n)) return false;
            }
            return true;
        }));

        foreach ($add as $item) {
            if (!is_string($item) || $item === '') continue;
            $denyNames[] = $item;
        }

        foreach ($regexAdd as $item) {
            if (!is_string($item) || $item === '') continue;
            $denyRegex[] = (stripos($item, 'regex:') === 0) ? $item : ('regex:' . $item);
        }

        $denyNames = array_values(array_unique(array_map('strtolower', $denyNames)));
        $denyRegex = array_values(array_unique($denyRegex));

        // Normalize subpaths
        $allowPaths = array_values(array_unique(array_map(function($p){
            $p = str_replace('\\','/',$p);
            $p = ltrim($p, '/');
            return $p;
        }, $allowPaths)));

        $denyPaths = array_values(array_unique(array_map(function($p){
            $p = str_replace('\\','/',$p);
            $p = ltrim($p, '/');
            return $p;
        }, $denyPaths)));

        return [
            'denyNames' => $denyNames,
            'denyRegex' => $denyRegex,
            'denyPaths' => $denyPaths,
            'allowPaths' => $allowPaths,
        ];
    }

    private function isDeniedScript(string $filename): bool
    {
        $pol = $this->policy();
        $denyNames = $pol['denyNames'];
        $denyRegex = $pol['denyRegex'];

        $low = strtolower($filename);
        if (in_array($low, $denyNames, true)) return true;

        foreach ($denyRegex as $rx) {
            if (stripos($rx, 'regex:') !== 0) continue;
            $pattern = substr($rx, 6);
            if (@preg_match($pattern, $filename) && preg_match($pattern, $filename)) return true;
        }
        return false;
    }

    private function isDeniedPath(string $relPath): bool
    {
        $pol = $this->policy();
        $relPath = str_replace('\\','/',$relPath);
        $relPath = ltrim($relPath, '/');

        foreach ($pol['denyPaths'] as $dp) {
            if (strcasecmp($dp, $relPath) === 0) return true;
        }
        // conservative: deny any path containing "/admin" segment
        if (preg_match('#(^|/)admin([^a-z0-9_]|$)#i', $relPath)) return true;
        return false;
    }

    /** Convert relative path to stable wrapper key */
    private function keyForPath(string $relPath): string
    {
        $relPath = str_replace('\\','/',$relPath);
        $relPath = preg_replace('#^/+?#', '', $relPath) ?? $relPath;
        $relPath = preg_replace('#\.php$#i', '', $relPath) ?? $relPath;
        $key = str_replace('/', '__', $relPath);
        $key = preg_replace('/[^a-z0-9_]/i', '_', $key) ?? $key;
        return strtolower($key);
    }

    /** @return array<string,string> */
    private function discoverScripts(): array
    {
        $map = [];

        if (!is_dir($this->legacyBase)) {
            return ['index' => 'index.php'];
        }

        // Root scripts
        $files = glob($this->legacyBase . '/*.php') ?: [];
        $rootNames = [];
        foreach ($files as $f) {
            $bn = basename($f);
            if ($this->isDeniedScript($bn)) continue;
            $rootNames[strtolower($bn)] = $bn;
        }

        foreach ($rootNames as $low => $bn) {
            $key = $this->keyForPath($bn);
            if ($key !== '') $map[$key] = $bn;
        }

        // Allowed subpath scripts from policy allow_paths
        $pol = $this->policy();
        foreach ($pol['allowPaths'] as $rel) {
            $rel = str_replace('\\','/',$rel);
            $rel = ltrim($rel, '/');
            if ($rel === '') continue;
            if (!preg_match('#\.php$#i', $rel)) continue;
            if ($this->isDeniedPath($rel)) continue;

            $abs = rtrim($this->legacyBase, '/\\') . '/' . $rel;
            if ($this->safeRewrite && !is_file($abs)) continue;

            $key = $this->keyForPath($rel);
            if ($key !== '' && !isset($map[$key])) $map[$key] = $rel;
        }

        if (!isset($map['index']) && isset($map['index_php'])) {
            $map['index'] = $map['index_php'];
        }
        if (!isset($map['index'])) $map = ['index' => 'index.php'] + $map;

        ksort($map);
        return $map;
    }

    private function stripForumHtml(string $raw): string
    {
        $lower = strtolower($raw);
        if (strpos($lower, '<html') === false && strpos($lower, '<body') === false) return $raw;

        $bodyOpen = strpos($lower, '<body');
        if ($bodyOpen === false) return $raw;

        $bodyStart = strpos($lower, '>', $bodyOpen);
        if ($bodyStart === false) return $raw;
        $bodyStart++;

        $bodyEnd = strrpos($lower, '</body>');
        if ($bodyEnd === false) return substr($raw, $bodyStart);

        return substr($raw, $bodyStart, $bodyEnd - $bodyStart);
    }

    private function rewriteLegacyLinks(string $html): string
    {
        // Rewrite links to any discovered script (root or allowed subpath)
        foreach ($this->scriptMap as $key => $relScript) {
            $abs = rtrim($this->legacyBase, '/\\') . '/' . $relScript;
            if ($this->safeRewrite && !is_file($abs)) continue;

            // Match href/action for either "file.php" or "sub/dir/file.php"
            $pattern = '/\b(href|action)\s*=\s*([\'"])(\.\/)?' . preg_quote($relScript, '/') . '(\?[^\'"]*)?\2/i';
            $html = preg_replace_callback($pattern, function ($m) use ($key) {
                $attr = $m[1];
                $q = $m[2];
                $qs = $m[4] ?? '';
                $url = '/index.php?module=forums&file=' . rawurlencode($key);
                if (is_string($qs) && $qs !== '') $url .= '&' . ltrim($qs, '?');
                return $attr . '=' . $q . $url . $q;
            }, $html) ?? $html;
        }

        // Asset folders (still safe rewrite)
        $html = preg_replace_callback('/\b(src|href)\s*=\s*([\'"])(images|templates|theme|mods|album_mod|cache)\/([^\'"]+)\2/i', function($m){
            $attr=$m[1]; $q=$m[2]; $dir=$m[3]; $rest=$m[4];
            if (preg_match('/^(https?:)?\/\//i', $rest)) return $m[0];
            $disk = $this->legacyBase . '/' . $dir . '/' . $rest;
            if ($this->safeRewrite && !is_file($disk) && !is_dir($disk)) return $m[0];
            $url = '/legacy/modules/Forums/' . $dir . '/' . $rest;
            return $attr . '=' . $q . $url . $q;
        }, $html) ?? $html;

        return $html;
    }
}
