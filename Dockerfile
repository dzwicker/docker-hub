FROM ubuntu:14.04
MAINTAINER daniel.zwicker@in2experience.com

######### Set locale to UTF-8 ###################
RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    locale-gen en_US.UTF-8 && \
    echo LANG=\"en_US.UTF-8\" > /etc/default/locale && \
    echo "Europe/Berlin" > /etc/timezone

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN \
    mkdir -p /var/lib/hub && \
    groupadd --gid 2000 hub && \
    useradd --system -d /var/lib/hub --uid 2000 --gid hub hub && \
    chown -R hub:hub /var/lib/hub

######### upgrade system and install java certs ##
RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y curl zip software-properties-common && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get update && \
    apt-get install -y oracle-java8-installer ca-certificates-java && \
    apt-get -y autoremove && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set environment variables.
# Define commonly used JAVA_HOME variable
ENV JAVA_HOME="/usr/lib/jvm/java-8-oracle"

######### Install hub ###################
COPY entry-point.sh /entry-point.sh

RUN \
    export HUB_VERSION=1.0 && \
    export HUB_BUILD=583 && \
    mkdir -p /usr/local/hub && \
    mkdir -p /var/lib/hub && \
    cd /usr/local/hub && \
    echo "$HUB_VERSION.$HUB_BUILD" > version.docker.image && \
    curl -L https://download.jetbrains.com/hub/${HUB_VERSION}/hub-ring-bundle-${HUB_VERSION}.${HUB_BUILD}.zip \
        > hub-ring-bundle.zip && \
    unzip hub-ring-bundle.zip && \
    rm -f hub-ring-bundle.zip && \
    chown -R hub:hub /usr/local/hub

USER hub
ENV HOME=/var/lib/hub
EXPOSE 8080
ENTRYPOINT ["/entry-point.sh"]
CMD ["run"]
