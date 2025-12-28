<?php
declare(strict_types=1);
/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 *
 * NOTE: This is a stub module.
 */

namespace NukeCE\Modules\Faq;

use NukeCE\Core\ModuleInterface;
use NukeCE\Core\Layout;

final class FaqModule implements ModuleInterface
{
    public function getName(): string { return 'faq'; }

    public function handle(array $params): void
    {
        Layout::header('Faq');
        echo '<h1>Faq</h1>';
        echo '<div class="nukece-card">';
        echo '<p>This feature is shipped as an add-on. Enable/install it from repo-root /addons.</p>';
        echo '</div>';
        Layout::footer();
    }
}
