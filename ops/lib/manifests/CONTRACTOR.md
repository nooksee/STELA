<!-- CCD: ff_target="machine-dense" ff_band="10-20" -->
# Contractor Brief

1 Temp path rule uses `var/tmp` only
2 RESULTS generation rule uses `ops/bin/certify` only
3 Receipt rule runs every DP mandated command and treats any skip as STOP
4 Disposable artifact rule treats OPEN dump bundles and manifests as non canonical session artifacts
5 Path rule uses existing repo-relative paths (from repository root) or explicit `NEW` changelog markers; absolute filesystem paths (for example `/home/...` or `/Users/...`) are not allowed; globs and brace expansion are forbidden
