<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Editor;

use NukeCE\Security\Csrf;

final class Editor
{
    /**
     * Render an enhanced editor surface around a textarea.
     *
     * Options:
     * - id (string)
     * - rows (int)
     * - mode (string) markdown|bbcode|hybrid
     * - placeholder (string)
     * - draft_key (string) localStorage key
     * - allow_preview (bool)
     * - allow_assist (bool) (local heuristics; AI layer plugs in later)
     * - allow_media (bool) (URL preview panel)
     */
    public static function render(string $name, string $value = '', array $opts = []): string
    {
        $id = (string)($opts['id'] ?? ('ed_' . preg_replace('/[^a-z0-9_\-]/i', '_', $name)));
        $rows = (int)($opts['rows'] ?? 10);
        $mode = (string)($opts['mode'] ?? 'hybrid');
        $placeholder = (string)($opts['placeholder'] ?? '');
        $draftKey = (string)($opts['draft_key'] ?? '');
        $allowPreview = array_key_exists('allow_preview', $opts) ? (bool)$opts['allow_preview'] : true;
        $allowAssist = array_key_exists('allow_assist', $opts) ? (bool)$opts['allow_assist'] : true;
        $allowMedia = array_key_exists('allow_media', $opts) ? (bool)$opts['allow_media'] : true;

        $csrf = Csrf::token();

        $attrs = [
            'class' => 'nukece-editor',
            'data-editor' => '1',
            'data-mode' => htmlspecialchars($mode, ENT_QUOTES, 'UTF-8'),
            'data-draft-key' => htmlspecialchars($draftKey, ENT_QUOTES, 'UTF-8'),
            'data-allow-preview' => $allowPreview ? '1' : '0',
            'data-allow-assist' => $allowAssist ? '1' : '0',
            'data-allow-media' => $allowMedia ? '1' : '0',
        ];

        $attrStr = '';
        foreach ($attrs as $k => $v) {
            $attrStr .= ' ' . $k . '="' . $v . '"';
        }

        $safeVal = htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
        $safePh  = htmlspecialchars($placeholder, ENT_QUOTES, 'UTF-8');

        // Minimal toolbar (classic spirit; modern convenience)
        $html = "<div{$attrStr}>";
        $html .= "<div class='nce-toolbar' role='toolbar' aria-label='Editor toolbar'>";
        $html .= "<button class='btn2 nce-btn' type='button' data-cmd='bold' aria-label='Bold'><b>B</b></button>";
        $html .= "<button class='btn2 nce-btn' type='button' data-cmd='italic' aria-label='Italic'><i>I</i></button>";
        $html .= "<button class='btn2 nce-btn' type='button' data-cmd='link' aria-label='Insert link'>Link</button>";
        $html .= "<button class='btn2 nce-btn' type='button' data-cmd='quote' aria-label='Quote'>Quote</button>";
        $html .= "<button class='btn2 nce-btn' type='button' data-cmd='code' aria-label='Code'>Code</button>";
        $html .= "<span class='nce-spacer'></span>";
        if ($allowPreview) $html .= "<button class='btn2 nce-btn' type='button' data-cmd='preview' aria-label='Toggle preview'>Preview</button>";
        if ($allowAssist)  $html .= "<button class='btn2 nce-btn' type='button' data-cmd='assist' aria-label='Writing assist'>Assist</button>";
        if ($allowMedia)   $html .= "<button class='btn2 nce-btn' type='button' data-cmd='media' aria-label='Media preview'>Media</button>";
        $html .= "</div>";

        $html .= "<textarea id='".htmlspecialchars($id,ENT_QUOTES,'UTF-8')."' name='".htmlspecialchars($name,ENT_QUOTES,'UTF-8')."' rows='{$rows}' class='nce-text' placeholder='{$safePh}' data-csrf='".htmlspecialchars($csrf,ENT_QUOTES,'UTF-8')."' required>{$safeVal}</textarea>";

        $html .= "<div class='nce-panels'>";
        $html .= "<div class='nce-panel nce-preview' hidden><div class='nce-preview-inner' aria-live='polite'></div></div>";
        $html .= "<div class='nce-panel nce-assist' hidden><div class='nce-assist-inner'></div></div>";
        $html .= "<div class='nce-panel nce-media' hidden><div class='nce-media-inner'></div></div>";
        $html .= "</div>";

        $html .= "<div class='nce-meta muted'><span data-draft-status=''></span><span class='nce-shortcuts'>Shortcuts: <b>Ctrl+B</b>, <b>Ctrl+I</b>, <b>Ctrl+K</b></span></div>";
        $html .= "</div>";

        return $html;
    }
}
