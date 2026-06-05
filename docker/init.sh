#!/bin/bash

set -e

if [ -d "/home/frappe/frappe-bench/apps/frappe" ]; then
    echo "Bench already exists, skipping init"
    cd /home/frappe/frappe-bench
    bench start
    exit 0
fi

echo "Creating new bench..."

export PATH="${NVM_DIR}/versions/node/v${NODE_VERSION_DEVELOP}/bin/:${PATH}"

bench init --skip-redis-config-generation frappe-bench

cd /home/frappe/frappe-bench

# Use containers instead of localhost
bench set-mariadb-host mariadb
bench set-redis-cache-host redis://redis:6379
bench set-redis-queue-host redis://redis:6379
bench set-redis-socketio-host redis://redis:6379

# Remove redis and watch from Procfile because Docker Compose runs Redis separately
sed -i '/redis/d' ./Procfile
sed -i '/watch/d' ./Procfile

bench get-app erpnext
bench get-app hrms

bench new-site hr.alrahigroup.com \
  --force \
  --mariadb-root-password 123 \
  --admin-password admin \
  --no-mariadb-socket

bench --site hr.alrahigroup.com install-app erpnext
bench --site hr.alrahigroup.com.com install-app hrms

bench --site hr.alrahigroup.com set-config developer_mode 1
bench --site hr.alrahigroup.com enable-scheduler
bench --site hr.alrahigroup.com clear-cache

bench use hr.alrahigroup.com

bench start
