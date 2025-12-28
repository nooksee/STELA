<?php
/**
 * PHP-Nuke CE (Community Edition)
 * Admin Maintenance (Gold)
 *
 * This module provides cache control, log rotation, health checks,
 * and legacy compatibility status in an AdminUi-consistent interface.
 *
 * Provenance: nukeCE project (2025-2026). Honors classic PHP-Nuke admin flow.
 */

// Bootstrap
$ROOT = realpath(__DIR__ . '/../../');
if ($ROOT === false) { $ROOT = __DIR__ . '/../../'; }

require_once $ROOT . '/includes/mainfile.php';

// SecurityGate (guarantee early coverage even if admin.php dispatch differs)
if (file_exists($ROOT . '/includes/security_gate.php')) {
    require_once $ROOT . '/includes/security_gate.php';
}

// Admin auth
if (!function_exists('is_admin') || !is_admin()) {
    header('HTTP/1.1 403 Forbidden');
    echo 'Forbidden';
    exit;
}

// AdminUi
if (file_exists($ROOT . '/src/Core/AdminUi.php')) {
    require_once $ROOT . '/src/Core/AdminUi.php';
}

// NukeSecurity logging helper (soft)
function nsec_log($event, $ctx = []) {
    if (class_exists('NukeSecurity') && method_exists('NukeSecurity', 'log')) {
        try { NukeSecurity::log($event, $ctx); } catch (Throwable $e) {}
        return;
    }
    // fall back to PHP error log (never fatal)
    error_log('[nukece][maintenance] ' . $event . ' ' . json_encode($ctx));
}

// CSRF (soft)
function nukece_csrf_token() {
    if (session_status() !== PHP_SESSION_ACTIVE) @session_start();
    if (empty($_SESSION['nukece_csrf'])) {
        $_SESSION['nukece_csrf'] = bin2hex(random_bytes(16));
    }
    return $_SESSION['nukece_csrf'];
}
function nukece_csrf_check($token) {
    if (session_status() !== PHP_SESSION_ACTIVE) @session_start();
    return isset($_SESSION['nukece_csrf']) && hash_equals($_SESSION['nukece_csrf'], (string)$token);
}

// Utilities
function rrmdir_contents($dir) {
    if (!is_dir($dir)) return [0,0];
    $files = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($dir, FilesystemIterator::SKIP_DOTS),
        RecursiveIteratorIterator::CHILD_FIRST
    );
    $deletedFiles = 0; $deletedDirs = 0;
    foreach ($files as $fileinfo) {
        $path = $fileinfo->getRealPath();
        if ($fileinfo->isDir()) {
            if (@rmdir($path)) $deletedDirs++;
        } else {
            if (@unlink($path)) $deletedFiles++;
        }
    }
    return [$deletedFiles, $deletedDirs];
}

function rotate_log_file($path, $keep = 5) {
    if (!file_exists($path)) return false;
    $keep = max(1, min(30, (int)$keep));
    for ($i = $keep; $i >= 1; $i--) {
        $src = $path . '.' . $i;
        $dst = $path . '.' . ($i + 1);
        if (file_exists($dst)) @unlink($dst);
        if (file_exists($src)) @rename($src, $dst);
    }
    @rename($path, $path . '.1');
    // recreate empty log
    @file_put_contents($path, "", LOCK_EX);
    return true;
}

// Paths (safe defaults)
$cacheDirs = [
    $ROOT . '/cache',
    $ROOT . '/data/cache',
    $ROOT . '/tmp/cache',
];
$logFiles = [
    $ROOT . '/data/nukesecurity.log',
    $ROOT . '/data/logs/nukesecurity.log',
    $ROOT . '/data/logs/app.log',
];

$messages = [];
$action = $_POST['action'] ?? '';
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $action) {
    $csrf = $_POST['csrf'] ?? '';
    if (!nukece_csrf_check($csrf)) {
        $messages[] = ['type' => 'error', 'text' => 'Security check failed. Please refresh and try again.'];
    } else {
        switch ($action) {
            case 'clear_cache':
                $totalFiles = 0; $totalDirs = 0;
                foreach ($cacheDirs as $dir) {
                    [$df, $dd] = rrmdir_contents($dir);
                    $totalFiles += $df; $totalDirs += $dd;
                }
                nsec_log('maintenance.cache.cleared', ['files' => $totalFiles, 'dirs' => $totalDirs]);
                $messages[] = ['type' => 'success', 'text' => "Cache cleared: {$totalFiles} files, {$totalDirs} dirs removed."];
                break;

            case 'rotate_logs':
                $keep = (int)($_POST['keep'] ?? 7);
                $rotated = 0; $skipped = 0;
                foreach ($logFiles as $lf) {
                    if (file_exists($lf)) {
                        if (rotate_log_file($lf, $keep)) $rotated++; else $skipped++;
                    }
                }
                nsec_log('maintenance.logs.rotated', ['keep' => $keep, 'rotated' => $rotated, 'skipped' => $skipped]);
                $messages[] = ['type' => 'success', 'text' => "Log rotation complete. Rotated: {$rotated}. Skipped: {$skipped}."];
                break;

            case 'trim_audit':
                // Placeholder-free: we implement a conservative trim hook if NukeSecurity exposes it.
                $days = max(7, min(3650, (int)($_POST['days'] ?? 180)));
                $ok = false;
                if (class_exists('NukeSecurity') && method_exists('NukeSecurity', 'trimAudit')) {
                    try { $ok = (bool)NukeSecurity::trimAudit($days); } catch (Throwable $e) { $ok = false; }
                }
                nsec_log('maintenance.audit.trim.request', ['days' => $days, 'ok' => $ok]);
                $messages[] = $ok
                    ? ['type' => 'success', 'text' => "Audit log trimmed to {$days} days."]
                    : ['type' => 'info', 'text' => "Audit trim requested ({$days} days). Your current NukeSecurity build may not expose trimAudit(). No data was modified."];
                break;
        }
    }
}

// Health checks
$health = [];
$health[] = ['label' => 'PHP version', 'value' => PHP_VERSION, 'ok' => version_compare(PHP_VERSION, '8.2.0', '>=')];
$health[] = ['label' => 'PDO', 'value' => extension_loaded('pdo') ? 'enabled' : 'missing', 'ok' => extension_loaded('pdo')];
$health[] = ['label' => 'mbstring', 'value' => extension_loaded('mbstring') ? 'enabled' : 'missing', 'ok' => extension_loaded('mbstring')];
$health[] = ['label' => 'openssl', 'value' => extension_loaded('openssl') ? 'enabled' : 'missing', 'ok' => extension_loaded('openssl')];
$health[] = ['label' => 'Writable data/', 'value' => is_writable($ROOT . '/data') ? 'yes' : 'no', 'ok' => is_writable($ROOT . '/data')];

// Legacy compatibility status
$legacy = [];
$legacy[] = ['label' => 'Install directory lock', 'value' => file_exists($ROOT . '/install/LOCK') ? 'LOCK present' : 'LOCK missing', 'ok' => file_exists($ROOT . '/install/LOCK')];
$legacy[] = ['label' => 'Legacy directory protected', 'value' => file_exists($ROOT . '/legacy/.htaccess') ? '.htaccess present' : 'missing', 'ok' => file_exists($ROOT . '/legacy/.htaccess')];
$legacy[] = ['label' => 'Install directory protected', 'value' => file_exists($ROOT . '/install/.htaccess') ? '.htaccess present' : 'missing', 'ok' => file_exists($ROOT . '/install/.htaccess')];

// Render
if (class_exists('AdminUi')) {
    AdminUi::pageStart('Maintenance', 'Cache, logs, health checks, and legacy lock status.', 'admin_maintenance');

    foreach ($messages as $m) {
        AdminUi::notice($m['type'], $m['text']);
    }

    AdminUi::groupStart('Quick Actions', 'Routine tasks to keep your site fast and safe.');

    echo '<form method="post" class="adminui-form">';
    echo '<input type="hidden" name="csrf" value="' . htmlspecialchars(nukece_csrf_token(), ENT_QUOTES) . '">';
    echo '<div class="adminui-row">';
    echo '<div class="adminui-col">';
    echo '<button class="adminui-btn" name="action" value="clear_cache" type="submit">Clear Cache</button>';
    echo '<div class="adminui-help">Removes cached files. Safe to run anytime.</div>';
    echo '</div>';
    echo '</div>';
    echo '</form>';

    echo '<form method="post" class="adminui-form">';
    echo '<input type="hidden" name="csrf" value="' . htmlspecialchars(nukece_csrf_token(), ENT_QUOTES) . '">';
    echo '<div class="adminui-row">';
    echo '<div class="adminui-col">';
    echo '<label class="adminui-label">Keep rotations</label>';
    echo '<input class="adminui-input" type="number" min="1" max="30" name="keep" value="7">';
    echo '<button class="adminui-btn" style="margin-left:8px" name="action" value="rotate_logs" type="submit">Rotate Logs</button>';
    echo '<div class="adminui-help">Renames current logs to .1, .2, … and starts a fresh file.</div>';
    echo '</div>';
    echo '</div>';
    echo '</form>';

    echo '<form method="post" class="adminui-form">';
    echo '<input type="hidden" name="csrf" value="' . htmlspecialchars(nukece_csrf_token(), ENT_QUOTES) . '">';
    echo '<div class="adminui-row">';
    echo '<div class="adminui-col">';
    echo '<label class="adminui-label">Audit retention (days)</label>';
    echo '<input class="adminui-input" type="number" min="7" max="3650" name="days" value="180">';
    echo '<button class="adminui-btn adminui-btn-secondary" style="margin-left:8px" name="action" value="trim_audit" type="submit">Trim Audit Log</button>';
    echo '<div class="adminui-help">If supported by your NukeSecurity build, this trims audit history safely.</div>';
    echo '</div>';
    echo '</div>';
    echo '</form>';

    AdminUi::groupEnd();

    AdminUi::groupStart('Health Checks', 'Quick visibility into runtime requirements and filesystem permissions.');
    echo '<div class="adminui-table-wrap"><table class="adminui-table">';
    echo '<thead><tr><th>Check</th><th>Status</th><th>Result</th></tr></thead><tbody>';
    foreach ($health as $h) {
        $badge = $h['ok'] ? 'OK' : 'Needs attention';
        $class = $h['ok'] ? 'adminui-badge-ok' : 'adminui-badge-warn';
        echo '<tr>';
        echo '<td>' . htmlspecialchars($h['label']) . '</td>';
        echo '<td>' . htmlspecialchars($h['value']) . '</td>';
        echo '<td><span class="adminui-badge ' . $class . '">' . $badge . '</span></td>';
        echo '</tr>';
    }
    echo '</tbody></table></div>';
    AdminUi::groupEnd();

    AdminUi::groupStart('Legacy Compatibility Status', 'These locks prevent classic PHP-era bypass risks.');
    echo '<div class="adminui-table-wrap"><table class="adminui-table">';
    echo '<thead><tr><th>Item</th><th>Status</th><th>Result</th></tr></thead><tbody>';
    foreach ($legacy as $l) {
        $badge = $l['ok'] ? 'Protected' : 'Action required';
        $class = $l['ok'] ? 'adminui-badge-ok' : 'adminui-badge-warn';
        echo '<tr>';
        echo '<td>' . htmlspecialchars($l['label']) . '</td>';
        echo '<td>' . htmlspecialchars($l['value']) . '</td>';
        echo '<td><span class="adminui-badge ' . $class . '">' . $badge . '</span></td>';
        echo '</tr>';
    }
    echo '</tbody></table></div>';
    echo '<div class="adminui-help">If a lock is missing, rerun install completion or apply the legacy lock patch.</div>';
    AdminUi::groupEnd();

    AdminUi::pageEnd();
} else {
    // Fallback (should not happen in nukeCE builds)
    echo '<h1>Maintenance</h1>';
    echo '<p>AdminUi not found.</p>';
}
