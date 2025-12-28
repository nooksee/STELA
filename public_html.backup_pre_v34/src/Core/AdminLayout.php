<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Core;

final class AdminLayout
{
    public static function header(string $title = 'Admin'): void
    {
        echo "<!doctype html><html lang='en'><head><meta charset='utf-8'>";
        echo "<meta name='viewport' content='width=device-width, initial-scale=1'>";
        echo "<title>" . htmlspecialchars($title, ENT_QUOTES, 'UTF-8') . "</title>";
        echo "<style>
            body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif;margin:0;background:#f6f6f6;color:#111}
            .top{display:flex;justify-content:space-between;align-items:center;padding:14px 18px;background:#111;color:#fff}
            .top a{color:#fff;text-decoration:none;opacity:.9}
            .wrap{max-width:1100px;margin:18px auto;padding:0 14px}
            .card{background:#fff;border:1px solid #e2e2e2;border-radius:14px;padding:14px}
            .grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px}
            textarea,input{box-sizing:border-box}
            code{background:#f1f1f1;padding:2px 6px;border-radius:8px}
            .ico{width:18px;height:18px;vertical-align:-3px;margin-right:8px;opacity:.92}
            .ico-fallback{display:inline-block;width:18px;height:18px;text-align:center;margin-right:8px;opacity:.55}
            .h1{display:flex;align-items:center;gap:8px}
            .btn{padding:10px 14px;border:1px solid #111;border-radius:12px;background:#111;color:#fff;cursor:pointer}
            .btn2{padding:10px 14px;border:1px solid #ccc;border-radius:12px;background:#fff;color:#111;cursor:pointer}
            .ok{padding:10px;border:1px solid #8c8;border-radius:12px;background:#efe}
            .err{padding:10px;border:1px solid #c88;border-radius:12px;background:#fee}
            .badge{display:inline-block;padding:3px 8px;border-radius:999px;border:1px solid #ccc;background:#f6f6f6;font-size:12px}
            .badge.ok{border-color:#8c8;background:#efe}
            .badge.bad{border-color:#c88;background:#fee}

            /* AdminUi (Phase 2) */
            .adminui-head{display:flex;justify-content:space-between;gap:14px;align-items:flex-start;margin-bottom:12px}
            .adminui-head-left{display:flex;gap:10px;align-items:flex-start}
            .adminui-h1{margin:0;font-size:24px;line-height:1.2}
            .adminui-sub{margin-top:4px;opacity:.7;font-size:12px}
            .adminui-actions{display:flex;gap:10px;flex-wrap:wrap;justify-content:flex-end}
            .adminui-muted{opacity:.7;font-size:12px}
            .adminui-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px;margin:12px 0}
            .adminui-card{background:#fff;border:1px solid #e2e2e2;border-radius:14px;padding:12px}
            .adminui-card-title{font-weight:700}
            .adminui-card-value{font-size:28px;margin-top:6px}
            .adminui-group{background:#fff;border:1px solid #e2e2e2;border-radius:16px;margin:14px 0;overflow:hidden}
            .adminui-group-head{padding:12px 14px;background:#fafafa;border-bottom:1px solid #eee}
            .adminui-group-title{font-weight:800}
            .adminui-group-body{padding:14px}
            .adminui-code{border:1px solid #e2e2e2;border-radius:14px;background:#0b0b0b;color:#eaeaea;padding:10px;overflow:auto;font-family:ui-monospace,Menlo,monospace;font-size:12px;line-height:1.45}
            .adminui-form{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px}
            .adminui-field input,.adminui-field select,.adminui-field textarea{width:100%;padding:10px;border:1px solid #ccc;border-radius:12px}
            .adminui-input{padding:10px;border:1px solid #ccc;border-radius:12px}
            .adminui-label{display:block;font-weight:700;margin-bottom:6px}
            .adminui-help{margin-top:6px;opacity:.7;font-size:12px}

            .adminui-tabs{display:flex;gap:8px;flex-wrap:wrap;margin:10px 0 16px}
            .adminui-tab{display:inline-block;padding:10px 12px;border:1px solid #ccc;border-radius:12px;background:#fff;color:#111;text-decoration:none}
            .adminui-tab.is-active{border-color:#111;background:#111;color:#fff}
            .adminui-table{width:100%;border-collapse:collapse}
            .adminui-table th{background:#fafafa;text-align:left;padding:10px;border-bottom:1px solid #eee}
            .adminui-table td{padding:10px;border-top:1px solid #eee;vertical-align:top}
            .adminui-actions-row{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-top:14px}
            .adminui-check{display:flex;gap:10px;align-items:flex-start}
            .adminui-check input[type=checkbox]{margin-top:3px}
            .adminui-notice{padding:10px 12px;border-radius:12px;border:1px solid #ccc;background:#fff;margin:10px 0}
            .adminui-notice.is-ok{border-color:#8c8;background:#efe}
            .adminui-notice.is-err{border-color:#c88;background:#fee}
            .adminui-notice.is-warn{border-color:#cc8;background:#ffd}
            .adminui-notice.is-info{border-color:#8ac;background:#eef}
            .adminui-table-wrap{overflow:auto}

        </style></head><body>";
        echo "<div class='top'><div><b>nukeCE</b> &nbsp;|&nbsp; Admin</div><div style='display:flex;gap:12px;align-items:center;'>
                <a href='/index.php'>Site</a>
                <a href='/index.php?module=admin_settings'>Settings</a>
                <a href='/index.php?module=admin_moderation'>Moderation</a>
                <a href='/index.php?module=admin_forums'>Forums Admin</a>
                <a href='/index.php?module=admin_login&logout=1'>Logout</a>
              </div></div>";
        echo "<div class='wrap'>";
    }

    

public static function icon(string $key, string $alt = ''): string
{
    // Prefer remastered system icon library when available.
    $safe = preg_replace('/[^a-z0-9_\-]/i', '', $key) ?? $key;
    $candidates = [
        "/assets/images/originals/system/src_images/$safe.png",
        "/assets/images/originals/system/src_images/$safe.gif",
        "/assets/images/originals/system/src_images/$safe.jpg",
        "/assets/images/originals/system/legacy_images/$safe.png",
        "/assets/images/originals/system/legacy_images/$safe.gif",
        "/assets/images/originals/system/legacy_images/$safe.jpg",
        // classic fallbacks (if present in old paths)
        "/images/$safe.png",
        "/images/$safe.gif",
    ];

    foreach ($candidates as $url) {
        $fs = dirname(__DIR__, 2) . $url;
        if (is_file($fs)) {
            $a = $alt !== '' ? $alt : $safe;
            return "<img class='ico' src='" . htmlspecialchars($url, ENT_QUOTES, 'UTF-8') . "' alt='" . htmlspecialchars($a, ENT_QUOTES, 'UTF-8') . "'>";
        }
    }
    return "<span class='ico ico-fallback' aria-hidden='true'>●</span>";
}

    public static function footer(): void
    {
        echo "</div></body></html>";
    }
}
