#!/bin/bash
# Инициализация replica set для shard1
docker compose exec -T shard1 mongosh --port 27018 --quiet <<EOF
rs.initiate({
  _id: "rs1",
  members: [{ _id: 0, host: "shard1:27018" }]
})
EOF
