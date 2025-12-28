<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/../includes/db.php';

function nukece_session_cookie_name(): string { return 'nukece_sid'; }

function nukece_current_user(): ?array {
    if (empty($_COOKIE[nukece_session_cookie_name()])) return null;

    $sid = (string)$_COOKIE[nukece_session_cookie_name()];
    if (!preg_match('/^[a-f0-9]{64}$/', $sid)) return null;

    $pdo = nukece_db();
    $stmt = $pdo->prepare("
        SELECT u.id, u.username, u.role
        FROM nukece_sessions s
        JOIN nukece_users u ON u.id = s.user_id
        WHERE s.id = ? AND s.expires_at > NOW()
        LIMIT 1
    ");
    $stmt->execute([$sid]);
    $u = $stmt->fetch();
    return $u ?: null;
}

function nukece_require_admin(): array {
    $u = nukece_current_user();
    if (!$u) {
        header('Location: /admin/login.php');
        exit;
    }
    return $u;
}

function nukece_login(int $userId): void {
    $sid = bin2hex(random_bytes(32));
    $expires = (new DateTimeImmutable('+8 hours'))->format('Y-m-d H:i:s');

    $pdo = nukece_db();
    $stmt = $pdo->prepare("INSERT INTO nukece_sessions (id, user_id, expires_at) VALUES (?, ?, ?)");
    $stmt->execute([$sid, $userId, $expires]);

    setcookie(nukece_session_cookie_name(), $sid, [
        'expires' => time() + 8*3600,
        'path' => '/',
        'httponly' => true,
        'samesite' => 'Lax',
        'secure' => false,
    ]);
}

function nukece_logout(): void {
    if (!empty($_COOKIE[nukece_session_cookie_name()])) {
        $sid = (string)$_COOKIE[nukece_session_cookie_name()];
        $pdo = nukece_db();
        $stmt = $pdo->prepare("DELETE FROM nukece_sessions WHERE id=?");
        $stmt->execute([$sid]);
    }
    setcookie(nukece_session_cookie_name(), '', time()-3600, '/');
}
