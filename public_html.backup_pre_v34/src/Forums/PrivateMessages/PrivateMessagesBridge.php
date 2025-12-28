<?php
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Forums\PrivateMessages;

use NukeCE\Core\Model;
use PDO;

final class PrivateMessagesBridge
{
    public function __construct(private string $tablePrefix = 'bb_') {}

    public function unreadCount(int $userId): array
    {
        $pdo = Model::db();
        $to = $this->tablePrefix . 'privmsgs_to';
        if (!$this->tableExists($pdo, $to)) return ['ok'=>false,'reason'=>'PM tables missing'];

        $cols = $this->columns($pdo, $to);
        if (!in_array('user_id',$cols,true)) return ['ok'=>false,'reason'=>'schema'];
        $unreadCol = in_array('privmsgs_unread',$cols,true) ? 'privmsgs_unread' : (in_array('unread',$cols,true) ? 'unread' : '');
        if ($unreadCol === '') return ['ok'=>false,'reason'=>'schema'];

        $st = $pdo->prepare("SELECT COUNT(*) FROM `$to` WHERE user_id=:u AND `$unreadCol`=1");
        $st->execute([':u'=>$userId]);
        return ['ok'=>true,'unread'=>(int)$st->fetchColumn()];
    }

    public function inbox(int $userId, int $limit = 40): array
    {
        $pdo = Model::db();
        $to = $this->tablePrefix . 'privmsgs_to';
        $pm = $this->tablePrefix . 'privmsgs';
        $txt = $this->tablePrefix . 'privmsgs_text';
        $users = $this->tablePrefix . 'users';
        if (!$this->tableExists($pdo,$to) || !$this->tableExists($pdo,$pm)) return ['ok'=>false,'reason'=>'PM tables missing'];

        $toCols = $this->columns($pdo,$to);
        $pmCols = $this->columns($pdo,$pm);

        $unreadCol = in_array('privmsgs_unread',$toCols,true) ? 'privmsgs_unread' : (in_array('unread',$toCols,true) ? 'unread' : null);
        $dateCol = in_array('privmsgs_date',$pmCols,true) ? 'privmsgs_date' : (in_array('msg_time',$pmCols,true) ? 'msg_time' : null);
        $subjCol = in_array('privmsgs_subject',$pmCols,true) ? 'privmsgs_subject' : (in_array('subject',$pmCols,true) ? 'subject' : null);
        $fromCol = in_array('privmsgs_from_userid',$pmCols,true) ? 'privmsgs_from_userid' : (in_array('from_userid',$pmCols,true) ? 'from_userid' : null);
        if (!$dateCol || !$subjCol || !$fromCol) return ['ok'=>false,'reason'=>'schema'];

        $selectUser = ""; $joinUser = "";
        if ($this->tableExists($pdo,$users)) {
            $uCols = $this->columns($pdo,$users);
            if (in_array('user_id',$uCols,true) && in_array('username',$uCols,true)) {
                $joinUser = "LEFT JOIN `$users` u ON u.user_id = m.`$fromCol`";
                $selectUser = ", u.username AS from_username";
            }
        }

        $selectText = ""; $joinText = "";
        if ($this->tableExists($pdo,$txt)) {
            $tCols = $this->columns($pdo,$txt);
            if (in_array('privmsgs_text',$tCols,true)) {
                if (in_array('privmsgs_id',$tCols,true)) {
                    $joinText = "LEFT JOIN `$txt` x ON x.privmsgs_id = m.privmsgs_id";
                } elseif (in_array('privmsgs_text_id',$tCols,true) && in_array('privmsgs_text_id',$pmCols,true)) {
                    $joinText = "LEFT JOIN `$txt` x ON x.privmsgs_text_id = m.privmsgs_text_id";
                }
                $selectText = ", x.privmsgs_text AS body";
            }
        }

        $newSel = $unreadCol ? ", t.`$unreadCol` AS is_unread" : "";
        $sql = "SELECT m.privmsgs_id AS id, m.`$subjCol` AS subject, m.`$dateCol` AS ts, m.`$fromCol` AS from_user
                $selectUser $newSel $selectText
                FROM `$to` t
                JOIN `$pm` m ON m.privmsgs_id = t.privmsgs_id
                $joinUser
                $joinText
                WHERE t.user_id=:u
                ORDER BY m.`$dateCol` DESC
                LIMIT ".(int)$limit;
        $st = $pdo->prepare($sql);
        $st->execute([':u'=>$userId]);
        return ['ok'=>true,'rows'=>($st->fetchAll(PDO::FETCH_ASSOC) ?: [])];
    }

    public function getInboxMessage(int $userId, int $pmId): array
    {
        $list = $this->inbox($userId, 200);
        if (!$list['ok']) return $list;
        foreach ($list['rows'] as $r) if ((int)($r['id']??0)===$pmId) return ['ok'=>true,'row'=>$r];
        return ['ok'=>false,'reason'=>'Not found'];
    }

    private function tableExists(PDO $pdo, string $table): bool
    {
        try { $st = $pdo->prepare("SHOW TABLES LIKE :t"); $st->execute([':t'=>$table]); return (bool)$st->fetchColumn(); }
        catch (\Throwable) { return false; }
    }

    private function columns(PDO $pdo, string $table): array
    {
        try {
            $st = $pdo->query("DESCRIBE `$table`");
            $cols = [];
            foreach ($st->fetchAll(PDO::FETCH_ASSOC) as $r) if (isset($r['Field'])) $cols[] = (string)$r['Field'];
            return $cols;
        } catch (\Throwable) { return []; }
    }

    /** Mark message read/unread for a user */
    public function setReadState(int $userId, int $pmId, bool $isUnread): array
    {
        $pdo = Model::db();
        $to = $this->tablePrefix . 'privmsgs_to';
        if (!$this->tableExists($pdo,$to)) return ['ok'=>false,'reason'=>'PM tables missing'];
        $cols = $this->columns($pdo,$to);
        $unreadCol = in_array('privmsgs_unread',$cols,true) ? 'privmsgs_unread' : (in_array('unread',$cols,true) ? 'unread' : '');
        $newCol = in_array('privmsgs_new',$cols,true) ? 'privmsgs_new' : (in_array('new',$cols,true) ? 'new' : '');
        if ($unreadCol === '') return ['ok'=>false,'reason'=>'schema'];

        $val = $isUnread ? 1 : 0;
        $sql = "UPDATE `$to` SET `$unreadCol` = :v";
        $params = [':v'=>$val, ':u'=>$userId, ':id'=>$pmId];
        if ($newCol !== '') {
            $sql .= ", `$newCol` = :v2";
            $params[':v2'] = $val;
        }
        $sql .= " WHERE user_id = :u AND privmsgs_id = :id";
        $st = $pdo->prepare($sql);
        $st->execute($params);
        return ['ok'=>true];
    }

    /** Delete message from a user's inbox safely (removes recipient row; cleans orphan core rows if possible) */
    public function deleteForUser(int $userId, int $pmId): array
    {
        $pdo = Model::db();
        $to = $this->tablePrefix . 'privmsgs_to';
        $pm = $this->tablePrefix . 'privmsgs';
        $txt = $this->tablePrefix . 'privmsgs_text';
        if (!$this->tableExists($pdo,$to)) return ['ok'=>false,'reason'=>'PM tables missing'];

        $st = $pdo->prepare("DELETE FROM `$to` WHERE user_id=:u AND privmsgs_id=:id");
        $st->execute([':u'=>$userId, ':id'=>$pmId]);

        // If no remaining recipients, attempt to delete pm + text row (best-effort)
        try {
            $st2 = $pdo->prepare("SELECT COUNT(*) FROM `$to` WHERE privmsgs_id=:id");
            $st2->execute([':id'=>$pmId]);
            $c = (int)$st2->fetchColumn();
            if ($c === 0) {
                if ($this->tableExists($pdo,$pm)) {
                    // Capture text id if present
                    $pmCols = $this->columns($pdo,$pm);
                    $textId = null;
                    if (in_array('privmsgs_text_id',$pmCols,true)) {
                        $q = $pdo->prepare("SELECT privmsgs_text_id FROM `$pm` WHERE privmsgs_id=:id");
                        $q->execute([':id'=>$pmId]);
                        $textId = $q->fetchColumn();
                    }
                    $pdo->prepare("DELETE FROM `$pm` WHERE privmsgs_id=:id")->execute([':id'=>$pmId]);
                    if ($textId !== null && $this->tableExists($pdo,$txt)) {
                        $pdo->prepare("DELETE FROM `$txt` WHERE privmsgs_text_id=:tid")->execute([':tid'=>$textId]);
                    } elseif ($this->tableExists($pdo,$txt)) {
                        // Some schemas key by privmsgs_id
                        $pdo->prepare("DELETE FROM `$txt` WHERE privmsgs_id=:id")->execute([':id'=>$pmId]);
                    }
                }
            }
        } catch (\Throwable) {}

        return ['ok'=>true];
    }

    /** Admin audit fetch (no user constraint) */
    public function getAnyMessage(int $pmId): array
    {
        $pdo = Model::db();
        $to = $this->tablePrefix . 'privmsgs_to';
        $pm = $this->tablePrefix . 'privmsgs';
        $txt = $this->tablePrefix . 'privmsgs_text';
        $users = $this->tablePrefix . 'users';
        if (!$this->tableExists($pdo,$pm)) return ['ok'=>false,'reason'=>'PM tables missing'];

        $pmCols = $this->columns($pdo,$pm);
        $dateCol = in_array('privmsgs_date',$pmCols,true) ? 'privmsgs_date' : (in_array('msg_time',$pmCols,true) ? 'msg_time' : null);
        $subjCol = in_array('privmsgs_subject',$pmCols,true) ? 'privmsgs_subject' : (in_array('subject',$pmCols,true) ? 'subject' : null);
        $fromCol = in_array('privmsgs_from_userid',$pmCols,true) ? 'privmsgs_from_userid' : (in_array('from_userid',$pmCols,true) ? 'from_userid' : null);
        if (!$dateCol || !$subjCol || !$fromCol) return ['ok'=>false,'reason'=>'schema'];

        $joinText = ''; $selectText = '';
        if ($this->tableExists($pdo,$txt)) {
            $tCols = $this->columns($pdo,$txt);
            if (in_array('privmsgs_text',$tCols,true)) {
                if (in_array('privmsgs_id',$tCols,true)) $joinText = "LEFT JOIN `$txt` x ON x.privmsgs_id = m.privmsgs_id";
                elseif (in_array('privmsgs_text_id',$tCols,true) && in_array('privmsgs_text_id',$pmCols,true)) $joinText = "LEFT JOIN `$txt` x ON x.privmsgs_text_id = m.privmsgs_text_id";
                $selectText = ", x.privmsgs_text AS body";
            }
        }

        $joinFrom = ''; $selectFrom = '';
        if ($this->tableExists($pdo,$users)) {
            $uCols = $this->columns($pdo,$users);
            if (in_array('user_id',$uCols,true) && in_array('username',$uCols,true)) {
                $joinFrom = "LEFT JOIN `$users` uf ON uf.user_id = m.`$fromCol`";
                $selectFrom = ", uf.username AS from_username";
            }
        }

        $sql = "SELECT m.privmsgs_id AS id, m.`$subjCol` AS subject, m.`$dateCol` AS ts, m.`$fromCol` AS from_user
                $selectFrom $selectText
                FROM `$pm` m
                $joinFrom
                $joinText
                WHERE m.privmsgs_id=:id
                LIMIT 1";
        $st = $pdo->prepare($sql);
        $st->execute([':id'=>$pmId]);
        $row = $st->fetch(PDO::FETCH_ASSOC);
        if (!$row) return ['ok'=>false,'reason'=>'Not found'];

        // recipients list (best-effort)
        $recips = [];
        if ($this->tableExists($pdo,$to) && $this->tableExists($pdo,$users)) {
            try {
                $st2 = $pdo->prepare("SELECT u.username FROM `$to` t JOIN `$users` u ON u.user_id=t.user_id WHERE t.privmsgs_id=:id");
                $st2->execute([':id'=>$pmId]);
                $recips = array_map(fn($r)=>$r['username'] ?? '', $st2->fetchAll(PDO::FETCH_ASSOC) ?: []);
            } catch (\Throwable) {}
        }

        $row['recipients'] = $recips;
        return ['ok'=>true,'row'=>$row];
    }

    public function usernameById(int $userId): string
    {
        $pdo = Model::db();
        $users = $this->tablePrefix . 'users';
        if (!$this->tableExists($pdo,$users)) return '';
        try {
            $st = $pdo->prepare("SELECT username FROM `$users` WHERE user_id=:id LIMIT 1");
            $st->execute([':id'=>$userId]);
            $u = $st->fetchColumn();
            return is_string($u) ? $u : '';
        } catch (\Throwable) {
            return '';
        }
    }
}
