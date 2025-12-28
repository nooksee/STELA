# Admin Maintenance (Gold)

This module provides a unified, AdminUi-consistent maintenance panel:

- Cache control (safe clears)
- Log rotation (file-based, conservative)
- Health checks (runtime + permissions)
- Legacy compatibility status (install/legacy locks)

## Security model

- Requires admin login
- Enforced by SecurityGate if present
- All actions emit NukeSecurity audit events where available

## Notes

- Cache directories checked: `cache/`, `data/cache/`, `tmp/cache/` (if present)
- Log files rotated if present under `data/` and `data/logs/`
- Audit trim is only performed if your NukeSecurity build exposes `NukeSecurity::trimAudit($days)`

