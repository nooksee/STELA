<?php
declare(strict_types=1);

namespace NukeCE\Module;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Renderer;

final class PunishModule implements ModuleInterface
{
    public function handle(array $params): void
    {
        Renderer::header('Punish');
        echo '<div class="content">';
        echo '<h2>Punish</h2>';
        echo '<p>This module is scaffolded for nukeCE. Implementation pending.</p>';
        echo '</div>';
        Renderer::footer();
    }
}
