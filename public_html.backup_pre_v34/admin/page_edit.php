<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/auth.php';

nukece_require_admin();
$pdo = nukece_db();

$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
$page = ['slug'=>'', 'title'=>'', 'body'=>''];

if ($id > 0) {
    $stmt = $pdo->prepare("SELECT id, slug, title, body FROM nukece_pages WHERE id=?");
    $stmt->execute([$id]);
    $row = $stmt->fetch();
    if ($row) $page = $row;
}

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $slug = trim((string)($_POST['slug'] ?? ''));
    $title = trim((string)($_POST['title'] ?? ''));
    $body = (string)($_POST['body'] ?? '');

    if ($slug === '' || $title === '') {
        $error = 'Slug and Title are required.';
    } else {
        if ($id > 0) {
            $stmt = $pdo->prepare("UPDATE nukece_pages SET slug=?, title=?, body=? WHERE id=?");
            $stmt->execute([$slug, $title, $body, $id]);
        } else {
            $stmt = $pdo->prepare("INSERT INTO nukece_pages (slug, title, body) VALUES (?, ?, ?)");
            $stmt->execute([$slug, $title, $body]);
            $id = (int)$pdo->lastInsertId();
        }
        header("Location: /admin/pages.php");
        exit;
    }
}
?>
<!doctype html>
<html>
<head><meta charset="utf-8"><title><?= $id ? "Edit" : "New" ?> Page</title></head>
<body>
<p><a href="/admin/pages.php">← Pages</a></p>
<h1><?= $id ? "Edit" : "New" ?> Page</h1>
<?php if ($error): ?><p style="color:red;"><?= htmlspecialchars($error) ?></p><?php endif; ?>

<form method="post">
  <label>Slug<br><input name="slug" value="<?= htmlspecialchars((string)$page['slug']) ?>" style="width:420px"></label><br><br>
  <label>Title<br><input name="title" value="<?= htmlspecialchars((string)$page['title']) ?>" style="width:420px"></label><br><br>
  <label>Body<br>
    <textarea name="body" rows="18" cols="80"><?= htmlspecialchars((string)$page['body']) ?></textarea>
  </label><br><br>
  <button type="submit">Save</button>
</form>

<?php if ($id): ?>
<p>Public URL: <a href="/page.php?slug=<?= urlencode((string)$page['slug']) ?>" target="_blank">/page.php?slug=<?= htmlspecialchars((string)$page['slug']) ?></a></p>
<?php endif; ?>
</body>
</html>
