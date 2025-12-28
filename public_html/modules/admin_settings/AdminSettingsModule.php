<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\AdminSettings;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\AdminLayout;
use NukeCE\Core\AdminUi;
use NukeCE\Security\AuthGate;
use NukeCE\Security\Csrf;
use NukeCE\Security\NukeSecurity;
use NukeCE\Core\SiteConfig;

final class AdminSettingsModule implements ModuleInterface
{
    public function getName(): string { return 'admin_settings'; }

    public function handle(array $params): void
    {
        AuthGate::requireAdmin();

        $tab = (string)($_GET['tab'] ?? 'general');
        $ok = '';
        $err = '';

        if (isset($_POST['save_settings'])) {
            $token = $_POST['_csrf'] ?? null;
            if (!Csrf::validate(is_string($token) ? $token : null)) {
                $err = 'CSRF validation failed.';
            } else {
                $actor = AuthGate::adminUsername();
                try {
                    $changes = $this->applyPost($tab, $actor);
                    if ($tab === 'labels') { $this->applyLabels($actor, $changes); }
                    foreach ($changes as $c) {
                        NukeSecurity::log('settings.changed', $c + ['actor'=>$actor]);
                    }
                    $ok = $changes ? 'Saved.' : 'No changes.';
                } catch (\Throwable $e) {
                    $err = 'Save failed: ' . htmlspecialchars($e->getMessage(), ENT_QUOTES, 'UTF-8');
                }
            }
        }

        if ($tab === 'audit' && isset($_POST['rollback_id'])) {
            $token = $_POST['_csrf'] ?? null;
            if (!Csrf::validate(is_string($token) ? $token : null)) {
                $err = 'CSRF validation failed.';
            } else {
                $id = (int)($_POST['rollback_id'] ?? 0);
                $actor = AuthGate::adminUsername();
                if ($id > 0 && SiteConfig::rollback($id, $actor)) {
                    NukeSecurity::log('settings.rolled_back', ['id'=>$id,'actor'=>$actor]);
                    $ok = 'Rolled back.';
                } else $err = 'Rollback failed.';
            }
        }

        
AdminLayout::header('Admin Settings');

        echo AdminUi::pageHead('Settings', 'settings', 'Site configuration and policy.');

        $tabs = [
            ['key'=>'general','label'=>'General','url'=>'/index.php?module=admin_settings&tab=general'],
            ['key'=>'theme','label'=>'Theme & UX','url'=>'/index.php?module=admin_settings&tab=theme'],
            ['key'=>'modules','label'=>'Modules','url'=>'/index.php?module=admin_settings&tab=modules'],
            ['key'=>'email','label'=>'Email','url'=>'/index.php?module=admin_settings&tab=email'],
            ['key'=>'security','label'=>'Security','url'=>'/index.php?module=admin_settings&tab=security'],
            ['key'=>'caching','label'=>'Caching','url'=>'/index.php?module=admin_settings&tab=caching'],
            ['key'=>'labels','label'=>'Labels','url'=>'/index.php?module=admin_settings&tab=labels'],
            ['key'=>'audit','label'=>'Audit','url'=>'/index.php?module=admin_settings&tab=audit'],
        ];
        echo AdminUi::tabs($tabs, $tab);

        if ($ok) echo AdminUi::notice('ok', $ok);
        if ($err) echo AdminUi::notice('err', $err);

        if ($tab === 'audit') {
            echo "<form method='post'>";
            echo $this->renderAudit();
            echo "</form>";
            AdminLayout::footer();
            return;
        }

        $inner = match ($tab) {
            'general' => $this->renderGeneral(),
            'theme' => $this->renderTheme(),
            'modules' => $this->renderModules(),
            'email' => $this->renderEmail(),
            'security' => $this->renderSecurity(),
            'caching' => $this->renderCaching(),
            'labels' => $this->renderLabels(),
            default => $this->renderGeneral(),
        };

        echo "<form method='post'>";
        echo Csrf::field();
        echo $inner;
        echo "<div class='adminui-actions-row'>";
        echo "<button class='btn' type='submit' name='save_settings' value='1'>Save</button>";
        echo "<span class='adminui-muted'>Secrets live in <code>config/config.php</code> or environment variables.</span>";
        echo "</div>";
        echo "</form>";

        AdminLayout::footer();
    }

    private function tabLink(string $t, string $label, string $active): string
    {
        $cls = $t === $active ? "btn" : "btn2";
        return "<a class='{$cls}' href='/index.php?module=admin_settings&tab={$t}'>" . htmlspecialchars($label,ENT_QUOTES,'UTF-8') . "</a>";
    }

    /** @return list<array{key:string,old:mixed,new:mixed,type:string}> */
    private function applyPost(string $tab, string $actor): array
    {
        $changes = [];
        $map = $this->fieldMap($tab);
        foreach ($map as $key => $m) {
            $type = $m['type'];
            $post = $m['post'];
            $def = $m['default'];

            if ($type === 'bool') $new = isset($_POST[$post]) && $_POST[$post] === '1';
            elseif ($type === 'int') $new = (int)($_POST[$post] ?? (string)$def);
            else $new = (string)($_POST[$post] ?? (string)$def);

            $old = SiteConfig::get($key, $def);
            if ($old !== $new) {
                SiteConfig::set($key, $new, $type, $actor);
                $changes[] = ['key'=>$key,'old'=>$old,'new'=>$new,'type'=>$type];
            }
        }

        // Locked maintenance behavior: posting is disabled when maintenance enabled
        if (SiteConfig::get('site.maintenance.enabled', false)) {
            SiteConfig::set('site.maintenance.readonly_posting', true, 'bool', $actor, 'locked');
        }

        return $changes;
    }

    private function fieldMap(string $tab): array
    {
        return match ($tab) {
            'general' => [
                'site.name' => ['post'=>'site_name','type'=>'string','default'=>'nukeCE'],
                'site.slogan' => ['post'=>'site_slogan','type'=>'string','default'=>''],
                'site.base_url' => ['post'=>'site_base_url','type'=>'string','default'=>''],
                'site.timezone' => ['post'=>'site_timezone','type'=>'string','default'=>'UTC'],
                'site.language' => ['post'=>'site_language','type'=>'string','default'=>'en'],
                'site.maintenance.enabled' => ['post'=>'maint_enabled','type'=>'bool','default'=>false],
                'site.maintenance.message' => ['post'=>'maint_message','type'=>'string','default'=>'Maintenance in progress.'],
            ],
            'theme' => [
                'theme.default' => ['post'=>'theme_default','type'=>'string','default'=>'nukegold'],
                'theme.allow_user_select' => ['post'=>'theme_allow_user','type'=>'bool','default'=>true],
                'theme.ticker.enabled' => ['post'=>'theme_ticker_enabled','type'=>'bool','default'=>false],
                'theme.ticker.source' => ['post'=>'theme_ticker_source','type'=>'string','default'=>''],
            ],
            'modules' => [
                'modules.forums.enabled' => ['post'=>'mod_forums','type'=>'bool','default'=>true],
                'modules.messages.enabled' => ['post'=>'mod_messages','type'=>'bool','default'=>true],
                'modules.editor.enabled' => ['post'=>'mod_editor','type'=>'bool','default'=>true],
            ],
            'email' => [
                'email.from_name' => ['post'=>'email_from_name','type'=>'string','default'=>'nukeCE'],
                'email.from_address' => ['post'=>'email_from_address','type'=>'string','default'=>''],
                'email.smtp.host' => ['post'=>'email_smtp_host','type'=>'string','default'=>''],
                'email.smtp.port' => ['post'=>'email_smtp_port','type'=>'int','default'=>587],
                'email.smtp.user' => ['post'=>'email_smtp_user','type'=>'string','default'=>''],
            ],
            'security' => [
                'security.mode' => ['post'=>'security_mode','type'=>'string','default'=>'log_only'],
                'security.alert.email' => ['post'=>'security_alert_email','type'=>'string','default'=>''],
                'security.alert.webhook' => ['post'=>'security_alert_webhook','type'=>'string','default'=>''],
            ],
            'caching' => [
                'cache.blocks.ttl' => ['post'=>'cache_blocks_ttl','type'=>'int','default'=>300],
                'cache.force_refresh_roles' => ['post'=>'cache_force_roles','type'=>'bool','default'=>false],
            ],
            default => [],
        };
    }


    private function renderGeneral(): string
    {
        $h = "<div class='adminui-form'>";
        $h .= AdminUi::formRow('Site name', $this->input('site_name', (string)SiteConfig::get('site.name', 'nukeCE')), 'Human-facing title used in headers.');
        $h .= AdminUi::formRow('Slogan', $this->input('site_slogan', (string)SiteConfig::get('site.slogan', '')), 'Short phrase shown in theme headers (optional).');
        $h .= AdminUi::formRow('Base URL', $this->input('site_base_url', (string)SiteConfig::get('site.base_url', '')), 'Used for absolute links in emails and feeds. Leave blank to auto-detect.');
        $h .= AdminUi::formRow('Timezone', $this->input('site_timezone', (string)SiteConfig::get('site.timezone', 'UTC')), 'Example: UTC or America/New_York.');
        $h .= AdminUi::formRow('Language', $this->input('site_language', (string)SiteConfig::get('site.language', 'en')), 'Default language key (e.g., en).');
        $h .= AdminUi::formRow('Maintenance mode', $this->check('maint_enabled', (bool)SiteConfig::get('site.maintenance.enabled', false), 'Read-only posting while enabled.'), 'When enabled, visitors can browse but cannot post.');
        $h .= AdminUi::formRow('Maintenance message', $this->textarea('maint_message', (string)SiteConfig::get('site.maintenance.message', 'Maintenance in progress.')), 'Shown to non-admin users.');
        $h .= "</div>";
        return AdminUi::group('General', 'Core site identity and visitor-facing defaults.', $h);
    }

    private function renderTheme(): string
    {
        $h = "<div class='adminui-form'>";
        $h .= AdminUi::formRow('Default theme', $this->input('theme_default', (string)SiteConfig::get('theme.default', 'nukegold')), 'Theme directory name (e.g., nukegold, subSilver).');
        $h .= AdminUi::formRow('Allow user theme selection', $this->check('theme_allow_user', (bool)SiteConfig::get('theme.allow_user_select', true)), 'Users can pick their own theme in their profile.');
        $h .= AdminUi::formRow('Header ticker enabled', $this->check('theme_ticker_enabled', (bool)SiteConfig::get('theme.ticker.enabled', false)), 'For themes like x-halo that support a header ticker.');
        $h .= AdminUi::formRow('Ticker source (text)', $this->textarea('theme_ticker_source', (string)SiteConfig::get('theme.ticker.source', '')), 'Plain text; theme may render as scrolling marquee/ticker.');
        $h .= "</div>";
        $h .= "<div class='adminui-muted'>Theme inventory, previews, and diagnostics live in Themes Admin.</div>";
        return AdminUi::group('Theme & UX policy', 'Global defaults. Theme-specific options remain in Themes Admin.', $h);
    }

    private function renderModules(): string
    {
        $h = "<div class='adminui-form'>";
        $h .= AdminUi::formRow('Forums', $this->check('mod_forums', (bool)SiteConfig::get('modules.forums.enabled', true)), 'Disable only if you are intentionally running without Forums.');
        $h .= AdminUi::formRow('Messages', $this->check('mod_messages', (bool)SiteConfig::get('modules.messages.enabled', true)), 'Disabling Messages hides compose/reply surfaces but preserves accounts.');
        $h .= AdminUi::formRow('Editor layer', $this->check('mod_editor', (bool)SiteConfig::get('modules.editor.enabled', true)), 'Rich-text helper layer over classic compose.');
        $h .= "</div>";

        $h .= "<div class='adminui-muted' style='margin-top:10px'>";
        $h .= "<strong>Module activation:</strong> nukeCE uses a version-controlled allowlist. ";
        $h .= "To enable/disable whole modules, edit <code>config/modules.php</code> and deploy the change.";
        $h .= "</div>";

        $cfgFile = dirname(__DIR__, 3) . '/config/modules.php';
        if (is_file($cfgFile)) {
            $cfg = include $cfgFile;
            if (is_array($cfg)) {
                $enabled = $cfg['enabled'] ?? [];
                $optional = $cfg['optional'] ?? [];
                if (is_array($enabled)) {
                    $h .= "<div class='adminui-card' style='margin-top:12px'>";
                    $h .= "<div class='adminui-card-title'>Enabled by default</div>";
                    $h .= "<div class='adminui-muted'>" . htmlspecialchars(implode(', ', $enabled), ENT_QUOTES, 'UTF-8') . "</div>";
                    $h .= "</div>";
                }
                if (is_array($optional)) {
                    $h .= "<div class='adminui-card' style='margin-top:12px'>";
                    $h .= "<div class='adminui-card-title'>Present but optional</div>";
                    $h .= "<div class='adminui-muted'>" . htmlspecialchars(implode(', ', $optional), ENT_QUOTES, 'UTF-8') . "</div>";
                    $h .= "</div>";
                }
            }
        }
        return AdminUi::group('Modules', 'Feature switches. Disable safely without breaking the rest of the system.', $h);
    }

    private function renderEmail(): string
    {
        $h = "<div class='adminui-form'>";
        $h .= AdminUi::formRow('From name', $this->input('email_from_name', (string)SiteConfig::get('email.from_name', 'nukeCE')));
        $h .= AdminUi::formRow('From address', $this->input('email_from_address', (string)SiteConfig::get('email.from_address', '')));
        $h .= AdminUi::formRow('SMTP host', $this->input('email_smtp_host', (string)SiteConfig::get('email.smtp.host', '')));
        $h .= AdminUi::formRow('SMTP port', $this->input('email_smtp_port', (string)SiteConfig::get('email.smtp.port', '587')), 'Most providers: 587 (STARTTLS) or 465 (TLS).');
        $h .= AdminUi::formRow('SMTP user', $this->input('email_smtp_user', (string)SiteConfig::get('email.smtp.user', '')));
        $h .= "</div>";
        $h .= "<div class='adminui-muted'>SMTP password is configured via env/config and is never shown in the UI.</div>";
        return AdminUi::group('Email', 'Outbound mail configuration for alerts, registrations, and digests.', $h);
    }

    private function renderSecurity(): string
    {
        $cur = (string)SiteConfig::get('security.mode', 'log_only');
        $select = "<select name='security_mode' class='adminui-input'>"
            . "<option value='log_only'" . ($cur === 'log_only' ? " selected" : "") . ">Log only</option>"
            . "<option value='mitigate'" . ($cur === 'mitigate' ? " selected" : "") . ">Mitigate</option>"
            . "</select>";

        $h = "<div class='adminui-form'>";
        $h .= AdminUi::formRow('Mode', $select, 'Log-only records events; Mitigate can apply rate limits / blocks where supported.');
        $h .= AdminUi::formRow('Alert email', $this->input('security_alert_email', (string)SiteConfig::get('security.alert.email', '')), 'Where threshold alerts are sent.');
        $h .= AdminUi::formRow('Alert webhook', $this->input('security_alert_webhook', (string)SiteConfig::get('security.alert.webhook', '')), 'Optional: JSON webhook endpoint.');
        $h .= "</div>";
        return AdminUi::group('Security integration', 'Policy-level switches. Detailed controls live in NukeSecurity.', $h);
    }

    private function renderCaching(): string
    {
        $h = "<div class='adminui-form'>";
        $h .= AdminUi::formRow('Block cache TTL (seconds)', $this->input('cache_blocks_ttl', (string)SiteConfig::get('cache.blocks.ttl', '300')), 'How long block output is cached.');
        $h .= AdminUi::formRow('Force refresh roles into Forums cache', $this->check('cache_force_roles', (bool)SiteConfig::get('cache.force_refresh_roles', false)), 'Push nukeCE roles into Forums cache (use after big role changes).');
        $h .= "</div>";
        return AdminUi::group('Caching', 'Performance knobs. Keep defaults unless you are tuning.', $h);
    }

    private function renderLabels(): string
    {
        $h = "<div class='adminui-form'>";
        $h .= AdminUi::formRow('Clubs label', $this->input('label_clubs', (string)SiteConfig::get('label.clubs', 'Clubs')), 'UI wording only.');
        $h .= AdminUi::formRow('Memberships label', $this->input('label_memberships', (string)SiteConfig::get('label.memberships', 'Memberships')), 'UI wording only.');
        $h .= AdminUi::formRow('Supporters label', $this->input('label_supporters', (string)SiteConfig::get('label.supporters', 'Supporters')), 'UI wording only.');
        $h .= "</div>";
        return AdminUi::group('Labels', 'Rename public-facing terms without touching logic or permissions.', $h);
    }

    private function renderAudit(): string
    {
        $rows = SiteConfig::history(50);

        $table = "<table class='adminui-table'>"
            . "<thead><tr><th>When</th><th>Key</th><th>By</th><th>Action</th></tr></thead><tbody>";

        foreach ($rows as $r) {
            $id = (int)($r['id'] ?? 0);
            $when = AdminUi::e((string)($r['changed_at'] ?? ''));
            $key = AdminUi::e((string)($r['config_key'] ?? ''));
            $by = AdminUi::e((string)($r['changed_by'] ?? ''));
            $table .= "<tr>"
                . "<td>{$when}</td>"
                . "<td><code>{$key}</code></td>"
                . "<td>{$by}</td>"
                . "<td><button class='btn2' type='submit' name='rollback_id' value='{$id}'>Rollback</button></td>"
                . "</tr>";
        }
        if (!$rows) {
            $table .= "<tr><td colspan='4'>No changes yet.</td></tr>";
        }
        $table .= "</tbody></table>";

        $inner = Csrf::field() . $table;
        $inner .= "<div class='adminui-muted'>Rollback writes an audit event in NukeSecurity.</div>";

        return AdminUi::group('Audit & rollback', 'History of changes stored in SiteConfig. Rollback is one-click but still logged.', $inner);
    }

    private function input(string $name, string $value): string
    {
        return "<input class='adminui-input' type='text' name='" . AdminUi::eAttr($name) . "' value='" . AdminUi::eAttr($value) . "'>";
    }

    private function textarea(string $name, string $value): string
    {
        return "<textarea class='adminui-input' name='" . AdminUi::eAttr($name) . "' rows='3'>" . AdminUi::e($value) . "</textarea>";
    }

    private function check(string $name, bool $checked, string $label = ''): string
    {
        $c = $checked ? " checked" : "";
        $h = "<div class='adminui-check'>";
        $h .= "<input type='hidden' name='" . AdminUi::eAttr($name) . "' value='0'>";
        $h .= "<input type='checkbox' name='" . AdminUi::eAttr($name) . "' value='1'{$c}>";
        if ($label !== '') {
            $h .= "<div><b>" . AdminUi::e($label) . "</b></div>";
        }
        $h .= "</div>";
        return $h;
    }

    private function applyLabels(string $actor, array &$changes): void
    {
        $map = [
            'label_clubs' => 'label.clubs',
            'label_memberships' => 'label.memberships',
            'label_supporters' => 'label.supporters',
        ];
        foreach ($map as $postKey => $cfgKey) {
            if (!array_key_exists($postKey, $_POST)) continue;
            $val = trim((string)($_POST[$postKey] ?? ''));
            $old = SiteConfig::get($cfgKey, '');
            if ($old !== $val) {
                SiteConfig::set($cfgKey, $val, 'string', $actor, 'Admin UI label');
                $changes[] = ['key'=>$cfgKey,'old'=>$old,'new'=>$val,'type'=>'string'];
            }
        }
    }
}
