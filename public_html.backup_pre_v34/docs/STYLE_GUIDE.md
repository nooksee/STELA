# PHP-Nuke CE Style Guide

This project keeps the *look and spirit* of classic PHP-Nuke, while modernizing the engine.

## Rules
- **PSR-12** for new/modernized code (enforced via `phpcs.xml`)
- Prefer **small functions**, explicit types (`declare(strict_types=1)`), and prepared statements (PDO)
- No mass refactors of third-party legacy trees (e.g., phpBB) unless required for security

## Formatting tools
- `.editorconfig` enforces whitespace/newlines consistently across editors
- `phpcs.xml` enforces PSR-12 on the first-party code areas
- `.php-cs-fixer.php` is included for optional auto-fixes (use carefully)

## Attribution
Do not remove original author notices. If you touch a file:
- preserve existing copyright/license blocks
- add a short note describing the change and date
