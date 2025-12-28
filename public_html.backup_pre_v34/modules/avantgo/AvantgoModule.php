<?php
declare(strict_types=1);
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 *
 * NOTE: This is a stub module.
 */

namespace NukeCE\Modules\Avantgo;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Layout;

final class AvantgoModule implements ModuleInterface
{
    public function getName(): string { return 'avantgo'; }

    public function handle(array $params): void
    {
        header('Location: /mobile', true, 301);
        exit;
        Layout::header('Avantgo');
        echo '<h1>Avantgo</h1>';
        echo '<div class="nukece-card">';
        echo '<p>Legacy redirect: AvantGo has been replaced by Mobile.</p>';
        echo '</div>';
        Layout::footer();
    }
}
