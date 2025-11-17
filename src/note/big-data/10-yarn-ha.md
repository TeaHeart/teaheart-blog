# yarn-ha

---

## 0.前置条件

[HDFS-HA](08-hdfs-ha.md)

## 1.配置 mapreduce 和 yarn

```bash
cd /opt/module/hadoop-3.3.1/etc/hadoop/
vim mapred-site.xml
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>mapreduce.jobhistory.address</name>
        <value>0.0.0.0:10020</value>
    </property>
    <property>
        <name>mapreduce.jobhistory.webapp.address</name>
        <value>0.0.0.0:19888</value>
    </property>
    <property>
        <name>yarn.app.mapreduce.am.env</name>
        <value>HADOOP_MAPRED_HOME=/opt/module/hadoop-3.3.1</value>
    </property>
    <property>
        <name>mapreduce.map.env</name>
        <value>HADOOP_MAPRED_HOME=/opt/module/hadoop-3.3.1</value>
    </property>
    <property>
        <name>mapreduce.reduce.env</name>
        <value>HADOOP_MAPRED_HOME=/opt/module/hadoop-3.3.1</value>
    </property>
</configuration>
```

```bash
vim yarn-site.xml
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.resourcemanager.recovery.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>yarn.resourcemanager.store.class</name>
        <value>org.apache.hadoop.yarn.server.resourcemanager.recovery.ZKRMStateStore</value>
    </property>
    <property>
        <name>yarn.resourcemanager.zk-address</name>
        <value>hadoop102:2181,hadoop103:2181,hadoop104:2181</value>
    </property>
    <property>
        <name>yarn.resourcemanager.ha.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>yarn.resourcemanager.cluster-id</name>
        <value>yarn-ha</value>
    </property>
    <property>
        <name>yarn.resourcemanager.ha.rm-ids</name>
        <value>rm1,rm2</value>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname.rm1</name>
        <value>hadoop102</value>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname.rm2</name>
        <value>hadoop103</value>
    </property>
    <property>
        <name>yarn.resourcemanager.webapp.address.rm1</name>
        <value>hadoop102:8088</value>
    </property>
    <property>
        <name>yarn.resourcemanager.webapp.address.rm2</name>
        <value>hadoop103:8088</value>
    </property>
</configuration>
```

```bash
xsync.sh mapred-site.xml
xsync.sh yarn-site.xml
```

## 2.启动服务

```bash
touch /opt/module/hadoop-3.3.1/etc/hadoop/excludes # 可选
zkServer.sh start
zkServer.sh status

# 在其中一个 namenode 节点执行
hdfs zkfc -formatZK

# 在所有节点执行
hdfs --daemon start journalnode

# 格式化其中一台namenode并启动
hdfs namenode -format
hdfs --daemon start namenode

# 在另一台同步namenode的元数据信息并启动
hdfs namenode -bootstrapStandby
hdfs --daemon start namenode

# 在两个namenode节点启动zkfc
hdfs --daemon start zkfc

# 所有节点启动datanode
hdfs --daemon start datanode
```

```bash
# hadoop102 和 hadoop103
yarn --daemon start resourcemanager
mapred --daemon start historyserver

# hadoop103
yarn --daemon start nodemanager
```

## 3.验证

```bash
jps

# hadoop102 和 hadoop103
# DataNode
# DFSZKFailoverController
# Jps
# QuorumPeerMain
# NameNode
# ResourceManager
# JobHistoryServer
# JournalNode

# hadoop104
# NodeManager
# Jps
# JournalNode
# DataNode
# QuorumPeerMain
```

- [http://hadoop102:9870/](http://hadoop102:9870/)
- [http://hadoop103:9870/](http://hadoop103:9870/)
- [http://hadoop102:8088/cluster/cluster](http://hadoop102:8088/cluster/cluster)
- [http://hadoop103:8088/cluster/cluster](http://hadoop103:8088/cluster/cluster)

## 4.测试用例

```bash
cd /opt/module/hadoop-3.3.1/
hdfs dfs -put /tmp/story.txt /input # 上传测试文件
hadoop jar ./share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.1.jar wordcount /input /output
# 查看结果
hdfs dfs -ls /output
hdfs dfs -cat /output/part-r-00000
```
