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