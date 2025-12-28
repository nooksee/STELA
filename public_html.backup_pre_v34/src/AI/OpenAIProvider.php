<?php
declare(strict_types=1);

namespace NukeCE\AI;

final class OpenAIProvider implements AiProvider
{
    public function complete(string $system, string $user, array $opts = []): array
    {
        $key = getenv('OPENAI_API_KEY') ?: '';
        if ($key === '') {
            return ['ok'=>false,'text'=>'OPENAI_API_KEY not set.','meta'=>['provider'=>'openai']];
        }

        $model = (string)($opts['model'] ?? 'gpt-4o-mini');
        $maxTokens = (int)($opts['max_tokens'] ?? 512);
        $temperature = (float)($opts['temperature'] ?? 0.2);

        $payload = [
            'model' => $model,
            'messages' => [
                ['role'=>'system','content'=>$system],
                ['role'=>'user','content'=>$user],
            ],
            'max_tokens' => $maxTokens,
            'temperature' => $temperature,
        ];

        $ch = curl_init('https://api.openai.com/v1/chat/completions');
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'Authorization: Bearer ' . $key,
            ],
            CURLOPT_POSTFIELDS => json_encode($payload, JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES),
            CURLOPT_TIMEOUT => 20,
        ]);
        $raw = curl_exec($ch);
        $err = curl_error($ch);
        $code = (int)curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
        curl_close($ch);

        if ($raw === false) {
            return ['ok'=>false,'text'=>'OpenAI request failed: '.$err,'meta'=>['provider'=>'openai','http'=>$code]];
        }

        $j = json_decode($raw, true);
        $text = '';
        if (is_array($j)) {
            $text = (string)($j['choices'][0]['message']['content'] ?? '');
        }

        $ok = ($code >= 200 && $code < 300 && $text !== '');
        return [
            'ok' => $ok,
            'text' => $text !== '' ? $text : 'OpenAI returned no content.',
            'meta' => ['provider'=>'openai','http'=>$code,'model'=>$model],
        ];
    }
}
