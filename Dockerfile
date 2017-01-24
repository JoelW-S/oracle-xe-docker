#
# Oracle Express Dockerfile
# Using provided Oracle Express installer
#

FROM centos:7

MAINTAINER Joel Whittaker-Smith <joel.whittaker-smith@atos.net>

ENV ORACLE_EXPRESS_VERSION=11.2.0-1.0.x86_64

WORKDIR /tmp

COPY oracle-xe-${ORACLE_EXPRESS_VERSION}.rpm .

COPY entryPoint.sh /

RUN \
    mkdir -p /run/lock/subsys

# Copy supplied official packages to image

RUN \
    echo proxy=http://192.168.122.1:3128 >> /etc/yum.conf && \
    yum install -y libaio bc initscripts net-tools flex; \
    yum clean all

# Install oracle express in the image
RUN \
    yum localinstall -y \
    oracle-xe-${ORACLE_EXPRESS_VERSION}.rpm

# Add oracle files to required directory
ADD \
    xe.rsp \
    init.ora \
    initXETemp.ora /u01/app/oracle/product/11.2.0/xe/config/scripts/

# Set correct ownership of files
RUN chown oracle:dba /u01/app/oracle/product/11.2.0/xe/config/scripts/*.ora \
                         /u01/app/oracle/product/11.2.0/xe/config/scripts/xe.rsp

# Set correct permissions
RUN chmod 755            /u01/app/oracle/product/11.2.0/xe/config/scripts/*.ora \
                         /u01/app/oracle/product/11.2.0/xe/config/scripts/xe.rsp

ENV ORACLE_HOME /u01/app/oracle/product/11.2.0/xe
ENV ORACLE_SID XE
ENV PATH       $ORACLE_HOME/bin:$PATH

RUN /etc/init.d/oracle-xe configure responseFile=/u01/app/oracle/product/11.2.0/xe/config/scripts/xe.rsp

RUN \
    chmod +x /entryPoint.sh

# Delete the Oracle XE RPM
RUN \
    rm -Rf /tmp/*

# Expose ports 1521 and 8080
EXPOSE 1521 8080

ENTRYPOINT ["/entryPoint.sh"]
