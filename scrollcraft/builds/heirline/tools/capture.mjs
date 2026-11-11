// usage: node capture.mjs <file.html> <outPrefix> [width] [height]
import { createRequire } from 'module';
const require = createRequire(process.cwd() + '/');
const { chromium } = require('playwright-core');
import fs from 'fs';
import path from 'path';
import { pathToFileURL } from 'url';

const [, , file, out, w = '1440', h = '900'] = process.argv;
const browser = await chromium.launch({ executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe' });
const page = await browser.newPage({ viewport: { width: +w, height: +h } });
await page.goto(file.startsWith('http') ? file : pathToFileURL(path.resolve(file)).href, { waitUntil: 'load', timeout: 120000 });
await page.waitForTimeout(3500);
// trigger reveal-on-scroll
const H = await page.evaluate(() => document.documentElement.scrollHeight);
for (let y = 0; y < H; y += 600) { await page.evaluate(v => window.scrollTo(0, v), y); await page.waitForTimeout(120); }
await page.evaluate(() => window.scrollTo(0, 0));
await page.waitForTimeout(800);
const text = await page.evaluate(() => document.body.innerText);
fs.writeFileSync(out + '.txt', text);
await page.screenshot({ path: out + '.png', fullPage: true });
console.log(out, 'height', H);
await browser.close();

