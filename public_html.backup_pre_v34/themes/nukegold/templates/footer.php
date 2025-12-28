</main>
    <aside class="ng-right">
      <?php Theme::renderBlocks('right'); ?>
    </aside>
  </div>

  <footer class="ng-footer">
    <div class="ng-footer-inner">
      <div>Powered by <b>nukeCE</b>.</div>
      <div class="ng-footnote">Theme: NukeGold (modernized).</div>
    </div>
  </footer>
</div>
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
