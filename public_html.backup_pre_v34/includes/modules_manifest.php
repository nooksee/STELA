<?php
declare(strict_types=1);
/**
 * Module manifest: defines core vs optional modules.
 * Optional modules are DISABLED by default unless enabled in config.
 *
 * Enable optional modules by creating:
 *   public_html/config/ENABLED_OPTIONAL_MODULES.php
 * returning an array of module names (lowercase).
 */
return [
  'optional' => [
  'your_account',
  'weblinks',
  'stats',
  'projects',
  'polls',
  'newsletter',
  'members',
  'faq'
],
];
