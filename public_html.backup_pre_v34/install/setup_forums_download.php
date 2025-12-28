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
 * nukeCE forums downloader (Option 2):
 * Downloads IntegraMOD/phpBB2x snapshot and installs the phpBB board files into legacy/modules/Forums.
 *
 * SECURITY NOTE:
 * - This script is intended to be run by an administrator from CLI or temporarily from the web.
 * - After installing, delete or restrict access to /install/.
 */

function fail(string $msg): void {
    header('Content-Type: text/plain; charset=utf-8');
    http_response_code(500);
    echo "ERROR: {$msg}\n";
    exit;
}

$root = realpath(__DIR__ . '/..');
if (!$root) fail("Cannot locate nukeCE root.");

$dest = $root . '/legacy/modules/Forums';
if (!is_dir($dest)) @mkdir($dest, 0755, true);

$dataDir = $root . '/data';
if (!is_dir($dataDir)) @mkdir($dataDir, 0755, true);

$zipUrl = 'https://api.github.com/repos/IntegraMOD/phpBB2x/zipball/main';
$tmpZip = $dataDir . '/phpbb2x.zip';

$ua = 'nukeCE-forums-installer/1.0';

$ch = curl_init($zipUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($ch, CURLOPT_USERAGENT, $ua);
curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 20);
curl_setopt($ch, CURLOPT_TIMEOUT, 300);
$bin = curl_exec($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$err  = curl_error($ch);
curl_close($ch);

if ($bin === false || $code < 200 || $code >= 300) {
    fail("Download failed (HTTP {$code}): {$err}");
}
file_put_contents($tmpZip, $bin);

$sha = hash_file('sha256', $tmpZip);
file_put_contents($dataDir . '/phpbb2x.sha256', $sha . "\n");

// Extract into temp
$tmpDir = $dataDir . '/phpbb2x_extract';
if (is_dir($tmpDir)) {
    $it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($tmpDir, FilesystemIterator::SKIP_DOTS), RecursiveIteratorIterator::CHILD_FIRST);
    foreach ($it as $f) $f->isDir() ? rmdir($f->getPathname()) : unlink($f->getPathname());
    @rmdir($tmpDir);
}
@mkdir($tmpDir, 0755, true);

$zip = new ZipArchive();
if ($zip->open($tmpZip) !== true) fail("Cannot open zip.");

$zip->extractTo($tmpDir);
$zip->close();

// Find extracted folder root
$entries = array_values(array_filter(scandir($tmpDir), fn($x) => $x !== '.' && $x !== '..'));
if (!$entries) fail("Zip extracted but no contents found.");
$top = $tmpDir . '/' . $entries[0];

// phpBB2x keeps board in /phpBB
$boardDir = $top . '/phpBB';
if (!is_dir($boardDir)) fail("Expected folder not found: phpBB");

echo "Downloaded phpBB2x snapshot.\n";
echo "SHA256: {$sha}\n";

// Backup existing legacy forums to _stub if not already done
if (is_dir($dest) && !is_dir($dest . '/_stub')) {
    @mkdir($dest . '/_stub', 0755, true);
    // Move existing *.php (our stub) into _stub
    foreach (glob($dest . '/*.php') ?: [] as $f) {
        @rename($f, $dest . '/_stub/' . basename($f));
    }
    // Move common folders we created
    foreach (['images','templates','theme','mods','album_mod','cache'] as $d) {
        if (is_dir($dest . '/' . $d)) {
            @rename($dest . '/' . $d, $dest . '/_stub/' . $d);
        }
    }
}

// Copy board files into legacy/modules/Forums
$it = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($boardDir, FilesystemIterator::SKIP_DOTS), RecursiveIteratorIterator::SELF_FIRST);
foreach ($it as $file) {
    $rel = substr($file->getPathname(), strlen($boardDir) + 1);
    $target = $dest . '/' . $rel;

    if ($file->isDir()) {
        if (!is_dir($target)) @mkdir($target, 0755, true);
    } else {
        $tdir = dirname($target);
        if (!is_dir($tdir)) @mkdir($tdir, 0755, true);
        copy($file->getPathname(), $target);
    }
}

file_put_contents($dest . '/.nukece_phpbb2x_installed', date('c') . "\n");

echo "Installed forums board into: {$dest}\n";
echo "Next:\n";
echo " - Configure phpBB2 database settings in legacy/modules/Forums/config.php\n";
echo " - Run the phpBB installer if required (then delete the install directory)\n";
echo " - Visit /index.php?module=forums\n";


// Auto-tune deny/allow rules after install
$cmd = PHP_BINARY . ' ' . __DIR__ . '/setup_forums_tune.php';
@system($cmd);
