#!/bin/sh

addKafkaNode() {
  echo "\n Adding new kafka broker node with broker id $1"
  docker run -d --net host -e BROKER_ID=$1 -e PORT=$2 kafkabroker
  echo "\n Wait for few seconds to Validate the node connected to zookeeper"
  sleep 10
  echo "\n Validate broker id $1 connected to zookeeper"
  ./kafka_2.13-2.7.0/bin/zookeeper-shell.sh localhost:2181 ls /brokers/ids
}

echo "Building kafka zookeeper image"
docker build zookeeper -t zookeepernode

echo "\n Building kafka broker image"
docker build kafka -t kafkabroker


echo "Download kafka binary for validation"
mkdir -p /tmp/kafka
chmod -R 777 /tmp/kafka

cd /tmp/kafka
curl -L https://archive.apache.org/dist/kafka/2.7.0/kafka_2.13-2.7.0.tgz -o /tmp/kafka/kafka_2.13-2.7.0.tgz && tar -xzf /tmp/kafka/kafka_2.13-2.7.0.tgz -C /tmp/kafka

echo "\n Running kafka zookeeper image"
docker run -d -p 2181:2181 zookeepernode

echo "\n Wait for few seconds before next operation"
sleep 10

addKafkaNode 100 9092
addKafkaNode 101 9093

echo "\n Wait for few seconds before creating topics"
sleep 10

echo "creating 20 topics with partition 4 and replication-factor 2"
i=1
while [ $i -le 20 ]
do
    ./kafka_2.13-2.7.0/bin/kafka-topics.sh --zookeeper localhost:2181 --create --topic testtopic${i} --replication-factor 2 --partitions 4
    ((i=i+1))
done

echo "\n Waiting for few seconds"
sleep 10
echo "describe all 20 topics"
./kafka_2.13-2.7.0/bin/kafka-topics.sh --zookeeper localhost:2181 --describe


echo "\n Adding 3 new kafka broker node with cluster \n "
addKafkaNode 102 9094
addKafkaNode 103 9095
addKafkaNode 104 9096

sleep 10
echo "\n describe all 20 topics before CLUSTER REBALANCING \n "
./kafka_2.13-2.7.0/bin/kafka-topics.sh --zookeeper localhost:2181 --describe


sleep 10
echo "\n Run CLUSTER REBALANCING with Cruise Control \n "


sleep 10
echo "\n describe all 20 topics after CLUSTER REBALANCING \n "
./kafka_2.13-2.7.0/bin/kafka-topics.sh --zookeeper localhost:2181 --describe
