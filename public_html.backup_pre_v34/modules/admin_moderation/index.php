    <?php
    /**
     * PHP-Nuke CE
     * Moderation
     */
    require_once __DIR__ . '/../../mainfile.php';
    require_once NUKECE_ROOT . '/includes/admin_ui.php';

    AdminUi::requireAdmin();
    include_once NUKECE_ROOT . '/includes/header.php';

    AdminUi::header('Moderation', [
        '/admin' => 'Dashboard',
        '/admin.php?op=logout' => 'Logout',
    ]);

    AdminUi::groupStart('Queue', 'Reported content, proposals, and flags');
echo '<p>Unified triage for forums, messages, and reference proposals. AI may propose; humans canonize.</p>';
echo AdminUi::button('/index.php?module=admin_moderation&view=open', 'Open Items', 'primary') . ' ';
echo AdminUi::button('/index.php?module=admin_moderation&view=reviewing', 'Reviewing', 'secondary') . ' ';
echo AdminUi::button('/index.php?module=admin_moderation&view=resolved', 'Resolved', 'secondary');
AdminUi::groupEnd();

AdminUi::groupStart('Tools', 'Bulk actions and exports');
echo '<p>All actions are logged via NukeSecurity.</p>';
echo AdminUi::button('/index.php?module=admin_moderation&action=export', 'Export CSV/JSON', 'secondary');
AdminUi::groupEnd();


    AdminUi::footer();
    include_once NUKECE_ROOT . '/includes/footer.php';
