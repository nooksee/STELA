# Users & Roles (v1)

nukeCE now includes a shared-hosting friendly users table with three roles:

- member
- editor
- admin

Admin panel login (`module=admin_login`) still exists and grants full admin capabilities.
Separately, a user account with role=admin also grants full capability access.

## Setup
Run:

- `/install/setup_users_roles.php`
- `/install/setup_pages_reference.php` (if you use Pages/Reference)

## Capabilities
Enforced via `src/Security/CapabilityGate.php`:

- `reference.propose`: guest/member/editor/admin (default)
- `content.edit`, `content.publish`: editor/admin
- `reference.queue.*`: editor/admin (approve creates a draft entry)


## Admin UI
- Users & Roles: `/index.php?module=admin_users`
