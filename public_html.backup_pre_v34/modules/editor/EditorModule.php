<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\Editor;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Layout;
use NukeCE\Security\AuthGate;
use NukeCE\Security\Csrf;

final class EditorModule implements ModuleInterface
{
    public function getName(): string { return 'admin_editor'; }

    public function handle(array $params): void
    {
        AuthGate::requireAdminOrRedirect();

        $root = dirname(__DIR__, 2);
        $cfgFile = $root . '/config/config.php';
        $cfg = is_file($cfgFile) ? (array)include $cfgFile : [];
        $action = (string)($_POST['action'] ?? ($_GET['action'] ?? 'view'));

// AI JSON endpoints (optional)
if ($action === 'ai_summarize' || $action === 'ai_grammar') {
    header('Content-Type: application/json; charset=utf-8');
    $text = (string)($_POST['text'] ?? '');
    $actor = AuthGate::currentUsername() ?: 'user';
    $feature = ($action === 'ai_summarize') ? 'editor_summarize' : 'editor_grammar';
    $system = ($action === 'ai_summarize')
        ? "Summarize the user's text clearly and briefly. Keep intent. No invention."
        : "Suggest grammar and clarity improvements. Return improved text only. No invention.";
    $res = \NukeCE\AI\AiService::run($feature, $system, $text, [
        'actor' => $actor,
        'source_module' => 'editor',
        'source_id' => 'assist',
    ]);
    echo json_encode(['ok'=>$res['ok'],'text'=>$res['text'],'meta'=>$res['meta']], JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES);
    return;
}

        $msg = '';
        if ($action === 'save') {
            if (!Csrf::validate($_POST['_csrf'] ?? null)) {
                $msg = 'Invalid CSRF token.';
            } else {
                $cfg['editor_enabled'] = !empty($_POST['editor_enabled']);
                $cfg['editor_messages_enabled'] = !empty($_POST['editor_messages_enabled']);
                $cfg['editor_forums_enabled'] = !empty($_POST['editor_forums_enabled']);
                $cfg['editor_news_enabled'] = !empty($_POST['editor_news_enabled']);

                // Persist by rewriting config.php conservatively (simple key patch)
                $text = is_file($cfgFile) ? file_get_contents($cfgFile) : '';
                $text = $this->patchBool($text ?: "<?php\nreturn [\n];\n", 'editor_enabled', (bool)$cfg['editor_enabled']);
                $text = $this->patchBool($text, 'editor_messages_enabled', (bool)$cfg['editor_messages_enabled']);
                $text = $this->patchBool($text, 'editor_forums_enabled', (bool)$cfg['editor_forums_enabled']);
                $text = $this->patchBool($text, 'editor_news_enabled', (bool)$cfg['editor_news_enabled']);
                file_put_contents($cfgFile, $text);
                $msg = 'Editor settings saved.';
            }
        }

        $enabled = (bool)($cfg['editor_enabled'] ?? false);
        $msgEnabled = (bool)($cfg['editor_messages_enabled'] ?? false);
        $forumsEnabled = (bool)($cfg['editor_forums_enabled'] ?? false);
        $newsEnabled = (bool)($cfg['editor_news_enabled'] ?? false);
        $csrf = Csrf::token();

        Layout::page('Editor Settings', function () use ($enabled, $msgEnabled, $forumsEnabled, $newsEnabled, $msg, $csrf) {
            echo "<h1>Editor</h1>";
            if ($msg) {
                $cls = str_contains($msg, 'Invalid') ? 'err' : 'ok';
                echo "<div class='{$cls}' style='margin:10px 0'>" . htmlspecialchars($msg, ENT_QUOTES, 'UTF-8') . "</div>";
            }
            echo "<div class='card' style='padding:14px;max-width:900px;display:grid;gap:12px'>";
            echo "<div class='muted'>Progressive enhancement only. If disabled, forms fall back to plain textarea.</div>";
            echo "<form method='post' action='/index.php?module=admin_editor' style='display:grid;gap:12px'>";
            echo "<input type='hidden' name='_csrf' value='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."'>";
            echo "<input type='hidden' name='action' value='save'>";
            echo "<label style='display:flex;gap:10px;align-items:center'><input type='checkbox' name='editor_enabled' ".($enabled?'checked':'')."> <b>Enable Editor (global)</b></label>";
            echo "<label style='display:flex;gap:10px;align-items:center'><input type='checkbox' name='editor_messages_enabled' ".($msgEnabled?'checked':'')."> Enable for Messages</label>";
            echo "<label style='display:flex;gap:10px;align-items:center'><input type='checkbox' name='editor_forums_enabled' ".($forumsEnabled?'checked':'')."> Enable for Forums</label>";
            echo "<label style='display:flex;gap:10px;align-items:center'><input type='checkbox' name='editor_news_enabled' ".($newsEnabled?'checked':'')."> Enable for News</label>";
            echo "<div style='display:flex;gap:10px;flex-wrap:wrap'>";
            echo "<button class='btn' type='submit'>Save</button>";
            echo "<a class='btn2' href='/index.php?module=admin'>Admin Home</a>";
            echo "</div>";
            echo "</form>";
            echo "</div>";
        }, ['module'=>'admin_editor']);
    }

    private function patchBool(string $configPhp, string $key, bool $value): string
    {
        $v = $value ? 'true' : 'false';
        $pattern = "/(['\"]" . preg_quote($key, '/') . "['\"]\s*=>\s*)(true|false)(\s*,)/i";
        if (preg_match($pattern, $configPhp)) {
            return preg_replace($pattern, "$1{$v}$3", $configPhp) ?? $configPhp;
        }
        // insert near feature toggles or near top of return array
        if (strpos($configPhp, "'messages_enabled'") !== false) {
            return preg_replace("/('messages_enabled'\s*=>\s*(true|false)\s*,)/i", "$1\n    '{$key}' => {$v},", $configPhp, 1) ?? $configPhp;
        }
        return str_replace("return [", "return [\n    '{$key}' => {$v},", $configPhp);
    }
}
