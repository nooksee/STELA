    <?php
    /**
     * PHP-Nuke CE
     * Admin Settings
     */
    require_once __DIR__ . '/../../mainfile.php';
    require_once NUKECE_ROOT . '/includes/admin_ui.php';

    AdminUi::requireAdmin();
    include_once NUKECE_ROOT . '/includes/header.php';

    AdminUi::header('Admin Settings', [
        '/admin' => 'Dashboard',
        '/admin.php?op=logout' => 'Logout',
    ]);

    AdminUi::groupStart('General', 'Identity, maintenance, and site posture');
echo '<p>Use this panel to set the site name, slogan, base URL, and maintenance mode.</p>';
echo AdminUi::button('/index.php?module=admin_settings&tab=general', 'Open General', 'primary');
AdminUi::groupEnd();

AdminUi::groupStart('Theme & UX', 'Default theme and user theme policy');
echo '<p>Policy lives here; theme inventory and health live in Themes.</p>';
echo AdminUi::button('/index.php?module=admin_settings&tab=theme', 'Open Theme & UX', 'primary') . ' ';
echo AdminUi::button('/admin.php?op=themes', 'Themes Manager', 'secondary');
AdminUi::groupEnd();

AdminUi::groupStart('Modules', 'Enable/disable modules and open module-specific configuration');
echo '<p>Keep the system coherent: enable/disable here, configure in the module admin pages.</p>';
echo AdminUi::button('/index.php?module=admin_settings&tab=modules', 'Open Modules', 'primary');
AdminUi::groupEnd();

AdminUi::groupStart('Security, Email, Cache', 'Operational settings with audit logging');
echo AdminUi::button('/index.php?module=admin_settings&tab=security', 'Security', 'secondary') . ' ';
echo AdminUi::button('/index.php?module=admin_settings&tab=email', 'Email', 'secondary') . ' ';
echo AdminUi::button('/index.php?module=admin_settings&tab=cache', 'Cache', 'secondary');
AdminUi::groupEnd();

AdminUi::groupStart('Audit & Rollback', 'Recent changes and quick rollback');
echo AdminUi::button('/index.php?module=admin_settings&tab=audit', 'Audit', 'primary');
AdminUi::groupEnd();


    AdminUi::footer();
    include_once NUKECE_ROOT . '/includes/footer.php';
