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

        // Save settings (non-audit tabs)
        if (isset($_POST['save_settings'])) {
            $token = $_POST['_csrf'] ?? null;
            if (!Csrf::validate(is_string($token) ? $token : null)) {
                $err = 'CSRF validation failed.';
            } else {
                $actor = AuthGate::adminUsername();
                try {
                    if ($tab === 'labels') {
                        $changes = [];
                        $this->applyLabels($actor, $changes);
                        foreach ($changes as $c) {
                            NukeSecurity::log('settings.labels.changed', $c + ['actor' => $actor]);
                        }
                        $ok = $changes ? 'Saved.' : 'No changes.';
                    } elseif ($tab !== 'audit') {
                        $changes = $this->applyPost($tab, $actor);
                        foreach ($changes as $c) {
                            NukeSecurity::log('settings.changed', $c + ['actor' => $actor]);
                        }
                        $ok = $changes ? 'Saved.' : 'No changes.';
                    }
                } catch (\Throwable $e) {
                    $err = 'Save failed: ' . htmlspecialchars($e->getMessage(), ENT_QUOTES, 'UTF-8');
                }
            }
        }

        // Rollback (audit tab)
        if ($tab === 'audit' && isset($_POST['rollback_id'])) {
            $token = $_POST['_csrf'] ?? null;
            if (!Csrf::validate(is_string($token) ? $token : null)) {
                $err = 'CSRF validation failed.';
            } else {
                $id = (int)($_POST['rollback_id'] ?? 0);
                $actor = AuthGate::adminUsername();
                if ($id > 0 && SiteConfig::rollback($id, $actor)) {
                    NukeSecurity::log('settings.rolled_back', ['id' => $id, 'actor' => $actor]);
                    $ok = 'Rolled back.';
                } else {
                    $err = 'Rollback failed.';
                }
            }
        }

        AdminLayout::header('Admin Settings');

        echo AdminUi::pageHead(
            'Settings',
            'settings',
            'Clear, audited configuration for PHP-Nuke CE.'
        );

        $tabs = [
            ['key' => 'general', 'label' => 'General', 'url' => '/index.php?module=admin_settings&tab=general'],
            ['key' => 'theme', 'label' => 'Theme & UX', 'url' => '/index.php?module=admin_settings&tab=theme'],
            ['key' => 'modules', 'label' => 'Modules', 'url' => '/index.php?module=admin_settings&tab=modules'],
            ['key' => 'email', 'label' => 'Email', 'url' => '/index.php?module=admin_settings&tab=email'],
            ['key' => 'security', 'label' => 'Security', 'url' => '/index.php?module=admin_settings&tab=security'],
            ['key' => 'caching', 'label' => 'Caching', 'url' => '/index.php?module=admin_settings&tab=caching'],
            ['key' => 'labels', 'label' => 'Labels', 'url' => '/index.php?module=admin_settings&tab=labels'],
            ['key' => 'audit', 'label' => 'Audit', 'url' => '/index.php?module=admin_settings&tab=audit'],
        ];
        echo AdminUi::tabs($tabs, $tab);

        if ($ok !== '') {
            echo "<div class='ok' style='margin:12px 0'>" . AdminUi::e($ok) . "</div>";
        }
        if ($err !== '') {
            echo "<div class='err' style='margin:12px 0'>" . AdminUi::e($err) . "</div>";
        }

        if ($tab === 'audit') {
            echo AdminUi::group(
                'Audit & Rollback',
                'Recent configuration changes. Rollbacks are logged to NukeSecurity.',
                $this->renderAuditUi()
            );
            AdminLayout::footer();
            return;
        }

        if ($tab === 'labels') {
            echo AdminUi::group(
                'Labels',
                'Change what users see in navigation (does not change the underlying module names).',
                $this->renderLabelsUi()
            );
            AdminLayout::footer();
            return;
        }

        $form = "<form method='post'>";
        $form .= "<div class='adminui-form'>";
        $form .= Csrf::field();

        $form .= match ($tab) {
            'general' => $this->renderGeneralUi(),
            'theme' => $this->renderThemeUi(),
            'modules' => $this->renderModulesUi(),
            'email' => $this->renderEmailUi(),
            'security' => $this->renderSecurityUi(),
            'caching' => $this->renderCachingUi(),
            default => $this->renderGeneralUi(),
        };

        $form .= "</div>";
        $form .= "<div class='adminui-actions-row'>";
        $form .= "<button class='btn' type='submit' name='save_settings' value='1'>Save</button>";
        $form .= "<span class='adminui-muted'>Secrets live in <code>config/config.php</code> or environment variables.</span>";
        $form .= "</div>";
        $form .= "</form>";

        echo AdminUi::group('Settings', 'These options are audited and can be rolled back via the Audit tab.', $form);

        AdminLayout::footer();
    }
