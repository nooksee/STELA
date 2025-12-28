<?php
/**
 * PHP-Nuke CE
 * Admin AI
 */
require_once __DIR__ . '/../../mainfile.php';
require_once NUKECE_ROOT . '/includes/admin_ui.php';

use NukeCE\Core\SiteConfig;
use NukeCE\AI\AiEventLog;

AdminUi::requireAdmin();
include_once NUKECE_ROOT . '/includes/header.php';

$tab = (string)($_GET['tab'] ?? 'status');
$actor = 'admin';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // simple CSRF hook if available
    if (class_exists('NukeCE\Security\Csrf') && !\NukeCE\Security\Csrf::validate($_POST['_csrf'] ?? null)) {
        $msg = 'Invalid CSRF token.';
    } else {
        $msg = 'Saved.';
        if ($tab === 'settings') {
            SiteConfig::set('ai.enabled', !empty($_POST['ai_enabled']), 'bool', $actor, 'AI global enable');
            SiteConfig::set('ai.killswitch', !empty($_POST['ai_killswitch']), 'bool', $actor, 'AI kill switch');
            SiteConfig::set('ai.provider', (string)($_POST['ai_provider'] ?? 'none'), 'string', $actor, 'AI provider');
            SiteConfig::set('ai.model', (string)($_POST['ai_model'] ?? 'gpt-4o-mini'), 'string', $actor, 'AI model');
            SiteConfig::set('ai.max_tokens', (int)($_POST['ai_max_tokens'] ?? 512), 'int', $actor, 'AI max tokens');
            SiteConfig::set('ai.temperature', (int)($_POST['ai_temperature'] ?? 20), 'int', $actor, 'AI temperature x100');
        }
        if ($tab === 'features') {
            $features = ['moderation_triage','reference_proposals','editor_hints','editor_summarize','editor_grammar','downloads_metadata','downloads_safety_scan','downloads_link_check'];
            foreach ($features as $f) {
                SiteConfig::set('ai.feature.'.$f, !empty($_POST['f_'.$f]), 'bool', $actor, 'AI feature toggle');
            }
        }
    }
}

AdminUi::header('AI', [
  '/admin' => 'Dashboard',
  '/admin.php?op=logout' => 'Logout',
]);

// Tabs
AdminUi::groupStart('AI Control', 'Governance-first AI settings. Secrets stay in env/config.');
echo AdminUi::button('/index.php?module=admin_ai&tab=status', 'Status', $tab==='status'?'primary':'secondary') . ' ';
echo AdminUi::button('/index.php?module=admin_ai&tab=settings', 'Provider & Limits', $tab==='settings'?'primary':'secondary') . ' ';
echo AdminUi::button('/index.php?module=admin_ai&tab=features', 'Features', $tab==='features'?'primary':'secondary') . ' ';
echo AdminUi::button('/index.php?module=admin_ai&tab=logs', 'Logs', $tab==='logs'?'primary':'secondary');
AdminUi::groupEnd();

if (!empty($msg ?? '')) {
    AdminUi::groupStart('Message');
    echo '<p>' . htmlspecialchars($msg, ENT_QUOTES, 'UTF-8') . '</p>';
    AdminUi::groupEnd();
}

if ($tab === 'status') {
    AdminUi::groupStart('Status', 'AI assists; humans decide. No silent automation.');
    $enabled = SiteConfig::get('ai.enabled', false, 'bool') ? 'Enabled' : 'Disabled';
    $ks = SiteConfig::get('ai.killswitch', false, 'bool') ? 'ON' : 'off';
    $prov = (string)SiteConfig::get('ai.provider', 'none', 'string');
    echo '<p><strong>AI:</strong> '.$enabled.' &nbsp; <strong>Kill switch:</strong> '.$ks.' &nbsp; <strong>Provider:</strong> '.htmlspecialchars($prov).'</p>';
    echo '<p><em>Secrets:</em> set OPENAI_API_KEY in your environment for OpenAI.</p>';
    AdminUi::groupEnd();
}

if ($tab === 'settings') {
    AdminUi::groupStart('Provider & Limits', 'Global governance. Module workflows live in their modules.');
    $csrf = class_exists('NukeCE\Security\Csrf') ? \NukeCE\Security\Csrf::token() : '';
    echo '<form method="post" action="/index.php?module=admin_ai&tab=settings">';
    if ($csrf) echo '<input type="hidden" name="_csrf" value="'.htmlspecialchars($csrf, ENT_QUOTES, 'UTF-8').'" />';
    $aiEnabled = SiteConfig::get('ai.enabled', false, 'bool') ? 'checked' : '';
    $aiKill = SiteConfig::get('ai.killswitch', false, 'bool') ? 'checked' : '';
    $prov = (string)SiteConfig::get('ai.provider', 'none', 'string');
    $model = (string)SiteConfig::get('ai.model', 'gpt-4o-mini', 'string');
    $mt = (int)SiteConfig::get('ai.max_tokens', 512, 'int');
    $temp = (int)SiteConfig::get('ai.temperature', 20, 'int');
    echo '<p><label><input type="checkbox" name="ai_enabled" value="1" '.$aiEnabled.'> Enable AI system-wide</label></p>';
    echo '<p><label><input type="checkbox" name="ai_killswitch" value="1" '.$aiKill.'> Emergency kill switch</label></p>';
    echo '<p><label>Provider: <select name="ai_provider">';
    foreach (['none'=>'None','openai'=>'OpenAI'] as $k=>$v) {
        $sel = ($prov===$k)?'selected':'';
        echo '<option value="'.htmlspecialchars($k).'" '.$sel.'>'.htmlspecialchars($v).'</option>';
    }
    echo '</select></label></p>';
    echo '<p><label>Model: <input type="text" name="ai_model" value="'.htmlspecialchars($model, ENT_QUOTES, 'UTF-8').'" /></label></p>';
    echo '<p><label>Max tokens: <input type="number" name="ai_max_tokens" value="'.(int)$mt.'" /></label></p>';
    echo '<p><label>Temperature (0-100): <input type="number" name="ai_temperature" value="'.(int)$temp.'" min="0" max="100" /></label></p>';
    echo AdminUi::button('#', 'Save', 'primary'); // styled link; submit via button below
    echo ' <button class="nukece-btn nukece-btn-primary" type="submit">Save</button>';
    echo '</form>';
    AdminUi::groupEnd();
}

if ($tab === 'features') {
    AdminUi::groupStart('Feature toggles', 'Enable only what you intend to supervise.');
    $csrf = class_exists('NukeCE\Security\Csrf') ? \NukeCE\Security\Csrf::token() : '';
    echo '<form method="post" action="/index.php?module=admin_ai&tab=features">';
    if ($csrf) echo '<input type="hidden" name="_csrf" value="'.htmlspecialchars($csrf, ENT_QUOTES, 'UTF-8').'" />';
    $features = ['moderation_triage','reference_proposals','editor_hints','editor_summarize','editor_grammar','downloads_metadata','downloads_safety_scan','downloads_link_check'];
    foreach ($features as $k=>$label) {
        $on = SiteConfig::get('ai.feature.'.$k, false, 'bool') ? 'checked' : '';
        echo '<p><label><input type="checkbox" name="f_'.$k.'" value="1" '.$on.'> '.htmlspecialchars($label).'</label></p>';
    }
    echo '<button class="nukece-btn nukece-btn-primary" type="submit">Save</button>';
    echo '</form>';
    AdminUi::groupEnd();
}

if ($tab === 'logs') {
    AdminUi::groupStart('Recent AI events', 'Every AI call is logged.');
    $rows = AiEventLog::recent(50);
    if (!$rows) {
        echo '<p>No AI events logged yet.</p>';
    } else {
        echo '<table><thead><tr><th>When</th><th>Feature</th><th>Provider</th><th>Model</th><th>OK</th></tr></thead><tbody>';
        foreach ($rows as $r) {
            echo '<tr>';
            echo '<td>'.htmlspecialchars((string)$r['created_at']).'</td>';
            echo '<td>'.htmlspecialchars((string)$r['feature_key']).'</td>';
            echo '<td>'.htmlspecialchars((string)$r['provider']).'</td>';
            echo '<td>'.htmlspecialchars((string)$r['model']).'</td>';
            echo '<td>'.((int)$r['ok']===1?'yes':'no').'</td>';
            echo '</tr>';
        }
        echo '</tbody></table>';
    }
    AdminUi::groupEnd();
}

AdminUi::footer();
include_once NUKECE_ROOT . '/includes/footer.php';
