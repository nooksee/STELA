/* PHP-Nuke CE (Community Edition / Custom Edition) — nukeCE Editor v1 */
(function () {
  function escapeHtml(s) {
    return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#39;');
  }

  function bbcodeToHtml(input) {
    let s = escapeHtml(input);

    // basic replacements (whitelist)
    s = s.replace(/\r\n/g, "\n");

    // code blocks first
    s = s.replace(/\[code\]([\s\S]*?)\[\/code\]/gi, function(_, c){
      return "<pre><code>" + c + "</code></pre>";
    });

    // quote blocks
    s = s.replace(/\[quote=([^\]]+)\]([\s\S]*?)\[\/quote\]/gi, function(_, who, c){
      return "<blockquote><b>" + who + ":</b><br>" + c + "</blockquote>";
    });
    s = s.replace(/\[quote\]([\s\S]*?)\[\/quote\]/gi, function(_, c){
      return "<blockquote>" + c + "</blockquote>";
    });

    // inline
    s = s.replace(/\[b\]([\s\S]*?)\[\/b\]/gi, "<b>$1</b>");
    s = s.replace(/\[i\]([\s\S]*?)\[\/i\]/gi, "<i>$1</i>");
    s = s.replace(/\[u\]([\s\S]*?)\[\/u\]/gi, "<u>$1</u>");
    s = s.replace(/\[s\]([\s\S]*?)\[\/s\]/gi, "<s>$1</s>");

    // urls
    s = s.replace(/\[url=([^\]]+)\]([\s\S]*?)\[\/url\]/gi, function(_, href, label){
      href = href.replace(/\s+/g,'');
      return "<a href=\"" + href + "\" target=\"_blank\" rel=\"noopener\">" + label + "</a>";
    });
    s = s.replace(/\[url\]([\s\S]*?)\[\/url\]/gi, function(_, href){
      href = href.replace(/\s+/g,'');
      return "<a href=\"" + href + "\" target=\"_blank\" rel=\"noopener\">" + href + "</a>";
    });

    // lists
    s = s.replace(/\[list=1\]([\s\S]*?)\[\/list\]/gi, function(_, body){
      const items = body.split(/\[\*\]/).map(x=>x.trim()).filter(Boolean);
      return "<ol>" + items.map(it=>"<li>"+it+"</li>").join("") + "</ol>";
    });
    s = s.replace(/\[list\]([\s\S]*?)\[\/list\]/gi, function(_, body){
      const items = body.split(/\[\*\]/).map(x=>x.trim()).filter(Boolean);
      return "<ul>" + items.map(it=>"<li>"+it+"</li>").join("") + "</ul>";
    });

    // newlines
    s = s.replace(/\n/g, "<br>");
    return s;
  }

  function wrapSelection(ta, open, close) {
    const start = ta.selectionStart || 0;
    const end = ta.selectionEnd || 0;
    const val = ta.value || "";
    const selected = val.substring(start, end);
    const before = val.substring(0, start);
    const after = val.substring(end);
    const next = before + open + selected + close + after;
    ta.value = next;
    const cursor = start + open.length;
    ta.focus();
    if (selected.length === 0) {
      ta.setSelectionRange(cursor, cursor);
    } else {
      ta.setSelectionRange(start, start + open.length + selected.length + close.length);
    }
  }

  function insertList(ta, ordered) {
    const start = ta.selectionStart || 0;
    const end = ta.selectionEnd || 0;
    const val = ta.value || "";
    const selected = val.substring(start, end) || "";
    const lines = selected ? selected.split(/\r?\n/) : [""];
    const items = lines.map(l => l.trim()).filter(l => l !== "");
    const body = items.length ? items.map(i => "[*]" + i).join("") : "[*]";
    const open = ordered ? "[list=1]" : "[list]";
    const close = "[/list]";
    const before = val.substring(0, start);
    const after = val.substring(end);
    ta.value = before + open + body + close + after;
    ta.focus();
  }

  function bindEditor(root) {
    const ta = root.querySelector(".nukece-editor-textarea");
    const preview = root.querySelector(".nukece-editor-preview");
    const toolbar = root.querySelector(".nukece-editor-toolbar");

    function togglePreview() {
      const on = preview.hasAttribute("hidden");
      if (on) {
        preview.innerHTML = bbcodeToHtml(ta.value || "");
        preview.removeAttribute("hidden");
      } else {
        preview.setAttribute("hidden", "hidden");
      }
    }

    toolbar.addEventListener("click", function (e) {
      const btn = e.target.closest(".ed-btn");
      if (!btn) return;
      const act = btn.getAttribute("data-act");
      if (!act) return;

      if (act === "preview") return togglePreview();
      if (act === "bold") return wrapSelection(ta, "[b]", "[/b]");
      if (act === "italic") return wrapSelection(ta, "[i]", "[/i]");
      if (act === "underline") return wrapSelection(ta, "[u]", "[/u]");
      if (act === "quote") return wrapSelection(ta, "[quote]", "[/quote]");
      if (act === "code") return wrapSelection(ta, "[code]", "[/code]");
      if (act === "link") {
        const url = prompt("Link URL:");
        if (!url) return;
        const start = ta.selectionStart || 0, end = ta.selectionEnd || 0;
        const val = ta.value || "";
        const selected = val.substring(start, end);
        if (selected) return wrapSelection(ta, "[url=" + url + "]", "[/url]");
        return wrapSelection(ta, "[url]" + url, "[/url]");
      }
      if (act === "ul") return insertList(ta, false);
      if (act === "ol") return insertList(ta, true);
    });

    // Update preview live while open
    ta.addEventListener("input", function () {
      if (!preview.hasAttribute("hidden")) {
        preview.innerHTML = bbcodeToHtml(ta.value || "");
      }
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".nukece-editor[data-editor='1']").forEach(bindEditor);
  });
})();
