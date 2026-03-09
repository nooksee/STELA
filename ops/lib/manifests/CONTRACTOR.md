<!-- CCD: ff_target="machine-dense" ff_band="30-40" -->
# Contractor Brief

## Rules

1 Temp path rule uses `var/tmp` only
2 RESULTS generation rule uses `ops/bin/certify` only
3 Receipt rule runs every DP mandated command and treats any skip as STOP
4 Disposable artifact rule treats OPEN dump bundles and manifests as non canonical session artifacts
5 Use repo-relative paths only in all output. Never print absolute filesystem paths. Do not emit clickable file links.
