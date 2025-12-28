<?php
/**
 * PHP-Nuke CE
 * nukeCE Admin UI helper (Evolution-style grouped panels)
 */
declare(strict_types=1);

final class AdminUi
{
    public static function requireAdmin(): void
    {
        if (class_exists('AuthGate')) {
            AuthGate::requireAdminOrRedirect();
            return;
        }
        // Fallback: allow through (legacy), but this should be rare.
    }

    public static function header(string $title, array $links = []): void
    {
        echo '<div class="nukece-admin">';
        echo '<div class="nukece-admin-head">';
        echo '<h1 class="nukece-admin-title">' . htmlspecialchars($title, ENT_QUOTES, 'UTF-8') . '</h1>';
        echo '<div class="nukece-admin-head-links">';
        foreach ($links as $href => $label) {
            echo '<a class="nukece-admin-head-link" href="' . htmlspecialchars((string)$href, ENT_QUOTES, 'UTF-8') . '">' .
                htmlspecialchars((string)$label, ENT_QUOTES, 'UTF-8') . '</a>';
        }
        echo '</div></div>';
    }

    public static function footer(): void
    {
        echo '</div>';
    }

    public static function groupStart(string $title, string $subtitle = ''): void
    {
        echo '<section class="nukece-admin-group">';
        echo '<div class="nukece-admin-group-head">';
        echo '<div class="nukece-admin-group-title">' . htmlspecialchars($title, ENT_QUOTES, 'UTF-8') . '</div>';
        if ($subtitle !== '') {
            echo '<div class="nukece-admin-group-subtitle">' . htmlspecialchars($subtitle, ENT_QUOTES, 'UTF-8') . '</div>';
        }
        echo '</div>';
        echo '<div class="nukece-admin-group-body">';
    }

    public static function groupEnd(): void
    {
        echo '</div></section>';
    }

    public static function button(string $href, string $label, string $variant = 'primary'): string
    {
        $cls = 'nukece-btn nukece-btn-' . preg_replace('/[^a-z0-9_-]/i', '', $variant);
        return '<a class="' . $cls . '" href="' . htmlspecialchars($href, ENT_QUOTES, 'UTF-8') . '">' .
            htmlspecialchars($label, ENT_QUOTES, 'UTF-8') . '</a>';
    }

    public static function resolveIcon(string $name): string
    {
        $theme = defined('NUKECE_THEME') ? NUKECE_THEME : (isset($GLOBALS['theme']) ? (string)$GLOBALS['theme'] : '');
        $candidates = [];
        if ($theme !== '') {
            $candidates[] = NUKECE_ROOT . "/themes/{$theme}/images/admin/{$name}.svg";
            $candidates[] = NUKECE_ROOT . "/themes/{$theme}/images/admin/{$name}.png";
        }
        $candidates[] = NUKECE_ROOT . "/assets/originals/admin/{$name}.svg";
        $candidates[] = NUKECE_ROOT . "/assets/originals/admin/{$name}.png";

        foreach ($candidates as $p) {
            if (is_file($p)) {
                return str_replace(NUKECE_ROOT, '', $p);
            }
        }
        return '';
    }

    public static function tile(string $href, string $label, string $desc, string $iconName): void
    {
        $iconPath = self::resolveIcon($iconName);
        echo '<a class="nukece-admin-tile" href="' . htmlspecialchars($href, ENT_QUOTES, 'UTF-8') . '">';
        if ($iconPath !== '') {
            echo '<div class="nukece-admin-icon"><img alt="" src="' . htmlspecialchars($iconPath, ENT_QUOTES, 'UTF-8') . '" /></div>';
        } else {
            echo '<div class="nukece-admin-icon nukece-admin-icon-fallback"></div>';
        }
        echo '<div class="nukece-admin-meta">';
        echo '<div class="nukece-admin-label">' . htmlspecialchars($label, ENT_QUOTES, 'UTF-8') . '</div>';
        echo '<div class="nukece-admin-desc">' . htmlspecialchars($desc, ENT_QUOTES, 'UTF-8') . '</div>';
        echo '</div></a>';
    }
}
