<?php
declare(strict_types=1);

namespace NukeCE\Module;

use NukeCE\Core\ModuleInterface;
use NukeCE\Security\AuthGate;

final class PhpinfoModule implements ModuleInterface
{
    public function handle(array $params): void
    {
        // Security: phpinfo should never be exposed to anonymous users.
        AuthGate::requireAdminOrRedirect();

        // Minimal output, explicit warning.
        header('Content-Type: text/html; charset=utf-8');
        echo '<h1>PHP Info (Admin Only)</h1>';
        echo '<p><strong>Warning:</strong> phpinfo() can leak environment details. Use only for debugging.</p>';
        phpinfo();
    }
}
