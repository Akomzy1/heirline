// Functional checks for the prototype's real controls.
import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const { chromium } = require('playwright-core');
const base = process.argv[2] || 'http://localhost:4500';
const browser = await chromium.launch({ executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe' });
const results = [];
const ok = (name, pass, extra = '') => results.push(`${pass ? 'PASS' : 'FAIL'}  ${name}${extra ? '  ' + extra : ''}`);

for (const [w, h] of [[1440, 900], [390, 844]]) {
  const ctx = await browser.newContext({ viewport: { width: w, height: h } });
  const page = await ctx.newPage();
  const errs = []; page.on('pageerror', e => errs.push(String(e)));
  await page.goto(base + '/', { waitUntil: 'load', timeout: 60000 }); await page.evaluate(() => document.fonts.ready); (0);
  const tag = `@${w}`;
  // overflow
  const ov = await page.evaluate(() => document.documentElement.scrollWidth - innerWidth);
  ok(`no horizontal overflow ${tag}`, ov <= 0, `(${ov}px)`);
  // mark three slips by clicking them in the scatter act
  await page.evaluate(() => { const s = document.querySelector('#problem'); scrollTo(0, s.offsetTop + innerHeight * 0.1); });
  await page.waitForTimeout(500);
  for (const id of ['lekki', 'shares', 'abroad']) await page.click(`.slip[data-id="${id}"]`);
  const pressed = await page.$$eval('.slip[aria-pressed="true"]', n => n.map(x => x.dataset.id));
  ok(`slips toggle aria-pressed ${tag}`, pressed.join() === 'lekki,shares,abroad', pressed.join());
  // keyboard: slips are buttons reachable by Tab
  const focusable = await page.$eval('.slip', b => b.tabIndex >= 0);
  ok(`slips keyboard-focusable ${tag}`, focusable);
  // close: letter intro and chips reflect marks
  await page.evaluate(() => document.querySelector('#consultation').scrollIntoView());
  await page.waitForTimeout(400);
  const intro = await page.textContent('[data-letter-intro]');
  ok(`letter addresses the marks ${tag}`, /You marked land, shares and assets abroad/.test(intro), JSON.stringify(intro.slice(0, 60)));
  const chips = await page.$$eval('[data-chips] input:checked', n => n.map(i => i.value));
  ok(`chips prefilled from register ${tag}`, chips.join() === 'land,shares,abroad', chips.join());
  const closeCount = await page.textContent('[data-close-count]');
  ok(`close register shows 3 sealed ${tag}`, closeCount.trim() === '3 entries, sealed', closeCount);
  // validation
  await page.click('[data-form] button[type=submit]');
  const invalid = await page.getAttribute('#f-name', 'aria-invalid');
  const errVisible = await page.isVisible('#f-name-err');
  const focused = await page.evaluate(() => document.activeElement.id);
  ok(`empty submit shows error and focuses field ${tag}`, invalid === 'true' && errVisible && focused === 'f-name');
  await page.fill('#f-name', 'Chief A.'); await page.fill('#f-contact', 'test@example.invalid');
  await page.click('[data-form] button[type=submit]');
  const consentBlocked = await page.isVisible('#f-consent-err') && await page.isVisible('[data-form]');
  ok(`submit without consent is blocked ${tag}`, consentBlocked);
  await page.check('#f-consent');
  await page.click('[data-form] button[type=submit]');
  const done = await page.isVisible('[data-done]');
  const formHidden = await page.isHidden('[data-form]');
  ok(`valid submit shows confirmation ${tag}`, done && formHidden);
  const method = await page.getAttribute('[data-form]', 'method');
  ok(`no-JS form posts, never GET ${tag}`, method === 'post');
  // register persists to the consultation page in the same session
  await page.goto(base + '/consultation.html', { waitUntil: 'load', timeout: 60000 }); await page.evaluate(() => document.fonts.ready); (0);
  const intro2 = await page.textContent('[data-letter-intro]');
  ok(`register carries to consultation page ${tag}`, /You marked/.test(intro2));
  const ov2 = await page.evaluate(() => document.documentElement.scrollWidth - innerWidth);
  ok(`consultation no overflow ${tag}`, ov2 <= 0, `(${ov2}px)`);
  await page.goto(base + '/health-check.html', { waitUntil: 'load', timeout: 60000 }); await page.evaluate(() => document.fonts.ready); (0);
  const ov3 = await page.evaluate(() => document.documentElement.scrollWidth - innerWidth);
  ok(`service page no overflow ${tag}`, ov3 <= 0, `(${ov3}px)`);
  if (w < 1000) {
    await page.click('[data-menu-open]');
    await page.waitForTimeout(350);
    const open = await page.evaluate(() => document.querySelector('[data-menu]').classList.contains('is-open'));
    const f = await page.evaluate(() => document.activeElement.matches('[data-menu-close]'));
    await page.keyboard.press('Escape');
    await page.waitForTimeout(350);
    const closed = await page.evaluate(() => !document.querySelector('[data-menu]').classList.contains('is-open') && document.activeElement.matches('[data-menu-open]'));
    ok(`menu opens with focus, Escape closes and returns focus ${tag}`, open && f && closed);
  }
  ok(`no page errors ${tag}`, errs.length === 0, errs.join(' | '));
  await ctx.close();
}
console.log(results.join('\n'));
await browser.close();

