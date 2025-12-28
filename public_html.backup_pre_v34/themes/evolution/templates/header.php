<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

use NukeCE\Core\Theme;

function pickOriginalAsset(array $rels): ?string {
  foreach ($rels as $rel) {
    $fs = __DIR__ . '/../assets/images/originals/' . $rel;
    if (is_file($fs)) return '/themes/evolution/assets/images/originals/' . $rel;
  }
  return null;
}


/**
 * Evolution theme header (clean-room homage).
 * Variables expected:
 * - $title (string)
 */
$siteName = Theme::config()['sitename'] ?? 'nukeCE';
?><!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title><?= htmlspecialchars(($title ? ($title . ' - ') : '') . $siteName, ENT_QUOTES, 'UTF-8') ?></title>
  <link rel="stylesheet" href="/themes/evolution/assets/css/style.css">
</head>
<body>
<div class="evo-topbar">
  <div class="evo-topbar-inner">
    <div class="evo-brand">
      <a href="/index.php" class="evo-brand-link"><?= htmlspecialchars((string)$siteName, ENT_QUOTES, 'UTF-8') ?></a>
<?php
  // Prefer "originals (remastered)" assets when present
  function pickOriginal(array $rels): ?string {
    foreach ($rels as $rel) {
      $fs = __DIR__ . '/../assets/images/originals/' . $rel;
      if (is_file($fs)) return '/themes/evolution/assets/images/originals/' . $rel;
    }
    return null;
  }
  $logoPath = pickOriginal(['images/Topics/nukeevolution.png','images/Topics/phpnuke.png','images/Evo-Themesde.png']);
?>
      <?php if ($logoPath): ?>
        <img class="nukece-logo" src="<?= htmlspecialchars($logoPath, ENT_QUOTES,'UTF-8') ?>" alt="logo">
      <?php endif; ?>
      <span class="evo-tag">Evolution</span>
    </div>

<?php $origNavStrip = pickOriginalAsset(['images/Downloads/lang_english/top.png','images/Downloads/lang_german/top.png']); if ($origNavStrip) echo "<style>.evo-nav{background-image:url('".htmlspecialchars($origNavStrip,ENT_QUOTES,'UTF-8')."');background-size:cover;background-position:center}</style>"; ?>
    <div class="evo-nav">
      <a href="/index.php">Home</a>
      <a href="/index.php?module=news">News</a>
      <a href="/index.php?module=forums"><?php $cfg = is_file(NUKECE_ROOT.'/config/config.php') ? (array)include NUKECE_ROOT.'/config/config.php' : []; echo (!isset($cfg['forums_enabled']) || $cfg['forums_enabled']) ? 'Forums' : 'Forums (off)'; ?></a>
      <a href="/index.php?module=account">Account</a>
    </div>
  </div>
</div>

<div class="evo-shell">
  <div class="evo-hero">
    <div class="evo-hero-inner">
      <div class="evo-hero-title"><?= htmlspecialchars((string)($title ?: 'Welcome'), ENT_QUOTES, 'UTF-8') ?></div>
      <div class="evo-hero-sub">Classic look. Modern core.</div>
    </div>
  </div>

  <div class="evo-layout">
    <main class="evo-main">
