<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

/** @var string $title */
/** @var string $themeSlug */
$t = htmlspecialchars($title, ENT_QUOTES, 'UTF-8');
$css = "/themes/{$themeSlug}/assets/css/style.css";
?><!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><?= $t ?></title>
  <link rel="stylesheet" href="<?= htmlspecialchars($css, ENT_QUOTES, 'UTF-8') ?>">
</head>
<body>
  <div class="top">
<?php $topBar = pickOriginal(['images/mainbar.gif']); if ($topBar) echo "<style>.top{background-image:url('".htmlspecialchars($topBar,ENT_QUOTES,'UTF-8')."');background-repeat:repeat-x}</style>"; ?>

    <a href="/index.php">Home</a>
<?php
  // Prefer "originals (remastered)" assets when present
  function pickOriginal(array $rels): ?string {
    foreach ($rels as $rel) {
      $fs = __DIR__ . '/../assets/images/originals/' . $rel;
      if (is_file($fs)) return '/themes/subSilver/assets/images/originals/' . $rel;
    }
    return null;
  }
  $logoPath = pickOriginal(['images/nukece.png','images/cellpic2.jpg']);
?>
      <?php if ($logoPath): ?>
        <img class="nukece-logo" src="<?= htmlspecialchars($logoPath, ENT_QUOTES,'UTF-8') ?>" alt="logo">
      <?php endif; ?>
    <a href="/index.php?module=news">News</a>
    <a href="/index.php?module=forums"><?php $cfg = is_file(NUKECE_ROOT.'/config/config.php') ? (array)include NUKECE_ROOT.'/config/config.php' : []; echo (!isset($cfg['forums_enabled']) || $cfg['forums_enabled']) ? 'Forums' : 'Forums (off)'; ?></a>
  </div>
  <div class="wrap">
