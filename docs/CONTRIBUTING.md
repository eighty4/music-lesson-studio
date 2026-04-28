# Up & running

Run these commands from the root of a fresh clone:

```shell
# install all Dart and npm dependencies
pnpm i
dart pub get

# launch postgres & apply migrations
docker compose up -d --wait
./sql/refresh-database.sh
```

Re-run `refresh-database.sh` to resync the database after changing migration scripts.
