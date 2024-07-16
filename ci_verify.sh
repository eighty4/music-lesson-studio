#!/bin/sh
set -e

# run through all the checks done for ci

cd packages/api_client
echo '\n*** mls_api ***'
flutter test
flutter analyze
dart format lib test --set-exit-if-changed
cd ../..

cd studio
echo '\n*** studio ***'
dart format lib test --set-exit-if-changed
flutter analyze
flutter test
cd ..

cd web
echo '\n*** web ***'
pnpm check
pnpm test
cd ..

cd test
echo '\n*** test ***'
pnpm test
cd ..
