<?php
  $isCollapsible = !empty($collapsible);
?>
<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

  // Prefer classic subSilver bar assets if present
  function pickOriginalBar(array $rels): ?string {
    foreach ($rels as $rel) {
      $fs = __DIR__ . '/../assets/images/originals/' . $rel;
      if (is_file($fs)) return '/themes/subSilver/assets/images/originals/' . $rel;
    }
    return null;
  }
  $bar = pickOriginalBar(['images/mainbar.gif','images/leftbar.gif','images/rightbar.gif']);
  $barStyle = $bar ? "background-image:url('".$bar."');background-repeat:repeat-x;background-position:center;" : "";
?>
<?php
/** @var string $titleHtml */
/** @var string $contentHtml */
?>
<section data-collapsible="<?= $isCollapsible ? '1' : '0' ?>" class="block">
  <h3
    <?php if ($isCollapsible): ?><button class="blk-toggle" type="button" aria-label="Toggle block" aria-expanded="true">▾</button><?php endif; ?> style="<?= htmlspecialchars($barStyle, ENT_QUOTES,'UTF-8') ?>"><?= $titleHtml ?></h3>
  <div class="content"><?= $contentHtml ?></div>
</section>
