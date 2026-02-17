#!/bin/bash
# Инициализация replica set rs2 с тремя репликами
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
docker compose exec -T shard2-1 mongosh --port 27018 --quiet < "$SCRIPT_DIR/init-shard2.js"
