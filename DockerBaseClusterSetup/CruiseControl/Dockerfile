# Multi-stage build requires Docker 17.05 or higher
# --------------- Builder stage ---------------
FROM centos:7 AS builder

ENV CCVERSION=2.5.30
ENV JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk

RUN yum -y install git java-1.8.0-openjdk-devel

#RUN git clone --branch ${CC_VERSION} https://github.com/linkedin/cruise-control.git
RUN mkdir -p /opt/cruise-control

RUN chmod -R 777 /opt

WORKDIR cruise-control

# Install Cruise Control GUI Frontend
RUN curl -L https://github.com/linkedin/cruise-control/archive/refs/tags/${CCVERSION}.tar.gz -o /tmp/cruise-control-${CCVERSION}.tar.gz
RUN tar zxvf /tmp/cruise-control-${CCVERSION}.tar.gz -C /opt
RUN mv /opt/cruise-control-${CCVERSION}/* /cruise-control/
#RUN rm -rf cruise-control-core cruise-control-metrics-reporter cruise-control-client


# Compile and remove leftover directories
#RUN ./gradlew jar :cruise-control:jar  \
#    && rm -rf cruise-control-core cruise-control-metrics-reporter cruise-control-client

# Configure Cruise Control to point to the proper Kafka and Zookeeper endpoints
RUN sed -i 's/bootstrap.servers=.*/bootstrap.servers=localhost:9092/g' config/cruisecontrol.properties \
    && sed -i 's/zookeeper.connect=.*/zookeeper.connect=localhost:2181/g' config/cruisecontrol.properties \
    && sed -i 's/capacity.config.file=.*/capacity.config.file=config\/capacityJBOD.json/g' config/cruisecontrol.properties \
    && sed -i 's/sample.store.topic.replication.factor=.*/sample.store.topic.replication.factor=1/g' config/cruisecontrol.properties

# Install Cruise Control GUI Frontend
RUN curl -L https://github.com/linkedin/cruise-control-ui/releases/download/v0.1.0/cruise-control-ui.tar.gz \
    -o /tmp/cruise-control-ui.tar.gz \
    && tar zxvf /tmp/cruise-control-ui.tar.gz

# --------------- Final stage ---------------
FROM centos:7

RUN yum -y install java-1.8.0-openjdk && \
    yum clean all -y

WORKDIR cruise-control
COPY --from=builder cruise-control .

COPY /start.sh /
RUN chmod -R 777 /start.sh

EXPOSE 8090

# Ensure Cruise Control writable for logs
RUN chmod a+rw -R .

#ENTRYPOINT ["/bin/bash", "-c", "/cruise-control/kafka-cruise-control-start.sh /cruise-control/config/cruisecontrol.properties"]


ENTRYPOINT ["/start.sh"]