/* Heirline shared behaviour: the visitor's register (the signature move), the header,
   the menu and the folio. Nothing here leaves the browser. sessionStorage is a convenience
   only: every read and write is guarded, and the page works without it. */
(function () {
  'use strict';
  var reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;

  // ------------------------------------------------------------ the register --
  var CATALOGUE = [
    { id: 'lekki',     cat: 'Land',          desc: 'Two plots, Lekki Phase 1',        ref: 'Deed of assignment, 1998', end: 'disputed' },
    { id: 'ijebu',     cat: 'Land',          desc: 'Family land, Ijebu-Ode',          ref: 'Papers held by an uncle',  end: 'evidenced' },
    { id: 'shares',    cat: 'Shares',        desc: 'Bank shares bought in 1987',      ref: 'Registrar not known',      end: 'verified' },
    { id: 'dividends', cat: 'Dividends',     desc: 'Dividend warrants never cashed',  ref: 'Since 2009',               end: 'verified' },
    { id: 'account',   cat: 'Bank account',  desc: 'A savings account, Ibadan',       ref: 'Dormant for some years',   end: 'verified' },
    { id: 'pension',   cat: 'Pension',       desc: 'An RSA from a first employer',    ref: 'PIN not to hand',          end: 'verified' },
    { id: 'policy',    cat: 'Policy',        desc: 'A life policy',                   ref: 'Insurer since merged',     end: 'evidenced' },
    { id: 'abroad',    cat: 'Abroad',        desc: 'A flat in London',                ref: 'Held in a company name',   end: 'verified' },
    { id: 'stake',     cat: 'Private stake', desc: "A share in a friend's business",  ref: 'No certificate',           end: 'evidenced' },
    { id: 'loan',      cat: 'Owed to you',   desc: 'Money lent to a cousin',          ref: 'Nothing in writing',       end: 'claimed' }
  ];
  var EXAMPLE = ['lekki', 'shares', 'dividends', 'account', 'abroad'];
  var ORDER = { claimed: 0, evidenced: 1, verified: 2 };
  var LABEL = { claimed: 'Claimed', evidenced: 'Evidenced', verified: 'Verified', disputed: 'Disputed' };
  var KEY = 'hl-register-v1';

  var state = { marked: [], stage: 0, sealed: false };
  try { var saved = JSON.parse(sessionStorage.getItem(KEY) || 'null'); if (saved && Array.isArray(saved.marked)) state.marked = saved.marked.filter(byId); } catch (e) {}
  function byId(id) { return CATALOGUE.some(function (c) { return c.id === id; }); }
  function save() { try { sessionStorage.setItem(KEY, JSON.stringify({ marked: state.marked })); } catch (e) {} }

  var listeners = [];
  function emit() { listeners.forEach(function (fn) { fn(state); }); }

  function statusFor(item, stage) {
    if (item.end === 'disputed') return stage >= 2 ? 'disputed' : stage >= 1 ? 'evidenced' : 'claimed';
    var cap = ORDER[item.end];
    return ['claimed', 'evidenced', 'verified'][Math.min(stage, cap)];
  }
  function isExample() { return state.marked.length === 0; }
  function entries(stage) {
    var ids = isExample() ? EXAMPLE : state.marked;
    var s = stage == null ? state.stage : stage;
    return CATALOGUE.filter(function (c) { return ids.indexOf(c.id) !== -1; })
      .map(function (c) { return { id: c.id, cat: c.cat, desc: c.desc, ref: c.ref, status: statusFor(c, s) }; });
  }

  function esc(t) { return String(t).replace(/[&<>"]/g, function (m) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[m]; }); }
  function rowHTML(e, withRef) {
    return '<li class="ledger__row" data-id="' + e.id + '">' +
      '<span class="ledger__cat">' + esc(e.cat) + '</span>' +
      '<span class="ledger__desc">' + esc(e.desc) + (withRef ? '<small>' + esc(e.ref) + '</small>' : '') + '</span>' +
      '<span class="status" data-s="' + e.status + '">' + LABEL[e.status] + '</span></li>';
  }
  // Render keeps rows stable and only swaps statuses, so a status change reads as a
  // change of state rather than a redraw.
  function render(ol, opts) {
    opts = opts || {};
    var list = entries(opts.stage);
    var ids = list.map(function (e) { return e.id; }).join(',');
    if (ol.getAttribute('data-ids') !== ids) {
      ol.innerHTML = list.map(function (e) { return rowHTML(e, opts.refs); }).join('');
      ol.setAttribute('data-ids', ids);
    } else {
      list.forEach(function (e) {
        var s = ol.querySelector('[data-id="' + e.id + '"] .status');
        if (s && s.getAttribute('data-s') !== e.status) { s.setAttribute('data-s', e.status); s.textContent = LABEL[e.status]; }
      });
    }
  }

  window.HL = {
    reduce: reduce, catalogue: CATALOGUE, state: state, entries: entries, render: render, isExample: isExample, LABEL: LABEL,
    on: function (fn) { listeners.push(fn); fn(state); },
    toggle: function (id) {
      var i = state.marked.indexOf(id);
      if (i === -1) state.marked.push(id); else state.marked.splice(i, 1);
      state.marked.sort(function (a, b) { return idx(a) - idx(b); });
      save(); emit();
    },
    setStage: function (n) { if (state.stage !== n) { state.stage = n; emit(); } },
    setSealed: function (b) { if (state.sealed !== b) { state.sealed = b; emit(); } }
  };
  function idx(id) { for (var i = 0; i < CATALOGUE.length; i++) if (CATALOGUE[i].id === id) return i; return 99; }

  // --------------------------------------------------------------- header --
  var header = document.querySelector('[data-header]');
  var themed = Array.prototype.slice.call(document.querySelectorAll('[data-theme]'));
  var probe = 30;
  function paintHeader() {
    if (!header) return;
    var y = scrollY, theme = 'day';
    for (var i = 0; i < themed.length; i++) {
      var r = themed[i].getBoundingClientRect();
      if (r.top <= probe && r.bottom > probe) { theme = themed[i].getAttribute('data-theme'); }
    }
    header.classList.toggle('on-day', theme === 'day');
    header.classList.toggle('on-evening', theme !== 'day');
    header.classList.toggle('is-scrolled', y > 40);
  }
  addEventListener('scroll', paintHeader, { passive: true });
  addEventListener('resize', paintHeader);
  paintHeader();

  // ----------------------------------------------------------------- menu --
  var menu = document.querySelector('[data-menu]');
  var opener = document.querySelector('[data-menu-open]');
  if (menu && opener) {
    var closer = menu.querySelector('[data-menu-close]');
    var open = function () {
      menu.classList.add('is-open'); opener.setAttribute('aria-expanded', 'true');
      document.documentElement.style.overflow = 'hidden'; closer.focus();
    };
    var shut = function (refocus) {
      menu.classList.remove('is-open'); opener.setAttribute('aria-expanded', 'false');
      document.documentElement.style.overflow = ''; if (refocus !== false) opener.focus();
    };
    opener.addEventListener('click', open);
    closer.addEventListener('click', function () { shut(); });
    menu.addEventListener('click', function (e) { if (e.target.closest('a')) shut(false); });
    menu.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') shut();
      if (e.key === 'Tab') {
        var f = menu.querySelectorAll('a, button'); var first = f[0], last = f[f.length - 1];
        if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
        else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
      }
    });
  }

  // ---------------------------------------------------------------- folio --
  var folio = document.querySelector('[data-folio]');
  if (folio) {
    var tog = folio.querySelector('[data-folio-toggle]');
    var fol = folio.querySelector('[data-ledger="folio"]');
    var cnt = folio.querySelector('[data-folio-count]');
    var sum = folio.querySelector('[data-folio-sum]');
    tog.addEventListener('click', function () {
      var o = folio.classList.toggle('is-open'); tog.setAttribute('aria-expanded', o ? 'true' : 'false');
    });
    HL.on(function () {
      var list = entries();
      render(fol, {});
      cnt.textContent = list.length + (list.length === 1 ? ' entry' : ' entries') + (state.sealed ? ' · sealed' : isExample() ? ' · example' : '');
      sum.innerHTML = list.map(function (e) {
        var c = { claimed: 'var(--ink-300)', evidenced: 'var(--info-300)', verified: 'var(--sage-300)', disputed: 'var(--ochre-300)' }[e.status];
        return '<i style="background:' + c + '"></i>';
      }).join('');
    });
    window.HL.showFolio = function (b) {
      folio.classList.toggle('is-shown', !!b);
      if (!b && folio.classList.contains('is-open')) { folio.classList.remove('is-open'); tog.setAttribute('aria-expanded', 'false'); }
    };
  } else {
    window.HL.showFolio = function () {};
  }

  // ------------------------------------------------------------ the date --
  var today = document.querySelectorAll('[data-today]');
  if (today.length) {
    var d = new Date(), m = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    today.forEach(function (n) { n.textContent = d.getDate() + ' ' + m[d.getMonth()] + ' ' + d.getFullYear(); });
  }

  // ------------------------------------------------- the consultation form --
  window.HL.mountForm = function (root) {
    var form = root.querySelector('[data-form]');
    if (!form) return;
    var chips = root.querySelector('[data-chips]');
    var topics = [
      ['land', 'Land and titles'], ['shares', 'Shares and dividends'], ['accounts', 'Dormant accounts'],
      ['pensions', 'Pensions and policies'], ['business', 'Business interests'], ['abroad', 'Assets abroad'],
      ['heirs', 'Preparing heirs'], ['estate', 'An estate in probate']
    ];
    var fromCat = { 'Land': 'land', 'Shares': 'shares', 'Dividends': 'shares', 'Bank account': 'accounts', 'Pension': 'pensions',
      'Policy': 'pensions', 'Abroad': 'abroad', 'Private stake': 'business', 'Owed to you': 'business' };
    chips.innerHTML = topics.map(function (t) {
      return '<label class="chip"><input type="checkbox" name="topics" value="' + t[0] + '"><span>' + t[1] + '</span></label>';
    }).join('');
    var intro = root.querySelector('[data-letter-intro]');
    var baseIntro = intro ? intro.textContent : '';
    HL.on(function () {
      if (isExample()) { if (intro) intro.textContent = baseIntro; return; }
      var want = {}; entries().forEach(function (e) { want[fromCat[e.cat]] = true; });
      chips.querySelectorAll('input').forEach(function (i) { if (!i.dataset.touched) i.checked = !!want[i.value]; });
      if (intro) {
        var PHRASE = { 'Land': 'land', 'Shares': 'shares', 'Dividends': 'unclaimed dividends', 'Bank account': 'a bank account',
          'Pension': 'a pension', 'Policy': 'a life policy', 'Abroad': 'assets abroad', 'Private stake': 'a private stake', 'Owed to you': 'money owed to you' };
        var names = entries().map(function (e) { return PHRASE[e.cat]; }).filter(function (v, i, a) { return a.indexOf(v) === i; });
        var list = names.length > 1 ? names.slice(0, -1).join(', ') + ' and ' + names[names.length - 1] : names[0];
        intro.textContent = 'You marked ' + list + '. We would like to understand the rest of the picture, privately and at your pace. There is no obligation.';
      }
    });
    chips.addEventListener('change', function (e) { if (e.target.matches('input')) e.target.dataset.touched = '1'; });
    form.addEventListener('submit', function (e) {
      e.preventDefault();
      var ok = true;
      [['f-name', 'f-name-err'], ['f-contact', 'f-contact-err']].forEach(function (p) {
        var i = form.querySelector('#' + p[0]), er = form.querySelector('#' + p[1]);
        var bad = !i.value.trim();
        i.setAttribute('aria-invalid', bad ? 'true' : 'false');
        if (bad) { i.setAttribute('aria-describedby', p[1]); er.hidden = false; if (ok) i.focus(); ok = false; }
        else { i.removeAttribute('aria-describedby'); er.hidden = true; }
      });
      var cb = form.querySelector('#f-consent'), cbe = form.querySelector('#f-consent-err');
      if (cb) {
        var noC = !cb.checked;
        cb.setAttribute('aria-invalid', noC ? 'true' : 'false');
        if (noC) { cb.setAttribute('aria-describedby', 'f-consent-err'); cbe.hidden = false; if (ok) cb.focus(); ok = false; }
        else { cb.removeAttribute('aria-describedby'); cbe.hidden = true; }
      }
      if (!ok) return;
      form.hidden = true;
      var done = root.querySelector('[data-done]'); done.hidden = false; done.focus();
    });
  };
})();
