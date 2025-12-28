<?php
/**
 * PHP-Nuke CE (Community Edition)
 * AI client shim.
 *
 * This module integrates with the nukeCE AI subsystem when present.
 * If not present or disabled, calls are safe no-ops.
 */

declare(strict_types=1);

namespace NukeCE\Ai;

final class AiClient
{
    public static function enabled(): bool
    {
        // Prefer existing global config if present.
        if (defined('NUKECE_AI_ENABLED')) {
            return (bool) NUKECE_AI_ENABLED;
        }
        // Try reading from a common config array.
        global $nukece_config;
        if (is_array($nukece_config) && isset($nukece_config['ai_enabled'])) {
            return (bool) $nukece_config['ai_enabled'];
        }
        return false;
    }

    /**
     * Fetch a preview for a URL: summary + suggested tags.
     * Returns ['summary' => string, 'tags' => string[]] or null.
     */
    public static function previewUrl(string $url): ?array
    {
        if (!self::enabled()) {
            return null;
        }

        // If an official AI service exists, use it.
        if (class_exists('\\NukeCE\\AI\\Service')) {
            try {
                /** @var object $svc */
                $svc = \NukeCE\AI\Service::instance();
                $res = $svc->previewUrl($url);
                if (is_array($res)) {
                    return [
                        'summary' => (string)($res['summary'] ?? ''),
                        'tags' => array_values(array_filter((array)($res['tags'] ?? []), 'is_string')),
                    ];
                }
            } catch (\Throwable $e) {
                return null;
            }
        }

        // Otherwise: no provider.
        return null;
    }
}
