/* Home choreography. The engine pins the acts and publishes --sc-p; this file owns the
   bespoke parts: hero pointer depth, the scatter and gather, the land states, the
   proof steps, the sealing, and when the folio is shown. Nothing here edits the engine. */
(function () {
  'use strict';
  var HL = window.HL, reduce = HL.reduce;
  ScrollCraft.mount(document.body);

  var clamp = function (v, a, b) { return Math.max(a, Math.min(b, v)); };
  var ease = function (t) { return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2; };
  var outc = function (t) { return 1 - Math.pow(1 - t, 3); };
  var win = function (p, a, b) { return clamp((p - a) / (b - a), 0, 1); };
  function prog(el) {
    var r = el.getBoundingClientRect(), travel = r.height - innerHeight;
    return travel > 1 ? clamp(-r.top / travel, 0, 1) : (r.top < 0 ? 1 : 0);
  }

  // ------------------------------------------------------- hero: pointer --
  var hero = document.querySelector('.hero');
  var fine = matchMedia('(hover: hover) and (pointer: fine)').matches;
  if (hero && fine && !reduce) {
    var tx = 0, ty = 0, cx = 0, cy = 0, live = false;
    hero.addEventListener('pointermove', function (e) {
      tx = (e.clientX / innerWidth) * 2 - 1; ty = (e.clientY / innerHeight) * 2 - 1;
      if (!live) { live = true; requestAnimationFrame(lean); }
    });
    hero.addEventListener('pointerleave', function () { tx = 0; ty = 0; });
    function lean() {
      cx += (tx - cx) * 0.06; cy += (ty - cy) * 0.06;
      hero.style.setProperty('--mx', cx.toFixed(4)); hero.style.setProperty('--my', cy.toFixed(4));
      if (Math.abs(tx - cx) > 0.001 || Math.abs(ty - cy) > 0.001) requestAnimationFrame(lean); else live = false;
    }
  }

  // ---------------------------------------------------- scatter: the slips --
  var scatter = document.querySelector('[data-scatter]');
  var field = scatter.querySelector('[data-field]');
  var reg = scatter.querySelector('[data-register]');
  var regOl = reg.querySelector('[data-ledger]');
  var DESK = [[0,2,-3,-34,-20],[35,0,2,4,-30],[69,5,-2,36,-14],[5,27,3,-40,6],[39,24,-4,0,10],[69,31,2,40,4],[0,53,-2,-30,26],[34,50,3,-4,34],[67,57,-3,34,30],[21,77,2,-8,40]];
  var MOB  = [[0,0,-2,-8,-10],[51,2,2,8,-12],[2,18,2,-10,-2],[50,20,-2,10,0],[0,37,-1,-10,6],[51,39,2,10,6],[2,56,2,-8,12],[50,58,-2,10,12],[0,75,-1,-8,16],[51,77,2,8,16]];
  var slips = HL.catalogue.map(function (c, i) {
    var b = document.createElement('button');
    b.type = 'button'; b.className = 'slip'; b.setAttribute('aria-pressed', 'false'); b.dataset.id = c.id;
    b.innerHTML = '<span class="slip__cat">' + c.cat + '</span><span class="slip__desc">' + c.desc + '</span><span class="slip__ref">' + c.ref + '</span>';
    b.addEventListener('click', function () { HL.toggle(c.id); });
    field.insertBefore(b, reg);
    return { el: b, id: c.id, i: i };
  });
  var mq = matchMedia('(max-width: 860px)');
  function place() {
    var P = mq.matches ? MOB : DESK;
    slips.forEach(function (s) {
      var q = P[s.i]; s.el.style.setProperty('--x', q[0] + '%'); s.el.style.setProperty('--y', q[1] + '%');
      s.el.style.setProperty('--r', q[2] + 'deg'); s.dx = q[3]; s.dy = q[4]; s.r = q[2];
    });
  }
  place(); mq.addEventListener('change', function () { place(); measure(); });

  var caption = scatter.querySelector('[data-reg-caption]'), count = scatter.querySelector('[data-reg-count]'), note = scatter.querySelector('[data-reg-note]');
  var geo = {};
  function measure() {
    var fr = field.getBoundingClientRect();
    slips.forEach(function (s) {
      s.home = { x: s.el.offsetLeft + s.el.offsetWidth / 2, y: s.el.offsetTop + s.el.offsetHeight / 2, w: s.el.offsetWidth };
    });
    geo = {};
    regOl.querySelectorAll('.ledger__row').forEach(function (row) {
      var r = row.getBoundingClientRect();
      geo[row.dataset.id] = { x: r.left - fr.left + Math.min(r.width, 360) / 2, y: r.top - fr.top + r.height / 2 };
    });
  }
  HL.on(function (st) {
    HL.render(regOl, { stage: 0 });
    var ex = HL.isExample(), n = HL.entries().length;
    caption.textContent = ex ? 'An example register' : 'Your register';
    count.textContent = n + (n === 1 ? ' entry' : ' entries');
    note.textContent = ex ? 'This is an example. Scroll back and mark your own, and it will follow you down the page.'
                          : 'Every item starts as a claim. Below, we show what it takes to prove it.';
    slips.forEach(function (s) { s.el.setAttribute('aria-pressed', st.marked.indexOf(s.id) !== -1 ? 'true' : 'false'); });
    requestAnimationFrame(measure);
  });
  addEventListener('resize', function () { requestAnimationFrame(measure); });
  document.fonts && document.fonts.ready.then(measure);

  function drawScatter(p) {
    if (reduce) return;
    var s = ease(win(p, 0, 0.40)), g = win(p, 0.42, 0.66), eg = ease(g);
    var keep = {}; HL.entries().forEach(function (e) { keep[e.id] = true; });
    slips.forEach(function (sl) {
      var dx = sl.dx * s, dy = sl.dy * s, rot = sl.r * (1 + 0.6 * s), sc = 1, op = 1;
      if (g > 0) {
        var t = geo[sl.id];
        if (keep[sl.id] && t && sl.home) {
          dx = dx + (t.x - sl.home.x - dx) * eg; dy = dy + (t.y - sl.home.y - dy) * eg;
          rot = rot * (1 - eg); sc = 1 - 0.22 * eg; op = 1 - win(g, 0.45, 0.78);
        } else {
          dx *= 1 + g; dy *= 1 + g; op = 1 - win(g, 0, 0.35);
        }
      }
      sl.el.style.transform = 'translate3d(' + dx.toFixed(1) + 'px,' + dy.toFixed(1) + 'px,0) rotate(' + rot.toFixed(2) + 'deg) scale(' + sc.toFixed(3) + ')';
      sl.el.style.opacity = op.toFixed(3);
      var off = g > 0.08;
      if (off !== sl.off) { sl.off = off; sl.el.tabIndex = off ? -1 : 0; sl.el.style.pointerEvents = off ? 'none' : ''; }
    });
    reg.style.opacity = win(g, 0.62, 0.92).toFixed(3);
    reg.classList.toggle('is-on', g > 0.7);
    regOl.querySelectorAll('.ledger__row').forEach(function (row, i) {
      row.style.setProperty('--w', (win(g, 0.6 + i * 0.05, 0.86 + i * 0.03) * 100).toFixed(1) + '%');
    });
  }

  // ------------------------------------------------------------- find --
  var find = document.querySelector('[data-find]');
  var verbs = find.querySelectorAll('[data-verbs] li');
  function drawFind(p) {
    var k = reduce ? 1 : p < 0.24 ? 0 : p < 0.5 ? 1 : p < 0.76 ? 2 : 3;
    if (find.dataset.k !== String(k)) {
      find.dataset.k = k;
      verbs.forEach(function (li, i) { li.classList.toggle('is-on', reduce || i === k); });
    }
    find.style.setProperty('--draw', reduce ? 1 : ease(win(p, 0.22, 0.46)).toFixed(4));
    find.style.setProperty('--watch', reduce ? 0 : ease(win(p, 0.5, 0.68)).toFixed(4));
  }

  // ------------------------------------------------------------ steps --
  var steps = document.querySelector('[data-steps]');
  var s1 = steps.querySelector('[data-step="1"]'), so = steps.querySelector('[data-step="signoff"]');
  var stepOl = steps.querySelector('[data-ledger="steps"]'), stepCap = steps.querySelector('[data-step-caption]');
  var CAPS = ['Step I · claimed', 'Step II · evidenced', 'Signed off · verified'];
  function drawSteps() {
    var line = innerHeight * 0.62, st;
    var sr = steps.getBoundingClientRect();
    if (sr.bottom < 0) st = 2;
    else if (so.getBoundingClientRect().top < line) st = 2;
    else if (s1.getBoundingClientRect().top < line) st = 1;
    else st = 0;
    HL.setStage(st);
  }
  HL.on(function (st) { HL.render(stepOl, { refs: true }); stepCap.textContent = CAPS[st.stage]; });

  // ------------------------------------------------------------- seal --
  var seal = document.querySelector('[data-seal]');
  var vault = seal.querySelector('.vault'), sv = seal.querySelector('.seal__vault');
  var peakOl = seal.querySelector('[data-ledger="peak"]'), ver = seal.querySelector('[data-vault-version]');
  var rows = seal.querySelector('.vault__rows');
  HL.on(function () {
    HL.render(peakOl, { stage: 2 });
    rows.style.setProperty('--rows-h', 'auto');
    requestAnimationFrame(function () { rows.style.setProperty('--rows-h', peakOl.scrollHeight + 'px'); });
  });
  function drawSeal(p) {
    var f = reduce ? 1 : ease(win(p, 0.10, 0.32));
    var ka = reduce ? 1 : ease(win(p, 0.33, 0.43)), kb = reduce ? 1 : ease(win(p, 0.43, 0.53));
    var stamp = reduce ? 1 : outc(win(p, 0.55, 0.63)), ring = reduce ? 0 : win(p, 0.6, 0.74);
    var j = reduce || mq.matches ? 1 : ease(win(p, 0.58, 0.72));
    vault.style.setProperty('--fold', f.toFixed(4));
    vault.style.setProperty('--ka', ka.toFixed(4)); vault.style.setProperty('--kb', kb.toFixed(4));
    vault.style.setProperty('--stamp', stamp.toFixed(4)); vault.style.setProperty('--ring', ring.toFixed(4));
    sv.style.setProperty('--j', j.toFixed(4));
    var sealed = stamp > 0.5;
    HL.setSealed(sealed);
    ver.textContent = sealed ? 'Version 1 · sealed' : 'Version 1 · open';
  }

  // -------------------------------------------------- services and close --
  var fit = document.querySelector('[data-fit]');
  var closeOl = document.querySelector('[data-ledger="close"]'), closeCount = document.querySelector('[data-close-count]');
  HL.on(function () {
    var list = HL.entries(2), ex = HL.isExample();
    if (fit) fit.hidden = ex || !list.some(function (e) { return e.cat === 'Land'; });
    HL.render(closeOl, { stage: 2 });
    closeCount.textContent = (ex ? 'An example, ' : '') + list.length + (list.length === 1 ? ' entry' : ' entries') + ', sealed';
  });
  HL.mountForm(document.querySelector('#consultation'));

  // ---------------------------------------------------------- the loop --
  var zones = Array.prototype.slice.call(document.querySelectorAll('[data-folio-zone]'));
  var queued = false;

  // hero copy sits under the headline however many lines it wraps to
  var heroTitle = document.querySelector('.hero__title'), heroCopy = document.querySelector('.hero__copy');
  function placeCopy() {
    var t = heroTitle.offsetTop + heroTitle.offsetHeight + (mq.matches ? 20 : 34);
    hero.style.setProperty('--copy-top', t + 'px');
  }
  placeCopy(); addEventListener('resize', placeCopy);
  document.fonts && document.fonts.ready.then(placeCopy);
  function frame() {
    queued = false;
    var ps = prog(scatter);
    drawScatter(ps);
    drawFind(prog(find));
    drawSteps();
    drawSeal(prog(seal));
    // the folio follows the visitor only where the register is not already on screen
    var mid = innerHeight * 0.5, show = false;
    zones.forEach(function (z) { var r = z.getBoundingClientRect(); if (r.top < mid && r.bottom > mid) show = true; });
    HL.showFolio(show);
  }
  function kick() { if (!queued) { queued = true; requestAnimationFrame(frame); } }
  addEventListener('scroll', kick, { passive: true });
  addEventListener('resize', kick);
  HL.on(kick);
  frame();
})();
