<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

use NukeCE\Core\Theme;

/** @var string $title */
$siteName = Theme::config()['sitename'] ?? 'nukeCE';

function pickOriginalAsset(array $rels): ?string {
  foreach ($rels as $rel) {
    $fs = __DIR__ . '/../assets/images/originals/' . $rel;
    if (is_file($fs)) return '/themes/nukegold/assets/images/originals/' . $rel;
  }
  return null;
}

$origLogo = pickOriginalAsset(['images/nukece.png','images/88button.jpg']);
$origBg   = pickOriginalAsset(['images/bg.jpg','images/block_bg.jpg']);
$origBar  = pickOriginalAsset(['images/mainbar.gif','images/leftbar.gif','images/rightbar.gif']);
$origNavStrip = pickOriginalAsset(['images/mainbar.gif','images/leftbar.gif','images/rightbar.gif']);

$cssVars = "";
if ($origBg)  $cssVars .= "--orig-bg:url('".$origBg."');";
if ($origBar) $cssVars .= "--orig-bar:url('".$origBar."');";
if ($origNavStrip) $cssVars .= "--orig-navstrip:url('".$origNavStrip."');";

?><!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title><?= htmlspecialchars(($title ? ($title.' - ') : '') . (string)$siteName, ENT_QUOTES, 'UTF-8') ?></title>
  <link rel="stylesheet" href="/themes/nukegold/assets/css/style.css">
</head>
<body style="<?= htmlspecialchars($cssVars, ENT_QUOTES, 'UTF-8') ?>">
<div class="ng-topbar">
  <div class="ng-topbar-inner">
    <div class="ng-brand">
      <a class="ng-brand-link" href="/index.php"><?= htmlspecialchars((string)$siteName, ENT_QUOTES, 'UTF-8') ?></a>
      <?php if ($origLogo): ?><img class="nukece-logo" src="<?= htmlspecialchars($origLogo, ENT_QUOTES,'UTF-8') ?>" alt="logo"><?php endif; ?>
      <span class="ng-pill">NukeGold</span>
    </div>
    <nav class="ng-nav">
      <a href="/index.php">Home</a>
      <a href="/index.php?module=news">News</a>
      <a href="/index.php?module=forums"><?php $cfg = is_file(NUKECE_ROOT.'/config/config.php') ? (array)include NUKECE_ROOT.'/config/config.php' : []; echo (!isset($cfg['forums_enabled']) || $cfg['forums_enabled']) ? 'Forums' : 'Forums (off)'; ?></a>
      <a href="/index.php?module=account">Account</a>
      <a href="/index.php?module=mobile" class="ng-mobile">Mobile</a>
    <?php $cfg = is_file(NUKECE_ROOT.'/config/config.php') ? (array)include NUKECE_ROOT.'/config/config.php' : []; if (!isset($cfg['messages_enabled']) || $cfg['messages_enabled']) { ?>
  <a href="/messages/inbox">Messages</a>
<?php } ?>
</nav>
  </div>
</div>

<div class="ng-shell">
  <div class="ng-layout">
    <main class="ng-main">
