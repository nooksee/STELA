<?php
/**
 * User Info / Login Block (nukeCE Gold)
 */

declare(strict_types=1);

if (!defined('BLOCK_FILE')) {
    exit;
}

require_once __DIR__ . '/../includes/BlockGold.php';

global $userinfo;

$isLoggedIn = is_array($userinfo) && !empty($userinfo['username']);

if ($isLoggedIn) {
    $u = BlockGold::esc((string) $userinfo['username']);
    $content = '<div class="nukece-userinfo">'
        . '<div class="nukece-userinfo__hello">Hello, <strong>' . $u . '</strong></div>'
        . '<ul class="nukece-block-list">'
        . '<li><a href="' . BlockGold::esc(BlockGold::url('modules.php?name=Your_Account')) . '">My Account</a></li>'
        . '<li><a href="' . BlockGold::esc(BlockGold::url('modules.php?name=Messages')) . '">Messages</a></li>'
        . '<li><a href="' . BlockGold::esc(BlockGold::url('modules.php?name=Forums')) . '">Forums</a></li>'
        . '<li><a href="' . BlockGold::esc(BlockGold::url('modules.php?name=Your_Account&op=logout')) . '">Logout</a></li>'
        . '</ul>'
        . '</div>';
} else {
    // Classic login post endpoint
    $action = 'modules.php?name=Your_Account';
    $content = '<form class="nukece-login" action="' . BlockGold::esc(BlockGold::url($action)) . '" method="post">'
        . '<div class="nukece-form-row"><label>Username</label><input class="nukece-input" type="text" name="username" autocomplete="username" /></div>'
        . '<div class="nukece-form-row"><label>Password</label><input class="nukece-input" type="password" name="user_password" autocomplete="current-password" /></div>'
        . '<div class="nukece-form-actions"><input class="nukece-btn" type="submit" value="Login" /></div>'
        . '<div class="nukece-form-meta"><a href="' . BlockGold::esc(BlockGold::url('modules.php?name=Your_Account&op=new_user')) . '">Create account</a></div>'
        . '</form>';
}
