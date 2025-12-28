<?php
  $isCollapsible = !empty($collapsible);
?>
<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

/**
 * Block template
 * Variables expected:
 * - $title (string)
 * - $content (string HTML)
 */
?>
<?php
  function pickOriginalBar(array $rels): ?string {
    foreach ($rels as $rel) {
      $fs = __DIR__ . '/../assets/images/originals/' . $rel;
      if (is_file($fs)) return '/themes/evolution/assets/images/originals/' . $rel;
    }
    return null;
  }
  // Evo packs often include top/header strips; use if present.
  $bar = pickOriginalBar(['images/Downloads/lang_english/top.png','images/Downloads/lang_german/top.png']);
  $barStyle = $bar ? "background-image:url('".$bar."');background-size:cover;background-position:center;" : "";
?>

<section data-collapsible="<?= $isCollapsible ? '1' : '0' ?>" class="evo-block">
  <?php if (!empty($title)): ?>
    <div class="evo-block-title"
    <?php if ($isCollapsible): ?><button class="blk-toggle" type="button" aria-label="Toggle block" aria-expanded="true">▾</button><?php endif; ?> style="<?= htmlspecialchars($barStyle, ENT_QUOTES,'UTF-8') ?>"><?= htmlspecialchars((string)$title, ENT_QUOTES, 'UTF-8') ?></div>
  <?php endif; ?>
  <div class="evo-block-body"><?= $content ?></div>
</section>
