# Secure Webroot Option (If You Insist on Everything Under `public_html/`)

**Recommendation:** keep `_meta/` **outside** webroot. This is safer and cleaner.

If you still want a single tree (e.g., for a simple hosting environment), do this:

## Layout
```
public_html/
  (web files...)
  _meta/            # move `_meta` here
```

## Apache (.htaccess)
Create `public_html/_meta/.htaccess`:
```
Require all denied
```

For older Apache:
```
Deny from all
```

Also deny other non-public dirs if you add them later (e.g., `_private/`, `_transcripts/`).

## Nginx
In your server block:
```
location ^~ /_meta/ { deny all; return 403; }
```

## PHP fallback guard (last resort)
If you cannot rely on server rules, place an `index.php` inside `_meta/` that immediately exits with 403.

## Why this still isn’t ideal
Mistakes happen: misconfigured servers, copied folders, dev environments, etc. Keeping meta out of webroot is the "no sharp edges" default.
