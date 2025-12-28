<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 *
 * Legacy compatibility alias:
 * encyclopedia -> reference
 */

namespace NukeCE\Modules\Encyclopedia;

use NukeCE\Core\ModuleInterface;

final class EncyclopediaModule implements ModuleInterface
{
    public function getName(): string { return 'encyclopedia'; }

    public function handle(array $params): void
    {
        // Legacy shim: encyclopedia is now 'reference'
        header('Location: /index.php?module=reference', true, 302);
        exit;
    }
}
