#!/bin/bash

DIR_ROOT="$(realpath "$( cd "$( dirname "$0" )" && pwd )/..")"
cd "$DIR_ROOT/sql" || exit 1

echo "drop schema if exists music_lesson_studio cascade" | docker exec -i music-postgres psql -U eighty4
< "v001-init-schema.sql" docker exec -i music-postgres psql -U eighty4
