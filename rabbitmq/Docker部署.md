## docker配置rabbitmq集群：

#### 启动集群
>docker run -d -p 15672:15672 -p 5672:5672 --name rabbit_master --hostname rabbit_master -e RABBITMQ_ERLANG_COOKIE='rabbitmq_cookie' rabbitmq:management

>docker run -d -p 15673:15672 -p 5673:5672 --name rabbit_node1 --hostname rabbit_node1 --link rabbit_master:rabbit_master -e RABBITMQ_ERLANG_COOKIE='rabbitmq_cookie' rabbitmq:management

>docker run -d -p 15674:15672 -p 5674:5672 --name rabbit_node2 --hostname rabbit_node2 --link rabbit_master:rabbit_master --link rabbit_node1:rabbit_node1 -e RABBITMQ_ERLANG_COOKIE='rabbitmq_cookie' rabbitmq:management

#### 节点加入集群
第1台
>docker exec -it rabbit_master bash
>
>rabbitmqctl stop_app
>rabbitmqctl reset 
>rabbitmqctl start_app 

第2台
>docker exec -it rabbit_node1 bash
>
>rabbitmqctl stop_app
>rabbitmqctl reset 
>rabbitmqctl join_cluster --ram rabbit@rabbit_master 
>rabbitmqctl start_app 
>exit

第3台
>docker exec -it rabbit_node2 bash
>
>rabbitmqctl stop_app
>rabbitmqctl reset 
>rabbitmqctl join_cluster --ram rabbit@rabbit_master 
>rabbitmqctl start_app 
>exit


**--ram 表示设置为内存节点；不带参数 表示设置为硬盘节点；集群中必须得至少有一个硬盘节点**

---

**或者直接使用docker-compose编排**
```yaml
version: "3.8"
services:
  rabbit_master:
    image: rabbitmq:management
    container_name: rabbit_master
    restart: always
    hostname: rabbit_master
    ports:
      - 5672:5672
      - 15672:15672
    volumes:
      - ./rabbit_master/data:/var/lib/rabbitmq
    environment:
      - TZ=Asia/Shanghai
      - LANG=en_US.UTF-8
      - RABBITMQ_ERLANG_COOKIE=RABBITMQCOOKIE
      - RABBITMQ_NODENAME:rabbit_master
    networks:
      - rabbitmq

  rabbit_node1:
    image: rabbitmq:management
    container_name: rabbit_node1
    restart: always
    hostname: rabbit_node1
    ports:
      - 5673:5672
      - 15673:15672
    volumes:
      - ./rabbit_node1/data:/var/lib/rabbitmq
    environment:
      - TZ=Asia/Shanghai
      - LANG=en_US.UTF-8
      - RABBITMQ_ERLANG_COOKIE=RABBITMQCOOKIE
      - RABBITMQ_NODENAME:rabbit_node1
    networks:
      - rabbitmq

  rabbit_node2:
    image: rabbitmq:management
    container_name: rabbit_node2
    restart: always
    hostname: rabbit_node2
    ports:
      - 5674:5672
      - 15674:15672
    volumes:
      - ./rabbit_node2/data:/var/lib/rabbitmq
    environment:
      - TZ=Asia/Shanghai
      - LANG=en_US.UTF-8
      - RABBITMQ_ERLANG_COOKIE=RABBITMQCOOKIE
      - RABBITMQ_NODENAME:rabbit_node2
    networks:
      - rabbitmq

networks:
  rabbitmq:
    driver: bridge
```

**运行初始化脚本**
```shell
#!/bin/bash

echo "------reset rabbit_master-----"
docker exec rabbit_master /bin/bash -c 'rabbitmqctl stop_app'
docker exec rabbit_master /bin/bash -c 'rabbitmqctl reset'
docker exec rabbit_master /bin/bash -c 'rabbitmqctl start_app'

echo "------reset rabbit_node1------"
docker exec rabbit_node1 /bin/bash -c 'rabbitmqctl stop_app'
docker exec rabbit_node1 /bin/bash -c 'rabbitmqctl reset'
docker exec rabbit_node1 /bin/bash -c 'rabbitmqctl join_cluster --ram rabbit@rabbit_master'
docker exec rabbit_node1 /bin/bash -c 'rabbitmqctl start_app'

echo "------reset rabbit_node2------"
docker exec rabbit_node2 /bin/bash -c 'rabbitmqctl stop_app'
docker exec rabbit_node2 /bin/bash -c 'rabbitmqctl reset'
docker exec rabbit_node2 /bin/bash -c 'rabbitmqctl join_cluster --ram rabbit@rabbit_master'
docker exec rabbit_node2 /bin/bash -c 'rabbitmqctl start_app'
```

---

#### 配置策略
<img width="837" alt="image" src="https://user-images.githubusercontent.com/34562805/200748894-cf1cdc0a-99dc-46d4-8ea6-c37097c8e150.png">

#### 连接
<img width="518" alt="image" src="https://user-images.githubusercontent.com/34562805/200749033-b4d25b2b-17f0-491d-8654-6b4995e37e5d.png">
