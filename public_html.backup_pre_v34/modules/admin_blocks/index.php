    <?php
    /**
     * PHP-Nuke CE
     * Blocks
     */
    require_once __DIR__ . '/../../mainfile.php';
    require_once NUKECE_ROOT . '/includes/admin_ui.php';

    AdminUi::requireAdmin();
    include_once NUKECE_ROOT . '/includes/header.php';

    AdminUi::header('Blocks', [
        '/admin' => 'Dashboard',
        '/admin.php?op=logout' => 'Logout',
    ]);

    AdminUi::groupStart('Blocks', 'Enable/disable, reorder, and cache');
echo AdminUi::button('/index.php?module=admin_blocks', 'Open Blocks Admin', 'primary');
AdminUi::groupEnd();


    AdminUi::footer();
    include_once NUKECE_ROOT . '/includes/footer.php';
