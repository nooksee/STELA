<?php
declare(strict_types=1);

namespace NukeCE\AI;

interface AiProvider
{
    /** @return array{ok:bool,text:string,meta:array<string,mixed>} */
    public function complete(string $system, string $user, array $opts = []): array;
}

final class Providers
{
    public static function get(string $provider): AiProvider
    {
        if ($provider === 'openai') return new OpenAIProvider();
        return new NullProvider();
    }
}

final class NullProvider implements AiProvider
{
    public function complete(string $system, string $user, array $opts = []): array
    {
        return [
            'ok' => false,
            'text' => 'AI is disabled or not configured.',
            'meta' => ['provider' => 'none'],
        ];
    }
}
