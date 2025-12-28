<?php
declare(strict_types=1);

/**
 * nukeCE Module Policy
 *
 * Canonical module slugs are lowercase (e.g. "downloads", "admin_nukesecurity").
 *
 * This file is intentionally simple and version-controlled:
 * - Prevents "ghost modules" from being callable.
 * - Preserves PHP-Nuke spirit by mapping legacy names to canonical slugs.
 */
return [
    'enabled' => [
        'home',
        'news',
        'stories',
        'topics',
        'search',
        'users',
        'account',

        'reference',
        'links',
        'downloads',
        'forums',

        'admin_login',
        'admin_dashboard',
        'admin_settings',
        'admin_users',
        'admin_themes',
        'admin_blocks',
        'admin_content',
        'admin_moderation',
        'admin_maintenance',
        'admin_nukesecurity',
        'admin_reference',
        'admin_downloads',
        'admin_links',
        'admin_forums',
    ],

    'optional' => [
        'faq','top','statistics','surveys','recommend',
        'blog','journal','weblinks','encyclopedia',
        'mobile','avantgo','members','messages','privmsg',
        'credits','content','feedback','advertising','phpinfo',
        'punish','submitnews',
    ],

    // Legacy module-name aliases (historic PHP-Nuke names -> canonical slugs)
    'aliases' => [
        'your_account'      => 'account',
        'your account'      => 'account',
        'web_links'         => 'links',
        'weblinks'          => 'links',
        'encyclopedia'      => 'reference',
        'journal'           => 'blog',
        'avantgo'           => 'mobile',
        'private_messages'  => 'privmsg',
        'private messages'  => 'privmsg',
        'recommend_us'      => 'recommend',
        'recommend us'      => 'recommend',
        'stories_archive'   => 'stories',
        'stories archive'   => 'stories',
        'submit_news'       => 'submitnews',
        'submit news'       => 'submitnews',
        'members_list'      => 'members',
        'members list'      => 'members',
        'site_map'          => 'search',
        'content'           => 'reference',
    ],
];
