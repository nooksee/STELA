# nukeCE v27 (Consolidation merge)

Build date (UTC): 2025-12-27T19:30:14.457515Z

## Baseline
- Uses your hand-assembled `nukece_compiled_assistant_code_022725.zip` as the baseline tree (through v25 decisions).
- Overlays the latest NukeSecurity work from v26 (Tor + GeoIP importer polish + gate wiring).

## NukeSecurity features now present
- Early request gate is wired in `index.php` and `admin.php`.
- GeoIP importer UI (staged + resumable + auto-step + header validation + cleanup option).
- Tor exit-node feed + stale warning panel.

## Evidence pointers
- `includes/security_gate.php`
- `src/Security/GeoIpImporter.php`
- `src/Security/TorExit.php`
- `modules/admin_nukesecurity/AdminNukesecurityModule.php`
- `docs/GEOIP_IMPORTER.md`
- `docs/TOR_FEED.md`
