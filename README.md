# mongo-cluster-with-docker-compose
## 集群部署

共使用三台服务器搭建集群，每台服务器端口分配如下：

| 服务          | 端口  |
| ------------- | ----- |
| mongos        | 10011 |
| config_server | 10021 |
| shard1_server | 10031 |
| shard2_server | 10041 |



服务器环境：

- Docker version 20.10.5
- docker-compose version 1.28.6
- root 权限



将部署文件夹拷贝至其中一台主机上，执行以下内容：

```bash
$ cd mongodb-with-docker-compose  # 进入文件目录
$ vim docker-compose.yml  # 将文件中 <your_host_ip_1/2/3> 修改为实际的三个主机ip
$ openssl rand -base64 756 > key.file  # 生成密钥文件，三台共用
$ chmod +x *.sh && ./mongo_install.sh  # 启动
```

将修改后的文件夹拷贝至其它两台主机上，执行以下内容：

```bash
$ cd mongodb-with-docker-compose  # 进入文件目录
$ chmod +x *.sh && ./mongo_install.sh  # 启动
```



所有服务启动成功后，由于配置了安全认证，在无用户情况下需进入容器使用本地 mongo 进行以下初始化：

1. 初始化配置服务器副本集

```bash
$ docker exec -it rs_config_server mongo --port 27019
> rs.initiate({
            _id: "rs-config-server",
            configsvr: true,
            members: [
                { _id : 0, host : "<your_host_ip_1>:10021" },
                { _id : 1, host : "<your_host_ip_2>:10021" },
                { _id : 2, host : "<your_host_ip_3>:10021" },
            ]
        });
> rs.status()  # 查看副本集状态
```

2. 初始化分片1副本集：

```bash
$ docker exec -it rs_shard1_server mongo --port 27018
> rs.initiate({
            _id: "rs-shard1-server",
            members: [
                { _id : 0, host : "<your_host_ip_1>:10031" },
                { _id : 1, host : "<your_host_ip_2>:10031" },
                { _id : 2, host : "<your_host_ip_3>:10031" },
            ]
        });
> rs.status()  # 查看副本集状态
```

3. 初始化分片2副本集：

```bash
$ docker exec -it rs_shard2_server mongo --port 27018
> rs.initiate({
            _id: "rs-shard2-server",
            members: [
                { _id : 0, host : "<your_host_ip_1>:10041" },
                { _id : 1, host : "<your_host_ip_2>:10041" },
                { _id : 2, host : "<your_host_ip_3>:10041" },
            ]
        });
> rs.status()  # 查看副本集状态
```

4. mongos 添加分片并添加用户：

```bash
$ docker exec -it rs_mongos_server mongo --port 27017
> sh.addShard("rs-shard1-server/<your_host_ip_1>:10031,<your_host_ip_2>:10031,<your_host_ip_3>:10031")
> sh.addShard("rs-shard2-server/<your_host_ip_1>:10041,<your_host_ip_2>:10041,<your_host_ip_3>:10041")
> use admin  # 切换至 admin
> db.createUser({
            user: "root",
            pwd: "123456",
            roles: [
               	{ role: "root", db: "admin" }
            ]
      })
```



## 验证

现在可以在外部客户端使用配置的用户连接 mongodb（需开放相应端口）：

```bash
$ mongo --host <your_host_ip> --port 10011 -u root
> show dbs  # 正常情况下可看到当前所有数据库
> sh.status()  # 查看分片情况
```

