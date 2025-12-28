<?php
declare(strict_types=1);
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 *
 * NOTE: This is a stub module.
 */

namespace NukeCE\Modules\Recommend;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Layout;

final class RecommendModule implements ModuleInterface
{
    public function getName(): string { return 'recommend'; }

    public function handle(array $params): void
    {
        Layout::header('Recommend');
        echo '<h1>Recommend</h1>';
        echo '<div class="nukece-card">';
        echo '<p>This feature is shipped as an add-on. Enable/install it from repo-root /addons.</p>';
        echo '</div>';
        Layout::footer();
    }
}
