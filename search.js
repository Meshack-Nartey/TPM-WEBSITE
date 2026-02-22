/* ===========================================
   TPM Site Search
   Overlay search using window.TPM_SEARCH_INDEX
   =========================================== */
(function () {
    'use strict';

    var overlay, input, results, activeIndex = -1;

    /* ---- Build overlay DOM ---- */
    function buildOverlay() {
        overlay = document.createElement('div');
        overlay.className = 'search-overlay';
        overlay.setAttribute('role', 'dialog');
        overlay.setAttribute('aria-modal', 'true');
        overlay.setAttribute('aria-label', 'Search');

        overlay.innerHTML = [
            '<div class="search-overlay-inner">',
            '  <div class="search-bar-wrap">',
            '    <span class="search-icon-inline">',
            '      <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>',
            '    </span>',
            '    <input id="searchInput" type="search" class="search-input" placeholder="Search books, sermons, pages…" autocomplete="off" spellcheck="false">',
            '    <button class="search-close-btn" aria-label="Close search">',
            '      <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>',
            '    </button>',
            '  </div>',
            '  <ul class="search-results" role="listbox"></ul>',
            '  <p class="search-hint">Start typing to search across all pages, books, and media</p>',
            '</div>'
        ].join('');

        document.body.appendChild(overlay);

        input   = overlay.querySelector('#searchInput');
        results = overlay.querySelector('.search-results');

        /* Events */
        overlay.querySelector('.search-close-btn').addEventListener('click', closeSearch);
        overlay.addEventListener('click', function (e) {
            if (e.target === overlay) closeSearch();
        });
        input.addEventListener('input', onInput);
        input.addEventListener('keydown', onKeydown);
    }

    /* ---- Open / close ---- */
    function openSearch() {
        overlay.classList.add('open');
        document.body.classList.add('search-open');
        setTimeout(function () { input.focus(); }, 50);
        activeIndex = -1;
    }

    function closeSearch() {
        overlay.classList.remove('open');
        document.body.classList.remove('search-open');
        input.value = '';
        results.innerHTML = '';
        overlay.querySelector('.search-hint').style.display = '';
        activeIndex = -1;
    }

    /* Instant close — skips CSS transition, used when navigating to a result */
    function closeSearchInstant() {
        overlay.style.transition = 'none';
        overlay.style.opacity = '0';
        overlay.style.visibility = 'hidden';
        document.body.classList.remove('search-open');
        input.value = '';
        results.innerHTML = '';
        overlay.querySelector('.search-hint').style.display = '';
        activeIndex = -1;
        /* Restore transition after hide so future opens animate normally */
        setTimeout(function () {
            overlay.classList.remove('open');
            overlay.style.transition = '';
            overlay.style.opacity = '';
            overlay.style.visibility = '';
        }, 50);
    }

    /* ---- Search logic ---- */
    function onInput() {
        var query = input.value.trim();
        var hint  = overlay.querySelector('.search-hint');

        if (!query) {
            results.innerHTML = '';
            hint.style.display = '';
            activeIndex = -1;
            return;
        }

        hint.style.display = 'none';

        var terms   = query.toLowerCase().split(/\s+/).filter(Boolean);
        var index   = window.TPM_SEARCH_INDEX || [];
        var matched = index.filter(function (item) {
            var hay = (item.title + ' ' + item.desc + ' ' + item.category).toLowerCase();
            return terms.every(function (t) { return hay.indexOf(t) !== -1; });
        }).slice(0, 8);

        renderResults(matched, query);
    }

    function renderResults(items, query) {
        activeIndex = -1;

        if (!items.length) {
            results.innerHTML = '<li class="search-no-results">No results for <strong>"' + escHtml(query) + '"</strong></li>';
            return;
        }

        results.innerHTML = items.map(function (item, i) {
            return [
                '<li class="search-result-item" role="option" data-index="' + i + '" data-url="' + escHtml(item.url) + '">',
                '  <a href="' + escHtml(item.url) + '" class="search-result-link" tabindex="-1">',
                '    <span class="search-result-cat">' + escHtml(item.category) + '</span>',
                '    <span class="search-result-title">' + highlight(item.title, query) + '</span>',
                '    <span class="search-result-desc">'  + highlight(item.desc,  query) + '</span>',
                '  </a>',
                '</li>'
            ].join('');
        }).join('');

        /* Click on result — close instantly, then let the <a> navigate */
        results.querySelectorAll('.search-result-link').forEach(function (a) {
            a.addEventListener('click', function () {
                closeSearchInstant();
            });
        });
    }

    /* ---- Keyboard navigation ---- */
    function onKeydown(e) {
        var items = results.querySelectorAll('.search-result-item');
        if (!items.length) {
            if (e.key === 'Escape') closeSearch();
            return;
        }

        if (e.key === 'ArrowDown') {
            e.preventDefault();
            setActive(items, Math.min(activeIndex + 1, items.length - 1));
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            setActive(items, Math.max(activeIndex - 1, -1));
        } else if (e.key === 'Enter') {
            if (activeIndex >= 0 && items[activeIndex]) {
                var url = items[activeIndex].getAttribute('data-url');
                if (url) { closeSearchInstant(); window.location.href = url; }
            }
        } else if (e.key === 'Escape') {
            closeSearch();
        }
    }

    function setActive(items, idx) {
        items.forEach(function (li) { li.classList.remove('active'); });
        activeIndex = idx;
        if (idx >= 0 && items[idx]) {
            items[idx].classList.add('active');
            items[idx].scrollIntoView({ block: 'nearest' });
        }
    }

    /* ---- Utilities ---- */
    function escHtml(str) {
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }

    function highlight(text, query) {
        var safe  = escHtml(text);
        var terms = query.trim().split(/\s+/).filter(Boolean);
        terms.forEach(function (term) {
            var re = new RegExp('(' + term.replace(/[.*+?^${}()|[\]\\]/g, '\\$&') + ')', 'gi');
            safe = safe.replace(re, '<mark>$1</mark>');
        });
        return safe;
    }

    /* ---- Global open trigger ---- */
    window.openTPMSearch = openSearch;

    /* ---- Init ---- */
    document.addEventListener('DOMContentLoaded', function () {
        buildOverlay();

        /* Keyboard shortcut: / or Ctrl+K opens search */
        document.addEventListener('keydown', function (e) {
            var tag = document.activeElement ? document.activeElement.tagName : '';
            if (tag === 'INPUT' || tag === 'TEXTAREA') return;
            if (e.key === '/' || (e.ctrlKey && e.key === 'k')) {
                e.preventDefault();
                openSearch();
            }
        });
    });
})();
