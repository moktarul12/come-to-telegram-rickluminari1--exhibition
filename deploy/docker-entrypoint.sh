#!/bin/sh
set -e
mkdir -p /app/server/data
if [ -z "${TURSO_DATABASE_URL:-}" ] && [ ! -f /app/server/data/expohub.db ]; then
  echo "[entrypoint] Seeding local libSQL database…"
  npm --prefix server run seed
fi
exec "$@"
