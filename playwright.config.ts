import { defineConfig, devices } from '@playwright/test';

/**
 * Configuration Playwright pour tester l'application Tontine v2
 */
export default defineConfig({
  testDir: './test/playwright',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  
  use: {
    baseURL: 'http://localhost:8080',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
  },

  projects: [
    {
      name: 'chromium',
      use: { 
        ...devices['Desktop Chrome'],
        // Désactiver les restrictions de sécurité Chrome
        launchOptions: {
          args: [
            '--disable-web-security',
            '--disable-features=IsolateOrigins,site-per-process',
            '--disable-site-isolation-trials',
            '--disable-blink-features=AutomationControlled',
            '--allow-running-insecure-content',
            '--disable-features=VizDisplayCompositor',
            '--user-data-dir=/tmp/chrome-dev-test',
            '--disable-dev-shm-usage',
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-gpu',
            '--disable-software-rasterizer',
            '--disable-extensions',
            '--disable-background-networking',
            '--disable-background-timer-throttling',
            '--disable-backgrounding-occluded-windows',
            '--disable-breakpad',
            '--disable-client-side-phishing-detection',
            '--disable-component-update',
            '--disable-default-apps',
            '--disable-domain-reliability',
            '--disable-features=AudioServiceOutOfProcess',
            '--disable-hang-monitor',
            '--disable-ipc-flooding-protection',
            '--disable-notifications',
            '--disable-offer-store-unmasked-wallet-cards',
            '--disable-popup-blocking',
            '--disable-print-preview',
            '--disable-prompt-on-repost',
            '--disable-renderer-backgrounding',
            '--disable-sync',
            '--disable-translate',
            '--metrics-recording-only',
            '--mute-audio',
            '--no-first-run',
            '--safebrowsing-disable-auto-update',
            '--enable-automation',
            '--password-store=basic',
            '--use-mock-keychain',
            '--ignore-certificate-errors',
            '--ignore-ssl-errors',
            '--ignore-certificate-errors-spki-list',
            '--allow-insecure-localhost',
            '--unsafely-treat-insecure-origin-as-secure=http://localhost:8080',
          ],
        },
        // Désactiver les vérifications de contexte
        ignoreHTTPSErrors: true,
        // Permettre les contenus mixtes
        bypassCSP: true,
      },
    },
  ],

  webServer: {
    command: 'flutter run -d chrome --web-port=8080 --web-browser-flag="--disable-web-security" --web-browser-flag="--disable-features=IsolateOrigins,site-per-process" --web-browser-flag="--user-data-dir=/tmp/chrome-dev-test" --web-browser-flag="--allow-running-insecure-content" --web-browser-flag="--ignore-certificate-errors" --web-browser-flag="--unsafely-treat-insecure-origin-as-secure=http://localhost:8080"',
    url: 'http://localhost:8080',
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
});

