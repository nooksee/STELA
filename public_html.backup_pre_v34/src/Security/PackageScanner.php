<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Security;

final class PackageScanner
{
    /**
     * Basic static scan for "classic webshell/obfuscation" indicators.
     * This is NOT malware detection; it is a safety lens for admins.
     *
     * @return array{ok:bool, findings:array<int,array{severity:string,file:string,rule:string,detail:string}>}
     */
    public static function scanPath(string $absolutePath, int $maxFiles = 2000): array
    {
        $findings = [];
        $files = [];

        if (is_dir($absolutePath)) {
            $it = new \RecursiveIteratorIterator(
                new \RecursiveDirectoryIterator($absolutePath, \FilesystemIterator::SKIP_DOTS)
            );
            foreach ($it as $f) {
                if (count($files) >= $maxFiles) break;
                /** @var \SplFileInfo $f */
                if ($f->isFile()) $files[] = $f->getPathname();
            }
        } elseif (is_file($absolutePath)) {
            $files[] = $absolutePath;
        }

        $rules = [
            ['high','eval', '/\beval\s*\(/i', 'Use of eval()'],
            ['high','base64_decode', '/\bbase64_decode\s*\(/i', 'Use of base64_decode()'],
            ['high','gzinflate', '/\bgzinflate\s*\(/i', 'Use of gzinflate()'],
            ['high','assert', '/\bassert\s*\(/i', 'Use of assert()'],
            ['med','preg_replace_e', '/preg_replace\s*\(\s*.*\/e['"]\s*,/i', 'preg_replace /e modifier'],
            ['med','shell_exec', '/\bshell_exec\s*\(|\bexec\s*\(|\bpassthru\s*\(|\bsystem\s*\(/i', 'Shell execution function'],
            ['med','curl_remote', '/\bcurl_exec\s*\(|\bfile_get_contents\s*\(\s*['"]https?:\/\//i', 'Remote fetch call'],
            ['low','obfuscation', '/\$[a-z0-9_]{1,4}\s*=\s*\$[a-z0-9_]{1,4}\s*\./i', 'Possible obfuscation pattern'],
        ];

        foreach ($files as $file) {
            $ext = strtolower(pathinfo($file, PATHINFO_EXTENSION));
            if (!in_array($ext, ['php','inc','phtml','js','txt','md','html','htm'])) continue;

            $data = @file_get_contents($file, false, null, 0, 200000);
            if (!is_string($data) || $data === '') continue;

            foreach ($rules as [$sev,$rule,$rx,$detail]) {
                if (preg_match($rx, $data)) {
                    $findings[] = [
                        'severity' => (string)$sev,
                        'file' => (string)$file,
                        'rule' => (string)$rule,
                        'detail' => (string)$detail,
                    ];
                }
            }
        }

        usort($findings, function($a,$b){
            $rank = ['high'=>0,'med'=>1,'low'=>2];
            return ($rank[$a['severity']] ?? 9) <=> ($rank[$b['severity']] ?? 9);
        });

        return ['ok'=>true,'findings'=>$findings];
    }
}
