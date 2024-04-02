# Music Lesson Studio - e2e

## Development

### Run tests headless in all browsers

```shell
# pnpm test
pnpm exec playwright test
```

### Run tests in interactive interface

```shell
# pnpm test:ui
pnpm exec playwright test --ui
```

### Run tests headless in a specific browser

```shell
pnpm exec playwright test --project=chromium
```

### Run tests in an open browser window

```shell
pnpm exec playwright test --headed --project=chromium
```

### Run a test by regular expression

```shell
pnpm exec playwright test --headed --project=firefox -g "add faculty"
```
