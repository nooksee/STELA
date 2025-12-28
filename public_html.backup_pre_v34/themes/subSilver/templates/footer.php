<?php ?>
  </div>
  <div class="footer"><small>nukeCE</small></div>
<script>
document.addEventListener('click', (e) => {
  const btn = e.target.closest('.blk-toggle');
  if (!btn) return;
  const block = btn.closest('[data-collapsible="1"]');
  if (!block) return;
  const body = block.querySelector('.ng-block-body,.xh-block-body,.evo-block-body,.content,.xh-block-body');
  if (!body) return;
  const isHidden = body.style.display === 'none';
  body.style.display = isHidden ? '' : 'none';
  btn.setAttribute('aria-expanded', isHidden ? 'true' : 'false');
  btn.textContent = isHidden ? '▾' : '▸';
});
</script>

</body>
</html>
