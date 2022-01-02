#!/bin/bash

# 停止、删除服务
docker-compose down

#删除存储文件
rm -rf /data/mongodb

# 删除 docker 网络
docker network rm mongodbs

