<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

use NukeCE\Core\MobileMode;

$title = 'Mobile';
$content = '';

$on = MobileMode::isMobileRequest();
$content .= "<div style='display:flex;gap:8px;flex-wrap:wrap;align-items:center'>";
$content .= $on
    ? "<span class='badge ok'>ON</span>"
    : "<span class='badge'>OFF</span>";
$content .= "<a href='/index.php?module=mobile' class='btn2'>Mobile Center</a>";
$content .= "</div>";

$content .= "<style>.badge{display:inline-block;padding:2px 8px;border-radius:999px;border:1px solid #ccc;font-size:12px}.badge.ok{border-color:#2a7}</style>";
