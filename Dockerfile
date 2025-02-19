#docker pull openjdk:8u292-jdk-slim azul/zulu-openjdk-alpine:8u292-8.54.0.21
FROM openjdk:8u292-jdk

ARG kafka_version=2.7.0
ARG scala_version=2.13
ARG glibc_version=2.31-r0
ARG vcs_ref=unspecified
ARG build_date=unspecified

LABEL org.label-schema.name="kafka" \
      org.label-schema.description="Apache Kafka" \
      org.label-schema.build-date="${build_date}" \
      org.label-schema.vcs-url="https://github.com/wurstmeister/kafka-docker" \
      org.label-schema.vcs-ref="${vcs_ref}" \
      org.label-schema.version="${scala_version}_${kafka_version}" \
      org.label-schema.schema-version="1.0" \
      maintainer="wurstmeister"

ENV KAFKA_VERSION=$kafka_version \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka \
    GLIBC_VERSION=$glibc_version

ENV PATH=${PATH}:${KAFKA_HOME}/bin

COPY download-kafka.sh start-kafka.sh broker-list.sh create-topics.sh versions.sh /tmp/

# RUN apt upgrade -y \
#  &&apt-get update -y \
#  &&apt-get install jq -y

# RUN apt upgrade -y \
#  &&apt-get update -y \
#  &&apt-get install jq -y \
#  && chmod a+x /tmp/*.sh \
#  && mv /tmp/start-kafka.sh /usr/bin && mv /tmp/broker-list.sh /usr/bin && mv /tmp/create-topics.sh /usr/bin && mv  /tmp/versions.sh /usr/bin

RUN apt upgrade -y \
 &&apt-get update -y \
 &&apt-get install apt-utils -y\
 &&apt-get install bash -y\
 &&apt-get install curl -y\
 &&apt-get install docker -y\
 &&apt-get install sudo -y\
 &&apt-get install jq -y \
 && chmod a+x /tmp/*.sh \
 && mv /tmp/start-kafka.sh /usr/bin && mv /tmp/broker-list.sh /usr/bin && mv /tmp/create-topics.sh /usr/bin && mv  /tmp/versions.sh /usr/bin \
 &&ls -a /tmp&& sync && /tmp/download-kafka.sh\
 && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
 && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
 && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} \
 && rm -rf /tmp/*
# RUN apt upgrade -y \
#  &&apt-get update -y \
#  &&apt-get install jq -y \
#  && chmod a+x /tmp/*.sh \
#  && mv /tmp/start-kafka.sh /tmp/broker-list.sh /tmp/create-topics.sh /tmp/versions.sh /usr/bin \
#  && sync && /tmp/download-kafka.sh \
#  && tar xfz /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz -C /opt \
#  && rm /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz \
#  && ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME} \
#  && rm /tmp/* \

COPY overrides /opt/overrides

VOLUME ["/kafka"]

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["start-kafka.sh"]
