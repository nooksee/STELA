<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Core;

use NukeCE\Core\MobileMode;

/**
 * Theme runtime (classic spirit, safer structure).
 *
 * - Themes live under /themes/<slug>/
 * - Each theme should provide:
 *   - info.json
 *   - templates/header.php, templates/footer.php, templates/block.php
 *
 * Selection:
 * - default: config['theme_default']
 * - optional user override via cookie: config['theme_cookie_name'] (if allowed)
 * - optional request preview: ?theme=<slug> (admin only in the future; currently enabled if exists)
 */
final class Theme
{
    private static ?array $cfg = null;
    private static ?string $active = null;

    public static function header(string $title): void
    {
        $slug = self::activeSlug();
        $tpl = self::themePath($slug, 'templates/header.php');

        if (is_file($tpl)) {
            $themeSlug = $slug;
            include $tpl;
            return;
        }

        // Fallback: minimal HTML if a theme is missing
        $t = htmlspecialchars($title, ENT_QUOTES, 'UTF-8');
        echo "<!doctype html><html lang='en'><head><meta charset='utf-8'><meta name='viewport' content='width=device-width, initial-scale=1'>";
        echo "<title>{$t}</title></head><body><div style='padding:10px;background:#111;color:#fff'><b>nukeCE</b></div><div style='padding:12px'>";
    }

    public static function footer(): void
    {
        $slug = self::activeSlug();
        $tpl = self::themePath($slug, 'templates/footer.php');

        if (is_file($tpl)) {
            include $tpl;
            return;
        }

        echo "</div></body></html>";
    }

    public static function block(string $title, string $content): string
    {
        $slug = self::activeSlug();
        $tpl = self::themePath($slug, 'templates/block.php');

        
        $collapsible = (bool)self::feature('collapsible_blocks', false, $slug);
$titleHtml = $title;     // already escaped upstream
        $contentHtml = $content; // already sanitized/escaped upstream

        if (is_file($tpl)) {
            ob_start();
            include $tpl;
            return (string)ob_get_clean();
        }

        return "<section style='border:1px solid #ddd;padding:10px;margin-bottom:10px'><b>{$titleHtml}</b><div>{$contentHtml}</div></section>";
    }

    private static ?array $state = null;

private static function state(): array
{
    if (self::$state !== null) return self::$state;
    $root = defined('NUKECE_ROOT') ? NUKECE_ROOT : dirname(__DIR__, 2);
    $file = rtrim($root, '/\\') . '/data/themes_state.json';
    if (is_file($file)) {
        $raw = @file_get_contents($file);
        $j = $raw ? json_decode($raw, true) : null;
        if (is_array($j)) {
            self::$state = $j;
            return self::$state;
        }
    }
    self::$state = [];
    return self::$state;
}

public static function isEnabled(string $slug): bool
{
    $st = self::state();
    $enabled = $st['enabled'] ?? null;
    if (!is_array($enabled) || !$enabled) return true; // default: all installed enabled
    foreach ($enabled as $s) {
        if (is_string($s) && strtolower($s) === strtolower($slug)) return true;
    }
    return false;
}

public static function allowUserSelection(): bool
{
    $st = self::state();
    if (array_key_exists('allow_user', $st)) return (bool)$st['allow_user'];
    $cfg = self::config();
        $default = self::defaultSlug();
    return (bool)($cfg['theme_allow_user'] ?? true);
}

public static function defaultSlug(): string
{
    $st = self::state();
    if (is_string($st['default'] ?? null) && $st['default'] !== '') return (string)$st['default'];
    $cfg = self::config();
        $default = self::defaultSlug();
    return (string)($cfg['theme_default'] ?? 'nukegold');
}

public static function configCookieName(): string
{
    $cfg = self::config();
        $default = self::defaultSlug();
    return (string)($cfg['theme_cookie_name'] ?? 'nukece_theme');
}

    public static function activeSlug(): string
    {
        if (self::$active !== null) return self::$active;

        $cfg = self::config();
        $default = self::defaultSlug();
        $default = is_string($cfg['theme_default'] ?? null) ? (string)$cfg['theme_default'] : 'nukegold';
        $cookieName = is_string($cfg['theme_cookie_name'] ?? null) ? (string)$cfg['theme_cookie_name'] : 'nukece_theme';
        $allowUser = (bool)($cfg['theme_allow_user'] ?? false);

        $slug = $default;

        // Mobile mode can force a lightweight theme (unless user explicitly chose a theme)
        $mobileForced = false;
        if (MobileMode::isMobileRequest()) {
            $mslug = MobileMode::themeSlug();
            if ($mslug && is_dir(self::themeDir($mslug)) && self::isEnabled($mslug)) {
                $slug = $mslug;
                $mobileForced = true;
            }
        }

        // Preview via query param (only if theme exists)
        if (!empty($_GET['theme']) && is_string($_GET['theme'])) {
            $candidate = strtolower(preg_replace('/[^a-z0-9_\-]/i', '', $_GET['theme']));
            if ($candidate && is_dir(self::themeDir($candidate)) && self::isEnabled($candidate)) {
                $slug = $candidate;
            }
        } elseif ($allowUser && !empty($_COOKIE[$cookieName]) && is_string($_COOKIE[$cookieName])) {
            $candidate = strtolower(preg_replace('/[^a-z0-9_\-]/i', '', $_COOKIE[$cookieName]));
            if ($candidate && is_dir(self::themeDir($candidate)) && self::isEnabled($candidate)) {
                $slug = $candidate;
            }
        }

        
        if (!self::isEnabled($slug) || !is_dir(self::themeDir($slug))) {
            foreach (self::listThemes() as $t) {
                if (!empty($t['enabled'])) { $slug = (string)$t['slug']; break; }
            }
        }
        self::$active = $slug;
        return $slug;
    }

    public static function themeDir(string $slug): string
    {
        $root = defined('NUKECE_ROOT') ? NUKECE_ROOT : dirname(__DIR__, 2);
        return rtrim($root, '/\\') . '/themes/' . $slug;
    }

    public static function themePath(string $slug, string $rel): string
    {
        return rtrim(self::themeDir($slug), '/\\') . '/' . ltrim($rel, '/\\');
    }

    public static function listThemes(): array
    {
        $dir = defined('NUKECE_ROOT') ? NUKECE_ROOT . '/themes' : dirname(__DIR__, 2) . '/themes';
        if (!is_dir($dir)) return [];

        $out = [];
        foreach (glob($dir . '/*', GLOB_ONLYDIR) ?: [] as $p) {
            $slug = basename($p);
            $infoFile = $p . '/info.json';
            $info = ['slug' => $slug, 'name' => $slug];
            $info['enabled'] = self::isEnabled($slug);
            if (is_file($infoFile)) {
                $raw = @file_get_contents($infoFile);
                $j = $raw ? json_decode($raw, true) : null;
                if (is_array($j)) {
                    $info = array_merge($info, $j);
                }
            }
            $out[] = $info;
        }
        usort($out, fn($a,$b) => strcmp((string)($a['slug'] ?? ''), (string)($b['slug'] ?? '')));
        return $out;
    }

    private static function config(): array
    {
        if (self::$cfg !== null) return self::$cfg;

        $file = defined('NUKECE_ROOT') ? NUKECE_ROOT . '/config/config.php' : dirname(__DIR__, 2) . '/config/config.php';
        if (is_file($file)) {
            $cfg = include $file;
            self::$cfg = is_array($cfg) ? $cfg : [];
        } else {
            self::$cfg = [];
        }
        return self::$cfg;
    }
/** @return array<string,mixed> */
public static function features(string $slug = ''): array
{
    $slug = $slug !== '' ? $slug : self::activeSlug();
    $file = self::rootDir() . '/data/theme_features.json';
    if (!is_file($file)) return [];
    $raw = @file_get_contents($file);
    $j = $raw ? json_decode($raw, true) : null;
    if (!is_array($j)) return [];
    $themes = is_array($j['themes'] ?? null) ? $j['themes'] : [];
    return is_array($themes[$slug] ?? null) ? $themes[$slug] : [];
}

public static function feature(string $key, mixed $default = null, string $slug = ''): mixed
{
    $f = self::features($slug);
    return array_key_exists($key, $f) ? $f[$key] : $default;
}

public static function setFeatures(string $slug, array $features): void
{
    $slug = preg_replace('/[^a-z0-9_\-]/i', '', $slug) ?? $slug;
    $file = self::rootDir() . '/data/theme_features.json';
    if (!is_dir(dirname($file))) @mkdir(dirname($file), 0755, true);
    $j = ['version' => 1, 'themes' => []];
    if (is_file($file)) {
        $raw = @file_get_contents($file);
        $cur = $raw ? json_decode($raw, true) : null;
        if (is_array($cur)) $j = $cur;
    }
    if (!is_array($j['themes'] ?? null)) $j['themes'] = [];
    $j['themes'][$slug] = $features;
    @file_put_contents($file, json_encode($j, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
}

private static function rootDir(): string
{
    return dirname(__DIR__, 2);
}

/**
 * Render blocks for a theme position.
 */
public static function renderBlocks(string $position, array $ctx = []): void
{
    $bm = new \NukeCE\Blocks\BlockManager(self::rootDir());
    echo $bm->renderPosition($position, $ctx);
}

}
