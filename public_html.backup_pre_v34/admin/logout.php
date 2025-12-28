<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/auth.php';

nukece_logout();
header('Location: /admin/login.php');
exit;
