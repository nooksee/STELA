<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

/**
 * Sample configuration file for nukeCE. To configure your installation,
 * copy this file to config.php and customise the values below to
 * match your environment. You can also use install/install.php which
 * generates a config.php for you.
 */
return [
    // Feature toggles (safe disable)
    'forums_enabled' => true,
    'messages_enabled' => true,
    'editor_enabled' => false,
    'editor_messages_enabled' => false,
    'editor_forums_enabled' => false,
    'editor_news_enabled' => false,

    'admin_user' => 'admin',
    // Set admin_pass_hash to password_hash('yourpassword', PASSWORD_BCRYPT)
    'admin_pass_hash' => '',

    'data_dir' => NUKECE_ROOT . '/data',

    // Themes
    'theme_default' => 'nukegold',
    'theme_allow_user' => true,
    'theme_cookie_name' => 'nukece_theme',

    'db_host' => 'localhost',      // Database host
    'db_name' => 'nukece',         // Database name
    'db_user' => 'username',       // Database user
    'db_pass' => 'password',       // Database password
];
