FROM ubuntu:14.04

MAINTAINER Couchbase Docker Team <docker@couchbase.com>

# Install dependencies
RUN echo "APT::Install-Recommends 0;" >> /etc/apt/apt.conf.d/01norecommends \
    && echo "APT::Install-Suggests 0;" >> /etc/apt/apt.conf.d/01norecommends \
    && apt-get update \
    apt-get install -yq runit wget python-httplib2  && \
    apt-get autoremove && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV CB_VERSION=4.0.0-rc0 \
    CB_RELEASE_URL=http://packages.couchbase.com/releases \
    CB_PACKAGE=couchbase-server-enterprise_4.0.0-rc0-ubuntu14.04_amd64.deb \
    PATH=$PATH:/opt/couchbase/bin:/opt/couchbase/bin/tools:/opt/couchbase/bin/install \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/couchbase/lib

# Install couchbase
RUN wget -N $CB_RELEASE_URL/$CB_VERSION/$CB_PACKAGE && \
    dpkg -i ./$CB_PACKAGE && rm -f ./$CB_PACKAGE

# Add runit script for couchbase-server
COPY scripts/run /etc/service/couchbase-server/run
RUN chmod 755 /etc/service/couchbase-server/run

# Add bootstrap script
COPY scripts/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["couchbase-server"]

EXPOSE 8091 8092 11207 11210 11211 18091 18092
VOLUME /opt/couchbase/var
