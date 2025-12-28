<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Core;

/**
 * AdminUi: shared admin primitives.
 *
 * Server-rendered (PHP), minimal JS, theme-friendly via CSS classes.
 * Keep the "Evolution grouped panels" layout as the default.
 */
final class AdminUi
{
    /** @param array<int,array{label:string,url:string,class?:string}> $actions */
    public static function pageHead(string $title, string $iconKey = '', string $subtitle = '', array $actions = []): string
    {
        $h = "<div class='adminui-head'>";
        $h .= "<div class='adminui-head-left'>";
        if ($iconKey !== '') {
            $h .= AdminLayout::icon($iconKey, $title);
        }
        $h .= "<div><h1 class='adminui-h1'>" . self::e($title) . "</h1>";
        if ($subtitle !== '') {
            $h .= "<div class='adminui-sub'>" . self::e($subtitle) . "</div>";
        }
        $h .= "</div></div>";
        if ($actions) {
            $h .= "<div class='adminui-actions'>";
            foreach ($actions as $a) {
                $cls = $a['class'] ?? 'btn2';
                $h .= "<a class='" . self::eAttr($cls) . "' href='" . self::eAttr($a['url']) . "'>" . self::e($a['label']) . "</a>";
            }
            $h .= "</div>";
        }
        $h .= "</div>";
        return $h;
    }

    public static function gridCards(array $cards): string
    {
        // $cards: [ ['title'=>..., 'sub'=>..., 'value'=>..., 'badgeHtml'=>optional] ]
        $h = "<div class='adminui-grid'>";
        foreach ($cards as $c) {
            $h .= "<div class='adminui-card'>";
            $h .= "<div class='adminui-card-title'>" . self::e((string)($c['title'] ?? '')) . "</div>";
            if (!empty($c['sub'])) {
                $h .= "<div class='adminui-muted'>" . self::e((string)$c['sub']) . "</div>";
            }
            if (isset($c['value'])) {
                $h .= "<div class='adminui-card-value'>" . self::e((string)$c['value']) . "</div>";
            }
            if (!empty($c['badgeHtml']) && is_string($c['badgeHtml'])) {
                $h .= "<div style='margin-top:8px'>" . $c['badgeHtml'] . "</div>";
            }
            $h .= "</div>";
        }
        $h .= "</div>";
        return $h;
    }

    public static function group(string $title, string $desc, string $innerHtml): string
    {
        $h = "<section class='adminui-group'>";
        $h .= "<div class='adminui-group-head'>";
        $h .= "<div class='adminui-group-title'>" . self::e($title) . "</div>";
        if ($desc !== '') {
            $h .= "<div class='adminui-muted'>" . self::e($desc) . "</div>";
        }
        $h .= "</div>";
        $h .= "<div class='adminui-group-body'>" . $innerHtml . "</div>";
        $h .= "</section>";
        return $h;
    }

    /** @param array<int,array{key:string,label:string,url:string}> $tabs */
    public static function tabs(array $tabs, string $activeKey): string
    {
        $h = "<nav class='adminui-tabs' aria-label='Admin sections'>";
        foreach ($tabs as $t) {
            $key = (string)($t['key'] ?? '');
            $label = (string)($t['label'] ?? '');
            $url = (string)($t['url'] ?? '#');
            $cls = ($key === $activeKey) ? 'adminui-tab is-active' : 'adminui-tab';
            $h .= "<a class='" . self::eAttr($cls) . "' href='" . self::eAttr($url) . "'>" . self::e($label) . "</a>";
        }
        $h .= "</nav>";
        return $h;
    }

    public static function codeBox(string $htmlLines, int $maxHeightPx = 420): string
    {
        return "<div class='adminui-code' style='max-height:" . (int)$maxHeightPx . "px'>" . $htmlLines . "</div>";
    }

    public static function formRow(string $label, string $fieldHtml, string $help = ''): string
    {
        $h = "<div class='adminui-field'>";
        $h .= "<label class='adminui-label'>" . self::e($label) . "</label>";
        $h .= $fieldHtml;
        if ($help !== '') {
            $h .= "<div class='adminui-help'>" . self::e($help) . "</div>";
        }
        $h .= "</div>";
        return $h;
    }

    public static function notice(string $type, string $message): string
    {
        $t = in_array($type, ['ok','err','warn','info'], true) ? $type : 'info';
        return "<div class='adminui-notice is-" . self::eAttr($t) . "' role='status'>" . self::e($message) . "</div>";
    }

    public static function e(string $s): string
    {
        return htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
    }

    public static function eAttr(string $s): string
    {
        return htmlspecialchars($s, ENT_QUOTES, 'UTF-8');
    }
}
