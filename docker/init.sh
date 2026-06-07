#!/bin/bash
set -e

SITE_NAME="hralrahi.com"
BENCH_DIR="/home/frappe/frappe-bench"

if [ -d "${BENCH_DIR}/apps/frappe" ]; then
  echo "Bench already exists, applying config and starting"
  cd "${BENCH_DIR}"

  export PATH="${NVM_DIR}/versions/node/v${NODE_VERSION_DEVELOP}/bin/:${PATH}"

  bench set-mariadb-host mariadb
  bench set-redis-cache-host redis://redis:6379
  bench set-redis-queue-host redis://redis:6379
  bench set-redis-socketio-host redis://redis:6379

  sed -i '/redis/d' ./Procfile || true
  sed -i '/watch/d' ./Procfile || true

  if [ ! -d "${BENCH_DIR}/sites/${SITE_NAME}" ]; then
    echo "Site ${SITE_NAME} does not exist, creating site"

    bench new-site "${SITE_NAME}" \
      --force \
      --mariadb-root-password 123 \
      --admin-password admin \
      --no-mariadb-socket

    bench --site "${SITE_NAME}" install-app erpnext
    bench --site "${SITE_NAME}" install-app hrms
    bench --site "${SITE_NAME}" set-config developer_mode 1
    bench --site "${SITE_NAME}" enable-scheduler
    bench --site "${SITE_NAME}" clear-cache
  fi

  bench use "${SITE_NAME}" || true
  bench --site "${SITE_NAME}" clear-cache || true

  bench start
  exit 0
fi

echo "Creating new bench..."

export PATH="${NVM_DIR}/versions/node/v${NODE_VERSION_DEVELOP}/bin/:${PATH}"

bench init --skip-redis-config-generation frappe-bench
cd "${BENCH_DIR}"

bench set-mariadb-host mariadb
bench set-redis-cache-host redis://redis:6379
bench set-redis-queue-host redis://redis:6379
bench set-redis-socketio-host redis://redis:6379

sed -i '/redis/d' ./Procfile || true
sed -i '/watch/d' ./Procfile || true

bench get-app erpnext
bench get-app hrms

bench new-site "${SITE_NAME}" \
  --force \
  --mariadb-root-password 123 \
  --admin-password admin \
  --no-mariadb-socket

bench --site "${SITE_NAME}" install-app erpnext
bench --site "${SITE_NAME}" install-app hrms
bench --site "${SITE_NAME}" set-config developer_mode 1
bench --site "${SITE_NAME}" enable-scheduler
bench --site "${SITE_NAME}" clear-cache

bench use "${SITE_NAME}"
bench start
