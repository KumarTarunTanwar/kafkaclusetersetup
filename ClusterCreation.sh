#!/bin/sh

downloadRequriedFiles(){

  mkdir -p /tmp/kafkacluster/cruisecontrol/logs
  echo "Copying cruisecontrol binary"
  script_path1="${BASH_SOURCE[0]}"
  DIR="$( dirname "$SOURCE" )"
  cp $DIR/cruise-control.zip /tmp/kafkacluster/cruisecontrol && tar -xzf /tmp/kafkacluster/cruisecontrol/cruise-control.zip -C /tmp/kafkacluster/cruisecontrol
  cp $DIR/cruise-control-ui.tar.gz /tmp/kafkacluster/cruisecontrol && tar -xzf /tmp/kafkacluster/cruisecontrol/cruise-control-ui.tar.gz -C /tmp/kafkacluster/cruisecontrol/cruise-control

  mkdir -p /tmp/kafkacluster/kafka
  if [ ! -d "/tmp/kafkacluster/kafka/kafka_2.13-2.7.0" ]; then
     echo "\n Download kafka binary"
     curl -L https://archive.apache.org/dist/kafka/2.7.0/kafka_2.13-2.7.0.tgz -o /tmp/kafkacluster/kafka/kafka_2.13-2.7.0.tgz \
     && tar -xzf /tmp/kafkacluster/kafka/kafka_2.13-2.7.0.tgz -C /tmp/kafkacluster/kafka

    cp $DIR/cruise-control-metrics-reporter-2.5.32.jar /tmp/kafkacluster/kafka/kafka_2.13-2.7.0/libs

  fi

  mkdir -p /tmp/kafkacluster/zookeeper
  if [ ! -d "/tmp/kafkacluster/zookeeper/zookeeper-3.4.7" ]; then
    echo "\n Download zookeeper binary"
    curl -L https://archive.apache.org/dist/zookeeper/zookeeper-3.4.7/zookeeper-3.4.7.tar.gz -o /tmp/kafkacluster/zookeeper/zookeeper-3.4.7.tar.gz \
    && tar -xzf /tmp/kafkacluster/zookeeper/zookeeper-3.4.7.tar.gz -C /tmp/kafkacluster/zookeeper
  fi
}

runZookeeperNode(){

  echo "\n Running kafka zookeeper Node"

  mkdir -p /tmp/kafkacluster/zookeeper/server/data
  mkdir -p /tmp/kafkacluster/zookeeper/server/log
  mkdir -p /tmp/kafkacluster/zookeeper/server/conf

  echo "clientPort=${zookeeperPort}" > /tmp/kafkacluster/zookeeper/server/conf/zoo.cfg
  echo "tickTime=2000" >> /tmp/kafkacluster/zookeeper/server/conf/zoo.cfg
  echo "initLimit=10" >> /tmp/kafkacluster/zookeeper/server/conf/zoo.cfg
  echo "syncLimit=10" >> /tmp/kafkacluster/zookeeper/server/conf/zoo.cfg
  echo "dataDir=/tmp/kafkacluster/zookeeper/server/data" >> /tmp/kafkacluster/zookeeper/server/conf/zoo.cfg
  echo "dataLogDir=/tmp/kafkacluster/zookeeper/server/log" >> /tmp/kafkacluster/zookeeper/server/conf/zoo.cfg

  nohup /tmp/kafkacluster/zookeeper/zookeeper-3.4.7/bin/zkServer.sh start-foreground /tmp/kafkacluster/zookeeper/server/conf/zoo.cfg >> /tmp/kafkacluster/zookeeper/server/log/zookeeper.out &

  echo "\n Wait for few seconds before next operation"
  sleep 10
}

addKafkaNode() {

#  kill -9 $(lsof -t -i:$2)

  echo "\n Adding new kafka broker node with broker id $1"

  mkdir -p /tmp/kafkacluster/kafka/kafka-$1/conf
  mkdir -p /tmp/kafkacluster/kafka/kafka-$1/logs
  mkdir -p /tmp/kafkacluster/kafka/kafka-$1/data

  echo "broker.id=$1" > /tmp/kafkacluster/kafka/kafka-$1/conf/server.properties
  echo "log.dirs=/tmp/kafkacluster/kafka/kafka-$1/logs" >> /tmp/kafkacluster/kafka/kafka-$1/conf/server.properties
  echo "port=$2" >> /tmp/kafkacluster/kafka/kafka-$1/conf/server.properties
  echo "advertised.port=$2" >> /tmp/kafkacluster/kafka/kafka-$1/conf/server.properties=
  echo "advertised.host.name=localhost" >> /tmp/kafkacluster/kafka/kafka-$1/conf/server.properties
  echo "host.name=localhost" >> /tmp/kafkacluster/kafka/kafka-$1/conf/server.properties
  echo "advertised.listeners=PLAINTEXT://localhost:$2" >> /tmp/kafkacluster/kafka/kafka-$1/conf/server.properties
  echo "zookeeper.connect=localhost:${zookeeperPort}" >> /tmp/kafkacluster/kafka/kafka-$1/conf/server.properties
  echo "metric.reporters=com.linkedin.kafka.cruisecontrol.metricsreporter.CruiseControlMetricsReporter" >> /tmp/kafkacluster/kafka/kafka-$1/conf/server.properties

  nohup /tmp/kafkacluster/kafka/kafka_2.13-2.7.0/bin/kafka-server-start.sh /tmp/kafkacluster/kafka/kafka-$1/conf/server.properties >>/tmp/kafkacluster/kafka/kafka-$1/logs/kafka-$1.out &

  echo "\n Wait for few seconds to Validate the node connected to zookeeper"
  sleep 10
   echo "\n Validate broker id $1 connected to zookeeper"
  ./kafka/kafka_2.13-2.7.0/bin/zookeeper-shell.sh localhost:${zookeeperPort} ls /brokers/ids
}

runCruiseControl(){
  sleep 10
  echo "\n Run CruiseControl with UI on http://localhost:9090/ \n "

  sed -i '' -e 's/bootstrap.servers=.*/bootstrap.servers=localhost:9095,localhost:9096,localhost:9097,localhost:9098,localhost:9099/g' cruisecontrol/cruise-control/config/cruisecontrol.properties
  sed -i '' -e 's/zookeeper.connect=.*/zookeeper.connect=localhost:'${zookeeperPort}'/g' cruisecontrol/cruise-control/config/cruisecontrol.properties
  sed -i '' -e 's/capacity.config.file=.*/capacity.config.file=cruisecontrol\/cruise-control\/config\/capacityJBOD.json/g' cruisecontrol/cruise-control/config/cruisecontrol.properties
  sed -i '' -e 's/cluster.configs.file=.*/cluster.configs.file=cruisecontrol\/cruise-control\/config\/clusterConfigs.json/g' cruisecontrol/cruise-control/config/cruisecontrol.properties
  sed -i '' -e 's/sample.store.topic.replication.factor=.*/sample.store.topic.replication.factor=1/g' cruisecontrol/cruise-control/config/cruisecontrol.properties
  sed -i '' -e 's/webserver.ui.diskpath=.*/webserver.ui.diskpath=cruisecontrol\/cruise-control\/cruise-control-ui\/dist\//g' cruisecontrol/cruise-control/config/cruisecontrol.properties
  sed -i '' -e 's/hard.goals=.*/hard.goals=com.linkedin.kafka.cruisecontrol.analyzer.goals.ReplicaDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.TopicReplicaDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.LeaderReplicaDistributionGoal,com.linkedin.kafka.cruisecontrol.analyzer.goals.CpuCapacityGoal/g' cruisecontrol/cruise-control/config/cruisecontrol.properties
  ./cruisecontrol/cruise-control/kafka-cruise-control-start.sh -jars cruisecontrol/cruise-control/cruise-control/build/dependant-libs/  cruisecontrol/cruise-control/config/cruisecontrol.properties 9090 >> /tmp/kafkacluster/cruisecontrol/logs/cruisecontrol.log &
}

echo "Starting Cluster creation"

echo "Cluster Will be Starting With zookeeper:2182 and kafkabrokers 9095-0999 Cluster creation"

mkdir -p /tmp/kafkacluster
chmod -R 777 /tmp/kafkacluster

zookeeperPort=2181

# Download and update all required files under tmp
downloadRequriedFiles

cd /tmp/kafkacluster
rm -rf /tmp/kafkacluster/kafka/kafka-1*

# Running kafka zookeeper Node
runZookeeperNode

echo "\n Validate broker id $1 connected to zookeeper"
./kafka/kafka_2.13-2.7.0/bin/zookeeper-shell.sh localhost:${zookeeperPort} ls /brokers/ids

# Addd Broker Nodes with id and port
addKafkaNode 100 9095
addKafkaNode 101 9096

echo "\n Wait for few seconds before creating topics"
sleep 10

echo "creating 20 topics with partition 4 and replication-factor 2"
i=1
while [ $i -le 20 ]
do
    ./kafka/kafka_2.13-2.7.0/bin/kafka-topics.sh --zookeeper localhost:${zookeeperPort} --create --topic testtopic${i} --replication-factor 2 --partitions 4
    ((i=i+1))
done

echo "\n Waiting for few seconds to describe all 20 topics"
sleep 10
./kafka/kafka_2.13-2.7.0/bin/kafka-topics.sh --zookeeper localhost:${zookeeperPort} --describe

# Run CruiseControl with UI on http://localhost:9090/
runCruiseControl

echo "validate kafka_cluster_state"
sleep 10
curl http://localhost:9090/kafkacruisecontrol/kafka_cluster_state?json=true

echo "\n Adding 3 new kafka broker node with cluster \n "
addKafkaNode 102 9097
addKafkaNode 103 9098
addKafkaNode 104 9099

sleep 10
echo "\n describe all 20 topics After Adding new Nodes \n "
./kafka/kafka_2.13-2.7.0/bin/kafka-topics.sh --zookeeper localhost:${zookeeperPort} --describe
