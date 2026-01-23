Project Context: php-nuke-ce (Stela)
Goal
Explainable, governable legacy modernization. We prioritize clear provenance and working code over process.

Critical Rules (Gates)
- No direct pushes to main. Work on work/* branches -> PR -> merge.
- Run verification before review: bash tools/verify_tree.sh

Repository Map
public_html/: Runtime webroot. The code that runs.
upstream/: Read-only donor snapshots. Reference only.
tools/: Verification scripts and repo tooling.
docs/: Human reference.

Workflow
Read TASK.md (local).
Edit code in a work/* branch.
Verify: bash tools/verify_tree.sh
Commit and open a PR.
