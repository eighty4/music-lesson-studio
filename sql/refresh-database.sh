#!/bin/bash

echo "drop schema if exists music_lesson_studio cascade" | docker exec -i music-postgres psql -U eighty4
< v001-init-schema.sql docker exec -i music-postgres psql -U eighty4
