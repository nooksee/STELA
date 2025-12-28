<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Account;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Theme;

final class AccountModule implements ModuleInterface
{
    public function getName(): string { return 'account'; }

    public function handle(array $params): void
    {
        $op = (string)($_GET['op'] ?? 'home');

        if ($op === 'appearance') {
            $this->appearance();
            return;
        }

        Theme::header('Your Account');
        echo "<h1>Your Account</h1>";
        echo "<div class='card' style='padding:12px'>";
        echo "<b>Preferences</b>";
        echo "<div style='margin-top:10px;display:flex;gap:10px;flex-wrap:wrap'>";
        if (Theme::allowUserSelection()) {
            echo "<a class='btn2' href='/index.php?module=account&op=appearance'>Appearance (Theme)</a>";
        } else {
            echo "<span class='muted'><small>Theme selection is disabled by admin.</small></span>";
        }
        echo "</div></div>";
        Theme::footer();
    }

    private function appearance(): void
    {
        Theme::header('Appearance');

        if (!Theme::allowUserSelection()) {
            echo "<h1>Appearance</h1>";
            echo "<p>Theme selection is currently disabled by admin.</p>";
            Theme::footer();
            return;
        }

        $cookie = Theme::configCookieName();
        $themes = array_values(array_filter(Theme::listThemes(), fn($t) => !empty($t['enabled'])));
        $current = Theme::activeSlug();

        $msg = '';
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $sel = (string)($_POST['theme'] ?? '');
            if ($sel === '' || $sel === 'default') {
                setcookie($cookie, '', time() - 3600, '/');
                $msg = "Theme reset to site default.";
                $current = Theme::defaultSlug();
            } else {
                foreach ($themes as $t) {
                    if ((string)$t['slug'] === $sel) {
                        setcookie($cookie, $sel, time() + 86400 * 365, '/');
                        $msg = "Theme updated.";
                        $current = $sel;
                        break;
                    }
                }
            }
        }

        echo "<h1>Appearance</h1>";
        if ($msg) echo "<div class='ok' style='margin:10px 0'>".htmlspecialchars($msg,ENT_QUOTES,'UTF-8')."</div>";

        echo "<div class='card' style='padding:12px'>";
        echo "<form method='post' action='/index.php?module=account&op=appearance' style='display:flex;gap:10px;align-items:center;flex-wrap:wrap'>";
        echo "<label>Theme: <select name='theme'>";
        echo "<option value='default'>Use site default</option>";
        foreach ($themes as $t) {
            $slug = (string)$t['slug'];
            $name = (string)($t['name'] ?? $slug);
            $selAttr = ($slug === $current) ? "selected" : "";
            echo "<option value='".htmlspecialchars($slug,ENT_QUOTES,'UTF-8')."' {$selAttr}>".htmlspecialchars($name,ENT_QUOTES,'UTF-8')." ({$slug})</option>";
        }
        echo "</select></label>";
        echo "<button class='btn' type='submit'>Save</button>";
        echo "</form>";
        echo "<div class='muted' style='margin-top:8px'><small>This preference is stored in your browser cookie until full user profiles are enabled.</small></div>";
        echo "</div>";

        echo "<p style='margin-top:12px'><a class='btn2' href='/index.php?module=account'>Back</a></p>";
        Theme::footer();
    }
}
