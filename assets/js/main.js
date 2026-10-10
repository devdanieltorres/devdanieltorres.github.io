/* Daniel Torres — portfólio
   Script clássico (defer). Sem dependências e sem fetch, para funcionar também
   ao abrir os arquivos direto do disco (file://). */
(function () {
  'use strict';

  var root = document.documentElement;
  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var $ = function (sel, ctx) { return (ctx || document).querySelector(sel); };
  var $$ = function (sel, ctx) { return Array.prototype.slice.call((ctx || document).querySelectorAll(sel)); };

  /* ---------------------------------------------------------- tema --- */
  var themeMeta = $('meta[name="theme-color"]');
  function applyTheme(theme) {
    root.setAttribute('data-theme', theme);
    if (themeMeta) themeMeta.setAttribute('content', theme === 'light' ? '#f5f6f8' : '#07090d');
    $$('[data-theme-toggle]').forEach(function (btn) {
      btn.setAttribute('aria-label', theme === 'light' ? 'Ativar tema escuro' : 'Ativar tema claro');
    });
  }
  applyTheme(root.getAttribute('data-theme') || 'dark');
  $$('[data-theme-toggle]').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var next = root.getAttribute('data-theme') === 'light' ? 'dark' : 'light';
      var swap = function () {
        applyTheme(next);
        try { localStorage.setItem('theme', next); } catch (e) { /* armazenamento indisponível */ }
      };
      if (document.startViewTransition && !reduceMotion) document.startViewTransition(swap);
      else swap();
    });
  });

  /* ------------------------------------------------ header ao rolar --- */
  var header = $('.site-header');
  if (header) {
    var ticking = false;
    var onScroll = function () {
      if (ticking) return;
      ticking = true;
      requestAnimationFrame(function () {
        header.toggleAttribute('data-scrolled', window.scrollY > 8);
        ticking = false;
      });
    };
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
  }

  /* ---------------------------------------------------- menu mobile --- */
  var mobileNav = $('#mobile-nav');
  if (mobileNav && typeof mobileNav.showModal === 'function') {
    $$('[data-menu-open]').forEach(function (btn) {
      btn.addEventListener('click', function () {
        mobileNav.showModal();
        btn.setAttribute('aria-expanded', 'true');
      });
    });
    mobileNav.addEventListener('close', function () {
      $$('[data-menu-open]').forEach(function (b) { b.setAttribute('aria-expanded', 'false'); });
    });
    $$('[data-menu-close], a', mobileNav).forEach(function (el) {
      el.addEventListener('click', function () { mobileNav.close(); });
    });
  }

  /* ------------------------------------- item ativo do menu (página) --- */
  var page = root.getAttribute('data-page');
  if (page) {
    $$('[data-nav="' + page + '"]').forEach(function (a) { a.setAttribute('aria-current', 'page'); });
  }

  /* ------------------------------------------ scroll-spy (âncoras) --- */
  function spy(links, rootMargin) {
    var map = new Map();
    links.forEach(function (a) {
      var id = decodeURIComponent(a.getAttribute('href').split('#')[1] || '');
      var target = id && document.getElementById(id);
      if (target) {
        if (!map.has(target)) map.set(target, []);
        map.get(target).push(a);
      }
    });
    if (!map.size || !('IntersectionObserver' in window)) return;
    var visible = new Set();
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) { e.isIntersecting ? visible.add(e.target) : visible.delete(e.target); });
      var current = null;
      map.forEach(function (_, target) { if (!current && visible.has(target)) current = target; });
      map.forEach(function (as, target) {
        as.forEach(function (a) {
          if (target === current) a.setAttribute('aria-current', 'true');
          else if (a.getAttribute('aria-current') === 'true') a.removeAttribute('aria-current');
        });
      });
    }, { rootMargin: rootMargin });
    map.forEach(function (_, target) { io.observe(target); });
  }
  spy($$('.nav a[href^="#"], .mobile-nav a[href^="#"]'), '-40% 0px -55% 0px');
  spy($$('.toc a[href^="#"]'), '-20% 0px -70% 0px');

  /* ------------------------------------------------ revelar ao rolar --- */
  var reveals = $$('.reveal');
  if (reveals.length) {
    if ('IntersectionObserver' in window && !reduceMotion) {
      var rio = new IntersectionObserver(function (entries) {
        entries.forEach(function (e) {
          if (e.isIntersecting) { e.target.classList.add('is-visible'); rio.unobserve(e.target); }
        });
      }, { rootMargin: '0px 0px -8% 0px', threshold: 0.08 });
      reveals.forEach(function (el) { rio.observe(el); });
    } else {
      reveals.forEach(function (el) { el.classList.add('is-visible'); });
    }
  }

  /* ------------------------------------------- brilho que segue o mouse --- */
  if (window.matchMedia('(hover: hover)').matches) {
    $$('[data-spotlight]').forEach(function (el) {
      el.addEventListener('pointermove', function (ev) {
        var r = el.getBoundingClientRect();
        el.style.setProperty('--mx', (ev.clientX - r.left) + 'px');
        el.style.setProperty('--my', (ev.clientY - r.top) + 'px');
      });
    });
  }

  /* ---------------------------------------- tempo de experiência --- */
  function monthsSince(ym, until) {
    var p = ym.split('-');
    var start = new Date(+p[0], +p[1] - 1, 1);
    var end = until ? new Date(+until.split('-')[0], +until.split('-')[1] - 1, 1) : new Date();
    return (end.getFullYear() - start.getFullYear()) * 12 + (end.getMonth() - start.getMonth()) + (until ? 1 : 0);
  }
  $$('[data-years-since]').forEach(function (el) {
    el.textContent = String(Math.floor(monthsSince(el.getAttribute('data-years-since')) / 12));
  });
  $$('[data-duration-from]').forEach(function (el) {
    var m = monthsSince(el.getAttribute('data-duration-from'), el.getAttribute('data-duration-to'));
    var y = Math.floor(m / 12), mm = m % 12, parts = [];
    if (y) parts.push(y + (y > 1 ? ' anos' : ' ano'));
    if (mm) parts.push(mm + (mm > 1 ? ' meses' : ' mês'));
    el.textContent = parts.join(' e ') || '1 mês';
  });
  $$('[data-year]').forEach(function (el) { el.textContent = String(new Date().getFullYear()); });

  /* ------------------------------------------------- copiar e-mail --- */
  var toast;
  function showToast(msg) {
    if (!toast) {
      toast = document.createElement('div');
      toast.className = 'toast';
      toast.setAttribute('role', 'status');
      document.body.appendChild(toast);
    }
    toast.textContent = msg;
    toast.classList.add('is-visible');
    clearTimeout(showToast.t);
    showToast.t = setTimeout(function () { toast.classList.remove('is-visible'); }, 2200);
  }
  $$('[data-copy]').forEach(function (btn) {
    btn.addEventListener('click', function (ev) {
      ev.preventDefault();
      var text = btn.getAttribute('data-copy');
      var done = function () { showToast('E-mail copiado'); };
      if (navigator.clipboard && window.isSecureContext) {
        navigator.clipboard.writeText(text).then(done, function () { window.prompt('Copie o e-mail:', text); });
      } else {
        var ta = document.createElement('textarea');
        ta.value = text; ta.setAttribute('readonly', ''); ta.style.position = 'fixed'; ta.style.opacity = '0';
        document.body.appendChild(ta); ta.select();
        try { document.execCommand('copy'); done(); } catch (e) { window.prompt('Copie o e-mail:', text); }
        ta.remove();
      }
    });
  });

  /* ------------------------------------------------------ lightbox --- */
  var galleryLinks = $$('[data-lightbox]');
  if (galleryLinks.length && typeof HTMLDialogElement === 'function') {
    var icon = function (d) {
      return '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="' + d + '"/></svg>';
    };
    var dlg = document.createElement('dialog');
    dlg.className = 'lightbox';
    dlg.setAttribute('aria-label', 'Visualização ampliada');
    dlg.innerHTML =
      '<div class="lightbox__top"><span class="lightbox__count" aria-live="polite"></span>' +
      '<button class="icon-button" type="button" data-close aria-label="Fechar">' + icon('M18 6 6 18M6 6l12 12') + '</button></div>' +
      '<div class="lightbox__stage">' +
      '<button class="icon-button lightbox__nav lightbox__nav--prev" type="button" data-prev aria-label="Imagem anterior">' + icon('m15 18-6-6 6-6') + '</button>' +
      '<img alt="">' +
      '<button class="icon-button lightbox__nav lightbox__nav--next" type="button" data-next aria-label="Próxima imagem">' + icon('m9 18 6-6-6-6') + '</button>' +
      '</div>' +
      '<div class="lightbox__bottom"><p class="lightbox__caption"></p></div>';
    document.body.appendChild(dlg);

    var img = $('img', dlg), caption = $('.lightbox__caption', dlg), count = $('.lightbox__count', dlg);
    var items = [], index = 0;

    var preload = function (i) {
      var it = items[(i + items.length) % items.length];
      if (it) { var p = new Image(); p.src = it.href; }
    };
    var show = function (i) {
      index = (i + items.length) % items.length;
      var it = items[index];
      img.src = it.href;
      img.alt = it.alt;
      caption.textContent = it.caption;
      count.textContent = (index + 1) + ' / ' + items.length;
      $('[data-prev]', dlg).hidden = $('[data-next]', dlg).hidden = items.length < 2;
      preload(index + 1); preload(index - 1);
    };

    galleryLinks.forEach(function (a) {
      a.addEventListener('click', function (ev) {
        ev.preventDefault();
        var group = a.closest('[data-gallery]') || document;
        var links = $$('[data-lightbox]', group);
        items = links.map(function (l) {
          var im = $('img', l);
          return { href: l.getAttribute('href'), alt: im ? im.alt : '', caption: l.getAttribute('data-caption') || '' };
        });
        show(links.indexOf(a));
        dlg.showModal();
      });
    });

    $('[data-close]', dlg).addEventListener('click', function () { dlg.close(); });
    $('[data-prev]', dlg).addEventListener('click', function () { show(index - 1); });
    $('[data-next]', dlg).addEventListener('click', function () { show(index + 1); });
    dlg.addEventListener('click', function (ev) {
      if (ev.target === dlg || ev.target.classList.contains('lightbox__stage')) dlg.close();
    });
    dlg.addEventListener('keydown', function (ev) {
      if (ev.key === 'ArrowLeft') { ev.preventDefault(); show(index - 1); }
      if (ev.key === 'ArrowRight') { ev.preventDefault(); show(index + 1); }
    });
    var startX = null;
    dlg.addEventListener('pointerdown', function (ev) { startX = ev.clientX; });
    dlg.addEventListener('pointerup', function (ev) {
      if (startX === null) return;
      var dx = ev.clientX - startX; startX = null;
      if (Math.abs(dx) > 50 && items.length > 1) show(index + (dx < 0 ? 1 : -1));
    });
  }

  /* --------------------------------------------- filtros de projetos --- */
  var grid = $('[data-projects]');
  if (grid) {
    var cards = $$('[data-category]', grid);
    var buttons = $$('[data-filter]');
    var search = $('[data-search]');
    var counter = $('[data-count]');
    var empty = $('[data-empty]');
    var state = { cat: 'todos', q: '' };
    var norm = function (s) {
      return (s || '').toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
    };
    cards.forEach(function (c) { c._text = norm(c.textContent + ' ' + (c.getAttribute('data-tags') || '')); });

    var apply = function () {
      var shown = 0, q = norm(state.q).trim();
      cards.forEach(function (c) {
        var ok = (state.cat === 'todos' || c.getAttribute('data-category') === state.cat) && (!q || c._text.indexOf(q) > -1);
        c.hidden = !ok;
        if (ok) shown++;
      });
      buttons.forEach(function (b) { b.setAttribute('aria-pressed', String(b.getAttribute('data-filter') === state.cat)); });
      if (counter) counter.textContent = 'Mostrando ' + shown + ' de ' + cards.length + ' projetos';
      if (empty) empty.hidden = shown > 0;
    };

    var fromHash = function () {
      var m = location.hash.match(/cat=([\w-]+)/);
      state.cat = m && buttons.some(function (b) { return b.getAttribute('data-filter') === m[1]; }) ? m[1] : 'todos';
      apply();
    };

    buttons.forEach(function (b) {
      b.addEventListener('click', function () {
        state.cat = b.getAttribute('data-filter');
        var url = state.cat === 'todos' ? location.pathname + location.search : '#cat=' + state.cat;
        history.replaceState(null, '', url);
        var run = function () { apply(); };
        if (document.startViewTransition && !reduceMotion) document.startViewTransition(run); else run();
      });
    });
    if (search) search.addEventListener('input', function () { state.q = search.value; apply(); });
    var clear = $('[data-clear]');
    if (clear) clear.addEventListener('click', function () {
      state.cat = 'todos'; state.q = ''; if (search) search.value = '';
      history.replaceState(null, '', location.pathname); apply();
    });
    window.addEventListener('hashchange', fromHash);
    fromHash();
  }
})();
