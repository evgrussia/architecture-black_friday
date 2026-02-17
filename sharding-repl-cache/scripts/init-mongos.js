sh.addShard("rs1/shard1-1:27018,shard1-2:27018,shard1-3:27018");
sh.addShard("rs2/shard2-1:27018,shard2-2:27018,shard2-3:27018");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "_id": "hashed" });
