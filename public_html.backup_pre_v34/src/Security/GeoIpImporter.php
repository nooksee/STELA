<?php
declare(strict_types=1);

namespace NukeCE\Security;

use NukeCE\Core\StoragePaths;
use NukeCE\Core\SafeFile;
use PDO;

final class GeoIpImporter
{
    private const STATE_FILE = 'geoip_import_state.json';
    private const STAGE_DIR  = 'nukesecurity/geoip';

    private function __construct() {}

    public static function stageDir(): string
    {
        return StoragePaths::join(StoragePaths::uploadsDir(), self::STAGE_DIR);
    }

    public static function statePath(): string
    {
        return StoragePaths::join(self::stageDir(), self::STATE_FILE);
    }

    public static function loadState(): array
    {
        $p = self::statePath();
        if (!is_file($p)) return [];
        $raw = @file_get_contents($p);
        $j = $raw ? json_decode($raw, true) : null;
        return is_array($j) ? $j : [];
    }

    public static function saveState(array $state): bool
    {
        return SafeFile::writeAtomic(self::statePath(), json_encode($state, JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES));
    }

    public static function reset(bool $deleteStaged = false): void
    {
        $state = self::loadState();
        if ($deleteStaged) {
            self::cleanupStaged($state);
        } else {
            @unlink(self::statePath());
        }
    }

    public static function stageUpload(string $key, array $file): array
    {
        $allowed = [
            'locations'  => 'locations.csv',
            'country_v4' => 'country_v4.csv',
            'country_v6' => 'country_v6.csv',
            'asn_v4'     => 'asn_v4.csv',
            'asn_v6'     => 'asn_v6.csv',
        ];
        if (!isset($allowed[$key])) return ['ok'=>false,'msg'=>'Invalid upload key'];
        if (!isset($file['tmp_name']) || !is_uploaded_file($file['tmp_name'])) return ['ok'=>false,'msg'=>'Upload missing'];

        $dir = self::stageDir();
        if (!is_dir($dir)) @mkdir($dir, 0755, true);

        $dest = StoragePaths::join($dir, $allowed[$key]);
        if (!@move_uploaded_file($file['tmp_name'], $dest)) return ['ok'=>false,'msg'=>'Failed moving upload'];

        // header sanity check
        $hdr = self::readHeader($dest);
        if (!self::validateHeader($key, $hdr)) {
            @unlink($dest);
            return ['ok'=>false,'msg'=>'CSV header did not look like expected format for '.$key];
        }

        $state = self::loadState();
        $state['status'] = $state['status'] ?? 'staged';
        $state['staged'] = $state['staged'] ?? [];
        $state['staged'][$key] = [
            'path' => $dest,
            'bytes' => (int)@filesize($dest),
            'staged_at' => gmdate('c'),
            'header' => $hdr,
        ];
        self::saveState($state);

        return ['ok'=>true,'msg'=>'Staged: '.$allowed[$key]];
    }

    public static function begin(PDO $pdo, int $chunkLines = 5000, bool $cleanupOnDone = false): array
    {
        $state = self::loadState();
        $staged = $state['staged'] ?? [];
        if (!$staged) return ['ok'=>false,'msg'=>'No staged files. Upload CSVs first.'];

        $state['status'] = 'importing';
        $state['chunk_lines'] = max(200, min(20000, $chunkLines));
        $state['cleanup_staged'] = $cleanupOnDone;
        $state['progress'] = $state['progress'] ?? [];
        $state['started_at'] = $state['started_at'] ?? gmdate('c');

        foreach (array_keys($staged) as $k) {
            $state['progress'][$k] = $state['progress'][$k] ?? ['offset'=>0,'done'=>false,'rows'=>0,'errors'=>0];
        }

        self::saveState($state);
        return ['ok'=>true,'msg'=>'Import started'];
    }

    public static function step(PDO $pdo): array
    {
        $state = self::loadState();
        if (($state['status'] ?? '') !== 'importing') {
            return ['ok'=>false,'msg'=>'Not importing. Click Start/Resume Import first.'];
        }

        $chunk = (int)($state['chunk_lines'] ?? 5000);
        $staged = $state['staged'] ?? [];
        $progress = $state['progress'] ?? [];

        $order = ['locations','country_v4','country_v6','asn_v4','asn_v6'];
        $nextKey = null;
        foreach ($order as $k) {
            if (isset($staged[$k]) && empty($progress[$k]['done'])) { $nextKey = $k; break; }
        }
        if (!$nextKey) {
            $state['status'] = 'done';
            $state['finished_at'] = gmdate('c');
            self::saveState($state);
            if (!empty($state['cleanup_staged'])) self::cleanupStaged($state);
            return ['ok'=>true,'msg'=>'All imports complete','done'=>true];
        }

        $path = (string)($staged[$nextKey]['path'] ?? '');
        if (!$path || !is_file($path)) {
            $progress[$nextKey]['done'] = true;
            $progress[$nextKey]['errors'] = (int)($progress[$nextKey]['errors'] ?? 0) + 1;
            $state['progress'] = $progress;
            self::saveState($state);
            return ['ok'=>true,'msg'=>'Missing staged file; skipping '.$nextKey,'done'=>false];
        }

        $offset = (int)($progress[$nextKey]['offset'] ?? 0);
        $fh = @fopen($path, 'rb');
        if (!$fh) {
            $progress[$nextKey]['done'] = true;
            $progress[$nextKey]['errors'] = (int)($progress[$nextKey]['errors'] ?? 0) + 1;
            $state['progress'] = $progress;
            self::saveState($state);
            return ['ok'=>true,'msg'=>'Could not open '.$nextKey.'; marked done','done'=>false];
        }

        $lineNo = 0;
        $rows = 0;
        $errors = 0;

        // Seek to offset line count
        while ($lineNo < $offset && !feof($fh)) {
            fgets($fh);
            $lineNo++;
        }

        // If offset is 0, read/discard header (already validated at stage time)
        if ($offset === 0) {
            fgets($fh);
            $lineNo++;
        }

        $pdo->beginTransaction();
        try {
            while ($rows < $chunk && !feof($fh)) {
                $line = fgets($fh);
                if ($line === false) break;
                $lineNo++;
                $cols = str_getcsv(trim($line));
                if (!$cols || count($cols) < 2) continue;

                try {
                    self::importRow($pdo, $nextKey, $cols);
                    $rows++;
                } catch (\Throwable $e) {
                    $errors++;
                }
            }
            $pdo->commit();
        } catch (\Throwable $e) {
            $pdo->rollBack();
            fclose($fh);
            return ['ok'=>false,'msg'=>'DB error during import step: '.$e->getMessage()];
        }
        fclose($fh);

        $progress[$nextKey]['offset'] = $lineNo;
        $progress[$nextKey]['rows'] = (int)($progress[$nextKey]['rows'] ?? 0) + $rows;
        $progress[$nextKey]['errors'] = (int)($progress[$nextKey]['errors'] ?? 0) + $errors;

        if (self::isEOF($path, $lineNo)) {
            $progress[$nextKey]['done'] = true;
        }

        $state['progress'] = $progress;
        self::saveState($state);

        return ['ok'=>true,'msg'=>'Imported '.$rows.' rows from '.$nextKey.' (errors '.$errors.')','done'=>false,'file'=>$nextKey];
    }

    public static function runMultiple(PDO $pdo, int $steps = 5): array
    {
        $steps = max(1, min(25, $steps));
        $last = null;
        for ($i=0; $i<$steps; $i++) {
            $last = self::step($pdo);
            if (!empty($last['done'])) break;
            if (isset($last['ok']) && $last['ok'] === false) break;
        }
        return $last ?: ['ok'=>false,'msg'=>'No steps executed'];
    }

    private static function validateHeader(string $key, array $header): bool
    {
        $h = array_map('strtolower', $header);
        $need = [
            'locations'  => ['geoname_id','country_iso_code','country_name'],
            'country_v4' => ['network','geoname_id'],
            'country_v6' => ['network','geoname_id'],
            'asn_v4'     => ['network','autonomous_system_number','autonomous_system_organization'],
            'asn_v6'     => ['network','autonomous_system_number','autonomous_system_organization'],
        ];
        if (!isset($need[$key])) return true;

        $hits = 0;
        foreach ($need[$key] as $n) {
            foreach ($h as $col) {
                if ($col === $n) { $hits++; break; }
            }
        }
        // Require at least 2 matching columns (robust to MaxMind adding columns)
        return $hits >= 2;
    }

    private static function readHeader(string $path): array
    {
        $fh = @fopen($path, 'rb');
        if (!$fh) return [];
        $line = fgets($fh);
        fclose($fh);
        if ($line === false) return [];
        return str_getcsv(trim($line));
    }

    private static function isEOF(string $path, int $lineNo): bool
    {
        $fh = @fopen($path, 'rb');
        if (!$fh) return true;
        $c = 0;
        while ($c < $lineNo && !feof($fh)) { fgets($fh); $c++; }
        $test = fgets($fh);
        $eof = ($test === false);
        fclose($fh);
        return $eof;
    }

    private static function cleanupStaged(array $state): void
    {
        $staged = $state['staged'] ?? [];
        foreach ($staged as $info) {
            $p = (string)($info['path'] ?? '');
            if ($p && is_file($p)) @unlink($p);
        }
        @unlink(self::statePath());
    }

    private static function importRow(PDO $pdo, string $key, array $c): void
    {
        if ($key === 'locations') {
            $geoname = (int)($c[0] ?? 0);
            $iso = (string)($c[4] ?? '');
            $name = (string)($c[5] ?? '');
            if (!$geoname) return;
            $stmt = $pdo->prepare("REPLACE INTO nsec_geoip_locations (geoname_id, country_iso_code, country_name) VALUES (?,?,?)");
            $stmt->execute([$geoname, $iso, $name]);
            return;
        }

        if ($key === 'country_v4') {
            $net = (string)($c[0] ?? '');
            $geo = (int)($c[1] ?? 0);
            if (!$net || !$geo) return;
            [$s,$e] = self::cidrToV4Range($net);
            $stmt = $pdo->prepare("REPLACE INTO nsec_geoip_country_v4 (start_int, end_int, geoname_id) VALUES (?,?,?)");
            $stmt->execute([$s,$e,$geo]);
            return;
        }

        if ($key === 'country_v6') {
            $net = (string)($c[0] ?? '');
            $geo = (int)($c[1] ?? 0);
            if (!$net || !$geo) return;
            [$s,$e] = self::cidrToV6RangeBin($net);
            $stmt = $pdo->prepare("REPLACE INTO nsec_geoip_country_v6 (start_bin, end_bin, geoname_id) VALUES (?,?,?)");
            $stmt->execute([$s,$e,$geo]);
            return;
        }

        if ($key === 'asn_v4') {
            $net = (string)($c[0] ?? '');
            $asn = (int)($c[1] ?? 0);
            $org = (string)($c[2] ?? '');
            if (!$net || !$asn) return;
            [$s,$e] = self::cidrToV4Range($net);
            $stmt = $pdo->prepare("REPLACE INTO nsec_geoip_asn_v4 (start_int, end_int, asn, org) VALUES (?,?,?,?)");
            $stmt->execute([$s,$e,$asn,$org]);
            return;
        }

        if ($key === 'asn_v6') {
            $net = (string)($c[0] ?? '');
            $asn = (int)($c[1] ?? 0);
            $org = (string)($c[2] ?? '');
            if (!$net || !$asn) return;
            [$s,$e] = self::cidrToV6RangeBin($net);
            $stmt = $pdo->prepare("REPLACE INTO nsec_geoip_asn_v6 (start_bin, end_bin, asn, org) VALUES (?,?,?,?)");
            $stmt->execute([$s,$e,$asn,$org]);
            return;
        }
    }

    private static function cidrToV4Range(string $cidr): array
    {
        [$ip, $mask] = array_pad(explode('/', $cidr, 2), 2, '32');
        $mask = (int)$mask;
        $ipLong = ip2long($ip);
        if ($ipLong === false) return [0,0];
        $netmask = $mask === 0 ? 0 : (~0 << (32 - $mask));
        $start = $ipLong & $netmask;
        $end = $start + (2 ** (32 - $mask)) - 1;
        $start = (int)sprintf('%u', $start);
        $end = (int)sprintf('%u', $end);
        return [$start, $end];
    }

    private static function cidrToV6RangeBin(string $cidr): array
    {
        [$ip, $mask] = array_pad(explode('/', $cidr, 2), 2, '128');
        $mask = (int)$mask;
        $bin = inet_pton($ip);
        if ($bin === false) return ['', ''];
        $start = self::v6Network($bin, $mask);
        $end = self::v6Broadcast($start, $mask);
        return [$start, $end];
    }

    private static function v6Network(string $bin, int $mask): string
    {
        $bytes = unpack('C*', $bin);
        $out = [];
        $bits = $mask;
        foreach ($bytes as $b) {
            if ($bits >= 8) { $out[] = $b; $bits -= 8; continue; }
            if ($bits <= 0) { $out[] = 0; continue; }
            $m = (0xFF << (8 - $bits)) & 0xFF;
            $out[] = $b & $m;
            $bits = 0;
        }
        return pack('C*', ...$out);
    }

    private static function v6Broadcast(string $network, int $mask): string
    {
        $bytes = unpack('C*', $network);
        $out = [];
        $bits = $mask;
        foreach ($bytes as $b) {
            if ($bits >= 8) { $out[] = $b; $bits -= 8; continue; }
            if ($bits <= 0) { $out[] = 255; continue; }
            $m = (0xFF >> $bits) & 0xFF;
            $out[] = $b | $m;
            $bits = 0;
        }
        return pack('C*', ...$out);
    }
}
