<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 *
 * NOTE: This file is generated/shipped for Docker/local dev convenience.
 * You may edit it directly, or run /install/install.php to regenerate.
 */

return [
    // Feature toggles (safe disable)
    'forums_enabled' => true,
    'messages_enabled' => true,
    'editor_enabled' => true,

    'admin_user' => getenv('NUKECE_ADMIN_USER') ?: 'admin',
    // Set NUKECE_ADMIN_PASS_HASH to password_hash('yourpassword', PASSWORD_BCRYPT)
    'admin_pass_hash' => getenv('NUKECE_ADMIN_PASS_HASH') ?: '',

    'data_dir' => NUKECE_ROOT . '/data',

    // Themes
    'theme_default' => getenv('NUKECE_THEME_DEFAULT') ?: 'nukegold',
    'theme_allow_user' => true,
    'theme_cookie_name' => 'nukece_theme',

    // Database (Docker defaults)
    'db_host' => getenv('NUKECE_DB_HOST') ?: 'db',
    'db_name' => getenv('NUKECE_DB_NAME') ?: 'nukece',
    'db_user' => getenv('NUKECE_DB_USER') ?: 'nukece',
    'db_pass' => getenv('NUKECE_DB_PASS') ?: 'nukece',
];
