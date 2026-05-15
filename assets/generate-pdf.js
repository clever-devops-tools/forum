const puppeteer = require('puppeteer');
const path = require('path');

(async () => {
  const browser = await puppeteer.launch({ headless: true, args: ['--no-sandbox', '--disable-setuid-sandbox'] });
  const page = await browser.newPage();

  const htmlPath = path.join(__dirname, 'COPILOT_CONEXIONES_RED.html');
  await page.goto(`file:///${htmlPath.replace(/\\/g, '/')}`, { waitUntil: 'networkidle0' });

  await page.pdf({
    path: path.join(__dirname, 'COPILOT_CONEXIONES_RED.pdf'),
    format: 'A4',
    printBackground: true,
    margin: { top: '20mm', bottom: '20mm', left: '15mm', right: '15mm' }
  });

  await browser.close();
  console.log('PDF generado exitosamente: COPILOT_CONEXIONES_RED.pdf');
})();
