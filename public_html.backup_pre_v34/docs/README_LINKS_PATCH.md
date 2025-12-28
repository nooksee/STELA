# nukeCE Links module + Core Blocks Gold Patch

This package is an **overlay** (copy on top of your current nukeCE install). It contains:

- **Links** module (modernized Web Links) with:
  - categories + link listings
  - submit flow + admin moderation queue
  - link health checks (admin-run)
  - AI assist hooks (optional): preview summary + tag suggestions (assist-only)
  - “Propose to Reference” handoff (optional)
- **Blocks (Gold)** updates:
  - Admin block
  - User/Login block
  - Search block
  - Languages block
  - Who’s Online block
  - Waiting Content block
  - NukeSecurity status block

## Why “Links” but legacy “Web Links” graphics still work
The module is named **Links** in code and URLs.
For icons/buttons, the theme asset resolver prefers `links.*` but will automatically fall back to `weblinks.*` if present in legacy themes.

## Install steps
1. Back up your site files + database.
2. Extract this zip into your nukeCE web root.
3. Apply database schema:
   - Run: `install/sql/links.sql`
4. In Admin:
   - Enable module: **Links**
   - Enable blocks you want (Links Categories / New Links)

## AI integration (assist-only)
If your nukeCE build includes the Admin AI subsystem, Links will automatically:
- Offer an **“AI Preview”** button in the moderation queue to fetch:
  - link summary
  - suggested tags
- Never auto-approve.
- All accepts/rejects are human-only and auditable.

If AI is disabled or not configured, the module runs normally.

## Health checks
Admin Links includes:
- **Check links now** (HEAD/GET probe with timeout)
- Marks links as OK / Redirect / Broken
- Optional: create **Reference proposal** entries for curated links

