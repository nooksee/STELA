<?php
/**
 * Who Is Online Block (nukeCE Gold)
 */

declare(strict_types=1);

if (!defined('BLOCK_FILE')) {
    exit;
}

require_once __DIR__ . '/../includes/BlockGold.php';

$content = BlockGold::cached('coreblock:whoisonline', 30, function () {
    global $db, $prefix;

    // Try a few known patterns; fail gracefully if table doesn't exist.
    $guest = 0;
    $member = 0;

    try {
        if (isset($db) && isset($prefix)) {
            // Some distros track in a "session" table.
            $table = $prefix . '_session';
            $res = $db->sql_query("SELECT uname FROM $table WHERE time > " . (time() - 300));
            if ($res) {
                while ($row = $db->sql_fetchrow($res)) {
                    $u = $row['uname'] ?? '';
                    if ($u === '' || $u === 'guest') {
                        $guest++;
                    } else {
                        $member++;
                    }
                }
            }
        }
    } catch (Throwable $e) {
        // ignore
    }

    $out = '<div class="nukece-online">'
        . '<div><strong>' . (int) $member . '</strong> member(s)</div>'
        . '<div><strong>' . (int) $guest . '</strong> guest(s)</div>'
        . '</div>';

    return $out;
});
