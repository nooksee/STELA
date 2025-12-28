<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Mobile;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Theme;
use NukeCE\Core\MobileMode;

/**
 * Mobile module
 *
 * World-class behavior:
 * - Provides a "Mobile Center" page with clear toggle controls
 * - Persists choice in cookie
 * - Integrates with Theme::activeSlug() via MobileMode (auto-detect + user override)
 *
 * Note: This module does NOT try to be a parallel content system.
 * It exists to manage the mobile experience and provide a stable landing page.
 */
final class MobileModule implements ModuleInterface
{
    public function getName(): string { return 'mobile'; }

    public function handle(array $params): void
    {
        $op = (string)($_GET['op'] ?? 'center');

        if ($op === 'set') {
            $this->set();
            return;
        }

        $this->center();
    }

    private function set(): void
    {
        // /index.php?module=mobile&op=set&mode=on|off|auto
        if (!MobileMode::allowUserToggle()) {
            Theme::header('Mobile');
            echo "<h1>Mobile</h1>";
            echo "<p>Mobile mode toggling is disabled by admin.</p>";
            Theme::footer();
            return;
        }

        $mode = strtolower((string)($_GET['mode'] ?? 'auto'));
        $set = null;

        if ($mode === 'on') $set = true;
        if ($mode === 'off') $set = false;
        if ($mode === 'auto') $set = null;

        if ($mode === 'auto') {
            // Clear cookie, fall back to auto-detect
            setcookie(MobileMode::cookieName(), '', time() - 3600, '/');
        } else {
            MobileMode::persistChoice($set);
        }

        $back = '/index.php?module=mobile';
        header("Location: {$back}");
        exit;
    }

    private function center(): void
    {
        $st = MobileMode::state();
        $isMobile = MobileMode::isMobileRequest();
        $cookie = MobileMode::cookieName();

        Theme::header('Mobile');

        echo "<h1>Mobile Center</h1>";
        echo "<p class='muted'><small>nukeCE can automatically switch to a lightweight theme for phones. You can also force it on/off for this browser.</small></p>";

        echo "<div class='card' style='padding:12px;display:grid;gap:10px'>";
        echo "<div><b>Status:</b> " . ($isMobile ? "<span class='badge ok'>mobile mode ON</span>" : "<span class='badge'>mobile mode OFF</span>") . "</div>";

        echo "<div style='display:flex;gap:10px;flex-wrap:wrap;align-items:center'>";
        if (MobileMode::allowUserToggle()) {
            echo "<a class='btn' href='/index.php?module=mobile&op=set&mode=on'>Force ON</a>";
            echo "<a class='btn2' href='/index.php?module=mobile&op=set&mode=off'>Force OFF</a>";
            echo "<a class='btn2' href='/index.php?module=mobile&op=set&mode=auto'>Auto-detect</a>";
        } else {
            echo "<span class='muted'><small>User toggling disabled by admin.</small></span>";
        }
        echo "</div>";

        echo "<div class='muted'><small>Cookie: <code>" . htmlspecialchars($cookie, ENT_QUOTES,'UTF-8') . "</code>. Theme used for mobile: <code>" . htmlspecialchars((string)($st['theme_slug'] ?? 'subSilver'), ENT_QUOTES,'UTF-8') . "</code>.</small></div>";
        echo "</div>";

        echo "<div class='card' style='padding:12px;margin-top:12px'>";
        echo "<b>Quick links</b>";
        echo "<div style='display:flex;gap:10px;flex-wrap:wrap;margin-top:10px'>";
        echo "<a class='btn2' href='/index.php'>Home</a>";
        echo "<a class='btn2' href='/index.php?module=news'>News</a>";
        echo "<a class='btn2' href='/index.php?module=forums'>Forums</a>";
        echo "</div>";
        echo "</div>";

        // small CSS for badges if theme doesn't define it
        echo "<style>.badge{display:inline-block;padding:2px 8px;border-radius:999px;border:1px solid #ccc;font-size:12px}.badge.ok{border-color:#2a7}</style>";

        Theme::footer();
    }
}
