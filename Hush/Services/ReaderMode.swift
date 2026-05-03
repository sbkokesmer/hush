import Foundation

enum ReaderMode {
    static let script: String = """
    (function() {
      try {
        const candidates = Array.from(document.querySelectorAll(
          'article, main, [role="main"], .post, .article-body, .article, .entry-content, .post-content, .content, #content, #main'
        ));
        let best = null, bestLen = 0;
        for (const c of candidates) {
          const len = (c.innerText || '').trim().length;
          if (len > bestLen) { best = c; bestLen = len; }
        }
        if (!best || bestLen < 200) {
          const all = document.body.querySelectorAll('div, section');
          for (const e of all) {
            if (e.querySelectorAll('div, section').length > 5) continue;
            const len = (e.innerText || '').trim().length;
            if (len > bestLen) { best = e; bestLen = len; }
          }
        }
        if (!best) { return JSON.stringify({ ok: false, reason: 'no-content' }); }

        const title = document.title || (document.querySelector('h1') || {}).innerText || '';
        const html = best.innerHTML;

        document.querySelectorAll('script, iframe, video, audio, embed, object').forEach(el => el.remove());

        document.documentElement.setAttribute('style', 'background:#1a1a1a !important;');
        document.body.setAttribute('style', 'background:#1a1a1a !important; margin:0; padding:0;');
        document.body.innerHTML = `
          <div style="background:#1a1a1a;min-height:100vh;padding:24px 16px 80px;">
            <article style="max-width:680px;margin:0 auto;font:17px/1.7 -apple-system,system-ui,sans-serif;color:#e8e8e8;">
              <h1 style="font:700 28px/1.3 -apple-system,system-ui,sans-serif;color:#fff;margin:0 0 24px;">${title.replace(/[<>]/g, '')}</h1>
              <div id="hush-reader-content">${html}</div>
            </article>
          </div>
        `;
        const content = document.getElementById('hush-reader-content');
        if (content) {
          content.querySelectorAll('*').forEach(el => {
            el.removeAttribute('style');
            el.removeAttribute('class');
            el.removeAttribute('id');
            el.removeAttribute('onclick');
          });
          content.querySelectorAll('img').forEach(img => {
            img.setAttribute('style', 'max-width:100%;height:auto;border-radius:8px;margin:16px 0;display:block;');
          });
          content.querySelectorAll('a').forEach(a => {
            a.setAttribute('style', 'color:#5db3ff;text-decoration:underline;');
          });
          content.querySelectorAll('blockquote').forEach(b => {
            b.setAttribute('style', 'border-left:3px solid #555;margin:16px 0;padding-left:16px;color:#bbb;');
          });
          content.querySelectorAll('pre, code').forEach(c => {
            c.setAttribute('style', 'background:#0d0d0d;color:#e8e8e8;padding:8px 12px;border-radius:6px;font:14px/1.5 ui-monospace,monospace;overflow-x:auto;display:block;');
          });
        }
        return JSON.stringify({ ok: true, length: bestLen });
      } catch(e) {
        return JSON.stringify({ ok: false, reason: e.message });
      }
    })();
    """
}
