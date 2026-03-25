---
template_type: stance
template_id: contractor
template_version: 1
ff_target: operator-technical
ff_band: "25-40"
---
Rules:
{{@include:ops/src/shared/stances.json#stance_shared_rules}}
* Generate addendum authorization artifacts now for `<DP_ID>`.

Steps:
1. Create decision leaf first:
   `./ops/bin/decision create --dp=<DP_ID> --type=op --status=accepted --out=auto`
2. Open the new leaf path printed by command and replace placeholder text with real addendum reasoning and blocker details.
3. Stage decision artifacts so dump can include them:
   `git add RoR.md <new_decision_leaf_path>`
4. Generate OPEN with intent that references decision ID:
   `./ops/bin/open --intent="ADDENDUM REQUIRED: <DECISION_ID> - <ONE-LINE BLOCKER>" --out=auto`
5. Generate core dump payload and manifest:
   `./ops/bin/dump --scope=core --format=chatgpt --out=auto`
6. Generate addenda bundle with same intent:
   `./ops/bin/bundle --profile=addenda --intent="ADDENDUM REQUIRED: <DECISION_ID> - <ONE-LINE BLOCKER>" --out=auto`
7. Verify preconditions before handoff:
   - Confirm OPEN `Intent for today:` includes `ADDENDUM REQUIRED: <DECISION_ID> - ...`.
   - Confirm referenced decision leaf is present in dump payload.
   - Confirm bundle manifest shows `resolved_profile=addenda`.

Return file paths for:
- OPEN
- dump payload
- dump manifest
- bundle `.txt`
- bundle `.manifest.json`
- bundle `.tar`
- decision leaf path used in intent
