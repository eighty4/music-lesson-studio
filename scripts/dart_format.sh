#!/bin/sh

DIR_ROOT="$(realpath $( cd "$( dirname "$0" )" && pwd )/..)"

cd "$DIR_ROOT" || exit 1

dart format \
  app/lib \
  app/test \
  packages/api_client/lib \
  packages/api_client/test \
  packages/create_auth_token/lib \
  studio/lib \
  studio/test \
  --set-exit-if-changed
