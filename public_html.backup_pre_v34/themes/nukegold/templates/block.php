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
<section data-collapsible="<?= $isCollapsible ? '1' : '0' ?>" class="ng-block">
  <?php if (!empty($title)): ?>
    <div class="ng-block-title">
    <?php if ($isCollapsible): ?><button class="blk-toggle" type="button" aria-label="Toggle block" aria-expanded="true">▾</button><?php endif; ?><?= htmlspecialchars((string)$title, ENT_QUOTES, 'UTF-8') ?></div>
  <?php endif; ?>
  <div class="ng-block-body"><?= $content ?></div>
</section>
