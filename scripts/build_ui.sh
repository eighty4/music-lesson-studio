#!/bin/sh

DIR_ROOT="$(realpath $( cd "$( dirname "$0" )" && pwd )/..)"
DIR_STUDIO="$DIR_ROOT/studio"
DIR_WEB="$DIR_ROOT/web"

rm -rf "$DIR_STUDIO/build/web"

cd "$DIR_STUDIO" || exit 1
flutter build web --base-href "/ui/" --release --target lib/main_web.dart --wasm

rm -rf "$DIR_WEB/static/ui"
mv "$DIR_STUDIO/build/web" "$DIR_WEB/static/ui"
