<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Editor;

final class EditorService
{
    private static bool $assetsPrinted = false;

    /** @param array<string,mixed> $options */
    public static function render(string $name, string $value, array $options = []): void
    {
        $cfgFile = dirname(__DIR__, 2) . '/config/config.php';
        $cfg = is_file($cfgFile) ? (array)include $cfgFile : [];

        $global = (bool)($cfg['editor_enabled'] ?? false);
        $scope = (string)($options['scope'] ?? '');
        $scopeEnabled = true;
        if ($scope === 'messages') $scopeEnabled = (bool)($cfg['editor_messages_enabled'] ?? false);
        if ($scope === 'forums') $scopeEnabled = (bool)($cfg['editor_forums_enabled'] ?? false);
        if ($scope === 'news') $scopeEnabled = (bool)($cfg['editor_news_enabled'] ?? false);

        $enabled = $global && $scopeEnabled;

        $id = (string)($options['id'] ?? ('ed_' . preg_replace('/[^a-z0-9_\-]/i','_', $name)));
        $rows = (int)($options['rows'] ?? 10);
        $placeholder = (string)($options['placeholder'] ?? '');

        if (!$enabled) {
            echo "<textarea name='".htmlspecialchars($name,ENT_QUOTES,'UTF-8')."' id='".htmlspecialchars($id,ENT_QUOTES,'UTF-8')."' rows='{$rows}' placeholder='".htmlspecialchars($placeholder,ENT_QUOTES,'UTF-8')."'>"
                . htmlspecialchars($value, ENT_QUOTES, 'UTF-8')
                . "</textarea>";
            return;
        }

        self::assets();

        $escName = htmlspecialchars($name,ENT_QUOTES,'UTF-8');
        $escId = htmlspecialchars($id,ENT_QUOTES,'UTF-8');

        echo "<div class='nukece-editor' data-editor='1'>";
        echo "  <div class='nukece-editor-toolbar' role='toolbar' aria-label='Editor toolbar'>";
        echo self::btn('bold','B','Bold');
        echo self::btn('italic','I','Italic');
        echo self::btn('underline','U','Underline');
        echo self::btn('quote','❝','Quote');
        echo self::btn('code','</>','Code');
        echo self::btn('link','🔗','Link');
        echo self::btn('ul','•','Bullets');
        echo self::btn('ol','1.','Numbered');
        echo "    <button type='button' class='ed-btn ed-preview' data-act='preview'>Preview</button>";
        echo "  </div>";
        echo "  <textarea class='nukece-editor-textarea' name='{$escName}' id='{$escId}' rows='{$rows}' placeholder='".htmlspecialchars($placeholder,ENT_QUOTES,'UTF-8')."'>"
            . htmlspecialchars($value, ENT_QUOTES, 'UTF-8')
            . "</textarea>";
        echo "  <div class='nukece-editor-preview' hidden aria-live='polite'></div>";
        echo "</div>";
    }

    public static function assets(): void
    {
        if (self::$assetsPrinted) return;
        self::$assetsPrinted = true;
        echo "<link rel='stylesheet' href='/assets/editor/editor.css?v=1'>\n";
        echo "<script defer src='/assets/editor/editor.js?v=1'></script>\n";
    }

    private static function btn(string $act, string $label, string $title): string
    {
        $t = htmlspecialchars($title, ENT_QUOTES, 'UTF-8');
        return "<button type='button' class='ed-btn' data-act='{$act}' title='{$t}' aria-label='{$t}'>{$label}</button>";
    }
}
