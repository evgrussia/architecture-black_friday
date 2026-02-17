#!/bin/bash
# Добавление шардов в кластер, включение шардирования для somedb и коллекции helloDoc
docker compose exec -T mongos mongosh --port 27017 --quiet <<EOF
sh.addShard("rs1/shard1:27018")
sh.addShard("rs2/shard2:27018")
sh.enableSharding("somedb")
sh.shardCollection("somedb.helloDoc", { "_id": "hashed" })
EOF
