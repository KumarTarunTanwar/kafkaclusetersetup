FROM ubuntu:latest

RUN apt-get update \
    && apt-get install -y curl wget runit default-jre-headless psmisc dnsutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://archive.apache.org/dist/zookeeper/zookeeper-3.4.7/zookeeper-3.4.7.tar.gz && tar -xzf zookeeper-3.4.7.tar.gz -C /opt
RUN mv /opt/zookeeper-3.4.7 /opt/zookeeper && cp /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg

COPY /entrypoint.sh /
RUN chmod -R 777 /entrypoint.sh

VOLUME ["/data/zookeeper/data","/data/zookeeper/log"]

EXPOSE 2181 2888 3888

ENTRYPOINT ["/entrypoint.sh"]