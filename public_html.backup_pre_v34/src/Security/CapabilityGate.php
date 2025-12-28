\
<?php
declare(strict_types=1);

/*
 * PHP-Nuke CE (Community Edition / Custom Edition)
 * Project name in-code: nukeCE
 *
 * Capability gate (v2):
 * - Backed by real users/roles (member/editor/admin).
 * - Admin auth (admin_login) still exists and implies "admin" capability.
 */

namespace NukeCE\Security;

final class CapabilityGate
{
    /**
     * Require a capability; redirects if not allowed.
     */
    public static function require(string $capability): void
    {
        if (!self::allowed($capability)) {
            // If logged out, send to login. If logged in but forbidden, send home.
            if (!UserAuth::isLoggedIn()) {
                header('Location: /index.php?module=users&op=login');
            } else {
                header('Location: /index.php');
            }
            exit;
        }
    }

    public static function allowed(string $capability): bool
    {
        // Admin panel login implies full admin power.
        if (AuthGate::isAdmin()) return true;

        $role = UserAuth::role(); // guest/member/editor/admin
        if ($role === 'admin') return true;

        // Guest baseline (public browsing)
        $guestCaps = [
            'reference.propose', // public proposals allowed by default
        ];

        // Member baseline
        $memberCaps = [
            'reference.propose',
        ];

        // Editor baseline
        $editorCaps = array_merge($memberCaps, [
            'content.edit',
            'content.publish',
            'reference.edit',
            'reference.publish',
            'reference.queue.review',
            'reference.queue.approve',
            'reference.queue.reject',
        ]);

        if ($role === 'guest') {
            return in_array($capability, $guestCaps, true);
        }
        if ($role === 'member') {
            return in_array($capability, $memberCaps, true);
        }
        if ($role === 'editor') {
            return in_array($capability, $editorCaps, true);
        }

        return false;
    }
}
