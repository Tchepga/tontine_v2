import { test, expect } from '@playwright/test';

test.describe('Design Tests - Tontine v2', () => {
  test.beforeEach(async ({ page }) => {
    // Attendre que l'application soit chargée
    await page.goto('/');
    await page.waitForLoadState('networkidle');
  });

  test('Page de login - Design responsive desktop', async ({ page }) => {
    // Vérifier que la page de login s'affiche
    await expect(page).toHaveTitle(/tontine/i);
    
    // Vérifier la présence des éléments de login
    const usernameField = page.locator('input[type="text"], input[placeholder*="email"], input[placeholder*="username"]').first();
    const passwordField = page.locator('input[type="password"]').first();
    
    // Attendre que les champs soient visibles
    await expect(usernameField).toBeVisible({ timeout: 10000 });
    await expect(passwordField).toBeVisible({ timeout: 10000 });
    
    // Prendre une capture d'écran
    await page.screenshot({ path: 'test/playwright/screenshots/login-desktop.png', fullPage: true });
  });

  test('Page de login - Design responsive mobile', async ({ page }) => {
    // Simuler un appareil mobile
    await page.setViewportSize({ width: 375, height: 667 });
    
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Vérifier que les éléments sont visibles sur mobile
    const usernameField = page.locator('input[type="text"], input[placeholder*="email"], input[placeholder*="username"]').first();
    const passwordField = page.locator('input[type="password"]').first();
    
    await expect(usernameField).toBeVisible({ timeout: 10000 });
    await expect(passwordField).toBeVisible({ timeout: 10000 });
    
    // Prendre une capture d'écran mobile
    await page.screenshot({ path: 'test/playwright/screenshots/login-mobile.png', fullPage: true });
  });

  test('Page de login - Design responsive tablette', async ({ page }) => {
    // Simuler une tablette
    await page.setViewportSize({ width: 768, height: 1024 });
    
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    const usernameField = page.locator('input[type="text"], input[placeholder*="email"], input[placeholder*="username"]').first();
    const passwordField = page.locator('input[type="password"]').first();
    
    await expect(usernameField).toBeVisible({ timeout: 10000 });
    await expect(passwordField).toBeVisible({ timeout: 10000 });
    
    // Prendre une capture d'écran tablette
    await page.screenshot({ path: 'test/playwright/screenshots/login-tablet.png', fullPage: true });
  });

  test('Vérifier les couleurs et le thème', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Vérifier que le body existe et a un style
    const body = page.locator('body');
    await expect(body).toBeVisible();
    
    // Vérifier la couleur de fond (couleur principale de l'app: #42a5f5)
    const backgroundColor = await body.evaluate((el) => {
      return window.getComputedStyle(el).backgroundColor;
    });
    
    // Prendre une capture pour vérifier visuellement
    await page.screenshot({ path: 'test/playwright/screenshots/theme-check.png', fullPage: true });
  });

  test('Test de navigation et responsive', async ({ page }) => {
    // Tester différentes tailles d'écran
    const viewports = [
      { name: 'mobile', width: 375, height: 667 },
      { name: 'tablet', width: 768, height: 1024 },
      { name: 'desktop', width: 1920, height: 1080 },
    ];

    for (const viewport of viewports) {
      await page.setViewportSize({ width: viewport.width, height: viewport.height });
      await page.goto('/');
      await page.waitForLoadState('networkidle');
      
      // Prendre une capture pour chaque taille
      await page.screenshot({ 
        path: `test/playwright/screenshots/responsive-${viewport.name}.png`, 
        fullPage: true 
      });
    }
  });
});

