<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Messages;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Layout;
use NukeCE\Core\Maintenance;
use NukeCE\Forums\PrivateMessages\PrivateMessagesBridge;
use NukeCE\Security\NukeSecurity;
use NukeCE\Security\NukeSecurityConfig;
use NukeCE\Security\AuthGate;
use NukeCE\Security\Csrf;
use NukeCE\Core\AppConfig;
use NukeCE\Editor\EditorService;

final class MessagesModule implements ModuleInterface
{
    private array $cfg;

    public function __construct()
    {
        $cfgFile = dirname(__DIR__, 2) . '/config/config.php';
        $this->cfg = is_file($cfgFile) ? (array)include $cfgFile : [];
    }

    public function getName(): string { return 'messages'; }

    public function handle(array $params): void
    {
        if (!AppConfig::getBool('messages_enabled', true)) {
            Layout::page('Messages', function () {
                echo "<h1>Messages</h1><div class='card' style='padding:14px'><b>Messages are disabled.</b></div>";
            }, ['module'=>'messages']);
            return;
        }
        if (!AppConfig::getBool('forums_enabled', true) || !is_dir(dirname(__DIR__, 2) . '/forums')) {
    Layout::page('Messages', function () {
        echo "<h1>Messages</h1>";
        echo "<div class='card' style='padding:14px'>";
        echo "<b>Forums are disabled.</b>";
        echo "<div class='muted' style='margin-top:6px'>Messages rely on the Forums engine.</div>";
        echo "</div>";
    }, ['module'=>'messages']);
    return;
}


        $action = (string)($params['action'] ?? ($_GET['action'] ?? 'inbox'));
        $segments = is_array($params['segments'] ?? null) ? $params['segments'] : [];
        $action = $action ?: 'inbox';

        if ($action === 'audit') {
            // Maintenance: disable posting actions
        if (Maintenance::readOnlyPosting() && in_array($action, ['compose','reply','delete'], true)) {
            Layout::page('Messages', function () {
                echo "<h1>Messages</h1><div class='card' style='padding:14px'><b>Maintenance mode</b><p>Posting is temporarily disabled.</p></div>";
            }, ['module'=>'messages']);
            return;
        }

        $pmId = (int)($segments[1] ?? ($_GET['id'] ?? 0));
            $this->audit($pmId);
            return;
        }

        $userId = $this->detectPhpbbUserId();
        if ($userId <= 0) {
            Layout::page('Messages', function () {
                echo "<h1>Messages</h1>";
                echo "<div class='card' style='padding:14px'>";
                echo "<p><b>You’re not logged in to Forums.</b></p>";
                echo "<p>Messages are backed by your Forums account. Please <a class='btn2' href='/forums/login.php'>log in via Forums</a> and return.</p>";
                echo "</div>";
            }, ['module'=>'messages']);
            return;
        }

        // Maintenance: disable posting actions
        if (Maintenance::readOnlyPosting() && in_array($action, ['compose','reply','delete'], true)) {
            Layout::page('Messages', function () {
                echo "<h1>Messages</h1><div class='card' style='padding:14px'><b>Maintenance mode</b><p>Posting is temporarily disabled.</p></div>";
            }, ['module'=>'messages']);
            return;
        }

        $pmId = (int)($segments[1] ?? ($_GET['id'] ?? 0));
        if ($action === 'view' && $pmId > 0) { $this->view($userId, $pmId); return; }
        if ($action === 'compose') { $this->compose(); return; }
        if ($action === 'send') { $this->send(); return; }
        if ($action === 'reply') { // Maintenance: disable posting actions
        if (Maintenance::readOnlyPosting() && in_array($action, ['compose','reply','delete'], true)) {
            Layout::page('Messages', function () {
                echo "<h1>Messages</h1><div class='card' style='padding:14px'><b>Maintenance mode</b><p>Posting is temporarily disabled.</p></div>";
            }, ['module'=>'messages']);
            return;
        }

        $pmId = (int)($segments[1] ?? ($_GET['id'] ?? 0)); $this->reply($pmId); return; }
        if ($action === 'delete') { // Maintenance: disable posting actions
        if (Maintenance::readOnlyPosting() && in_array($action, ['compose','reply','delete'], true)) {
            Layout::page('Messages', function () {
                echo "<h1>Messages</h1><div class='card' style='padding:14px'><b>Maintenance mode</b><p>Posting is temporarily disabled.</p></div>";
            }, ['module'=>'messages']);
            return;
        }

        $pmId = (int)($segments[1] ?? ($_GET['id'] ?? 0)); $this->delete($pmId); return; }
        if ($action === 'markread') { // Maintenance: disable posting actions
        if (Maintenance::readOnlyPosting() && in_array($action, ['compose','reply','delete'], true)) {
            Layout::page('Messages', function () {
                echo "<h1>Messages</h1><div class='card' style='padding:14px'><b>Maintenance mode</b><p>Posting is temporarily disabled.</p></div>";
            }, ['module'=>'messages']);
            return;
        }

        $pmId = (int)($segments[1] ?? ($_GET['id'] ?? 0)); $this->markRead($pmId, true); return; }
        if ($action === 'markunread') { // Maintenance: disable posting actions
        if (Maintenance::readOnlyPosting() && in_array($action, ['compose','reply','delete'], true)) {
            Layout::page('Messages', function () {
                echo "<h1>Messages</h1><div class='card' style='padding:14px'><b>Maintenance mode</b><p>Posting is temporarily disabled.</p></div>";
            }, ['module'=>'messages']);
            return;
        }

        $pmId = (int)($segments[1] ?? ($_GET['id'] ?? 0)); $this->markRead($pmId, false); return; }

        $this->inbox($userId);
    }

    private function inbox(int $userId): void
    {
        $prefix = (string)($this->cfg['forums_table_prefix'] ?? 'bb_');
        $bridge = new PrivateMessagesBridge($prefix);
        $list = $bridge->inbox($userId, 40);
        $un = $bridge->unreadCount($userId);
        $unread = (int)($un['unread'] ?? 0);

        Layout::page('Messages', function () use ($list, $unread) {
            echo "<div style='display:flex;justify-content:space-between;gap:12px;align-items:center;flex-wrap:wrap'>";
            echo "<h1>Messages</h1>";
            echo "<div style='display:flex;gap:10px;align-items:center'>";
            echo "<a class='btn2' href='/messages/inbox'>Inbox</a>";
            echo "<a class='btn2' href='/messages/compose'>Compose</a>";
            echo "</div></div>";
            echo "<div class='muted' style='margin:6px 0 14px'>Unread: <b>".(int)$unread."</b></div>";

            if (!$list['ok']) {
                echo "<div class='err'>Unable to read inbox: ".htmlspecialchars((string)($list['reason'] ?? 'unknown'), ENT_QUOTES,'UTF-8')."</div>";
                echo "<p class='muted'>Fallback: <a href='/index.php?module=forums&file=privmsg.php'>Forums PMs</a>.</p>";
                return;
            }

            $rows = $list['rows'] ?? [];
            if (!$rows) { echo "<div class='card' style='padding:14px'>No messages.</div>"; return; }

            echo "<div class='card' style='padding:0;overflow:hidden'>";
            echo "<table style='width:100%;border-collapse:collapse'>";
            echo "<thead><tr style='background:#f6f7fa'><th style='text-align:left;padding:10px'>From</th><th style='text-align:left;padding:10px'>Subject</th><th style='text-align:left;padding:10px'>Date</th></tr></thead><tbody>";
            foreach ($rows as $r) {
                $id = (int)($r['id'] ?? 0);
                $from = htmlspecialchars((string)($r['from_username'] ?? ('User #' . (int)($r['from_user'] ?? 0))), ENT_QUOTES,'UTF-8');
                $subj = htmlspecialchars((string)($r['subject'] ?? ''), ENT_QUOTES,'UTF-8');
                $ts = (int)($r['ts'] ?? 0);
                $date = $ts ? date('Y-m-d H:i', $ts) : '';
                $isUnread = !empty($r['is_unread']);
                $style = $isUnread ? "font-weight:900" : "font-weight:700";
                echo "<tr>";
                echo "<td style='padding:10px;border-top:1px solid #eee'>{$from}</td>";
                echo "<td style='padding:10px;border-top:1px solid #eee;{$style}'><a href='/messages/view/{$id}'>".$subj."</a></td>";
                echo "<td style='padding:10px;border-top:1px solid #eee'>".htmlspecialchars($date,ENT_QUOTES,'UTF-8')."</td>";
                echo "</tr>";
            }
            echo "</tbody></table></div>";
        }, ['module'=>'messages']);
    }

    private function view(int $userId, int $pmId): void
    {
        $prefix = (string)($this->cfg['forums_table_prefix'] ?? 'bb_');
        $bridge = new PrivateMessagesBridge($prefix);
        $msg = $bridge->getInboxMessage($userId, $pmId);

        Layout::page('Message', function () use ($msg) {
            echo "<div style='display:flex;justify-content:space-between;gap:12px;align-items:center;flex-wrap:wrap'>";
            echo "<h1>Message</h1>";
            echo "<div><a class='btn2' href='/messages/inbox'>Back</a></div>";
            echo "</div>";

            if (!$msg['ok']) { echo "<div class='err'>".htmlspecialchars((string)($msg['reason'] ?? 'Not found'), ENT_QUOTES,'UTF-8')."</div>"; return; }

            $r = $msg['row'] ?? [];
            $from = htmlspecialchars((string)($r['from_username'] ?? ('User #' . (int)($r['from_user'] ?? 0))), ENT_QUOTES,'UTF-8');
            $subj = htmlspecialchars((string)($r['subject'] ?? ''), ENT_QUOTES,'UTF-8');
            $body = (string)($r['body'] ?? '');
            $ts = (int)($r['ts'] ?? 0);
            $date = $ts ? date('Y-m-d H:i', $ts) : '';

            echo "<div class='card' style='padding:14px;display:grid;gap:10px'>";
            echo "<div class='muted'>From: <b>{$from}</b> • {$date}</div>";
            echo "<div style='font-size:18px;font-weight:900'>{$subj}</div>";
            if ($body !== '') echo "<div style='line-height:1.5'>".nl2br(htmlspecialchars($body, ENT_QUOTES,'UTF-8'))."</div>";
            else echo "<div class='muted'>Body not available via this schema. Use Forums PM view if needed.</div>";
            echo "<div style='display:flex;gap:10px;flex-wrap:wrap;margin-top:10px'>";
echo "<a class='btn2' href='/messages/reply/{$pmId}'>Reply</a>";
echo "<a class='btn2' href='/messages/markread/{$pmId}'>Mark read</a>";
echo "<a class='btn2' href='/messages/markunread/{$pmId}'>Mark unread</a>";
$csrf = \NukeCE\Security\Csrf::token();
echo "<form method='post' action='/messages/delete/{$pmId}' style='display:inline;margin:0'>";
echo "<input type='hidden' name='_csrf' value='".htmlspecialchars($csrf, ENT_QUOTES, 'UTF-8')."'>";
echo "<button class='btn2' type='submit' onclick=\"return confirm('Delete this message?')\">Delete</button>";
echo "</form>";
echo "<a class='btn2' href='/messages/compose'>Compose</a>";
echo "<a class='btn2' href='/index.php?module=forums&file=privmsg.php&folder=inbox'>Legacy view</a>";
echo "</div></div>";
        }, ['module'=>'messages']);
    }

    private function compose(): void
{
    $csrf = Csrf::token();
    Layout::page('Compose', function () use ($csrf) {
        echo "<h1>Compose</h1>";
        echo "<div class='card' style='padding:14px;display:grid;gap:12px;max-width:780px'>";
        echo "<form method='post' action='/messages/send' style='display:grid;gap:12px'>";
        echo "<input type='hidden' name='_csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
        echo "<label>To (username)<input type='text' name='to' required></label>";
        echo "<label>Subject<input type='text' name='subject' required></label>";
        echo "<label>Message</label>";
            EditorService::render('body', '', ['scope'=>'messages','rows'=>8]);
        echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
        echo "<button class='btn' type='submit'>Send</button>";
        echo "<a class='btn2' href='/messages/inbox'>Cancel</a>";
        echo "</div>";
        echo "</form>";
        echo "<div class='muted'>Powered by the Forums PM engine — delivered through a native nukeCE interface.</div>";
        echo "</div>";
    }, ['module'=>'messages']);
}

    private function send(): void
{
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        header("Location: /messages/compose");
        exit;
    }
    if (!Csrf::validate($_POST['_csrf'] ?? null)) {
        Layout::page('Compose', function () {
            echo "<h1>Compose</h1><div class='err'>Invalid CSRF token.</div><p><a class='btn2' href='/messages/compose'>Back</a></p>";
        }, ['module'=>'messages']);
        return;
    }

    $to = trim((string)($_POST['to'] ?? ''));
    $subject = trim((string)($_POST['subject'] ?? ''));
    $body = (string)($_POST['body'] ?? '');

    if ($to === '' || $subject === '' || trim($body) === '') {
        Layout::page('Compose', function () {
            echo "<h1>Compose</h1><div class='err'>All fields are required.</div><p><a class='btn2' href='/messages/compose'>Back</a></p>";
        }, ['module'=>'messages']);
        return;
    }

    // Must be logged into forums
    $userId = $this->detectPhpbbUserId();
    if ($userId <= 0) {
        header("Location: /forums/login.php");
        exit;
    }

    // Attempt native send via phpBB2 functions (best-effort). Fallback to legacy composer if unavailable.
    $sent = false;
    $error = '';

    try {
        $root = dirname(__DIR__, 2);
        $phpbb = $root . '/forums';
        $common = $phpbb . '/common.php';
        if (!is_file($common)) {
            throw new \RuntimeException("Forums common.php missing");
        }

        // Load phpBB context
        ob_start();
        include $common;
        ob_end_clean();

        // Resolve recipient user_id
        $toUserId = 0;
        if (isset($db) && is_object($db)) {
            $uTable = $this->cfg['forums_table_prefix'] ?? 'bb_';
            $uTable .= 'users';
            $safeTo = str_replace("'", "''", $to);
            $sql = "SELECT user_id FROM $uTable WHERE username = '$safeTo' LIMIT 1";
            $res = $db->sql_query($sql);
            if ($res) {
                $row = $db->sql_fetchrow($res);
                if (is_array($row) && isset($row['user_id'])) $toUserId = (int)$row['user_id'];
            }
        }
        if ($toUserId <= 0) {
            throw new \RuntimeException("Recipient not found");
        }

        $fn = $phpbb . '/includes/functions_privmsgs.php';
        if (!is_file($fn)) {
            throw new \RuntimeException("phpBB PM functions missing");
        }
        include_once $fn;

        if (!function_exists('submit_pm')) {
            throw new \RuntimeException("submit_pm() not available");
        }

        // Submit PM (phpBB2 style). Many phpBB2 mods keep this signature.
        // submit_pm($mode, $subject, $message, $to_userdata, $from_userdata, $html_on, $bbcode_on, $smilies_on, $sig_on);
        $to_userdata = ['user_id' => $toUserId];
        $from_userdata = isset($userdata) && is_array($userdata) ? $userdata : ['user_id' => $userId];

        $html_on = 0; $bbcode_on = 1; $smilies_on = 1; $sig_on = 1;

        @submit_pm('post', $subject, $body, $to_userdata, $from_userdata, $html_on, $bbcode_on, $smilies_on, $sig_on);

        $sent = true;
    } catch (\Throwable $e) {
        $error = $e->getMessage();
        $sent = false;
    }

    if ($sent) {
        NukeSecurity::logEvent('messages.send', ['to'=>$to, 'subject'=>$subject]);
        Layout::page('Message Sent', function () {
            echo "<h1>Message Sent</h1><div class='ok'>Your message was sent.</div><p><a class='btn2' href='/messages/inbox'>Back to inbox</a></p>";
        }, ['module'=>'messages']);
        return;
    }

    // Fallback: open legacy composer with prefill (still wrapped)
    $q = http_build_query(['mode'=>'post', 'username'=>$to, 'subject'=>$subject]);
    Layout::page('Compose', function () use ($error, $q) {
        echo "<h1>Compose</h1>";
        echo "<div class='err'>Native send unavailable on this phpBB PM build: " . htmlspecialchars($error, ENT_QUOTES,'UTF-8') . "</div>";
        echo "<p><a class='btn' href='/index.php?module=forums&file=privmsg.php&{$q}'>Use Forums composer</a></p>";
    }, ['module'=>'messages']);
}

private function reply(int $pmId): void
{
    $userId = $this->detectPhpbbUserId();
    if ($userId <= 0) { header("Location: /forums/login.php"); exit; }

    $prefix = (string)($this->cfg['forums_table_prefix'] ?? 'bb_');
    $bridge = new PrivateMessagesBridge($prefix);
    $msg = $bridge->getInboxMessage($userId, $pmId);

    if (!($msg['ok'] ?? false)) {
        Layout::page('Reply', function () {
            echo "<h1>Reply</h1><div class='err'>Message not found.</div><p><a class='btn2' href='/messages/inbox'>Back</a></p>";
        }, ['module'=>'messages']);
        return;
    }

    $r = $msg['row'] ?? [];
    $toUser = (string)($r['from_username'] ?? '');
    if ($toUser === '') {
        $toUser = 'User #' . (int)($r['from_user'] ?? 0);
    }
    $subj = (string)($r['subject'] ?? '');
    if (stripos($subj, 're:') !== 0) $subj = 'Re: ' . $subj;

    $origBody = (string)($r['body'] ?? '');
    $quote = $origBody !== '' ? ("\n\n----\n" . $origBody) : '';
    $csrf = Csrf::token();

    Layout::page('Reply', function () use ($csrf, $toUser, $subj, $quote, $pmId) {
        echo "<h1>Reply</h1>";
        echo "<div class='card' style='padding:14px;display:grid;gap:12px;max-width:780px'>";
        echo "<form method='post' action='/messages/send' style='display:grid;gap:12px'>";
        echo "<input type='hidden' name='_csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
        echo "<input type='hidden' name='reply_to' value='".(int)$pmId."'>";
        echo "<label>To (username)<input type='text' name='to' required value='".htmlspecialchars($toUser,ENT_QUOTES,'UTF-8')."'></label>";
        echo "<label>Subject<input type='text' name='subject' required value='".htmlspecialchars($subj,ENT_QUOTES,'UTF-8')."'></label>";
        echo "<label>Message</label>";
            EditorService::render('body', $quote, ['scope'=>'messages','rows'=>10]);
        echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
        echo "<button class='btn' type='submit'>Send reply</button>";
        echo "<a class='btn2' href='/messages/view/".(int)$pmId."'>Cancel</a>";
        echo "</div>";
        echo "</form>";
        echo "</div>";
    }, ['module'=>'messages']);
}

private function markRead(int $pmId, bool $read): void
{
    $userId = $this->detectPhpbbUserId();
    if ($userId <= 0) { header("Location: /forums/login.php"); exit; }
    if ($pmId <= 0) { header("Location: /messages/inbox"); exit; }

    $prefix = (string)($this->cfg['forums_table_prefix'] ?? 'bb_');
    $bridge = new PrivateMessagesBridge($prefix);
    $bridge->setReadState($userId, $pmId, !$read);
    header("Location: /messages/view/" . (int)$pmId);
    exit;
}

private function delete(int $pmId): void
{
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') { header("Location: /messages/view/" . (int)$pmId); exit; }
    if (!Csrf::validate($_POST['_csrf'] ?? null)) {
        Layout::page('Delete', function () {
            echo "<h1>Delete</h1><div class='err'>Invalid CSRF token.</div><p><a class='btn2' href='/messages/inbox'>Back</a></p>";
        }, ['module'=>'messages']);
        return;
    }

    $userId = $this->detectPhpbbUserId();
    if ($userId <= 0) { header("Location: /forums/login.php"); exit; }
    if ($pmId <= 0) { header("Location: /messages/inbox"); exit; }

    $prefix = (string)($this->cfg['forums_table_prefix'] ?? 'bb_');
    $bridge = new PrivateMessagesBridge($prefix);
    $bridge->deleteForUser($userId, $pmId);

    NukeSecurity::logEvent('messages.delete', ['pm_id'=>$pmId]);
    header("Location: /messages/inbox");
    exit;
}


private function audit(int $pmId): void
{
    $cfg = NukeSecurityConfig::load(dirname(__DIR__, 2));
    $mode = (string)($cfg['messages']['audit_mode'] ?? 'private'); // private|audit|hybrid

    Layout::page('Messages Audit', function () use ($pmId, $mode) {
        echo "<h1>Messages Audit</h1>";
        echo "<div class='card' style='padding:14px;display:grid;gap:10px;max-width:920px'>";
        echo "<div class='muted'>Mode: <b>".htmlspecialchars($mode,ENT_QUOTES,'UTF-8')."</b></div>";

        if ($mode === 'private') { echo "<div class='err'>Audit is disabled (private mode).</div></div>"; return; }
        if ($pmId <= 0) { echo "<div class='muted'>Use <code>/messages/audit/&lt;id&gt;</code></div></div>"; return; }

        $reason = (string)($_GET['reason'] ?? '');
        if ($reason === '') { echo "<div class='err'><b>Reason required.</b> Append <code>?reason=REQUIRED</code>.</div></div>"; return; }

        $unlock = (bool)($_GET['unlock'] ?? false);
        $canView = ($mode === 'audit') || ($mode === 'hybrid' && $unlock);

        if ($mode === 'hybrid' && !$unlock) {
            echo "<div class='muted'>Hybrid: metadata is visible by default. Content requires an explicit unlock (logged).</div>";
            echo "<form method='get' action='/messages/audit/".(int)$pmId."' style='display:flex;gap:10px;flex-wrap:wrap;align-items:center'>";
            echo "<input type='hidden' name='reason' value='".htmlspecialchars($reason,ENT_QUOTES,'UTF-8')."'>";
            echo "<input type='hidden' name='unlock' value='1'>";
            echo "<button class='btn2' type='submit' onclick=\"return confirm('Unlock and view message content? This will be logged.')\">Unlock content</button>";
            echo "</form>";
        }

        \NukeCE\Security\NukeSecurity::logEvent('messages.audit.access', [
            'pm_id' => $pmId, 'reason' => $reason, 'mode' => $mode, 'unlock' => $canView ? 1 : 0,
        ]);

        $cfgFile = dirname(__DIR__, 2) . '/config/config.php';
        $appCfg = is_file($cfgFile) ? (array)include $cfgFile : [];
        $prefix = (string)($appCfg['forums_table_prefix'] ?? 'bb_');
        $bridge = new \NukeCE\Forums\PrivateMessages\PrivateMessagesBridge($prefix);
        $res = $bridge->getAnyMessage($pmId);

        if (!($res['ok'] ?? false)) {
            echo "<div class='err'>Unable to load message: ".htmlspecialchars((string)($res['reason'] ?? 'unknown'), ENT_QUOTES,'UTF-8')."</div></div>";
            return;
        }

        $r = $res['row'] ?? [];
        $from = htmlspecialchars((string)($r['from_username'] ?? ('User #' . (int)($r['from_user'] ?? 0))), ENT_QUOTES,'UTF-8');
        $subj = htmlspecialchars((string)($r['subject'] ?? ''), ENT_QUOTES,'UTF-8');
        $ts = (int)($r['ts'] ?? 0);
        $date = $ts ? date('Y-m-d H:i', $ts) : '';
        $recips = $r['recipients'] ?? [];
        $recipsStr = $recips ? htmlspecialchars(implode(', ', array_filter($recips)), ENT_QUOTES,'UTF-8') : '(unknown)';

        echo "<div><b>From:</b> {$from}</div>";
        echo "<div><b>To:</b> {$recipsStr}</div>";
        echo "<div><b>Date:</b> ".htmlspecialchars($date,ENT_QUOTES,'UTF-8')."</div>";
        echo "<div style='font-size:18px;font-weight:900'>{$subj}</div>";

        if ($canView) {
            \NukeCE\Security\NukeSecurity::logEvent('messages.audit.read', ['pm_id'=>$pmId,'reason'=>$reason,'mode'=>$mode]);
            $body = (string)($r['body'] ?? '');
            if ($body !== '') echo "<div style='margin-top:10px;line-height:1.5'>".nl2br(htmlspecialchars($body,ENT_QUOTES,'UTF-8'))."</div>";
            else echo "<div class='muted'>Body not available via this schema.</div>";
        } else {
            echo "<div class='muted'>Content hidden (hybrid mode). Unlock to view.</div>";
        }

        echo "</div>";
    }, ['module'=>'messages']);
}

    private function detectPhpbbUserId(): int
    {
        $common = dirname(__DIR__, 2) . '/forums/common.php';
        if (!is_file($common)) return 0;
        $uid = 0;
        try {
            ob_start();
            include $common;
            ob_end_clean();
            if (isset($userdata) && is_array($userdata) && isset($userdata['user_id'])) $uid = (int)$userdata['user_id'];
        } catch (\Throwable) { return 0; }
        return $uid > 0 ? $uid : 0;
    }
}
