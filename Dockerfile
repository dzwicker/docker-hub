FROM dzwicker/docker-ubuntu:latest
MAINTAINER email@daniel-zwicker.de

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN \
    mkdir -p /var/lib/hub && \
    groupadd --gid 2000 hub && \
    useradd --system -d /var/lib/hub --uid 2000 --gid hub hub && \
    chown -R hub:hub /var/lib/hub

######### Install hub ###################
COPY entry-point.sh /entry-point.sh

RUN \
    export HUB_VERSION=2.5 && \
    export HUB_BUILD=399 && \
    mkdir -p /var/lib/hub && \
    cd /usr/local && \
    curl -L https://download.jetbrains.com/hub/${HUB_VERSION}/hub-ring-bundle-${HUB_VERSION}.${HUB_BUILD}.zip \
        > hub-ring-bundle.zip && \
    unzip hub-ring-bundle.zip && \
    rm -f hub-ring-bundle.zip && \
    mv /usr/local/hub-ring-bundle-${HUB_VERSION}.${HUB_BUILD} /usr/local/hub && \
    echo "$HUB_VERSION.$HUB_BUILD" > /usr/local/hub/version.docker.image && \
    chown -R hub:hub /usr/local/hub

USER hub
ENV HOME=/var/lib/hub
EXPOSE 8080
ENTRYPOINT ["/entry-point.sh"]
CMD ["run"]
