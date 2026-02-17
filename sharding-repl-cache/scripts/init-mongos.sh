#!/bin/bash
# Добавление шардов в кластер, включение шардирования для somedb и коллекции helloDoc
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
docker compose exec -T mongos mongosh --port 27017 --quiet < "$SCRIPT_DIR/init-mongos.js"
