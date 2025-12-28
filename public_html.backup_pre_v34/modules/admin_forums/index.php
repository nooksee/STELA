    <?php
    /**
     * PHP-Nuke CE
     * Forums Admin
     */
    require_once __DIR__ . '/../../mainfile.php';
    require_once NUKECE_ROOT . '/includes/admin_ui.php';

    AdminUi::requireAdmin();
    include_once NUKECE_ROOT . '/includes/header.php';

    AdminUi::header('Forums Admin', [
        '/admin' => 'Dashboard',
        '/admin.php?op=logout' => 'Logout',
    ]);

    AdminUi::groupStart('Forums Admin', 'Routing, safety, and wrapper tools');
echo AdminUi::button('/index.php?module=admin_forums', 'Open Forums Admin', 'primary');
AdminUi::groupEnd();


    AdminUi::footer();
    include_once NUKECE_ROOT . '/includes/footer.php';
