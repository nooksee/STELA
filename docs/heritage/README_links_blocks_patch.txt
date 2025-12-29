nukeCE Links Blocks Patch: Queue + Top Links + Reference Shortcut
===============================================================

Adds 3 blocks:

1) blocks/block_links_queue.php
   - Admin-only view of pending link submissions (count + quick jump to queue).

2) blocks/block_links_top.php
   - Public top links list by hits.

3) blocks/block_reference_propose_link.php
   - Shortcut for editors/reviewers to propose a link into Reference queue
     (human review, never auto-canonized).

Notes:
- Uses $prefix.'_links_links' table with columns: lid,title,url,status,hits,date,submitter.
- Assumes Reference module supports op=submit&type=link.
- Permissions:
  - links.admin (for queue block)
  - reference.submit (for propose shortcut) via NukeSecurity when available.
