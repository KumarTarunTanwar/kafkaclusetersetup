FROM ubuntu:latest

RUN apt-get update \
    && apt-get install -y curl wget runit default-jre-headless psmisc dnsutils iproute2 netcat vim\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV KAFKA_VERSION=2.7.0 \
    SCALA_VERSION=2.13

RUN wget -q https://archive.apache.org/dist/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz && tar -xzf kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz -C /opt
RUN mv /opt/kafka_$SCALA_VERSION-$KAFKA_VERSION /opt/kafka

COPY /entrypoint.sh /
RUN chmod -R 777 /entrypoint.sh

EXPOSE 9092 29092

ENTRYPOINT ["/entrypoint.sh"]
