<?php
header('Content-Type: text/html; charset=utf-8');
?>
<!doctype html>
<html><head><meta charset="utf-8"><title>Forums - index</title></head>
<body>
  <h1>Forums (legacy stub): index</h1>
  <p>This is a minimal phpBB2-style stub shipped with nukeCE_full so the wrapper + rewrite tooling is testable.</p>
  <ul>
    <li><a href='index.php'>Forum index</a></li><li><a href='viewforum.php?f=1'>View forum</a></li><li><a href='viewtopic.php?t=123'>View topic</a></li><li><a href='posting.php?mode=newtopic&f=1'>Post new</a></li><li><a href='profile.php?mode=viewprofile&u=2'>Profile</a></li><li><a href='search.php?search_keywords=test'>Search</a></li><li><a href='album.php'>Album</a></li><li><a href='attach_rules.php'>Attachment rules</a></li><li><a href='admin.php'>Admin (should be denied)</a></li><li><a href='install.php'>Install (should be denied)</a></li><li><a href='images/logo.png'>Asset logo</a></li>
  </ul>
  <form method="post" action="posting.php?mode=reply&t=123">
    <input type="text" name="subject" value="Hello">
    <button type="submit">Post</button>
  </form>
</body></html>
