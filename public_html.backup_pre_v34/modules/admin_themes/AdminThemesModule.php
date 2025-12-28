<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\AdminThemes;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Theme;
use NukeCE\Security\Csrf;
use NukeCE\Security\NukeSecurity;

final class AdminThemesModule implements ModuleInterface
{
    public function getName(): string { return 'admin_themes'; }

    public function handle(array $params): void
    {
        NukeSecurity::requireAdmin();

        $root = defined('NUKECE_ROOT') ? NUKECE_ROOT : dirname(__DIR__, 2);
        require_once $root . '/includes/admin_ui.php';
        include_once $root . '/includes/header.php';

        AdminUi::header('Themes', [
            '/admin' => 'Dashboard',
            '/admin.php?op=logout' => 'Logout',
        ]);

        $stateFile = rtrim($root, '/\\') . '/data/themes_state.json';
        @mkdir(dirname($stateFile), 0755, true);

        $state = $this->loadState($stateFile);
        $msg = '';

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            Csrf::requireValid($_POST['_csrf'] ?? '');
            $action = (string)($_POST['action'] ?? 'save');

            if ($action === 'save_features') {
                $slug = (string)($_POST['theme_slug'] ?? '');
                $slug = preg_replace('/[^a-z0-9_\-]/i','', $slug) ?? $slug;
                $features = Theme::features($slug);
                $features['collapsible_blocks'] = !empty($_POST['collapsible_blocks']);
                if ($slug === 'x-halo') {
                    $features['ticker_enabled'] = !empty($_POST['ticker_enabled']);
                    $features['ticker_text'] = (string)($_POST['ticker_text'] ?? '');
                }
                Theme::setFeatures($slug, $features);
                $msg = "Saved theme features.";
            } elseif ($action === 'save') {
                $enabled = is_array($_POST['enabled'] ?? null) ? $_POST['enabled'] : [];
                $enabled = array_values(array_unique(array_map('strtolower', array_filter($enabled, 'is_string'))));

                $state['enabled'] = $enabled; // if empty => all enabled
                $state['allow_user'] = !empty($_POST['allow_user']);

                $default = (string)($_POST['default'] ?? '');
                if ($default !== '' && is_dir($root . '/themes/' . $default)) {
                    $state['default'] = $default;
                }

                $this->saveState($stateFile, $state);
                $msg = "Saved theme settings.";
            }
        }

        $themes = Theme::listThemes();
        $default = (string)($state['default'] ?? Theme::defaultSlug());
        $allowUser = (bool)($state['allow_user'] ?? Theme::allowUserSelection());
echo "<h1 class='h1'>Themes</h1>";
        if ($msg) echo "<div class='ok' style='margin:10px 0'>" . htmlspecialchars($msg, ENT_QUOTES,'UTF-8') . "</div>";

        $csrf = Csrf::token();

        echo "<form method='post' action='/index.php?module=admin_themes' style='display:grid;gap:12px;'>";
        echo "<input type='hidden' name='_csrf' value='{$csrf}'>";
        echo "<input type='hidden' name='action' value='save'>";

        echo "<div class='card' style='padding:12px'>";
        echo "<b>Global</b>";
        echo "<div style='display:flex;gap:14px;flex-wrap:wrap;align-items:center;margin-top:10px'>";
        echo "<label style='display:flex;gap:8px;align-items:center'><input type='checkbox' name='allow_user' value='1' ".($allowUser?'checked':'')."> Allow users to select a theme</label>";
        echo "<label style='display:flex;gap:8px;align-items:center'>Default theme: <select name='default'>";
        foreach ($themes as $t) {
            $slug = (string)($t['slug'] ?? '');
            $name = (string)($t['name'] ?? $slug);
            $sel = ($slug === $default) ? "selected" : "";
            echo "<option value='".htmlspecialchars($slug,ENT_QUOTES,'UTF-8')."' {$sel}>".htmlspecialchars($name,ENT_QUOTES,'UTF-8')." ({$slug})</option>";
        }
        echo "</select></label>";
        echo "</div>";
        echo "</div>";

        echo "<div class='card' style='padding:12px'>";
        echo "<b>Installed themes</b>";
        echo "<div class='muted' style='margin-top:4px'><small>Uncheck to disable. If you leave all unchecked, nukeCE treats all installed themes as enabled.</small></div>";
        echo "<table width='100%' cellpadding='8' cellspacing='0' style='border-collapse:collapse;margin-top:10px'>";
        echo "<tr style='background:#f4f4f4'><th align='left'>Enabled</th><th align='left'>Theme</th><th align='left'>Slug</th><th align='left'>Preview</th></tr>";
        foreach ($themes as $t) {
            $slug = (string)($t['slug'] ?? '');
            $name = (string)($t['name'] ?? $slug);
            $enabled = !empty($t['enabled']);
            $checked = $enabled ? "checked" : "";
            $preview = "/index.php?theme=" . rawurlencode($slug);
            echo "<tr style='border-top:1px solid #eee'>";
            echo "<td><input type='checkbox' name='enabled[]' value='".htmlspecialchars($slug,ENT_QUOTES,'UTF-8')."' {$checked}></td>";
            echo "<td><b>".htmlspecialchars($name,ENT_QUOTES,'UTF-8')."</b></td>";
            echo "<td><code>".htmlspecialchars($slug,ENT_QUOTES,'UTF-8')."</code></td>";
            echo "<td><a class='btn2' href='".htmlspecialchars($preview,ENT_QUOTES,'UTF-8')."'>Preview</a></td>";
            echo "</tr>";
        }
        echo "</table>";
        echo "</div>";

        echo "<div><button class='btn' type='submit'>Save</button></div>";
        echo "</form>";


// Theme Features (optional per-theme behaviors)
echo "<hr style='margin:18px 0;border:none;border-top:1px solid #e6e6e6'>";
echo "<form method='post' action='/index.php?module=admin_themes' class='card' style='display:grid;gap:12px'>";
echo "<input type='hidden' name='_csrf' value='{$csrf}'>";
echo "<input type='hidden' name='action' value='save_features'>";

$selTheme = (string)($_GET['theme'] ?? $default);
$selTheme = preg_replace('/[^a-z0-9_\-]/i','', $selTheme) ?? $selTheme;
$feat = Theme::features($selTheme);
$cb = !empty($feat['collapsible_blocks']) ? "checked" : "";

echo "<div style='display:flex;justify-content:space-between;gap:12px;align-items:center;flex-wrap:wrap'>";
echo "<div><b>Theme Features</b><div class='muted' style='margin-top:4px'>Optional behaviors (ticker, collapsible blocks, header widgets) per theme.</div></div>";
echo "<label>Theme: <select name='theme_slug' onchange='location.href=\"/index.php?module=admin_themes&theme=\"+encodeURIComponent(this.value)'>";
foreach ($themes as $t) {
    $slug = (string)($t['slug'] ?? '');
    $name = (string)($t['name'] ?? $slug);
    $sel = ($slug === $selTheme) ? "selected" : "";
    echo "<option value='".htmlspecialchars($slug,ENT_QUOTES,'UTF-8')."' {$sel}>".htmlspecialchars($name,ENT_QUOTES,'UTF-8')." ({$slug})</option>";
}
echo "</select></label>";
echo "</div>";

echo "<label style='display:flex;gap:8px;align-items:center'><input type='checkbox' name='collapsible_blocks' value='1' {$cb}> Collapsible blocks</label>";

if ($selTheme === 'x-halo') {
    $te = !empty($feat['ticker_enabled']) ? "checked" : "";
    $tt = htmlspecialchars((string)($feat['ticker_text'] ?? ''), ENT_QUOTES,'UTF-8');
    echo "<div class='card' style='padding:12px;border-radius:12px;border:1px solid #e6e6e6'>";
    echo "<b>X-Halo ticker</b><div class='muted' style='margin-top:4px'>Platinum-era scrolling ticker in header.</div>";
    echo "<label style='display:flex;gap:8px;align-items:center;margin-top:8px'><input type='checkbox' name='ticker_enabled' value='1' {$te}> Enable ticker</label>";
    echo "<label style='display:grid;gap:6px;margin-top:10px'>Ticker text<textarea name='ticker_text' rows='2'>{$tt}</textarea></label>";
    echo "</div>";
}

echo "<div><button class='btn' type='submit'>Save features</button></div>";
echo "</form>";
        AdminUi::groupEnd();

        AdminUi::footer();
        include_once $root . '/includes/footer.php';
}

    private function loadState(string $file): array
    {
        if (!is_file($file)) return ['enabled'=>[], 'default'=>'', 'allow_user'=>true];
        $raw = @file_get_contents($file);
        $j = $raw ? json_decode($raw, true) : null;
        if (!is_array($j)) return ['enabled'=>[], 'default'=>'', 'allow_user'=>true];
        return $j;
    }

    private function saveState(string $file, array $state): void
    {
        @file_put_contents($file, json_encode($state, JSON_UNESCAPED_SLASHES|JSON_PRETTY_PRINT), LOCK_EX);
    }
}
