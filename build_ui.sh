#!/bin/sh

cd studio || exit 1
rm -rf build/web
flutter build web --base-href "/ui/" --release --target lib/main_web.dart
cd .. || exit 1

rm -rf web/static/ui
mv studio/build/web web/static/ui
