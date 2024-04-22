#!/bin/sh

cd ui || exit 1
rm -rf build/web
flutter build web --base-href "/ui/"
cd .. || exit 1

rm -rf web/static/ui
mv ui/build/web web/static/ui
