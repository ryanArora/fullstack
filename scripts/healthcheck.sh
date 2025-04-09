#!/usr/bin/env bash
set -euo pipefail

if [ -f .env ]; then
  set -o allexport
  source .env
  set +o allexport
fi

for i in {1..10}; do
  echo "Healthcheck for postgres $i/10..."

  if psql -h $POSTGRES_HOST -U $POSTGRES_USER -d $POSTGRES_DB -c "SELECT 1;"; then
    echo "Success on attempt $i"
    break
  fi

  sleep 2
done

for i in {1..10}; do
  echo "Healthcheck for minio $i/10..."

  PROTOCOL="http"
  if [ "$MINIO_USE_SSL" = "1" ] || [ "$MINIO_USE_SSL" = "true" ]; then
    PROTOCOL="https"
  fi

  if curl -fI "$PROTOCOL://$MINIO_ENDPOINT:$MINIO_PORT/minio/health/live"; then
    echo "Success on attempt $i"
    break
  fi

  sleep 2
done