#!/bin/bash
# Инициализация config server как replica set (обязательно для MongoDB 5+)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
docker compose exec -T configsrv mongosh --port 27019 --quiet < "$SCRIPT_DIR/init-configsrv.js"
