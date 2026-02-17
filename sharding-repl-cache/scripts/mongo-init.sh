#!/bin/bash
# Наполнение коллекции helloDoc в БД somedb
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
docker compose exec -T mongos mongosh --port 27017 --quiet < "$SCRIPT_DIR/mongo-init.js"
