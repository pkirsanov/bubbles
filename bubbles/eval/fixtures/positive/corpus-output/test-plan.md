# Test Plan — Scope 3

| Test | Category | File | Live system |
|---|---|---|---|
| Submission normalisation | unit | tests/test_submit_record.py | No |
| Filter regression (adversarial) | unit | tests/test_filter.py | No |
| Checkout journey | ui-unit | tests/checkout.spec.ts | No |

`tests/checkout.spec.ts` intercepts network requests with `page.route`, so it is
classified **ui-unit**, not `e2e-ui`. The taxonomy reserves the live categories
for real-stack execution; labelling a mocked run `e2e-ui` would assert a
verification that never happened.
