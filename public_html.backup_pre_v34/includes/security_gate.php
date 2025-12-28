<?php
declare(strict_types=1);

/*
 * nukeCE Security Gate
 *
 * Early-request hook that lets NukeSecurity enforce policies before routing.
 * Fail-open by design: must never brick a site.
 */

use NukeCE\Security\NukeSecurity;

if (defined('NUKECE_SECURITY_GATE_RAN')) {
    return;
}
define('NUKECE_SECURITY_GATE_RAN', true);

try {
    if (class_exists(NukeSecurity::class) && method_exists(NukeSecurity::class, 'guardRequest')) {
        NukeSecurity::guardRequest();
    }
} catch (Throwable $e) {
    try {
        if (class_exists(NukeSecurity::class)) {
            NukeSecurity::log('gate', 'guard_exception', ['msg' => $e->getMessage()]);
        }
    } catch (Throwable $ignored) {}
}
