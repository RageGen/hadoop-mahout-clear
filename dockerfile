FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV HADOOP_VERSION=3.3.6
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV MAHOUT_LOCAL="True"
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

ENV HDFS_NAMENODE_USER=hadoop
ENV HDFS_DATANODE_USER=hadoop
ENV YARN_RESOURCEMANAGER_USER=hadoop
ENV YARN_NODEMANAGER_USER=hadoop

RUN apt-get update && \
    apt-get install -y curl openjdk-8-jdk wget python3 python3-pip ssh tzdata nano maven

RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzvf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} /usr/local/hadoop && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

RUN groupadd -r hadoop && \
    useradd -r -g hadoop -s /bin/bash hadoop && \
    chown -R hadoop:hadoop $HADOOP_HOME && \
    chmod -R 755 $HADOOP_HOME

COPY core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml

RUN echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh

RUN mkdir -p /home/hadoop/.ssh && \
    ssh-keygen -t rsa -P "" -f /home/hadoop/.ssh/id_rsa && \
    cat /home/hadoop/.ssh/id_rsa.pub >> /home/hadoop/.ssh/authorized_keys && \
    chmod 0600 /home/hadoop/.ssh/authorized_keys && \
    chown -R hadoop:hadoop /home/hadoop/.ssh

RUN mkdir -p /usr/local/hadoop/dfs/data && \
    chown -R hadoop:hadoop /usr/local/hadoop/dfs

RUN pip3 install hdfs

RUN echo "export PATH=\$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin" >> /home/hadoop/.bashrc && \
    echo "export JAVA_HOME=$JAVA_HOME" >> /home/hadoop/.bashrc
ENV MAHOUT_VERSION=0.5
RUN wget https://archive.apache.org/dist/mahout/${MAHOUT_VERSION}/mahout-distribution-${MAHOUT_VERSION}.tar.gz && \
    tar -xzvf mahout-distribution-${MAHOUT_VERSION}.tar.gz && \
    mv mahout-distribution-${MAHOUT_VERSION} /usr/local/mahout && \
    rm mahout-distribution-${MAHOUT_VERSION}.tar.gz

ENV PATH=$PATH:/usr/local/mahout/bin

EXPOSE 9870 9000 50070 9864 9866 8080 7077 4040 8020

CMD service ssh start && \
    $HADOOP_HOME/bin/hdfs namenode -format -force && \
    $HADOOP_HOME/bin/hdfs namenode & \
    sleep 5 && \
    $HADOOP_HOME/bin/hdfs datanode & \
    sleep 5 && \
    start-yarn.sh && \
    tail -f $HADOOP_HOME/logs/*.log

