# Music Lesson Studio - UI

## Development

Run to be embedded in web app:

```shell
flutter run -d web-server --web-port 5710
```

Run standalone in Chrome browser:

```shell
flutter run -d chrome --web-port 5710
```

Analyze sources:

```shell
flutter analyze
```

Format sources:

```shell
dart format lib test
```

Upgrade dependencies:

```shell
dart pub upgrade
```

Check for out of date dependencies:

```shell
dart pub outdated
```

## Build

```shell
flutter build web --base-href "/" --release
```
