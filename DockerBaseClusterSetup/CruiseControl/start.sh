#!/bin/bash


echo " Entering start.sh"

pwd
#cd /opt/cruise-control
ls -lta

ls -lta /cruise-control/

#cat /cruise-control/config/cruisecontrol.properties


#/cruise-control/kafka-cruise-control-start.sh  /cruise-control/config/cruisecontrol.properties
#exec ./kafka-cruise-control-start.sh config/cruisecontrol.properties 8090
#/bin/bash ${DEBUG:+-x} /cruise-control/kafka-cruise-control-start.sh /cruise-control/config/cruisecontrol.properties 8090

exec java -Djava.security.auth.login.config=/cruise-control/config/cruise_control_jaas.conf -Dkafka.logs.dir=logs -Dlog4j.configuration=file:/cruise-control/config/log4j.properties -cp :/cruise-control/* com.linkedin.kafka.cruisecontrol.KafkaCruiseControlMain /cruise-control/config/cruisecontrol.properties 9090
