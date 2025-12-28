<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

use NukeCE\Forums\PrivateMessages\PrivateMessagesBridge;

$uid = 0;
$common = NUKECE_ROOT . '/forums/common.php';
if (is_file($common)) {
    try {
        ob_start();
        include $common;
        ob_end_clean();
        if (isset($userdata) && is_array($userdata) && isset($userdata['user_id'])) $uid = (int)$userdata['user_id'];
    } catch (\Throwable) { $uid = 0; }
}

echo "<div style='display:grid;gap:10px'>";

if (isset($cfg['messages_enabled']) && !$cfg['messages_enabled']) { echo "<div class='muted'>Messages disabled.</div></div>"; return; }
if (isset($cfg['forums_enabled']) && !$cfg['forums_enabled']) { echo "<div class='muted'>Forums disabled.</div></div>"; return; }


if ($uid <= 0) {
    echo "<div class='muted'>Log in to Forums to see messages.</div>";
    echo "<a class='btn2' href='/forums/login.php'>Forums Login</a>";
    echo "</div>";
    return;
}

$cfg = is_file(NUKECE_ROOT.'/config/config.php') ? (array)include NUKECE_ROOT.'/config/config.php' : [];
$prefix = (string)($cfg['forums_table_prefix'] ?? 'bb_');

$bridge = new PrivateMessagesBridge($prefix);
$un = $bridge->unreadCount($uid);
$unread = (int)($un['unread'] ?? 0);

echo "<div class='muted'>Unread: <b>{$unread}</b></div>";
echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
echo "<a class='btn2' href='/messages/inbox'>Open inbox</a>";
echo "<a class='btn2' href='/messages/compose'>Compose</a>";
echo "</div>";

$list = $bridge->inbox($uid, 5);
if (($list['ok'] ?? false) && !empty($list['rows'])) {
    echo "<div style='display:grid;gap:6px;margin-top:8px'>";
    foreach ($list['rows'] as $r) {
        $id = (int)($r['id'] ?? 0);
        $subj = htmlspecialchars((string)($r['subject'] ?? ''), ENT_QUOTES,'UTF-8');
        echo "<div><a href='/messages/view/{$id}'>{$subj}</a></div>";
    }
    echo "</div>";
}

echo "</div>";
