<?php
declare(strict_types=1);


/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Blocks;

use NukeCE\Core\Theme;

/**
 * Classic Nuke-style blocks runtime.
 *
 * Storage model (shared-hosting friendly):
 * - data/blocks.json controls enabled/disabled, order, and position (left/right/center).
 * - blocks/*.php are block files. Each block file MUST return a callable:
 *     function(array $ctx): string
 *
 * Blocks are rendered inside the Layout wrapper (user pages) and can also be
 * embedded by modules.
 */
final class BlockManager
{
    private string $root;
    private string $blocksDir;
    private string $stateFile;
    private string $cacheDir;

    public function __construct(string $rootDir)
    {
        $this->root = rtrim($rootDir, '/\\');
        $this->blocksDir = $this->root . '/blocks';
        $this->stateFile = $this->root . '/data/blocks.json';
        $this->cacheDir = $this->root . '/data/block_cache';
        if (!is_dir($this->cacheDir)) @mkdir($this->cacheDir, 0755, true);
        if (!is_dir($this->root . '/data')) @mkdir($this->root . '/data', 0755, true);
        if (!is_file($this->stateFile)) {
            $this->saveState($this->defaultState());
        }
    }

    /** @return array<string,mixed> */
    public function getState(): array
    {
        $raw = @file_get_contents($this->stateFile);
        $j = $raw ? json_decode($raw, true) : null;
        return is_array($j) ? $j : $this->defaultState();
    }

    public function saveState(array $state): void
    {
        @file_put_contents($this->stateFile, json_encode($state, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT), LOCK_EX);
    }

    /** @return array<int,array<string,mixed>> */
    public function listAvailableBlocks(): array
    {
        $out = [];
        foreach (glob($this->blocksDir . '/*.php') ?: [] as $f) {
            $id = basename($f, '.php');
            $out[] = ['id' => $id, 'file' => basename($f)];
        }
        usort($out, fn($a,$b) => strcmp($a['id'],$b['id']));
        return $out;
    }

    public function renderPosition(string $position, array $ctx = []): string
    {
        $state = $this->getState();
        $blocks = is_array($state['blocks'] ?? null) ? $state['blocks'] : [];
        $order = is_array($state['order'][$position] ?? null) ? $state['order'][$position] : [];

        // Build ordered list using saved order then append remaining enabled blocks in that position.
        $byId = [];
        foreach ($blocks as $b) {
            if (!is_array($b)) continue;
            if (($b['position'] ?? '') !== $position) continue;
            if (!empty($b['disabled'])) continue;
            $id = (string)($b['id'] ?? '');
            if ($id === '') continue;
            $byId[$id] = $b;
        }

        $ids = [];
        foreach ($order as $id) {
            if (isset($byId[$id])) $ids[] = $id;
        }
        foreach (array_keys($byId) as $id) {
            if (!in_array($id, $ids, true)) $ids[] = $id;
        }

        $html = '';
        foreach ($ids as $id) {
            $html .= $this->renderBlock($id, $ctx);
        }
        return $html;
    }

    public function renderBlock(string $id, array $ctx = []): string
    {
        $id = preg_replace('/[^a-z0-9_]/i', '', $id) ?? $id;
        $file = $this->blocksDir . '/' . $id . '.php';
        if (!is_file($file)) return '';
        $fn = include $file;
        if (!is_callable($fn)) return '';

        // Optional cache (per-block TTL in seconds) set via Blocks Admin.
        $ttl = 0;
        $state = $this->getState();
        foreach ((array)($state['blocks'] ?? []) as $b) {
            if (!is_array($b)) continue;
            if ((string)($b['id'] ?? '') === $id) { $ttl = (int)($b['cache_ttl'] ?? 0); break; }
        }
        if ($ttl > 0) {
            $cacheFile = $this->cacheDir . '/' . $id . '.json';
            if (is_file($cacheFile)) {
                $raw = @file_get_contents($cacheFile);
                $j = $raw ? json_decode($raw, true) : null;
                if (is_array($j) && isset($j['ts'], $j['html']) && (time() - (int)$j['ts'] < $ttl)) {
                    return (string)$j['html'];
                }
            }
        }

        try {
            $content = (string)($fn)($ctx);
        } catch (\Throwable $e) {
            $content = "<small class='muted'>Block error: " . htmlspecialchars($e->getMessage(), ENT_QUOTES, 'UTF-8') . "</small>";
        }

        $title = htmlspecialchars($this->titleForBlock($id), ENT_QUOTES, 'UTF-8');
        $html = Theme::block($title, $content);
        if ($ttl > 0) {
            $cacheFile = $this->cacheDir . '/' . $id . '.json';
            @file_put_contents($cacheFile, json_encode(['ts'=>time(),'html'=>$html], JSON_UNESCAPED_SLASHES));
        }
        return $html;
    }

    private function titleForBlock(string $id): string
    {
        $map = [
            'news_recent' => 'News',
            'forums_links' => 'Forums',
            'nukesecurity_threats' => 'NukeSecurity',
        ];
        return $map[$id] ?? ucwords(str_replace('_',' ', $id));
    }

    /** @return array<string,mixed> */
    private function defaultState(): array
    {
        return [
            'version' => 1,
            'blocks' => [
                ['id' => 'news_recent', 'position' => 'right', 'disabled' => false],
                ['id' => 'forums_links', 'position' => 'right', 'disabled' => false],
                ['id' => 'nukesecurity_threats', 'position' => 'right', 'disabled' => false],
            ],
            'order' => [
                'left' => [],
                'right' => ['news_recent','forums_links','nukesecurity_threats'],
                'center' => [],
            ],
        ];
    }
}
