<?php
require_once __DIR__ . '/../mainfile.php';
if (class_exists('AuthGate')) { AuthGate::requireAdminOrRedirect(); }
header('Location: /index.php?module=admin_dashboard');
exit;
