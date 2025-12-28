<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Modules\AdminBlocks;

use NukeCE\Core\ModuleInterface;
use NukeCE\Blocks\BlockManager;
use NukeCE\Security\Csrf;
use NukeCE\Security\NukeSecurity;

/**
 * Blocks Admin (classic workflow, modern UX).
 * - enable/disable
 * - position left/right/center
 * - drag/drop reorder per position
 */
final class AdminBlocksModule implements ModuleInterface
{
    public function getName(): string
    {
        return 'admin_blocks';
    }

    public function handle(array $params): void
    {
        NukeSecurity::log('admin_blocks', 'view');

        $root = defined('NUKECE_ROOT') ? NUKECE_ROOT : dirname(__DIR__, 2);
        require_once $root . '/includes/admin_ui.php';
        include_once $root . '/includes/header.php';

        AdminUi::header('Blocks', [
            '/admin' => 'Dashboard',
            '/admin.php?op=logout' => 'Logout',
        ]);

        AdminUi::groupStart('Blocks', 'Enable/disable and reorder blocks (drag & drop). Changes are audited.');

        $bm = new BlockManager($root);
        $state = $bm->getState();
        $msg = '';

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            Csrf::requireValid($_POST['_csrf'] ?? '');

            $action = (string)($_POST['action'] ?? 'save');
            if ($action === 'save') {
                $blocks = is_array($_POST['blocks'] ?? null) ? $_POST['blocks'] : [];
                $newBlocks = [];
                foreach ($blocks as $row) {
                    if (!is_array($row)) continue;
                    $id = preg_replace('/[^a-z0-9_]/i', '', (string)($row['id'] ?? ''));
                    if ($id === '') continue;
                    $pos = (string)($row['position'] ?? 'right');
                    if (!in_array($pos, ['left','right','center'], true)) $pos = 'right';
                    $disabled = isset($row['enabled']) ? empty($row['enabled']) : !empty($row['disabled']);
                    $ttl = (int)($row['cache_ttl'] ?? 0);
                    if ($ttl < 0) $ttl = 0;

                    $newBlocks[] = ['id' => $id, 'position' => $pos, 'disabled' => $disabled];
                }

                $order = [
                    'left' => $this->parseOrder($_POST['order_left'] ?? ''),
                    'right' => $this->parseOrder($_POST['order_right'] ?? ''),
                    'center' => $this->parseOrder($_POST['order_center'] ?? ''),
                ];

                $state['blocks'] = $newBlocks;
                $state['order'] = $order;
                $bm->saveState($state);
                $state = $bm->getState();
                $msg = "<div class='ok'>Saved.</div>";
                NukeSecurity::log('admin_blocks', 'save', ['counts' => count($newBlocks)]);
            }
        }

        $csrf = Csrf::token();
        $available = $bm->listAvailableBlocks();

        // Ensure every available block appears in config at least once
        $existingIds = [];
        foreach (($state['blocks'] ?? []) as $b) if (is_array($b) && !empty($b['id'])) $existingIds[(string)$b['id']] = true;
        foreach ($available as $b) {
            $id = (string)$b['id'];
            if (!isset($existingIds[$id])) {
                $state['blocks'][] = ['id' => $id, 'position' => 'right', 'disabled' => false];
            }
        }

        // Render
        if ($msg) { echo $msg; }

        echo "<form method='post' action='/index.php?module=admin_blocks' class='adminui-form'>";
        echo "<input type='hidden' name='_csrf' value='{$csrf}'>";
        echo "<input type='hidden' name='action' value='save'>";

        // Hidden order fields (synced by JS)
        $oL = htmlspecialchars(implode("\n", (array)($state['order']['left'] ?? [])), ENT_QUOTES,'UTF-8');
        $oR = htmlspecialchars(implode("\n", (array)($state['order']['right'] ?? [])), ENT_QUOTES,'UTF-8');
        $oC = htmlspecialchars(implode("\n", (array)($state['order']['center'] ?? [])), ENT_QUOTES,'UTF-8');
        echo "<input type='hidden' id='order_left' name='order_left' value='{$oL}'>";
        echo "<input type='hidden' id='order_right' name='order_right' value='{$oR}'>";
        echo "<input type='hidden' id='order_center' name='order_center' value='{$oC}'>";

        echo "<div class='adminui-help'>Classic Nuke workflow, modern convenience. Drag blocks to reorder within each column. All changes are audited by NukeSecurity.</div>";

        echo "<div class='adminui-grid3' style='margin-top:12px'>";
        // Left / Center / Right columns
        $cols = [
            'left' => 'Left',
            'center' => 'Center',
            'right' => 'Right',
        ];

        // Map blocks by position
        $byPos = ['left'=>[], 'center'=>[], 'right'=>[]];
        foreach (($state['blocks'] ?? []) as $b) {
            if (!is_array($b)) continue;
            $pid = (string)($b['position'] ?? 'right');
            if (!isset($byPos[$pid])) $pid = 'right';
            $byPos[$pid][] = $b;
        }

        // Sort each position by stored order
        foreach ($cols as $pos => $label) {
            $order = (array)($state['order'][$pos] ?? []);
            $index = [];
            foreach ($order as $i => $bid) { $index[(string)$bid] = $i; }
            usort($byPos[$pos], function($a,$b) use ($index){
                $ai = $index[(string)($a['id'] ?? '')] ?? 999999;
                $bi = $index[(string)($b['id'] ?? '')] ?? 999999;
                return $ai <=> $bi;
            });

            echo "<div class='adminui-group'>";
            echo "<div class='adminui-group-title'>".htmlspecialchars($label,ENT_QUOTES,'UTF-8')."</div>";
            echo "<div class='adminui-group-sub'>Drag to reorder</div>";

            echo "<ul class='adminui-draglist' data-pos='{$pos}' id='drag_{$pos}'>";
            $idx = 0;
            foreach ($byPos[$pos] as $b) {
                $idRaw = (string)($b['id'] ?? '');
                $id = htmlspecialchars($idRaw, ENT_QUOTES, 'UTF-8');
                $disabled = !empty($b['disabled']);
                $checked = $disabled ? "" : "checked";
                echo "<li class='adminui-dragitem' draggable='true' data-id='{$id}'>";
                echo "<div class='adminui-row'>";
                echo "<div class='adminui-col' style='flex:1'>";
                echo "<div class='adminui-label'><code>{$id}</code></div>";
                echo "</div>";
                echo "<div class='adminui-col' style='display:flex;gap:10px;align-items:center'>";
                // enabled checkbox (invert disabled)
                echo "<label class='adminui-check'><input type='checkbox' name='blocks[{$pos}_{$idx}][enabled]' value='1' {$checked}> Enabled</label>";
                echo "<input type='hidden' name='blocks[{$pos}_{$idx}][id]' value='{$id}'>";
                echo "<input type='hidden' name='blocks[{$pos}_{$idx}][position]' value='{$pos}'>";
                echo "</div>";
                echo "</div>";
                echo "</li>";
                $idx++;
            }
            echo "</ul>";

            echo "</div>";
        }

        echo "</div>"; // grid

        echo "<div class='adminui-toolbar' style='margin-top:14px'>";
        echo "<button class='adminui-btn primary' type='submit'>Save</button>";
        echo "<a class='adminui-btn' href='/admin.php?op=audit&scope=admin_blocks'>View audit log</a>";
        echo "</div>";

        echo "</form>";

        // Drag/drop JS (no deps)
        echo "<script>
        (function(){
          function sync(pos){
            const list = document.getElementById('drag_'+pos);
            if(!list) return;
            const ids = Array.from(list.querySelectorAll('.adminui-dragitem')).map(li=>li.getAttribute('data-id')||'').filter(Boolean);
            const hidden = document.getElementById('order_'+pos);
            if(hidden) hidden.value = ids.join('\\n');
          }
          function wire(pos){
            const list = document.getElementById('drag_'+pos);
            if(!list) return;
            let dragEl = null;
            list.addEventListener('dragstart', (e)=>{
              const li = e.target.closest('.adminui-dragitem');
              if(!li) return;
              dragEl = li;
              li.classList.add('dragging');
              e.dataTransfer.effectAllowed='move';
            });
            list.addEventListener('dragend', ()=>{
              if(dragEl) dragEl.classList.remove('dragging');
              dragEl=null;
              sync(pos);
            });
            list.addEventListener('dragover', (e)=>{
              e.preventDefault();
              const after = (function(container, y){
                const items = [...container.querySelectorAll('.adminui-dragitem:not(.dragging)')];
                return items.reduce((closest, child)=>{
                  const box = child.getBoundingClientRect();
                  const offset = y - box.top - box.height/2;
                  if(offset < 0 && offset > closest.offset){ return {offset:offset, element:child}; }
                  return closest;
                }, {offset:-Infinity, element:null}).element;
              })(list, e.clientY);
              const dragging = list.querySelector('.dragging');
              if(!dragging) return;
              if(after==null) list.appendChild(dragging);
              else list.insertBefore(dragging, after);
            });
          }
          ['left','center','right'].forEach(wire);
          ['left','center','right'].forEach(sync);
        })();
        </script>";

        echo "</div></div>";

        echo "<div>";
        echo "<h3 style='margin:0 0 8px 0'>Order: Left</h3>";
        echo $this->renderOrderBox('left', $state);
        echo "<h3 style='margin:14px 0 8px 0'>Order: Center</h3>";
        echo $this->renderOrderBox('center', $state);
        echo "<h3 style='margin:14px 0 8px 0'>Order: Right</h3>";
        echo $this->renderOrderBox('right', $state);
        echo "</div>";

        echo "<div>";
        echo "<h3 style='margin:0 0 8px 0'>Notes</h3>";
        echo "<div class='muted'><small>The page layout currently renders the <b>Right</b> column blocks on user pages. Left/Center are supported and reserved for theme upgrades.</small></div>";
        echo "<div style='margin-top:12px'><button class='btn' type='submit'>Save</button> <a href='/index.php' class='btn2'>View site</a></div>";
        echo "</div>";

        echo "</div>"; // grid
        echo "</form>";

        echo "<script>
        (function(){
          const list = document.getElementById('blocksList');
          let dragEl = null;
          list.addEventListener('dragstart', (e)=>{ dragEl = e.target.closest('.item'); if(!dragEl) return; dragEl.style.opacity='0.5'; });
          list.addEventListener('dragend', (e)=>{ if(dragEl) dragEl.style.opacity='1'; dragEl=null; syncOrders(); });
          list.addEventListener('dragover', (e)=>{ e.preventDefault(); const over = e.target.closest('.item'); if(!dragEl || !over || over===dragEl) return;
              const rect = over.getBoundingClientRect(); const next = (e.clientY - rect.top) > (rect.height/2);
              list.insertBefore(dragEl, next ? over.nextSibling : over);
          });
          function syncOrders(){
            const ids = Array.from(list.querySelectorAll('.item')).map(el=>el.getAttribute('data-id'));
            // store same global order into all order boxes for now; per-position ordering can be refined later.
            document.getElementById('order_left').value = ids.join('\\n');
            document.getElementById('order_center').value = ids.join('\\n');
            document.getElementById('order_right').value = ids.join('\\n');
          }
          syncOrders();
        })();
        </script>";

        echo "</div></div>";
        AdminUi::groupEnd();
        AdminUi::footer();
        include_once $root . '/includes/footer.php';
}

    private function renderOrderBox(string $pos, array $state): string
    {
        $k = "order_" . $pos;
        $vals = is_array($state['order'][$pos] ?? null) ? $state['order'][$pos] : [];
        $text = htmlspecialchars(implode("\n", array_map('strval', $vals)), ENT_QUOTES, 'UTF-8');
        return "<textarea id='{$k}' name='{$k}' rows='7' style='width:100%;font-family:ui-monospace,Menlo,monospace;font-size:12px;padding:10px;border:1px solid #ccc;border-radius:12px'>{$text}</textarea>";
    }

    private function parseOrder(string $raw): array
    {
        $raw = str_replace("\r", "", (string)$raw);
        $lines = array_filter(array_map('trim', explode("\n", $raw)));
        $out = [];
        foreach ($lines as $l) {
            $id = preg_replace('/[^a-z0-9_]/i', '', $l);
            if ($id !== '') $out[] = $id;
        }
        return array_values(array_unique($out));
    }
}
