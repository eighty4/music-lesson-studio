#!/bin/sh

cd studio || exit 1
rm -rf build/web
flutter build web --base-href "/ui/" --release --target lib/main_web.dart
cd .. || exit 1

rm -rf web/static/ui
mv studio/build/web web/static/ui

_ev=PUBLIC_STUDIO_FSWV
_fswv=$(grep "serviceWorkerVersion ="  < web/static/ui/index.html | cut -d'"' -f2)
sed -i '' "s/$_ev=\"\"/$_ev=\"$_fswv\"/" web/.env
