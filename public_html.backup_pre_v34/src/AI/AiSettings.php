<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\AI;

use NukeCE\Core\SiteConfig;

/**
 * DB-backed AI settings. Secrets stay in env/config (e.g., OPENAI_API_KEY).
 */
final class AiSettings
{
    public static function isEnabled(): bool
    {
        return (bool) (SiteConfig::get('ai.enabled', false, 'bool'));
    }

    public static function provider(): string
    {
        return (string) (SiteConfig::get('ai.provider', 'none', 'string'));
    }

    public static function model(): string
    {
        return (string) (SiteConfig::get('ai.model', 'gpt-4o-mini', 'string'));
    }

    public static function featureEnabled(string $featureKey): bool
    {
        return (bool) (SiteConfig::get('ai.feature.' . $featureKey, false, 'bool'));
    }

    public static function killSwitch(): bool
    {
        return (bool) (SiteConfig::get('ai.killswitch', false, 'bool'));
    }

    public static function maxTokens(): int
    {
        return (int) (SiteConfig::get('ai.max_tokens', 512, 'int'));
    }

    public static function temperature(): int
    {
        // store as int 0-100 to keep DB simple
        return (int) (SiteConfig::get('ai.temperature', 20, 'int'));
    }
}
