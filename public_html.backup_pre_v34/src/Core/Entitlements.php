<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 */

namespace NukeCE\Core;

use NukeCE\Security\AuthGate;

final class Entitlements
{
    /**
     * Return true if the current user has the given tier.
     * If the Memberships add-on is not installed, this safely returns false.
     */
    public static function currentUserHasTier(string $tierSlug): bool
    {
        $username = AuthGate::currentUsername() ?: '';
        if ($username === '') return false;

        if (class_exists('NukeCE\\Modules\\Memberships\\Gate')) {
            return \NukeCE\Modules\Memberships\Gate::userHasTier($username, $tierSlug);
        }
        return false;
    }

    /**
     * Render a classic-friendly "requires supporters" message.
     */
    public static function renderRequires(string $tierSlug, string $message = ''): void
    {
        $label = class_exists('NukeCE\\Core\\Labels') ? \NukeCE\Core\Labels::get('memberships', 'Members') : 'Members';
        $tier = htmlspecialchars($tierSlug, ENT_QUOTES, 'UTF-8');
        $label = htmlspecialchars($label, ENT_QUOTES, 'UTF-8');
        echo "<div class='nukece-card'><h3>Restricted</h3>";
        echo "<p>This item requires $label tier: <strong>$tier</strong>.</p>";
        if ($message !== '') echo "<p>" . htmlspecialchars($message, ENT_QUOTES, 'UTF-8') . "</p>";
        echo "</div>";
    }
}
