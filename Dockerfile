FROM docker:dind
MAINTAINER GoCD <go-cd-dev@googlegroups.com>

LABEL gocd.version="18.1.0" \
  description="GoCD agent based on alpine version 3.7" \
  maintainer="GoCD <go-cd-dev@googlegroups.com>" \
  gocd.full.version="18.1.0-5937" \
  gocd.git.sha="8a847b96ee8d38173f80178ed1285f0e53a970e0"

ADD https://github.com/krallin/tini/releases/download/v0.16.1/tini-static-amd64 /usr/local/sbin/tini
ADD https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64 /usr/local/sbin/gosu

# force encoding
ENV LANG=en_US.utf8

ARG UID=1000
ARG GID=1000

RUN \
  # add mode and permissions for files we added above
  chmod 0755 /usr/local/sbin/tini && \
  chown root:root /usr/local/sbin/tini && \
  chmod 0755 /usr/local/sbin/gosu && \
  chown root:root /usr/local/sbin/gosu && \
  # add our user and group first to make sure their IDs get assigned consistently,
  # regardless of whatever dependencies get added
  addgroup -g ${GID} go && \
  adduser -D -u ${UID} -s /bin/bash -G go go && \
  addgroup go root && \
  apk --no-cache --wait 30 upgrade && \
  apk add --wait 30 --no-cache openjdk8-jre-base git mercurial subversion openssh-client bash curl && \
  # download the zip file
  curl --fail --location --silent --show-error "https://download.gocd.org/binaries/18.1.0-5937/generic/go-agent-18.1.0-5937.zip" > /tmp/go-agent.zip && \
  # unzip the zip file into /go-agent, after stripping the first path prefix
  unzip /tmp/go-agent.zip -d / && \
  mv go-agent-18.1.0 /go-agent && \
  rm /tmp/go-agent.zip && \
  mkdir -p /docker-entrypoint.d

# ensure that logs are printed to console output
COPY agent-bootstrapper-logback-include.xml /go-agent/config/agent-bootstrapper-logback-include.xml
COPY agent-launcher-logback-include.xml /go-agent/config/agent-launcher-logback-include.xml
COPY agent-logback-include.xml /go-agent/config/agent-logback-include.xml

ADD docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
