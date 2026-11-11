// Usage: node reference/tools/inspect-prototype.mjs <console|portal|website|website-service|website-consultation> "<css selector>" [width] [height]
// The website prototype (v2, approved 11 Nov 2026) is multi-file in reference/prototypes/website/.
// Its scroll acts publish --sc-p; scroll the page before reading values from a pinned act.
// Prints computed styles (font, size, colour, spacing, radius, border, shadow) and box size
// for every element matching the selector in the approved prototype. Use it to read the
// prototype's real values instead of guessing. Needs: npm i -D playwright
import { chromium } from 'playwright';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
const [, , which = 'console', selector = 'body', w = '1440', h = '900'] = process.argv;
const file = {
  console: 'console.html', portal: 'portal.html',
  website: 'website/index.html', 'website-service': 'website/health-check.html', 'website-consultation': 'website/consultation.html',
}[which];
const url = pathToFileURL(path.resolve('reference/prototypes', file)).href;
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: +w, height: +h } });
await page.goto(url);
await page.waitForTimeout(1500);
const rows = await page.$$eval(selector, (els) =>
  els.slice(0, 12).map((e) => {
    const s = getComputedStyle(e), r = e.getBoundingClientRect();
    const pick = (...k) => Object.fromEntries(k.map((x) => [x, s[x]]));
    return {
      text: (e.innerText || '').trim().slice(0, 60),
      box: { w: Math.round(r.width), h: Math.round(r.height), x: Math.round(r.x), y: Math.round(r.y) },
      ...pick('fontFamily', 'fontSize', 'fontWeight', 'lineHeight', 'letterSpacing', 'textTransform', 'color',
        'backgroundColor', 'padding', 'margin', 'gap', 'borderRadius', 'border', 'boxShadow', 'transition'),
    };
  }),
);
console.log(JSON.stringify(rows, null, 2));
await browser.close();
