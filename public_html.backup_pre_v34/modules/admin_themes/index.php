    <?php
    /**
     * PHP-Nuke CE
     * Themes
     */
    require_once __DIR__ . '/../../mainfile.php';
    require_once NUKECE_ROOT . '/includes/admin_ui.php';

    AdminUi::requireAdmin();
    include_once NUKECE_ROOT . '/includes/header.php';

    AdminUi::header('Themes', [
        '/admin' => 'Dashboard',
        '/admin.php?op=logout' => 'Logout',
    ]);

    AdminUi::groupStart('Themes', 'Inventory, previews, and health checks');
echo '<p>Theme policy is in Settings. Theme inventory lives here.</p>';
echo AdminUi::button('/index.php?module=admin_themes', 'Open Themes Manager', 'primary');
AdminUi::groupEnd();


    AdminUi::footer();
    include_once NUKECE_ROOT . '/includes/footer.php';
