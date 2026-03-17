# Verification Manifest Spec

## Purpose
`ops/etc/verification.manifest` is the lane-policy source for `tools/verify.sh` and certify replay routing.

## Required Scalars
- `verification_manifest_version`
- `default_mode`
- `gates_mode`
- `certify_mode`

## Lane Definition Contract
Each `lane=` row must declare:
- lane name
- `order`
- `modes`
- `command`
- `scope`
- `owner`
- `registry_table`
- `registry_path`
- `reason_class`
- `decision_leaf`
- `match`

## Reason Classes
- `closeout-critical`
- `packet-local`
- `standalone-full-only`

## Contract
- `tools/verify.sh --mode=full` runs all lanes in order
- `tools/verify.sh --mode=certify-critical` runs closeout-critical lanes and packet-local lanes on path match
- `tools/verify.sh --mode=gates` consumes the same lane policy for PR routing
- lane policy must resolve `Infra Importance` from the canonical registries
