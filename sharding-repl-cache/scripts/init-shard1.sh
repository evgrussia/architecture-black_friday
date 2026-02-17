#!/bin/bash
# Инициализация replica set rs1 с тремя репликами
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
docker compose exec -T shard1-1 mongosh --port 27018 --quiet < "$SCRIPT_DIR/init-shard1.js"
