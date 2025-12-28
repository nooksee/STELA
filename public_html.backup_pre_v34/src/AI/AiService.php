<?php
declare(strict_types=1);

namespace NukeCE\AI;

use NukeCE\Core\SiteConfig;

final class AiService
{
    /** @return array{ok:bool,text:string,meta:array<string,mixed>} */
    public static function run(string $featureKey, string $system, string $user, array $ctx = []): array
    {
        if (AiSettings::killSwitch()) {
            return ['ok'=>false,'text'=>'AI kill switch is enabled.','meta'=>['killswitch'=>true]];
        }
        if (!AiSettings::isEnabled()) {
            return ['ok'=>false,'text'=>'AI is disabled.','meta'=>['enabled'=>false]];
        }
        if (!AiSettings::featureEnabled($featureKey)) {
            return ['ok'=>false,'text'=>'This AI feature is disabled.','meta'=>['feature'=>$featureKey]];
        }

        $providerName = AiSettings::provider();
        $provider = Providers::get($providerName);

        $res = $provider->complete($system, $user, [
            'model' => AiSettings::model(),
            'max_tokens' => AiSettings::maxTokens(),
            'temperature' => AiSettings::temperature() / 100.0,
        ]);

        // log
        AiEventLog::add([
            'actor' => (string)($ctx['actor'] ?? 'system'),
            'source_module' => (string)($ctx['source_module'] ?? ''),
            'source_id' => (string)($ctx['source_id'] ?? ''),
            'feature_key' => $featureKey,
            'provider' => $providerName,
            'model' => AiSettings::model(),
            'prompt' => substr($system . "\n\n" . $user, 0, 20000),
            'response' => substr((string)$res['text'], 0, 20000),
            'meta_json' => json_encode($res['meta'] ?? [], JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES),
            'ok' => !empty($res['ok']),
        ]);

        return $res;
    }
}
