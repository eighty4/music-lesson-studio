# Music Lesson Studio

## Dev workflow

Read [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) to prep a new workspace for development.

### App

```shell
cd app
flutter run
```

### Studio UI

Release build is required for developing Studio UI proxied through the webapp. An issue when proxying Dart Web's debug service WS connection prevents debug mode.

```shell
cd studio
flutter run -d web-server --web-port 5710 --release
```

### Web app

```shell
cd web
pnpm dev
```

### Playwright tests

```shell
cd test
pnpm test:ui
```
