<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

use NukeCE\Core\Theme;

/**
 * X-Halo theme header (clean-room homage).
 */
$siteName = Theme::config()['sitename'] ?? 'nukeCE';
<?php
  // Prefer "originals (remastered)" assets when present.
  function pickOriginalAsset(array $rels): ?string {
    foreach ($rels as $rel) {
      $fs = __DIR__ . '/../assets/images/originals/' . $rel;
      if (is_file($fs)) return '/themes/x-halo/assets/images/originals/' . $rel;
    }
    return null;
  }
  $origLogo = pickOriginalAsset(['resources/setup/html/themes/XHalo/images/logo.jpg','resources/setup/html/themes/XHalo/images/XHalo-hd1_logo.jpg','images/logo.jpg','images/XHalo-hd1_logo.jpg']);
  $origBg   = pickOriginalAsset(['resources/setup/html/themes/XHalo/images/topics/AllTopics.gif','images/bg.jpg','resources/setup/html/themes/XHalo/images/back.jpg']);
  $origBar  = pickOriginalAsset(['resources/setup/html/themes/XHalo/images/mainbar.gif','images/mainbar.gif','resources/setup/html/themes/XHalo/forums/images/event_block_bar.gif']);
  $cssVars = "";
  if ($origBg)  $cssVars .= "--orig-bg:url('".$origBg."');";
  if ($origBar) $cssVars .= "--orig-bar:url('".$origBar."');";
$navHome = pickOriginalAsset(['resources/menu/home.gif','resources/setup/html/themes/XHalo/images/menu/home.gif','images/menu/home.png','images/menu/home.gif']);
$navInfo = pickOriginalAsset(['resources/menu/info.gif','resources/setup/html/themes/XHalo/images/menu/info.gif','images/menu/info.png','images/menu/info.gif']);
$navThemes = pickOriginalAsset(['resources/menu/themes.gif','resources/setup/html/themes/XHalo/images/menu/themes.gif','images/menu/themes.png','images/menu/themes.gif']);
$navMsgs = pickOriginalAsset(['resources/menu/messages.gif','resources/setup/html/themes/XHalo/images/menu/messages.gif','images/menu/messages.png','images/menu/messages.gif']);
$cssVars .= $navHome ? "--orig-navicon-home:url('".$navHome."');" : "";
$cssVars .= $navInfo ? "--orig-navicon-info:url('".$navInfo."');" : "";
$cssVars .= $navThemes ? "--orig-navicon-themes:url('".$navThemes."');" : "";
$cssVars .= $navMsgs ? "--orig-navicon-messages:url('".$navMsgs."');" : "";
?>

?><!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title><?= htmlspecialchars(($title ? ($title . ' - ') : '') . $siteName, ENT_QUOTES, 'UTF-8') ?></title>
  <link rel="stylesheet" href="/themes/x-halo/assets/css/style.css">
</head>
<body style="<?= htmlspecialchars($cssVars, ENT_QUOTES, 'UTF-8') ?>">
<div class="xh-top">
  <div class="xh-top-inner">
    <div class="xh-brand">
      <a class="xh-brand-link" href="/index.php"><?= htmlspecialchars((string)$siteName, ENT_QUOTES, 'UTF-8') ?></a>
      <?php
        $logoPath = null;
        if (is_file(__DIR__ . '/../assets/images/originals/images/logo.jpg')) $logoPath = '/themes/x-halo/assets/images/originals/images/logo.jpg';
        if (is_file(__DIR__ . '/../assets/images/originals/images/XHalo-hd1_logo.jpg')) $logoPath = '/themes/x-halo/assets/images/originals/images/XHalo-hd1_logo.jpg';
      ?>
      <?php if ($logoPath): ?>
        <img class="nukece-logo" src="<?= htmlspecialchars($logoPath, ENT_QUOTES,'UTF-8') ?>" alt="logo">
      <?php endif; ?>

      <span class="xh-pill">X‑Halo</span>
    </div>
    <nav class="xh-nav">
      <a href="/index.php">Home</a>
      <a href="/index.php?module=news">News</a>
      <a href="/index.php?module=forums"><?php $cfg = is_file(NUKECE_ROOT.'/config/config.php') ? (array)include NUKECE_ROOT.'/config/config.php' : []; echo (!isset($cfg['forums_enabled']) || $cfg['forums_enabled']) ? 'Forums' : 'Forums (off)'; ?></a>
      <a href="/index.php?module=account">Account</a>
      <a class="xh-mobile" href="/index.php?module=mobile">Mobile</a>
    </nav>
<?php
  // Optional X-Halo ticker (Platinum-era homage) without changing the theme system.
  // Enable by creating: /data/xhalo_ticker.json  (or set Theme config key: xhalo_ticker_text)
  // JSON format: {"enabled": true, "text": "Welcome to PHP-Nuke CE — nukeCE under the hood."}
  $tickerText = '';
  $tickerEnabled = false;

  $rootPath = defined('NUKECE_ROOT') ? NUKECE_ROOT : dirname(__DIR__, 3);
  $tickerFile = rtrim($rootPath, '/\\') . '/data/xhalo_ticker.json';

  if (is_file($tickerFile)) {
    $raw = @file_get_contents($tickerFile);
    $j = $raw ? json_decode($raw, true) : null;
    if (is_array($j)) {
      $tickerEnabled = !empty($j['enabled']);
      $tickerText = (string)($j['text'] ?? '');
    }
  }

  $cfg = Theme::config();
  if (!$tickerText) {
    $tickerEnabled = (bool)Theme::feature('ticker_enabled', false, 'x-halo');
    $tickerText = (string)Theme::feature('ticker_text', '', 'x-halo');
  }
?>

  </div>
<?php if ($tickerEnabled && $tickerText !== ''): ?>
  <div class="xh-ticker" role="status" aria-label="Site ticker">
    <div class="xh-ticker-track">
      <div class="xh-ticker-item"><?= htmlspecialchars($tickerText, ENT_QUOTES, 'UTF-8') ?></div>
      <div class="xh-ticker-item" aria-hidden="true"><?= htmlspecialchars($tickerText, ENT_QUOTES, 'UTF-8') ?></div>
    </div>
  </div>
<?php endif; ?>

<div class="xh-shell">
  <div class="xh-banner">
    <div class="xh-banner-inner">
      <div class="xh-title"><?= htmlspecialchars((string)($title ?: 'Welcome'), ENT_QUOTES, 'UTF-8') ?></div>
      <div class="xh-sub">Dark, crisp, and fast — classic vibe with a modern core.</div>
    </div>
  </div>

  <div class="xh-layout">
    <main class="xh-main">
