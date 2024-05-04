# Music Lesson Studio

## Dev workflow

### App

```shell
cd app
flutter run
```

### Studio UI

```shell
cd studio
flutter run -d web-server --web-port 5710
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
