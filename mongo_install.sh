#!/bin/bash

# 创建相应的目录
mkdir -p /data/mongodb/mongos/config
mkdir -p /data/mongodb/conf/config
mkdir -p /data/mongodb/conf/db
mkdir -p /data/mongodb/shard1/config
mkdir -p /data/mongodb/shard1/db
mkdir -p /data/mongodb/shard2/config
mkdir -p /data/mongodb/shard2/db
mkdir -p /data/mongodb/security

# 拷贝配置文件
cp mongos.conf /data/mongodb/mongos/config/mongos.conf
cp mongod.conf /data/mongodb/conf/config/mongod.conf
cp mongod.conf /data/mongodb/shard1/config/mongod.conf
cp mongod.conf /data/mongodb/shard2/config/mongod.conf
cp key.file /data/mongodb/security/key.file

# 配置 key.file 权限
chmod 400 /data/mongodb/security/key.file
chown 999 /data/mongodb/security/key.file

# 创建 docker 网络
docker network create mongodbs

# 启动服务
docker-compose up -d