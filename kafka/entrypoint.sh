#!/bin/bash

brokerIdStart=${BROKER_ID_START:-100}

      echo "Finding/Generating broker id"
      if [[ -z "${BROKER_ID}" ]]; then
              echo "server id is not provided .Assuming its k8s deployment"
              [[ `hostname` =~ -([0-9]+)$ ]] || exit 1
              ordinal=${BASH_REMATCH[1]}
              brokerID=$(( $brokerIdStart + $ordinal))
        else
               echo "broker id provided"
              brokerID=${BROKER_ID}
      fi

echo "broker id for this node ${brokerID}"
export brokerID=$brokerID

export hostIp=`hostname -I | cut -d' ' -f1`

echo " IP of the machine is ${hostIp}"

mkdir -p /etc/kafka/conf
mkdir -p /etc/kafka/logs
port=${PORT:-9092}

echo "broker.id=${brokerID}" > /etc/kafka/conf/server.properties
echo "log.dirs=/etc/kafka/logs" >> /etc/kafka/conf/server.properties
echo "port=${port}" >> /etc/kafka/conf/server.properties
echo "advertised.port=${port}" >> /etc/kafka/conf/server.properties
echo "host.name=${hostIp}" >> /etc/kafka/conf/server.properties
#echo "advertised.listeners=PLAINTEXT://${hostIp}:${port}" >> /etc/kafka/conf/server.properties
echo "zookeeper.connect=localhost:2181" >> /etc/kafka/conf/server.properties
#echo "advertised.listeners=PLAINTEXT://localhost:${port}" >> /etc/kafka/conf/server.properties
echo "advertised.host.name=localhost" >> /etc/kafka/conf/server.properties

echo "advertised.listeners=OUTSIDE://localhost:29092,INTERNAL://localhost:${port}" >> /etc/kafka/conf/server.properties
echo "listener.security.protocol.map=INTERNAL:PLAINTEXT,OUTSIDE:PLAINTEXT" >> /etc/kafka/conf/server.properties
echo "listeners=INTERNAL://:29092,OUTSIDE://:${port}" >> /etc/kafka/conf/server.properties
echo "inter.broker.listener.name=INTERNAL" >> /etc/kafka/conf/server.properties

brokerID=${BROKER_ID:-0}
echo "broker id for this node ${brokerID}"
export brokerID=$brokerID
export hostIp=`hostname -I | cut -d' ' -f1`

echo "hostname ${hostname}"

exec /opt/kafka/bin/kafka-server-start.sh /etc/kafka/conf/server.properties