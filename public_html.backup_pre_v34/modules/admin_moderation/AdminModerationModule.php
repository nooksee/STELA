<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\AdminModeration;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\AdminLayout;
use NukeCE\Core\AdminUi;
use NukeCE\Security\AuthGate;
use NukeCE\Security\Csrf;
use NukeCE\Security\NukeSecurity;
use NukeCE\Moderation\ModerationQueue;

final class AdminModerationModule implements ModuleInterface
{
    public function getName(): string { return 'admin_moderation'; }

    public function handle(array $params): void
    {
        AuthGate::requireAdmin();

        $ok = '';
        $err = '';

        if (isset($_POST['set_status'])) {
            $token = $_POST['_csrf'] ?? null;
            if (!Csrf::validate(is_string($token) ? $token : null)) {
                $err = 'CSRF validation failed.';
            } else {
                $id = (int)($_POST['id'] ?? 0);
                $status = (string)($_POST['status'] ?? 'open');
                $note = (string)($_POST['note'] ?? '');
                $actor = AuthGate::adminUsername();
                if ($id > 0 && in_array($status, ['open','reviewing','resolved','dismissed'], true)) {
                    if (ModerationQueue::setStatus($id, $status, $actor, $note)) {
                        NukeSecurity::log('moderation.status_changed', ['id'=>$id,'status'=>$status,'note'=>$note,'actor'=>$actor]);
                        $ok = 'Updated.';
                    } else $err = 'Update failed.';
                } else $err = 'Invalid input.';
            }
        }

        $filters = [
            'status' => (string)($_GET['status'] ?? ''),
            'type' => (string)($_GET['type'] ?? ''),
            'severity' => (string)($_GET['severity'] ?? ''),
        ];
        $rows = ModerationQueue::list($filters, 200);

        AdminLayout::header('Moderation');
        echo AdminUi::pageHead(
            'Moderation',
            'moderation',
            'Unified queue for Forums, Messages, Reference proposals, and security flags. AI assists triage only; humans decide.'
        );

        if ($ok) echo AdminUi::notice('ok', $ok);
        if ($err) echo AdminUi::notice('err', $err);

        ob_start();
        echo "<form method='get'>";
        echo "<input type='hidden' name='module' value='admin_moderation'>";
        echo "<div class='adminui-form'>";
        echo AdminUi::formRow('Status', $this->selectHtml('status', $filters['status'], [''=>'All','open'=>'Open','reviewing'=>'Reviewing','resolved'=>'Resolved','dismissed'=>'Dismissed']));
        echo AdminUi::formRow('Type', $this->selectHtml('type', $filters['type'], [''=>'All','forum_report'=>'Forum report','message_report'=>'Message report','reference_proposal'=>'Reference proposal','security_flag'=>'Security flag']));
        echo AdminUi::formRow('Severity', $this->selectHtml('severity', $filters['severity'], [''=>'All','low'=>'Low','medium'=>'Medium','high'=>'High']));
        echo "</div>";
        echo "<div class='adminui-actions-row'><button class='btn2' type='submit'>Filter</button><span class='adminui-muted'>Filtering never changes state.</span></div>";
        echo "</form>";
        $filterInner = (string)ob_get_clean();
        echo AdminUi::group('Filters', 'Narrow the triage queue. Filtering never changes state.', $filterInner);

        ob_start();
        echo "<form method='post'>";
        echo Csrf::field();
        echo "<div class='adminui-table-wrap'>";
        echo "<table class='adminui-table'>";
        echo "<thead><tr><th>ID</th><th>Type</th><th>Source</th><th>Status</th><th>Severity</th><th>Action</th></tr></thead><tbody>";

        foreach ($rows as $r) {
            $id = (int)($r['id'] ?? 0);
            $type = htmlspecialchars((string)($r['queue_type'] ?? ''), ENT_QUOTES,'UTF-8');
            $srcm = htmlspecialchars((string)($r['source_module'] ?? ''), ENT_QUOTES,'UTF-8');
            $srci = htmlspecialchars((string)($r['source_id'] ?? ''), ENT_QUOTES,'UTF-8');
            $st = htmlspecialchars((string)($r['status'] ?? ''), ENT_QUOTES,'UTF-8');
            $sev = htmlspecialchars((string)($r['severity'] ?? ''), ENT_QUOTES,'UTF-8');
            echo "<tr>";
            echo "<td>{$id}</td>";
            echo "<td><code>{$type}</code></td>";
            echo "<td>{$srcm} #{$srci}</td>";
            echo "<td><span class='badge'>{$st}</span></td>";
            echo "<td><span class='badge'>{$sev}</span></td>";
            echo "<td>";
            echo "<input type='hidden' name='id' value='{$id}'>";
            echo "<select name='status' class='adminui-input'>";
            foreach (['open','reviewing','resolved','dismissed'] as $s) {
                $sel = $st === $s ? " selected" : "";
                echo "<option value='{$s}'{$sel}>{$s}</option>";
            }
            echo "</select> ";
            echo "<input name='note' placeholder='note' class='adminui-input' /> ";
            echo "<button class='btn2' type='submit' name='set_status' value='1'>Update</button>";
            echo "</td></tr>";
        }
        if (!$rows) echo "<tr><td colspan='6'>Queue is empty.</td></tr>";
        echo "</tbody></table></div>";
        echo "</form>";
        $queueInner = (string)ob_get_clean();
        echo AdminUi::group('Queue', 'Status changes are audited. AI can flag; humans decide.', $queueInner);

        AdminLayout::footer();
    }

    private function selectHtml(string $name, string $cur, array $opts): string
    {
        $h = "<select class='adminui-input' name='" . htmlspecialchars($name,ENT_QUOTES,'UTF-8') . "'>";
        foreach ($opts as $v=>$l) {
            $sel = $cur === (string)$v ? " selected" : "";
            $h .= "<option value='" . htmlspecialchars((string)$v,ENT_QUOTES,'UTF-8') . "'{$sel}>" . htmlspecialchars((string)$l,ENT_QUOTES,'UTF-8') . "</option>";
        }
        $h .= "</select>";
        return $h;
    }
}
