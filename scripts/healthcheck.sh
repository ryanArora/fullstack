#!/usr/bin/env bash
set -euo pipefail

if [ -f .env ]; then
  set -o allexport
  source .env
  set +o allexport
fi

HEALTHCHECKS=10

postgres_success=false
for i in $(seq 1 $HEALTHCHECKS); do
  echo "Healthcheck for postgres $i/$HEALTHCHECKS..."

  if psql "$POSTGRES_URL" -c "SELECT 1;"; then
    echo "Success on attempt $i"
    postgres_success=true
    break
  fi

  sleep 2
done

if [ "$postgres_success" = false ]; then
  echo "Failed to connect to postgres after $HEALTHCHECKS attempts"
  exit 1
fi

minio_success=false
for i in $(seq 1 $HEALTHCHECKS); do
  echo "Healthcheck for minio $i/$HEALTHCHECKS..."

  PROTOCOL="http"
  if [ "$MINIO_USE_SSL" = "1" ] || [ "$MINIO_USE_SSL" = "true" ]; then
    PROTOCOL="https"
  fi

  if curl -fI "$PROTOCOL://$MINIO_ENDPOINT:$MINIO_PORT/minio/health/live"; then
    echo "Success on attempt $i"
    minio_success=true
    break
  fi

  sleep 2
done

if [ "$minio_success" = false ]; then
  echo "Failed to connect to minio after $HEALTHCHECKS attempts"
  exit 1
fi

echo "Healthcheck successful"
exit 0