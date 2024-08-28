FROM armdocker.rnd.ericsson.se/proj-orchestration-so/eric-oss-pf-base-image:2.21.0
ARG POLICY_LOGS=/var/log/onap/policy/apex-pdp
ENV POLICY_HOME=/opt/app/policy/apex-pdp
ENV POLICY_LOGS=$POLICY_LOGS

RUN zypper in -l -y shadow iproute2 iputils wget
RUN zypper in -l -y zip

# Create apex user and group
RUN groupadd apexuser && useradd -m apexuser -G apexuser

# Add Apex-specific directories and set ownership as the Apex admin user
RUN mkdir -p $POLICY_HOME \
    && mkdir -p $POLICY_LOGS \
    && chown -R apexuser:apexuser $POLICY_LOGS

# Unpack the tarball
RUN wget --no-check-certificate https://arm.epk.ericsson.se/artifactory/list/proj-policy-framework-generic-local/com/ericsson/apex/apex-pdp-package-full-2.2.3-SNAPSHOT-TMP-ELALTO.tar.gz \
    && tar -zxvf apex-pdp-package-full-2.2.3-SNAPSHOT-TMP-ELALTO.tar.gz --directory $POLICY_HOME \
    && rm apex-pdp-package-full-2.2.3-SNAPSHOT-TMP-ELALTO.tar.gz

# Added to fix SM-111272 & SM-114368
RUN zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/net/JMSAppender.class && \
    zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/net/SocketServer.class && \
    zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/net/JMSSink.class && \
    zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/jdbc/JDBCAppender.class && \
    zip -d $POLICY_HOME/lib/log4j-1.2.17.jar org/apache/log4j/chainsaw/*


COPY logback.xml $POLICY_HOME/etc
	
# Ensure everything has the correct permissions
RUN find /opt/app -type d -perm 755 \
    && find /opt/app -type f -perm 644 \
    && chmod 755 $POLICY_HOME/bin/*

# Copy examples to Apex user area
RUN cp -pr $POLICY_HOME/examples /home/apexuser \
    && chown -R apexuser:apexuser /home/apexuser/*

USER apexuser
ENV PATH $POLICY_HOME/bin:$PATH
WORKDIR /home/apexuser
