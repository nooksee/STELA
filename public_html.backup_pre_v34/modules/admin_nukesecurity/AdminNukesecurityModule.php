<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\AdminNukesecurity;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Model;
use NukeCE\Core\AdminLayout;
use NukeCE\Core\AppConfig;
use NukeCE\Security\Csrf;
use NukeCE\Security\TorExit;
use NukeCE\Security\GeoIpImporter;
use NukeCE\Security\NukeSecurity;
use NukeCE\Security\NukeSecurityConfig;
use PDO;

/**
 * NukeSecurity Admin (log-only mode).
 * - log viewer
 * - export CSV/JSON
 * - thresholds + webhook/email placeholders
 *
 * This is designed to be "php-nuke-y": simple, one-screen, practical.
 */
final class AdminNukesecurityModule extends Model implements ModuleInterface
{
    public function getName(): string
    {
        return 'admin_nukesecurity';
    }

    public function handle(array $params): void
    {
        NukeSecurity::log('admin_nukesecurity', 'view');

        $root = defined('NUKECE_ROOT') ? NUKECE_ROOT : dirname(__DIR__, 2);
        $logFile = $root . '/data/nukesecurity.log';
        $cfgFile = $root . '/data/nukesecurity.json'; // kept for UI display
        $cfg = NukeSecurityConfig::load($root);


                if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            Csrf::requireValid($_POST['_csrf'] ?? '');
            $action = (string)($_POST['action'] ?? 'save');

            if ($action === 'save_messages_audit') {
                $cfg = NukeSecurityConfig::load($rootDir);
                $mode = (string)($_POST['audit_mode'] ?? 'private');
                if (!in_array($mode, ['private','audit','hybrid'], true)) $mode = 'private';
                if (!isset($cfg['messages']) || !is_array($cfg['messages'])) $cfg['messages'] = [];
                $cfg['messages']['audit_mode'] = $mode;
                NukeSecurityConfig::save($rootDir, $cfg);
                $msg = 'Messages audit mode saved.';
            
            } elseif ($action === 'save_tor') {
                $cfg = NukeSecurityConfig::load($rootDir);
                if (!isset($cfg['tor']) || !is_array($cfg['tor'])) $cfg['tor'] = [];
                $cfg['tor']['enabled'] = isset($_POST['tor_enabled']) ? true : false;
                $mode = (string)($_POST['tor_mode'] ?? 'flag');
                if (!in_array($mode, ['allow','flag','block'], true)) $mode = 'flag';
                $cfg['tor']['mode'] = $mode;
                $cfg['tor']['source_url'] = trim((string)($_POST['tor_source_url'] ?? ''));
                NukeSecurityConfig::save($rootDir, $cfg);
                $msg = 'Tor settings saved.';
            } elseif ($action === 'refresh_tor') {
                $cfg = NukeSecurityConfig::load($rootDir);
                $url = trim((string)($_POST['tor_source_url'] ?? ($cfg['tor']['source_url'] ?? '')));
                if (!isset($cfg['tor']) || !is_array($cfg['tor'])) $cfg['tor'] = [];
                $cfg['tor']['source_url'] = $url;
                // Fetch and refresh
                require_once $rootDir . '/includes/db.php';
                $pdo = nukece_db();
                $res = TorExit::refreshFromUrl($pdo, $url);
                if ($res['ok']) {
                    $cfg['tor']['last_updated'] = gmdate('c');
                    $cfg['tor']['last_count'] = (int)$res['count'];
                    NukeSecurityConfig::save($rootDir, $cfg);
                    $msg = 'Tor feed refreshed: ' . (int)$res['count'] . ' IPs.';
                } else {
                    $msg = 'Tor refresh failed: ' . (string)$res['error'];
                }
} elseif ($action === 'save') {
                $cfg['alerts'] = [
                    'email' => trim((string)($_POST['alert_email'] ?? '')),
                    'webhook' => trim((string)($_POST['alert_webhook'] ?? '')),
                    'threshold' => max(1, (int)($_POST['alert_threshold'] ?? 10)),
                    'geoip' => [
                        'enabled' => isset($_POST['geoip_enabled']),
                        'enforcement' => in_array((string)($_POST['geoip_enforcement'] ?? 'log_only'), ['log_only','enforce'], true) ? (string)($_POST['geoip_enforcement'] ?? 'log_only') : 'log_only',
                        'default_action' => in_array((string)($_POST['geoip_default_action'] ?? 'allow'), ['allow','flag','block'], true) ? (string)($_POST['geoip_default_action'] ?? 'allow') : 'allow',
                    ],
                ];
                NukeSecurityConfig::save($root, $cfg);
                NukeSecurity::log('admin_nukesecurity', 'save_cfg', $cfg['alerts']);
            }
} elseif ($action === 'country_rule_save' || $action === 'country_rule_delete') {
    $pdo = $this->getConnection();
    $this->ensureGeoIpSchema($pdo);
    $iso2 = strtoupper(substr(trim((string)($_POST['iso2'] ?? '')),0,2));
    if ($iso2 === '' || strlen($iso2) !== 2) {
        $msg = 'Invalid ISO2.';
    } else {
        if ($action === 'country_rule_delete') {
            $st = $pdo->prepare("DELETE FROM nsec_country_rules WHERE iso2=?");
            $st->execute([$iso2]);
            NukeSecurity::log('geoip','country_rule_delete',['country'=>$iso2]);
            $msg = 'Rule deleted.';
        } else {
            $act = (string)($_POST['action_rule'] ?? 'allow');
            if (!in_array($act, ['allow','flag','block'], true)) $act = 'allow';
            $enabled = isset($_POST['enabled']) ? 1 : 0;
            $note = trim((string)($_POST['note'] ?? ''));
            $st = $pdo->prepare("REPLACE INTO nsec_country_rules (iso2,action,enabled,note,updated_at) VALUES (?,?,?,?,?)");
            $st->execute([$iso2,$act,$enabled,$note,gmdate('Y-m-d H:i:s')]);
            NukeSecurity::log('geoip','country_rule_save',['country'=>$iso2,'action'=>$act,'enabled'=>$enabled]);
            $msg = 'Rule saved.';
        }
    }

} elseif (strpos($action, 'geoip_') === 0) {
    // Data Feeds: Geo/IP importer (modernized successor to classic NukeSentinel updates)
    $pdo = $this->getConnection();
    $this->ensureGeoIpSchema($pdo);

    if ($action === 'geoip_upload_locations') {
        $msg = $this->handleGeoIpUpload('locations', $root, $pdo);
    } elseif ($action === 'geoip_upload_blocks4') {
        $msg = $this->handleGeoIpUpload('blocks4', $root, $pdo);
    } elseif ($action === 'geoip_upload_blocks6') {
    } elseif ($action === 'geoip_upload_asn4') {
        $msg = $this->handleGeoIpUpload('asn4', $root, $pdo);
    } elseif ($action === 'geoip_upload_asn6') {
        $msg = $this->handleGeoIpUpload('asn6', $root, $pdo);

        $msg = $this->handleGeoIpUpload('blocks6', $root, $pdo);
    } elseif ($action === 'geoip_import_locations') {
        $msg = $this->importGeoIpLocations($root, $pdo);
    } elseif ($action === 'geoip_import_blocks4') {
        $msg = $this->importGeoIpBlocks($root, $pdo, 'blocks4');
    } elseif ($action === 'geoip_import_blocks6') {
    } elseif ($action === 'geoip_import_asn4') {
        $msg = $this->importGeoIpAsn($root, $pdo, 'asn4');
    } elseif ($action === 'geoip_import_asn6') {
        $msg = $this->importGeoIpAsn($root, $pdo, 'asn6');

        $msg = $this->importGeoIpBlocks($root, $pdo, 'blocks6');
    } elseif ($action === 'geoip_reset') {
        $this->geoIpResetState($root);
        $msg = 'Geo/IP import state reset.';
    }
}
        }
        }

        // Exports
        $export = (string)($_GET['export'] ?? '');
        if ($export === 'json') {
            $this->exportJson($logFile);
            return;
        }
        if ($export === 'csv') {
            $this->exportCsv($logFile);
            return;
        }

        $csrf = Csrf::token();
        $lines = is_file($logFile) ? (file($logFile, FILE_IGNORE_NEW_LINES) ?: []) : [];
        $recent = array_slice($lines, -200);

        AdminLayout::header('NukeSecurity');
        echo '<p class="muted">Quick: <a href="admin.php?op=admin_nukesecurity&view=datafeeds">Data Feeds</a> | <a href="admin.php?op=admin_nukesecurity&view=geoip_import">GeoIP Import</a></p>';

        if ($view === 'geoip_import') {
            self::renderGeoIpImport($pdo, $cfg);
            AdminLayout::footer();
            return;
        }

        echo '<p class="muted">Quick: <a href="admin.php?op=admin_nukesecurity&view=datafeeds">Data Feeds</a> | <a href="admin.php?op=admin_nukesecurity&view=geoip_import">GeoIP Import</a></p>';

        echo "<div class='wrap'><div class='card'>";
        echo "<div style='display:flex;justify-content:space-between;gap:12px;align-items:center'>";
        echo "<div><h1 class='h1'><?= AdminLayout::icon('security','nukesecurity') ?>NukeSecurity</h1><div class='muted'><small>Log-only mode. (Attribution preserved in CREDITS.)</small></div></div>";
        echo "<div><a class='btn2' href='/index.php?module=admin_nukesecurity&export=json'>Export JSON</a> ";
        echo "<a class='btn2' href='/index.php?module=admin_nukesecurity&export=csv'>Export CSV</a></div>";
        echo "</div>";

        // Dashboard widget
        $count = count($recent);
        echo "<div style='margin-top:12px' class='grid'>";
        echo "<div class='card' style='padding:12px'><b>Recent events</b><div class='muted'><small>Last 200 lines</small></div><div style='font-size:28px;margin-top:6px'>{$count}</div></div>";
        echo "<div class='card' style='padding:12px'><b>Alert threshold</b><div class='muted'><small>Trigger when events exceed threshold</small></div><div style='font-size:28px;margin-top:6px'>" . (int)($cfg['alerts']['threshold'] ?? 10) . "</div></div>";
        echo "<div class='card' style='padding:12px'><b>Status</b><div class='muted'><small>Enforcement</small></div><div style='font-size:28px;margin-top:6px'>LOG</div></div>";
        echo "</div>";

        echo "<h2 style='margin:14px 0 8px 0'>Log Viewer</h2>";
        echo "<div style='border:1px solid #e2e2e2;border-radius:14px;background:#0b0b0b;color:#eaeaea;padding:10px;max-height:420px;overflow:auto;font-family:ui-monospace,Menlo,monospace;font-size:12px'>";
        if (!$recent) echo "<div class='muted'><small>No log yet.</small></div>";
        foreach ($recent as $ln) {
            echo htmlspecialchars($ln, ENT_QUOTES, 'UTF-8') . "<br>";
        }
        echo "</div>";

        echo "<h2 style='margin:14px 0 8px 0'>Alerts</h2>";
        
// Compat status panel (legacy imports)
$compat = is_array($cfg['compat'] ?? null) ? $cfg['compat'] : [];
$migrated = !empty($compat['migrated']);
$migratedAt = (string)($compat['migrated_at'] ?? '');
$from = $compat['migrated_from'] ?? [];
if (!is_array($from)) $from = [];

$legacyImport = $compat['legacy_import'] ?? [];
if (!is_array($legacyImport)) $legacyImport = [];

$map = $compat['legacy_key_map'] ?? [];
if (!is_array($map)) $map = [];

echo "<div class='card' style='margin-top:12px;padding:12px'>";
echo "<div style='display:flex;align-items:center;justify-content:space-between;gap:10px;flex-wrap:wrap'>";
echo "<div><b>Compat status</b><div class='muted'><small>Legacy NukeSentinel / nsnst imports into NukeSecurity</small></div></div>";
echo $migrated ? "<span class='badge ok'>migrated</span>" : "<span class='badge'>no legacy detected</span>";
echo "</div>";

echo "<div style='margin-top:10px' class='grid'>";
echo "<div class='card' style='padding:10px'><b>Sources</b><div class='muted'><small>" . ($from ? htmlspecialchars(implode(', ', $from), ENT_QUOTES, 'UTF-8') : "None") . "</small></div>";
if ($migratedAt) echo "<div class='muted'><small>At: " . htmlspecialchars($migratedAt, ENT_QUOTES, 'UTF-8') . "</small></div>";
echo "</div>";

echo "<div class='card' style='padding:10px'><b>Mapped keys</b><div class='muted'><small>" . count($map) . " known mappings</small></div>";
echo "<div style='margin-top:6px;max-height:110px;overflow:auto;font-family:ui-monospace, SFMono-Regular, Menlo, monospace;font-size:12px;white-space:pre-wrap'>";
foreach ($map as $k => $v) {
    if (!is_string($k) || !is_string($v)) continue;
    echo htmlspecialchars($k . " -> " . $v, ENT_QUOTES, 'UTF-8') . "\n";
}
echo "</div></div>";

echo "<div class='card' style='padding:10px'><b>Imported legacy keys</b><div class='muted'><small>" . count($legacyImport) . " captured</small></div>";
echo "<div style='margin-top:6px;max-height:110px;overflow:auto;font-family:ui-monospace, SFMono-Regular, Menlo, monospace;font-size:12px;white-space:pre-wrap'>";
$shown = 0;
foreach ($legacyImport as $k => $v) {
    if (!is_string($k)) continue;
    $shown++;
    if ($shown > 50) { echo "... (truncated)\n"; break; }
    $val = is_scalar($v) ? (string)$v : json_encode($v);
    echo htmlspecialchars($k . " = " . $val, ENT_QUOTES, 'UTF-8') . "\n";
}
echo "</div></div>";
echo "</div>"; // grid

echo "<div class='muted' style='margin-top:10px'><small>Tip: run <code>php install/migrate_nukesecurity_compat.php</code> to force a one-shot migration write, then refresh this page.</small></div>";
echo "</div>";
echo "<form method='post' action='/index.php?module=admin_nukesecurity' class='grid' style='grid-template-columns:repeat(3,minmax(0,1fr));gap:12px'>";
        echo "<input type='hidden' name='_csrf' value='{$csrf}'><input type='hidden' name='action' value='save'>";
        echo "<div><label>Email</label><input style='width:100%' name='alert_email' value='" . htmlspecialchars((string)($cfg['alerts']['email'] ?? ''), ENT_QUOTES,'UTF-8') . "' placeholder='you@example.com'></div>";
        echo "<div><label>Webhook</label><input style='width:100%' name='alert_webhook' value='" . htmlspecialchars((string)($cfg['alerts']['webhook'] ?? ''), ENT_QUOTES,'UTF-8') . "' placeholder='https://...'></div>";
        echo "<div><label>Threshold</label><input style='width:100%' type='number' min='1' name='alert_threshold' value='" . (int)($cfg['alerts']['threshold'] ?? 10) . "'></div>";
        echo "<div style='grid-column:1/-1'><button class='btn' type='submit'>Save</button></div>";
        echo "</form>";

        echo "</div></div>";
        
// Messages audit mode (Option C)
$cfg = NukeSecurityConfig::load($rootDir);
$mode = (string)($cfg['messages']['audit_mode'] ?? 'private');
$mPrivate = $mode === 'private' ? "selected" : "";
$mAudit = $mode === 'audit' ? "selected" : "";
$mHybrid = $mode === 'hybrid' ? "selected" : "";

echo "<hr style='margin:18px 0;border:none;border-top:1px solid #e6e6e6'>";
echo "<div class='card' style='padding:14px;display:grid;gap:10px'>";
echo "<b>Messages Audit</b>";
echo "<div class='muted'>Default is private. Audit/hybrid requires a reason and is logged.</div>";
echo "<form method='post' action='/index.php?module=admin_nukesecurity' style='display:flex;gap:10px;align-items:center;flex-wrap:wrap'>";
echo "<input type='hidden' name='_csrf' value='{$csrf}'>";
echo "<input type='hidden' name='action' value='save_messages_audit'>";
echo "<label>Mode <select name='audit_mode'>";
echo "<option value='private' {$mPrivate}>private</option>";
echo "<option value='hybrid' {$mHybrid}>hybrid</option>";
echo "<option value='audit' {$mAudit}>audit</option>";
echo "</select></label>";
echo "<button class='btn' type='submit'>Save</button>";
echo "</form>";
echo "</div>";

        
// Data Feeds (Geo/IP)
$this->renderDataFeedsPanel($csrf, $root);



        
        // --- Tor Exit Nodes ---
        $cfgTor = (NukeSecurityConfig::load($rootDir)['tor'] ?? []);
        $torEnabled = (bool)($cfgTor['enabled'] ?? false);
        $torMode = (string)($cfgTor['mode'] ?? 'flag');
        $torUrl = (string)($cfgTor['source_url'] ?? 'https://check.torproject.org/torbulkexitlist');
        $torLast = (string)($cfgTor['last_updated'] ?? '');
        $torCount = (int)($cfgTor['last_count'] ?? 0);

        echo '<h2>Tor Exit Nodes</h2>
<?php
            $torStats = \NukeCE\Security\TorExit::getStats($pdo);
            $torLast = $torStats['last_ts'] ?? '';
            $torAgeDays = (int)($cfg['tor_max_age_days'] ?? 7);
            $isStale = false;
            if ($torLast) {
                $ts = strtotime($torLast);
                if ($ts) {
                    $isStale = (time() - $ts) > ($torAgeDays * 86400);
                }
            }
?>
<p class="muted">Current list: <strong><?php echo (int)($torStats['count'] ?? 0); ?></strong> nodes. Last refresh: <strong><?php echo htmlspecialchars($torLast ?: 'never'); ?></strong>.</p>
<?php if ($isStale): ?>
<div class="warning">Tor feed is older than <?php echo (int)$torAgeDays; ?> days. Refresh recommended.</div>
<?php endif; ?>';
        echo '<p class="muted">Optional enforcement against known Tor exit IPs. Fail-open if the feed is unavailable.</p>';
        echo '<form method="post" action="admin.php?op=admin_nukesecurity">';
        echo '<input type="hidden" name="_csrf" value="' . htmlspecialchars(Csrf::token(), ENT_QUOTES) . '">';
        echo '<input type="hidden" name="action" value="save_tor">';
        echo '<label><input type="checkbox" name="tor_enabled" ' . ($torEnabled ? 'checked' : '') . '> Enable Tor checks</label><br>';
        echo '<label>Mode: <select name="tor_mode">';
        foreach (['allow'=>'Allow','flag'=>'Flag (log only)','block'=>'Block (403)'] as $k=>$v) {
            $sel = ($torMode === $k) ? 'selected' : '';
            echo '<option value="' . $k . '" ' . $sel . '>' . $v . '</option>';
        }
        echo '</select></label><br>';
        echo '<label>Feed URL: <input style="width:60%" type="text" name="tor_source_url" value="' . htmlspecialchars($torUrl, ENT_QUOTES) . '"></label><br>';
            <label>Max feed age (days) <input type="number" name="tor_max_age_days" min="1" max="60" value="<?php echo (int)($cfg['tor_max_age_days'] ?? 7); ?>"></label>
        echo '<button type="submit">Save Tor Settings</button>';
        echo '</form>';

        echo '<form method="post" action="admin.php?op=admin_nukesecurity" style="margin-top:10px">';
        echo '<input type="hidden" name="_csrf" value="' . htmlspecialchars(Csrf::token(), ENT_QUOTES) . '">';
        echo '<input type="hidden" name="action" value="refresh_tor">';
        echo '<input type="hidden" name="tor_source_url" value="' . htmlspecialchars($torUrl, ENT_QUOTES) . '">';
        echo '<button type="submit">Refresh Tor Feed Now</button>';
        if ($torLast !== '') {
            echo '<span class="muted"> Last: ' . htmlspecialchars($torLast) . ' (' . (int)$torCount . ' IPs)</span>';
        }
        echo '</form>';

// --- Paths & permissions (v17) ---
        $uploadsDir = AppConfig::getString('uploads_dir', $rootDir . '/uploads');
        $cacheDir   = AppConfig::getString('cache_dir',   $rootDir . '/cache');
        $tmpDir     = AppConfig::getString('tmp_dir',     $rootDir . '/tmp');
        $logsDir    = AppConfig::getString('logs_dir',    $rootDir . '/logs');

        $paths = [
            'uploads_dir' => $uploadsDir,
            'cache_dir'   => $cacheDir,
            'tmp_dir'     => $tmpDir,
            'logs_dir'    => $logsDir,
            'data_dir'    => AppConfig::getString('data_dir', $rootDir . '/data'),
        ];

        echo "<h2>Paths & permissions</h2>";
        echo "<p>Quick health check for filesystem paths used by nukeCE. These should exist and be writable where appropriate. In Apache deployments, .htaccess hardening is expected to deny direct HTTP access to sensitive folders.</p>";
        echo "<table class='nukece-table' style='width:100%'>";
        echo "<tr><th>Key</th><th>Path</th><th>Exists</th><th>Writable</th></tr>";
        foreach ($paths as $k => $p) {
            $ex = is_dir($p);
            $wr = $ex ? is_writable($p) : false;
            echo "<tr>";
            echo "<td>" . htmlspecialchars($k) . "</td>";
            echo "<td><code>" . htmlspecialchars($p) . "</code></td>";
            echo "<td>" . ($ex ? "YES" : "NO") . "</td>";
            echo "<td>" . ($wr ? "YES" : "NO") . "</td>";
            echo "</tr>";
        }
        echo "</table>";

        $allowInstall = $rootDir . "/config/ALLOW_INSTALL";
        echo "<h3>Installer lock</h3>";
        echo "<p>Installer is locked unless <code>config/ALLOW_INSTALL</code> exists.</p>";
        echo "<p>ALLOW_INSTALL: <b>" . (is_file($allowInstall) ? "PRESENT" : "ABSENT") . "</b></p>";


        

        AdminLayout::footer();
    }

    private function exportJson(string $logFile): void
    {
        header('Content-Type: application/json; charset=utf-8');
        $lines = is_file($logFile) ? (file($logFile, FILE_IGNORE_NEW_LINES) ?: []) : [];
        echo json_encode(['lines' => $lines], JSON_UNESCAPED_SLASHES|JSON_PRETTY_PRINT);
    }

    private function exportCsv(string $logFile): void
    {
        header('Content-Type: text/csv; charset=utf-8');
        header('Content-Disposition: attachment; filename="nukesecurity.csv"');
        $lines = is_file($logFile) ? (file($logFile, FILE_IGNORE_NEW_LINES) ?: []) : [];
        $out = fopen('php://output', 'w');
        fputcsv($out, ['line']);
        foreach ($lines as $ln) fputcsv($out, [$ln]);
        fclose($out);
    }


private function feedsDir(string $root): string
{
    $dir = $root . '/data/feeds';
    if (!is_dir($dir)) @mkdir($dir, 0775, true);
    return $dir;
}

private function geoIpStatePath(string $root): string
{
    return $this->feedsDir($root) . '/geoip_state.json';
}

private function geoIpLoadState(string $root): array
{
    $p = $this->geoIpStatePath($root);
    if (!is_file($p)) return [
        'locations' => ['offset'=>0,'done'=>false],
        'blocks4' => ['offset'=>0,'done'=>false],
        'blocks6' => ['offset'=>0,'done'=>false],
        'asn4' => ['offset'=>0,'done'=>false],
        'asn6' => ['offset'=>0,'done'=>false],
    ];
    $j = json_decode((string)file_get_contents($p), true);
    return is_array($j) ? $j : [
        'locations' => ['offset'=>0,'done'=>false],
        'blocks4' => ['offset'=>0,'done'=>false],
        'blocks6' => ['offset'=>0,'done'=>false],
    ];
}

private function geoIpSaveState(string $root, array $state): void
{
    file_put_contents($this->geoIpStatePath($root), json_encode($state, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES));
}

private function geoIpResetState(string $root): void
{
    @unlink($this->geoIpStatePath($root));
}

private function ensureGeoIpSchema(PDO $pdo): void
{
    // GeoLite2 Locations (Countries)
    $pdo->exec("CREATE TABLE IF NOT EXISTS nsec_geoip_locations (
        geoname_id INT UNSIGNED NOT NULL PRIMARY KEY,
        country_iso_code CHAR(2) NULL,
        country_name VARCHAR(128) NULL,
        updated_at DATETIME NOT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Country block ranges (fast lookup)
    $pdo->exec("CREATE TABLE IF NOT EXISTS nsec_geoip_country_v4 (
        start_int INT UNSIGNED NOT NULL,
        end_int INT UNSIGNED NOT NULL,
        iso2 CHAR(2) NULL,
        network VARCHAR(64) NOT NULL,
        updated_at DATETIME NOT NULL,
        PRIMARY KEY (start_int, end_int),
        KEY idx_iso2 (iso2),
        KEY idx_range (start_int, end_int)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $pdo->exec("CREATE TABLE IF NOT EXISTS nsec_geoip_country_v6 (
        start_bin VARBINARY(16) NOT NULL,
        end_bin VARBINARY(16) NOT NULL,
        iso2 CHAR(2) NULL,
        network VARCHAR(64) NOT NULL,
        updated_at DATETIME NOT NULL,
        PRIMARY KEY (start_bin, end_bin),
        KEY idx_iso2 (iso2)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // ASN ranges (fast lookup)
    $pdo->exec("CREATE TABLE IF NOT EXISTS nsec_geoip_asn_v4 (
        start_int INT UNSIGNED NOT NULL,
        end_int INT UNSIGNED NOT NULL,
        asn INT UNSIGNED NULL,
        org VARCHAR(255) NULL,
        network VARCHAR(64) NOT NULL,
        updated_at DATETIME NOT NULL,
        PRIMARY KEY (start_int, end_int),
        KEY idx_asn (asn),
        KEY idx_range (start_int, end_int)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    $pdo->exec("CREATE TABLE IF NOT EXISTS nsec_geoip_asn_v6 (
        start_bin VARBINARY(16) NOT NULL,
        end_bin VARBINARY(16) NOT NULL,
        asn INT UNSIGNED NULL,
        org VARCHAR(255) NULL,
        network VARCHAR(64) NOT NULL,
        updated_at DATETIME NOT NULL,
        PRIMARY KEY (start_bin, end_bin),
        KEY idx_asn (asn)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Country rules
    $pdo->exec("CREATE TABLE IF NOT EXISTS nsec_country_rules (
        iso2 CHAR(2) NOT NULL,
        action ENUM('allow','flag','block') NOT NULL DEFAULT 'allow',
        enabled TINYINT(1) NOT NULL DEFAULT 1,
        note VARCHAR(255) NULL,
        updated_at DATETIME NOT NULL,
        PRIMARY KEY (iso2)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Lightweight import state / metadata (optional; we also keep a JSON state file)
    $pdo->exec("CREATE TABLE IF NOT EXISTS nsec_geoip_import_runs (
        id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
        kind VARCHAR(32) NOT NULL,
        source_file VARCHAR(255) NOT NULL,
        imported_rows INT UNSIGNED NOT NULL DEFAULT 0,
        status ENUM('staged','running','done','error') NOT NULL DEFAULT 'staged',
        note VARCHAR(255) NULL,
        updated_at DATETIME NOT NULL,
        KEY idx_kind (kind)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
}


private function handleGeoIpUpload(string $kind, string $root, PDO $pdo): string
{
    $field = 'geoip_file';
    if (empty($_FILES[$field]['tmp_name'])) return 'No file uploaded.';
    $tmp = (string)$_FILES[$field]['tmp_name'];
    $name = (string)$_FILES[$field]['name'];
    $safe = preg_replace('/[^a-zA-Z0-9._-]/', '_', $name);

    $dest = $this->feedsDir($root) . "/geoip_{$kind}_" . time() . "_" . $safe;
    if (!@move_uploaded_file($tmp, $dest)) return 'Upload failed.';

    // Remember latest path in state
    $state = $this->geoIpLoadState($root);
    $state[$kind]['file'] = $dest;
    $state[$kind]['offset'] = 0;
    $state[$kind]['done'] = false;
    $this->geoIpSaveState($root, $state);

    NukeSecurity::log('datafeeds', 'geoip_upload', ['kind'=>$kind,'file'=>basename($dest)]);
    return "Uploaded: " . htmlspecialchars(basename($dest), ENT_QUOTES, 'UTF-8') . ". Ready to import.";
}

private function importGeoIpLocations(string $root, PDO $pdo): string
{
    $state = $this->geoIpLoadState($root);
    $file = (string)($state['locations']['file'] ?? '');
    if ($file === '' || !is_file($file)) return 'Upload GeoLite2 Locations CSV first.';
    $offset = (int)($state['locations']['offset'] ?? 0);

    $batch = 3000;
    $fh = fopen($file, 'rb');
    if (!$fh) return 'Could not open file.';
    $header = fgetcsv($fh);
    if (!is_array($header)) { fclose($fh); return 'Invalid CSV.'; }
    $map = array_flip($header);
    if (!isset($map['geoname_id'])) { fclose($fh); return 'CSV missing geoname_id column.'; }

    // Skip rows already imported
    $i = 0;
    while ($i < $offset && ($row = fgetcsv($fh)) !== false) { $i++; }

    $now = gmdate('Y-m-d H:i:s');
    $st = $pdo->prepare("REPLACE INTO nsec_geoip_locations (geoname_id,country_iso_code,country_name,updated_at) VALUES (?,?,?,?)");

    $imported = 0;
    while ($imported < $batch && ($row = fgetcsv($fh)) !== false) {
        $i++;
        $gid = (int)($row[$map['geoname_id']] ?? 0);
        if ($gid <= 0) continue;
        $iso = isset($map['country_iso_code']) ? trim((string)($row[$map['country_iso_code']] ?? '')) : null;
        $name = isset($map['country_name']) ? trim((string)($row[$map['country_name']] ?? '')) : null;
        $st->execute([$gid, $iso !== '' ? $iso : null, $name !== '' ? $name : null, $now]);
        $imported++;
    }
    $done = feof($fh);
    fclose($fh);

    $state['locations']['offset'] = $i;
    $state['locations']['done'] = $done;
    $this->geoIpSaveState($root, $state);

    NukeSecurity::log('datafeeds', 'geoip_import_locations', ['imported'=>$imported,'offset'=>$i,'done'=>$done]);
    return $done ? "Locations import complete. Rows processed: $i." : "Imported $imported location rows. Continue to process more.";
}

private function importGeoIpBlocks(string $root, PDO $pdo, string $kind): string
{
    $state = $this->geoIpLoadState($root);
    $file = (string)($state[$kind]['file'] ?? '');
    if ($file === '' || !is_file($file)) return 'Upload GeoLite2 Blocks CSV first.';
    $offset = (int)($state[$kind]['offset'] ?? 0);

    $ipVer = ($kind === 'blocks6') ? 6 : 4;
    $batch = 4000;

    $fh = fopen($file, 'rb');
    if (!$fh) return 'Could not open file.';
    $header = fgetcsv($fh);
    if (!is_array($header)) { fclose($fh); return 'Invalid CSV.'; }
    $map = array_flip($header);
    if (!isset($map['network'])) { fclose($fh); return 'CSV missing network column.'; }

    // Determine which geoname id to use (country_geoname_id preferred)
    $gidKey = null;
    foreach (['country_geoname_id','registered_country_geoname_id','represented_country_geoname_id','geoname_id'] as $k) {
        if (isset($map[$k])) { $gidKey = $k; break; }
    }
    if ($gidKey === null) { fclose($fh); return 'CSV missing country_geoname_id columns.'; }

    $i = 0;
    while ($i < $offset && ($row = fgetcsv($fh)) !== false) { $i++; }

    $now = gmdate('Y-m-d H:i:s');
    $lookup = $pdo->prepare("SELECT country_iso_code FROM nsec_geoip_locations WHERE geoname_id=? LIMIT 1");
    $ins = ($ipVer === 6)
        ? $pdo->prepare("INSERT INTO nsec_geoip_country_v6 (start_bin,end_bin,iso2,network,updated_at) VALUES (?,?,?,?,?)")
        : $pdo->prepare("INSERT INTO nsec_geoip_country_v4 (start_int,end_int,iso2,network,updated_at) VALUES (?,?,?,?,?)");

    $imported = 0;
    while ($imported < $batch && ($row = fgetcsv($fh)) !== false) {
        $i++;
        $net = trim((string)($row[$map['network']] ?? ''));
        if ($net === '') continue;
        $gid = (int)($row[$map[$gidKey]] ?? 0);
        $iso = null;
        if ($gid > 0) {
            $lookup->execute([$gid]);
            $iso = $lookup->fetchColumn();
            if ($iso !== false) $iso = (string)$iso;
        }
        $range = ($ipVer === 6) ? $this->cidrToRangeV6($net) : $this->cidrToRangeV4($net);
        if ($range !== null) {
            if ($ipVer === 6) {
                [$startBin, $endBin] = $range;
                $ins->execute([$startBin, $endBin, $iso, $net, $now]);
            } else {
                [$startInt, $endInt] = $range;
                $ins->execute([$startInt, $endInt, $iso, $net, $now]);
            }
        }
        $imported++;
    }
    $done = feof($fh);
    fclose($fh);

    $state[$kind]['offset'] = $i;
    $state[$kind]['done'] = $done;
    $this->geoIpSaveState($root, $state);

    NukeSecurity::log('datafeeds', 'geoip_import_blocks', ['kind'=>$kind,'imported'=>$imported,'offset'=>$i,'done'=>$done]);
    return $done ? strtoupper($kind) . " import complete. Rows processed: $i." : "Imported $imported $kind rows. Continue to process more.";
}

private function importGeoIpAsn(string $root, PDO $pdo, string $kind): string
{
    $state = $this->geoIpLoadState($root);
    $file = (string)($state[$kind]['file'] ?? '');
    if ($file === '' || !is_file($file)) return 'Upload GeoLite2 ASN Blocks CSV first.';
    $offset = (int)($state[$kind]['offset'] ?? 0);

    $ipVer = ($kind === 'asn6') ? 6 : 4;
    $batch = 4000;

    $fh = fopen($file, 'rb');
    if (!$fh) return 'Could not open file.';
    $header = fgetcsv($fh);
    if (!is_array($header)) { fclose($fh); return 'Invalid CSV.'; }
    $map = array_flip($header);
    if (!isset($map['network'])) { fclose($fh); return 'CSV missing network column.'; }
    if (!isset($map['autonomous_system_number'])) { fclose($fh); return 'CSV missing autonomous_system_number column.'; }
    if (!isset($map['autonomous_system_organization'])) { fclose($fh); return 'CSV missing autonomous_system_organization column.'; }

    $i = 0;
    while ($i < $offset && ($row = fgetcsv($fh)) !== false) { $i++; }

    $now = gmdate('Y-m-d H:i:s');
    $ins = ($ipVer === 6)
        ? $pdo->prepare("INSERT INTO nsec_geoip_asn_v6 (start_bin,end_bin,asn,org,network,updated_at) VALUES (?,?,?,?,?,?)")
        : $pdo->prepare("INSERT INTO nsec_geoip_asn_v4 (start_int,end_int,asn,org,network,updated_at) VALUES (?,?,?,?,?,?)");

    $imported = 0;
    while ($imported < $batch && ($row = fgetcsv($fh)) !== false) {
        $i++;
        $net = trim((string)($row[$map['network']] ?? ''));
        if ($net === '') continue;

        $asn = (int)($row[$map['autonomous_system_number']] ?? 0);
        $org = trim((string)($row[$map['autonomous_system_organization']] ?? ''));

        $range = ($ipVer === 6) ? $this->cidrToRangeV6($net) : $this->cidrToRangeV4($net);
        if ($range === null) continue;

        if ($ipVer === 6) {
            [$startBin, $endBin] = $range;
            $ins->execute([$startBin, $endBin, $asn > 0 ? $asn : null, ($org !== '' ? $org : null), $net, $now]);
        } else {
            [$startInt, $endInt] = $range;
            $ins->execute([$startInt, $endInt, $asn > 0 ? $asn : null, ($org !== '' ? $org : null), $net, $now]);
        }

        $imported++;
    }
    $done = feof($fh);
    fclose($fh);

    $state[$kind]['offset'] = $i;
    $state[$kind]['done'] = $done;
    $this->geoIpSaveState($root, $state);

    NukeSecurity::log('datafeeds', 'geoip_import_asn', ['kind'=>$kind,'imported'=>$imported,'offset'=>$i,'done'=>$done]);
    return $done ? "ASN import complete ({$imported} rows this pass)." : "Imported {$imported} ASN rows... continue.";
}

private function cidrToRangeV4(string $cidr): ?array
{
    if (strpos($cidr, '/') === false) return null;
    [$ip, $mask] = explode('/', $cidr, 2);
    $mask = (int)$mask;
    if ($mask < 0 || $mask > 32) return null;
    $ipl = ip2long($ip);
    if ($ipl === false) return null;
    if ($ipl < 0) $ipl += 4294967296;

    $hostBits = 32 - $mask;
    $start = ($ipl >> $hostBits) << $hostBits;
    $end = $start + (int)(pow(2, $hostBits) - 1);

    return [(int)$start, (int)$end];
}

private function cidrToRangeV6(string $cidr): ?array
{
    if (strpos($cidr, '/') === false) return null;
    [$ip, $mask] = explode('/', $cidr, 2);
    $mask = (int)$mask;
    if ($mask < 0 || $mask > 128) return null;

    $bin = inet_pton($ip);
    if ($bin === false || strlen($bin) !== 16) return null;

    $bytes = array_values(unpack('C*', $bin)); // 1..16
    $fullBytes = intdiv($mask, 8);
    $remBits = $mask % 8;

    // start
    $start = $bytes;
    // zero bits after prefix
    for ($i = $fullBytes + 1; $i <= 16; $i++) $start[$i-1] = 0;
    if ($remBits !== 0 && $fullBytes < 16) {
        $keep = (0xFF << (8 - $remBits)) & 0xFF;
        $start[$fullBytes] = $start[$fullBytes] & $keep;
    }

    // end
    $end = $bytes;
    for ($i = $fullBytes + 1; $i <= 16; $i++) $end[$i-1] = 255;
    if ($remBits !== 0 && $fullBytes < 16) {
        $keep = (0xFF << (8 - $remBits)) & 0xFF;
        $end[$fullBytes] = ($end[$fullBytes] & $keep) | (~$keep & 0xFF);
    }

    $startBin = pack('C*', ...$start);
    $endBin = pack('C*', ...$end);
    return [$startBin, $endBin];
}


private function renderDataFeedsPanel(string $csrf, string $root): void
{
    $state = $this->geoIpLoadState($root);

    AdminLayout::cardStart('Data Feeds: Geo/IP (Country)', 'Modern successor to classic NukeSentinel country/IP updates. Admin-controlled, deterministic, audited.');
    echo "<p class='muted'>Workflow: upload <code>GeoLite2-Country-Locations-*.csv</code>, import it, then upload/import Blocks IPv4 and optionally IPv6.</p>";

    $this->renderGeoIpStatus($state);

    echo "<hr>";

    echo "<h3>1) Upload Locations CSV</h3>";
    echo "<form method='post' enctype='multipart/form-data'>";
    echo "<input type='hidden' name='_csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
    echo "<input type='hidden' name='action' value='geoip_upload_locations'>";
    echo "<input type='file' name='geoip_file' accept='.csv,text/csv'>";
    echo " <button class='nukece-btn nukece-btn-primary' type='submit'>Upload</button>";
    echo "</form>";
    echo "<form method='post' style='margin-top:6px'>";
    echo "<input type='hidden' name='_csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
    echo "<input type='hidden' name='action' value='geoip_import_locations'>";
    echo "<button class='nukece-btn' type='submit'>Import/Continue Locations</button>";
    echo "</form>";

    echo "<hr><h3>2) Upload Blocks IPv4 CSV</h3>";
    echo "<form method='post' enctype='multipart/form-data'>";
    echo "<input type='hidden' name='_csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
    echo "<input type='hidden' name='action' value='geoip_upload_blocks4'>";
    echo "<input type='file' name='geoip_file' accept='.csv,text/csv'>";
    echo " <button class='nukece-btn nukece-btn-primary' type='submit'>Upload</button>";
    echo "</form>";
    echo "<form method='post' style='margin-top:6px'>";
    echo "<input type='hidden' name='_csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
    echo "<input type='hidden' name='action' value='geoip_import_blocks4'>";
    echo "<button class='nukece-btn' type='submit'>Import/Continue Blocks IPv4</button>";
    echo "</form>";

    echo "<hr><h3>3) Upload Blocks IPv6 CSV (optional)</h3>";
    echo "<form method='post' enctype='multipart/form-data'>";
    echo "<input type='hidden' name='_csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
    echo "<input type='hidden' name='action' value='geoip_upload_blocks6'>";
    echo "<input type='file' name='geoip_file' accept='.csv,text/csv'>";
    echo " <button class='nukece-btn nukece-btn-primary' type='submit'>Upload</button>";
    echo "</form>";
    echo "<form method='post' style='margin-top:6px'>";
    echo "<input type='hidden' name='_csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
    echo "<input type='hidden' name='action' value='geoip_import_blocks6'>";
    echo "<button class='nukece-btn' type='submit'>Import/Continue Blocks IPv6</button>";
    echo "</form>";


    echo "<hr><h3>4) Upload ASN Blocks IPv4 CSV (optional, recommended)</h3>";
    echo "<form method='post' enctype='multipart/form-data'>";
    echo "<input type='hidden' name='_csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
    echo "<input type='hidden' name='action' value='geoip_upload_asn4'>";
    echo "<input type='file' name='geoip_file' accept='.csv,text/csv'>";
    echo " <button class='nukece-btn nukece-btn-primary' type='submit'>Upload</button>";
    echo "</form>";
    echo "<form method='post' style='margin-top:6px'>";
    echo "<input type='hidden' name='_csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
    echo "<input type='hidden' name='action' value='geoip_import_asn4'>";
    echo "<button class='nukece-btn' type='submit'>Import/Continue ASN IPv4</button>";
    echo "</form>";

    echo "<hr><h3>5) Upload ASN Blocks IPv6 CSV (optional)</h3>";
    echo "<form method='post' enctype='multipart/form-data'>";
    echo "<input type='hidden' name='_csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
    echo "<input type='hidden' name='action' value='geoip_upload_asn6'>";
    echo "<input type='file' name='geoip_file' accept='.csv,text/csv'>";
    echo " <button class='nukece-btn nukece-btn-primary' type='submit'>Upload</button>";
    echo "</form>";
    echo "<form method='post' style='margin-top:6px'>";
    echo "<input type='hidden' name='_csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
    echo "<input type='hidden' name='action' value='geoip_import_asn6'>";
    echo "<button class='nukece-btn' type='submit'>Import/Continue ASN IPv6</button>";
    echo "</form>";

    echo "<hr>";
    echo "<form method='post'>";
    echo "<input type='hidden' name='_csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
    echo "<input type='hidden' name='action' value='geoip_reset'>";
    echo "<button class='nukece-btn' type='submit'>Reset Import State</button>";
    echo "</form>";

    AdminLayout::cardEnd();
}

private function renderGeoIpStatus(array $state): void
{
    echo "<h3>Status</h3>";
    echo "<table>";
    echo "<tr><th>Feed</th><th>File</th><th>Offset</th><th>Done</th></tr>";
    foreach (['locations'=>'Locations','blocks4'=>'Blocks IPv4','blocks6'=>'Blocks IPv6','asn4'=>'ASN IPv4','asn6'=>'ASN IPv6'] as $k=>$label) {
        $file = isset($state[$k]['file']) ? basename((string)$state[$k]['file']) : '';
        $off = (int)($state[$k]['offset'] ?? 0);
        $done = !empty($state[$k]['done']) ? 'yes' : 'no';
        echo "<tr><td>".htmlspecialchars($label,ENT_QUOTES,'UTF-8')."</td><td><small>".htmlspecialchars($file,ENT_QUOTES,'UTF-8')."</small></td><td>$off</td><td>$done</td></tr>";
    }
    echo "</table>";
}



private function cidrToIpv4Range(string $cidr): ?array
{
    $cidr = trim($cidr);
    if ($cidr === '' || strpos($cidr, '/') === false) return null;
    [$ip, $mask] = explode('/', $cidr, 2);
    $mask = (int)$mask;
    if ($mask < 0 || $mask > 32) return null;
    if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4) === false) return null;
    $ipLong = ip2long($ip);
    if ($ipLong === false) return null;
    if ($ipLong < 0) $ipLong += 4294967296;

    $hostBits = 32 - $mask;
    $start = ($ipLong >> $hostBits) << $hostBits;
    $end = $start + (2 ** $hostBits) - 1;
    return [(int)$start, (int)$end];
}
}