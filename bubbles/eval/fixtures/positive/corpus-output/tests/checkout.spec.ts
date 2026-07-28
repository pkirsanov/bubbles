import { test, expect } from '@playwright/test';

// Mocked on purpose: this exercises rendering and state, not the live stack.
// Because it intercepts, it is classified ui-unit in the test plan.
test('renders submitted record', async ({ page }) => {
  await page.route('**/api/v1/records', route =>
    route.fulfill({ status: 200, body: JSON.stringify({ persistedCount: 1 }) }));
  await page.goto('/records');
  await expect(page.getByTestId('record-count')).toHaveText('1');
});
