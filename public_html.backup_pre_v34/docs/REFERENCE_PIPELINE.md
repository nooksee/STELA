# Reference Intake Pipeline (v1)

Doctrine:
- AI can propose; humans canonize.
- Canon is published only by users with curation capability.

Current implementation:
- Public `Reference` module includes a **Propose** form.
- Proposals are stored in the `ref_queue` table as `status=new`.
- Admins review in `admin_reference` and can:
  - Mark reviewing
  - Reject
  - Approve → create a draft entry in `ref_entries`

Capability model:
- v1 uses `CapabilityGate` mapped to the existing admin check.
- Later: wire to real user roles/permissions via NukeSecurity policy.

Tables:
- ref_entries
- ref_tags
- ref_entry_tags
- ref_queue
