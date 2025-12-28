<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\AdminMobile;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\AdminLayout;
use NukeCE\Core\MobileMode;
use NukeCE\Core\Theme;
use NukeCE\Security\Csrf;
use NukeCE\Security\NukeSecurity;

final class AdminMobileModule implements ModuleInterface
{
    public function getName(): string { return 'admin_mobile'; }

    public function handle(array $params): void
    {
        NukeSecurity::requireAdmin();

        $state = MobileMode::state();
        $msg = '';

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            Csrf::requireValid($_POST['_csrf'] ?? '');

            $state['enabled'] = !empty($_POST['enabled']);
            $state['auto_detect'] = !empty($_POST['auto_detect']);
            $state['allow_user_toggle'] = !empty($_POST['allow_user_toggle']);
            $state['cookie_name'] = preg_replace('/[^a-z0-9_]/i', '', (string)($_POST['cookie_name'] ?? 'nukece_mobile')) ?: 'nukece_mobile';
            $state['force_param'] = preg_replace('/[^a-z0-9_]/i', '', (string)($_POST['force_param'] ?? 'mobile')) ?: 'mobile';

            $theme = (string)($_POST['theme_slug'] ?? 'subSilver');
            if ($theme && is_dir((defined('NUKECE_ROOT') ? NUKECE_ROOT : dirname(__DIR__, 2)) . '/themes/' . $theme)) {
                $state['theme_slug'] = $theme;
            }

            MobileMode::save($state);
            $msg = "Saved mobile settings.";
        }

        $themes = array_values(array_filter(Theme::listThemes(), fn($t) => !empty($t['enabled'])));

        AdminLayout::header('Mobile');
        echo "<h1 class='h1'><?= AdminLayout::icon('mobile','mobile') ?>Mobile</h1>";
        if ($msg) echo "<div class='ok' style='margin:10px 0'>" . htmlspecialchars($msg, ENT_QUOTES,'UTF-8') . "</div>";

        $csrf = Csrf::token();

        echo "<form method='post' action='/index.php?module=admin_mobile' style='display:grid;gap:12px;max-width:860px'>";
        echo "<input type='hidden' name='_csrf' value='{$csrf}'>";

        echo "<div class='card' style='padding:12px;display:grid;gap:10px'>";
        echo "<label style='display:flex;gap:8px;align-items:center'><input type='checkbox' name='enabled' value='1' ".(!empty($state['enabled'])?'checked':'')."> Enable mobile mode</label>";
        echo "<label style='display:flex;gap:8px;align-items:center'><input type='checkbox' name='auto_detect' value='1' ".(!empty($state['auto_detect'])?'checked':'')."> Auto-detect mobile user agents</label>";
        echo "<label style='display:flex;gap:8px;align-items:center'><input type='checkbox' name='allow_user_toggle' value='1' ".(!empty($state['allow_user_toggle'])?'checked':'')."> Allow user toggle via cookie/URL</label>";

        echo "<label>Mobile theme: <select name='theme_slug'>";
        foreach ($themes as $t) {
            $slug = (string)$t['slug'];
            $name = (string)($t['name'] ?? $slug);
            $sel = ($slug === (string)($state['theme_slug'] ?? 'subSilver')) ? "selected" : "";
            echo "<option value='".htmlspecialchars($slug,ENT_QUOTES,'UTF-8')."' {$sel}>".htmlspecialchars($name,ENT_QUOTES,'UTF-8')." ({$slug})</option>";
        }
        echo "</select></label>";

        echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
        echo "<label>Cookie name: <input name='cookie_name' value='".htmlspecialchars((string)($state['cookie_name'] ?? 'nukece_mobile'),ENT_QUOTES,'UTF-8')."'></label>";
        echo "<label>Force param: <input name='force_param' value='".htmlspecialchars((string)($state['force_param'] ?? 'mobile'),ENT_QUOTES,'UTF-8')."'></label>";
        echo "</div>";

        echo "<div class='muted'><small>Force param controls <code>?mobile=1</code> / <code>?mobile=0</code>. Cookie persists user choice per browser.</small></div>";
        echo "</div>";

        echo "<div><button class='btn' type='submit'>Save</button></div>";
        echo "</form>";

        AdminLayout::footer();
    }
}
