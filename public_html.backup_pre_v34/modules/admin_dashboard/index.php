<?php
/**
 * PHP-Nuke CE
 * nukeCE Admin Dashboard (Evolution-style grouped panels)
 */
require_once __DIR__ . '/../../mainfile.php';
require_once NUKECE_ROOT . '/includes/admin_ui.php';

AdminUi::requireAdmin();
include_once NUKECE_ROOT . '/includes/header.php';

AdminUi::header('Administration', [
    '/admin.php?op=logout' => 'Logout',
]);

$groups = [
  [
    'title' => 'Site',
    'subtitle' => 'Identity, configuration, and system posture',
    'tiles' => [
      ['href'=>'/admin.php?op=settings',   'label'=>'Settings',      'desc'=>'Site identity, modules, email, caching, security policy', 'icon'=>'settings'],
          ['href'=>'/admin.php?op=ai',         'label'=>'AI',            'desc'=>'Provider, features, logs, kill switch', 'icon'=>'ai'],
      ['href'=>'/admin.php?op=themes',     'label'=>'Themes',        'desc'=>'Theme inventory, health checks, previews', 'icon'=>'themes'],
      ['href'=>'/admin.php?op=blocks',     'label'=>'Blocks',        'desc'=>'Enable/disable, reorder, cache controls', 'icon'=>'blocks'],
    ],
  ],
  [
    'title' => 'Community',
    'subtitle' => 'People, permissions, and social trust',
    'tiles' => [
      ['href'=>'/admin.php?op=users',      'label'=>'Users & Roles', 'desc'=>'Accounts, roles, permissions', 'icon'=>'users'],
      ['href'=>'/admin.php?op=clubs',      'label'=>'Clubs',         'desc'=>'Sub-communities: membership + localized tools', 'icon'=>'clubs'],
          ['href'=>'/admin.php?op=moderation', 'label'=>'Moderation',    'desc'=>'Unified triage: forums, messages, reference queue', 'icon'=>'moderation'],
      ['href'=>'/admin.php?op=reference',  'label'=>'Reference',     'desc'=>'Knowledge base: proposals → canon', 'icon'=>'reference'],
          ['href'=>'/admin.php?op=security',   'label'=>'NukeSecurity',  'desc'=>'Threat logs, alerts, thresholds, export', 'icon'=>'security'],
    ],
  ],
  [
    'title' => 'Forums & Messaging',
    'subtitle' => 'Integration, routing safety, and communication',
    'tiles' => [
      ['href'=>'/admin.php?op=forums',     'label'=>'Forums Admin',  'desc'=>'Routing & safety, wrapper tools', 'icon'=>'forums'],
      ['href'=>'/admin.php?op=messages',   'label'=>'Messages',      'desc'=>'System messaging administration', 'icon'=>'users'],
    ],
  ],
  [
    'title' => 'Experience',
    'subtitle' => 'Mobile and presentation layers',
    'tiles' => [
      ['href'=>'/admin.php?op=mobile',     'label'=>'Mobile',        'desc'=>'Mobile module settings', 'icon'=>'mobile'],
    ],
  ],
];

foreach ($groups as $g) {
    AdminUi::groupStart($g['title'], $g['subtitle']);
    echo '<div class="nukece-admin-grid">';
    foreach ($g['tiles'] as $t) {
        AdminUi::tile($t['href'], $t['label'], $t['desc'], $t['icon']);
    }
    echo '</div>';
    AdminUi::groupEnd();
}

AdminUi::footer();
include_once NUKECE_ROOT . '/includes/footer.php';
