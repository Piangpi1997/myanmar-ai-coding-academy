// Chromium checks the real exported document, not a reimplementation of its policy.
// Android WebView settings still require physical-device validation.
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const path = require('node:path');
const { chromium } = require('playwright');

(async () => {
  const directory = process.argv[2];
  assert(directory, 'Provide the exported fixture directory');
  const browser = await chromium.launch({ headless: true });
  try {
    const page = await browser.newPage();
    page.setDefaultTimeout(10000);
    const network = [];
    // Test boundaries without ever contacting an external host if a policy regresses.
    await page.route(/^https?:/, async route => { network.push(route.request().url()); await route.abort(); });
    const load = async name => {
      await page.setContent(await fs.readFile(path.join(directory, name), 'utf8'));
      const iframe = page.frameLocator('iframe');
      return iframe;
    };
    const starter = await load('starter.html');
    await starter.locator('#hello').click();
    assert.equal(await starter.locator('#message').textContent(), 'Welcome to Myanmar Academy!');
    console.log('PASS: starter HTML/CSS/JavaScript interaction');

    await load('restrictions.html');
    const frame = page.frames().find(candidate => candidate.parentFrame() === page.mainFrame());
    assert(frame, 'Restricted child frame was not created');
    await frame.waitForFunction(() => window.securityResults?.fetch === true);
    const results = await frame.evaluate(() => window.securityResults);
    assert.deepEqual(results, { parent: true, storage: true, cookies: true, comparison: true, closing: '</SCRIPT>', fetch: true });
    assert.equal(await page.locator('iframe').count(), 1);
    assert.equal(await frame.locator('#original').textContent(), 'Restricted frame');
    assert.deepEqual(network, [], 'Preview attempted an external request');
    console.log('PASS: opaque parent boundary, storage/cookie rejection, blocked network, closing tags and JS operators');

    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    await load('error.html');
    await page.waitForFunction(() => document.querySelector('iframe') !== null);
    // Event delivery is asynchronous, use a bounded assertion loop.
    for (let i = 0; errors.length === 0 && i < 20; i++) await new Promise(resolve => setTimeout(resolve, 50));
    assert(errors.some(message => message.includes('academy-test-error')));
    console.log('PASS: JavaScript runtime errors are observable');
    errors.length = 0;
    const lessons = (await fs.readdir(directory)).filter(name => name.startsWith('lesson-'));
    assert.equal(lessons.length, 40);
    for (const name of lessons) {
      await load(name);
      await page.frameLocator('iframe').locator('body').waitFor();
      assert.deepEqual(errors, [], `Lesson preview error in ${name}`);
    }
    const counter = await load('lesson-web-17-code.html');
    await counter.locator('#add').click();
    assert.equal(await counter.locator('#count').textContent(), '1');
    const calculator = await load('lesson-web-18-code.html');
    await calculator.locator('#calc').click();
    assert.equal(await calculator.locator('#total').textContent(), 'Total: 10');
    const text = await load('lesson-web-19-code.html');
    await text.locator('#show').click();
    assert.equal(await text.locator('#out').textContent(), '<b>hello</b>');
    assert.equal(await text.locator('#out b').count(), 0);
    const checklist = await load('lesson-web-20-code.html');
    await checklist.locator('input').first().check();
    assert.equal(await checklist.locator('#summary').textContent(), '1 / 3 complete');
    assert.deepEqual(network, []);
    console.log('PASS: 40 authored HTML previews, counter, calculator, literal text and checklist');

  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
