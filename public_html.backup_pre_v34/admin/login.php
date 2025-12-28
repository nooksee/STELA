<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/auth.php';

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim((string)($_POST['username'] ?? ''));
    $password = (string)($_POST['password'] ?? '');

    $pdo = nukece_db();
    $stmt = $pdo->prepare("SELECT id, pass_hash FROM nukece_users WHERE username=? LIMIT 1");
    $stmt->execute([$username]);
    $row = $stmt->fetch();

    if ($row && password_verify($password, (string)$row['pass_hash'])) {
        nukece_login((int)$row['id']);
        header('Location: /admin/');
        exit;
    }
    $error = 'Invalid login.';
}
?>
<!doctype html>
<html>
<head><meta charset="utf-8"><title>nukeCE Admin Login</title></head>
<body>
<h1>nukeCE Admin</h1>
<?php if ($error): ?><p style="color:red;"><?= htmlspecialchars($error) ?></p><?php endif; ?>
<form method="post" autocomplete="off">
    <label>Username <input name="username" /></label><br><br>
    <label>Password <input name="password" type="password" /></label><br><br>
    <button type="submit">Login</button>
</form>
<p><small>After install: admin / admin123</small></p>
</body>
</html>
