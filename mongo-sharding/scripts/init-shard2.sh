#!/bin/bash
# Инициализация replica set для shard2
docker compose exec -T shard2 mongosh --port 27018 --quiet <<EOF
rs.initiate({
  _id: "rs2",
  members: [{ _id: 0, host: "shard2:27018" }]
})
EOF
