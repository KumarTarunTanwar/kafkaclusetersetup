#!/bin/bash

mkdir -p /mnt/zookeeper/data
mkdir -p /mnt/zookeeper/log
mkdir -p /etc/zookeeper/conf

echo "Update zookeeper config file"

echo "clientPort=2181" > /etc/zookeeper/conf/zoo.cfg
echo "tickTime=2000" >> /etc/zookeeper/conf/zoo.cfg
echo "initLimit=10" >> /etc/zookeeper/conf/zoo.cfg
echo "syncLimit=10" >> /etc/zookeeper/conf/zoo.cfg
echo "dataDir=/mnt/zookeeper/data" >> /etc/zookeeper/conf/zoo.cfg
echo "dataLogDir=/mnt/zookeeper/log" >> /etc/zookeeper/conf/zoo.cfg

cat /etc/zookeeper/conf/zoo.cfg

exec /opt/zookeeper/bin/zkServer.sh start-foreground /etc/zookeeper/conf/zoo.cfg