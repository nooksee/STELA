<?php
// Safety lock: prevent installer scripts from running after setup.
$__nukece_lock = __DIR__ . '/LOCK';
if (is_file($__nukece_lock)) {
    header('HTTP/1.1 403 Forbidden');
    exit('Installer is locked. Remove install/LOCK to run installers.');
}

declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

/**
 * STRICT Auto-tune Forums rewrite rules for the legacy phpBB2 tree (phpBB2x modpacks).
 *
 * SECURITY MODEL:
 * - Default DENY every discovered *.php "entry script" under legacy/modules/Forums
 * - Allow only computed "safe entry points" (allowlist)
 * - Supports subfolder entrypoints (e.g. mods/foo.php) via allow_paths[]
 *
 * Writes data/forums_rewrite.json with:
 * - safe_rewrite: true
 * - denylist_add: (all ROOT scripts except allowlist)
 * - denylist_remove: (ROOT allowlist)
 * - allow_paths: (SAFE SUBPATH scripts to rewrite into wrapper)
 * - deny_paths_add: (SUBPATH scripts explicitly denied)
 */
define('NUKECE_ROOT', realpath(__DIR__ . '/..') ?: (__DIR__ . '/..'));

$legacyBase = NUKECE_ROOT . '/legacy/modules/Forums';
$dataDir = NUKECE_ROOT . '/data';
@mkdir($dataDir, 0755, true);

if (!is_dir($legacyBase)) {
    fwrite(STDERR, "Legacy forums dir not found: $legacyBase\n");
    exit(1);
}

function relpath(string $base, string $abs): string {
    $base = rtrim(str_replace('\\','/',$base), '/') . '/';
    $abs = str_replace('\\','/',$abs);
    if (strpos($abs, $base) === 0) return substr($abs, strlen($base));
    return basename($abs);
}

$rootFiles = glob($legacyBase . '/*.php') ?: [];
$rootNames = array_map('basename', $rootFiles);
sort($rootNames, SORT_NATURAL | SORT_FLAG_CASE);

// Explicit root allowlist: core entry points + integrations you want to behave as first-class
$explicitRootAllow = [
    'index.php','viewforum.php','viewtopic.php','posting.php','profile.php','search.php',
    'privmsg.php','login.php','memberlist.php','groupcp.php','faq.php','modcp.php',
    'viewonline.php','recent.php','statistics.php','merge.php','uacp.php','usercp_confirm.php',
    'show_post.php','viewpost_reports.php','attach_rules.php',

    // Gallery/album lineage
    'album.php','album_cat.php','album_comment.php','album_comment_delete.php','album_comment_edit.php',
    'album_cp.php','album_delete.php','album_edit.php','album_page.php','album_personal.php',
    'album_personal_index.php','album_pic.php','album_rate.php','album_thumbnail.php','album_upload.php',
];

// Subfolder scanning (conservative): only look under these directories
// (Modpacks often put public entry scripts under mods/* or similar.)
$safeSubdirs = [
    'mods',
    'album_mod',

    'games',
    'kb',
    'downloads',
    'download',
    'links',
    'calendar',
    'portal',
];

// Safe prefixes for auto-allow (file base name)
$safePrefixes = [
    'arcade', 'ibproarcade', 'games',
    'kb', 'download', 'downloads', 'links',
    'calendar', 'portal', 'shop', 'donate',
];

// Never-allow prefixes (file base name)
$denyPrefixes = ['admin','install','upgrade','backup','restore','config','phpinfo','db','common','shell','cron','task','schema','migrate'];

// ---------- ROOT allow/deny ----------
$allowRoot = [];
$lowerExplicitRoot = array_map('strtolower', $explicitRootAllow);

foreach ($rootNames as $fn) {
    $lfn = strtolower($fn);
    $base = strtolower(pathinfo($fn, PATHINFO_FILENAME));

    if (in_array($lfn, $lowerExplicitRoot, true)) {
        $allowRoot[] = $fn;
        continue;
    }

    $blocked = false;
    foreach ($denyPrefixes as $pfx) {
        if (strpos($base, $pfx) === 0) { $blocked = true; break; }
    }
    if ($blocked) continue;

    foreach ($safePrefixes as $pfx) {
        if (strpos($base, strtolower($pfx)) === 0) { $allowRoot[] = $fn; break; }
    }
}

$allowRoot = array_values(array_unique($allowRoot));
sort($allowRoot, SORT_NATURAL | SORT_FLAG_CASE);
$allowRootSet = array_fill_keys(array_map('strtolower', $allowRoot), true);

$denyAdd = [];
foreach ($rootNames as $fn) {
    if (!isset($allowRootSet[strtolower($fn)])) $denyAdd[] = $fn;
}
sort($denyAdd, SORT_NATURAL | SORT_FLAG_CASE);

// ---------- SUBPATH allow/deny ----------
$allowPaths = [];
$denyPathsAdd = [];

foreach ($safeSubdirs as $sub) {
    $dir = $legacyBase . '/' . $sub;
    if (!is_dir($dir)) continue;

    // Depth-limited recursive scan (3 levels) for *.php
    $rii = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($dir, FilesystemIterator::SKIP_DOTS),
        RecursiveIteratorIterator::SELF_FIRST
    );

    foreach ($rii as $file) {
        /** @var SplFileInfo $file */
        if (!$file->isFile()) continue;
        if (strtolower($file->getExtension()) !== 'php') continue;

        $abs = $file->getPathname();
        $rel = relpath($legacyBase, $abs);         // e.g. mods/foo.php or mods/sub/x.php
        $relNorm = str_replace('\\','/',$rel);

        // Limit depth by counting slashes
        if (substr_count($relNorm, '/') > 6) continue;

        $base = strtolower(pathinfo($relNorm, PATHINFO_FILENAME));

        // segment-based allow: if any path segment is a safe area and file is index.php
        $segments = explode('/', strtolower($relNorm));
        $isIndex = (strtolower(basename($relNorm)) === 'index.php');
        $segmentSafe = false;
        foreach ($segments as $seg) {
            foreach ($safePrefixes as $pfx) {
                if ($seg === strtolower($pfx)) { $segmentSafe = true; break 2; }
            }
        }


        // Hard block
        // segment deny (extra strict): if any path segment begins with a deny prefix, block
        $segBlocked = false;
        foreach ($segments as $seg) {
            foreach ($denyPrefixes as $pfx) {
                if (strpos($seg, $pfx) === 0) { $segBlocked = true; break 2; }
            }
        }
        if ($segBlocked) {
            $denyPathsAdd[] = $relNorm;
            continue;
        }

        $blocked = false;
        foreach ($denyPrefixes as $pfx) {
            if (strpos($base, $pfx) === 0) { $blocked = true; break; }
        }
        if ($blocked) {
            $denyPathsAdd[] = $relNorm;
            continue;
        }

        // Allow if base starts with safe prefixes OR directory itself is in safeSubdirs and file name is clearly public
        $isSafe = false;
        foreach ($safePrefixes as $pfx) {
            if (strpos($base, strtolower($pfx)) === 0) { $isSafe = true; break; }
        }

        // conservative fallback: allow "index.php" in safe subdirs
        if (!$isSafe && $isIndex) $isSafe = true;

        if (!$isSafe && $segmentSafe && $isIndex) $isSafe = true;

        if ($isSafe) $allowPaths[] = $relNorm;
        else $denyPathsAdd[] = $relNorm;
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
    'generated_at' => gmdate('c'),
    'mode' => 'strict_default_deny_with_subpaths',
    'notes' => 'STRICT auto-tune (default-deny). Root scripts denied except allowlist. Subfolder scripts allowed only when explicitly computed safe.',
];

file_put_contents($dataDir . '/forums_rewrite.json', json_encode($state, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES), LOCK_EX);

echo "Wrote {$dataDir}/forums_rewrite.json\n";
echo "root allowlist: " . count($allowRoot) . " scripts\n";
echo "root denylist_add: " . count($denyAdd) . " scripts\n";
echo "subpath allow_paths: " . count($allowPaths) . " scripts\n";
echo "subpath deny_paths_add: " . count($denyPathsAdd) . " scripts\n";
