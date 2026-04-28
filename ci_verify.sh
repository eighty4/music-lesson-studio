#!/bin/sh
set -e

# run through all the checks done for ci

# requires db and web dependencies running for tests to succeed
#  ./
#    docker compose up -d --wait
#  ./web
#    pnpm dev

if ! nc -z localhost 5432 2>/dev/null ; then
  echo "postgres is not running locally\n\n    run \`docker compose up -d --wait\`\n"
  exit 1
fi

if ! curl -s http://localhost:5173 -o /dev/null ; then
  echo "web is not running locally\n\n    run \`pnpm dev\` from ./web\n"
  exit 1
fi

# update playwright browsers
cd packages/create_auth_token
pnpm exec playwright install
cd ../..
cd test
pnpm exec playwright install
cd ..

cd packages/api_client
echo '\n*** mls_api: test ***'
flutter test
cd ../..

cd app
echo '\n*** app: test ***'
flutter test
echo '\n*** app: build ***'
flutter build appbundle
cd ..

cd studio
echo '\n*** studio: test ***'
flutter test
cd ..

cd web
echo '\n*** web: check ***'
pnpm check
echo '\n*** web: test ***'
pnpm test
cd ..

cd test
echo '\n*** test: test ***'
pnpm test
cd ..

echo '\n*** flutter analyze ***'
flutter analyze

echo '\n*** dart fmt ***'
./scripts/dart_format.sh
