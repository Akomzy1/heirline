// Quick look: screenshots at given scroll fractions of the document, or at element-relative positions.
// usage: node tools/peek.mjs <url> <outdir> <w> <h> <spec...>   spec = "#id:0.5" (act progress) or "y:1200"
import { createRequire } from 'module';
import fs from 'fs';
const require = createRequire(import.meta.url);
const { chromium } = require('playwright-core');
const [, , url, out, w, h, ...specs] = process.argv;
fs.mkdirSync(out, { recursive: true });
const browser = await chromium.launch({ executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe' });
const ctx = await browser.newContext({ viewport: { width: +w, height: +h }, deviceScaleFactor: 1, reducedMotion: process.env.REDUCED ? 'reduce' : 'no-preference' });
const page = await ctx.newPage();
const errs = [];
page.on('pageerror', e => errs.push(String(e)));
page.on('console', m => { if (m.type() === 'error') errs.push(m.text()); });
await page.goto(url, { waitUntil: 'networkidle' });
await page.evaluate(() => document.fonts.ready);
if (process.env.MARK) {
  await page.evaluate(ids => { ids.split(',').forEach(id => window.HL.toggle(id)); }, process.env.MARK);
}
let n = 0;
for (const sp of specs) {
  const [k, v] = sp.split(':');
  const y = await page.evaluate(([k, v]) => {
    if (k === 'y') return +v;
    const el = document.querySelector(k);
    const top = el.getBoundingClientRect().top + scrollY;
    return top + (el.offsetHeight - innerHeight) * +v;
  }, [k, v]);
  await page.evaluate(y => window.scrollTo(0, y), Math.round(y));
  await page.waitForTimeout(500);
  await page.evaluate(() => window.dispatchEvent(new Event('scroll')));
  await page.waitForTimeout(450);
  const name = `${out}/${String(n++).padStart(2, '0')}-${sp.replace(/[^a-z0-9.]/gi, '_')}.png`;
  await page.screenshot({ path: name });
}
console.log(errs.length ? 'ERRORS:\n' + errs.join('\n') : 'no console errors');
await browser.close();
