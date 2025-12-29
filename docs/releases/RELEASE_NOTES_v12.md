# nukeCE v12 (Track A: Coherence + Security Hardening)

Build date (UTC): 2025-12-27T00:03:45.667395Z

## Scope
- Module loadability/coherence
- HTTP deny guardrails for sensitive paths
- Embed triage docs + v12 plan in boot/docs


## Changes

### Modules
- Added missing entrypoint classes:
  - `modules/clubs/ClubsModule.php`
  - `modules/punish/PunishModule.php`
  - `modules/phpinfo/PhpinfoModule.php` (admin-gated)


### Security hardening
- Added `.htaccess` deny rules to prevent direct HTTP access:
  - `install/`
  - `config/`
  - `includes/`


### Docs
- Added `boot/docs/triage/*` and `boot/docs/v12_TRACK_A_PLAN.md`.
