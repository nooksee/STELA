<?php
declare(strict_types=1);

require_once __DIR__ . '/../includes/bootstrap.php';
require_once __DIR__ . '/../includes/db.php';
require_once __DIR__ . '/auth.php';

nukece_require_admin();
$pdo = nukece_db();

$pages = $pdo->query("SELECT id, slug, title, updated_at FROM nukece_pages ORDER BY updated_at DESC")->fetchAll();
?>
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Pages</title></head>
<body>
<p><a href="/admin/">← Dashboard</a></p>
<h1>Pages</h1>
<p><a href="/admin/page_edit.php">+ New Page</a></p>

<table border="1" cellpadding="6" cellspacing="0">
<tr><th>ID</th><th>Slug</th><th>Title</th><th>Updated</th><th>Actions</th></tr>
<?php foreach ($pages as $p): ?>
<tr>
  <td><?= (int)$p['id'] ?></td>
  <td><?= htmlspecialchars((string)$p['slug']) ?></td>
  <td><?= htmlspecialchars((string)$p['title']) ?></td>
  <td><?= htmlspecialchars((string)$p['updated_at']) ?></td>
  <td>
    <a href="/admin/page_edit.php?id=<?= (int)$p['id'] ?>">Edit</a> |
    <a href="/page.php?slug=<?= urlencode((string)$p['slug']) ?>" target="_blank">View</a>
  </td>
</tr>
<?php endforeach; ?>
</table>
</body>
</html>
