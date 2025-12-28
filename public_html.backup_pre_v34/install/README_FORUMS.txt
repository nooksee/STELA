Forums setup (Option 2: phpBB2x)

Run: php install/setup_forums_download.php
This downloads IntegraMOD/phpBB2x (zipball main) and installs phpBB board files into legacy/modules/Forums.
It stores the downloaded SHA256 in data/phpbb2x.sha256.

After install:
- Configure legacy/modules/Forums/config.php for your DB.
- If you run phpBB install, delete/lock down legacy/modules/Forums/install/ afterwards.

---
SECURITY NOTE (nukeCE):
After installation, create a file named install/LOCK to disable all installer/migration scripts.
You can also delete the /install directory entirely once your site is running.
