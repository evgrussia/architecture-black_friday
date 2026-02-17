#!/bin/bash
# Инициализация config server как replica set (обязательно для MongoDB 5+)
docker compose exec -T configsrv mongosh --port 27019 --quiet <<EOF
rs.initiate({
  _id: "configReplSet",
  configsvr: true,
  members: [{ _id: 0, host: "configsrv:27019" }]
})
EOF
