<!-- CCD: ff_target="operator-technical" ff_band="25-40" -->
## **Contractor (OPEN + DUMP + ADDENDUM REQUIRED)**

Generate addendum authorization artifacts now for <DP_ID>.

1. Create decision leaf first:
./ops/bin/decision create --dp=<DP_ID> --type=op --status=accepted --out=auto

2. Open the new leaf (path printed by the command), replace placeholder text with real addendum reasoning/blocker details.

3. Stage the decision artifacts so dump can include them:
git add RoR.md <new_decision_leaf_path>

4. Generate OPEN with intent that references the decision ID:
./ops/bin/open --intent="ADDENDUM REQUIRED: <DECISION_ID> - <ONE-LINE BLOCKER>" --out=auto

5. Generate core dump payload + manifest:
./ops/bin/dump --scope=core --format=chatgpt --out=auto

6. Verify preconditions before handoff:
- Confirm OPEN `Intent for today:` includes `ADDENDUM REQUIRED: <DECISION_ID> - ...`.
- Confirm the referenced decision leaf is present in the dump payload.

7. Optional convenience bundle:
./ops/bin/bundle --profile=audit --out=auto

Return file paths for:
- OPEN
- dump payload
- dump manifest
- bundle .txt
- bundle .manifest.json
- decision leaf path used in intent
