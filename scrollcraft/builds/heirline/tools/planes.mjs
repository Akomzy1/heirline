// Runs tools/planes.html in headless Chrome and writes the hero planes to out/planes/.
import { createRequire } from 'module';
import fs from 'fs';
import path from 'path';
import { pathToFileURL } from 'url';
const require = createRequire(import.meta.url);
const { chromium } = require('playwright-core');

const root = path.resolve(path.dirname(new URL(import.meta.url).pathname.replace(/^\/([A-Z]:)/, '$1')), '..');
const browser = await chromium.launch({
  executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe',
  args: ['--allow-file-access-from-files', '--js-flags=--max-old-space-size=4096'],
});
const page = await browser.newPage();
page.on('console', m => console.log('page:', m.text()));
await page.goto(pathToFileURL(path.join(root, 'tools', 'planes.html')).href);
const src = pathToFileURL(path.join(root, 'out', '01-hero.png')).href;
const res = await page.evaluate(s => window.run(s), src);
fs.mkdirSync(path.join(root, 'out', 'planes'), { recursive: true });
for (const [k, b64] of Object.entries(res)) {
  fs.writeFileSync(path.join(root, 'out', 'planes', k + '.png'), Buffer.from(b64, 'base64'));
  console.log('wrote', k);
}
await browser.close();
