# hdfs-ha

---

## 0.前置条件

1. [hadoop 解压安装](04-hdfs伪分布式部署.md#1.上传 hadoop 并解压安装)
2. [hadoop 环境变量配置](04-hdfs伪分布式部署.md#2.配置 hadoop 环境变量)
3. [zookeeper 分布式部署](06-zookeeper分布式部署.md)

## 1.配置 hadoop

|    名称     |    类型    |
|:---------:|:--------:|
| hadoop102 | namenode |
| hadoop103 | namenode |
| hadoop104 | datanode |

```bash
cd /opt/module/hadoop-3.3.1/etc/hadoop
vim core-site.xml
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>hadoop.security.authorization</name>
        <value>false</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/opt/module/hadoop-3.3.1/data/tmp</value>
    </property>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://hadoop102:9820</value>
    </property>
    <property>
        <name>ha.zookeeper.quorum</name>
        <value>hadoop102:2181,hadoop103:2181,hadoop104:2181</value>
    </property>
    <property>
        <name>ha.zookeeper.session-timeout.ms</name>
        <value>10000</value>
    </property>
    <property>
        <name>net.topology.node.switch.mapping.impl</name>
        <value>org.apache.hadoop.net.TableMapping</value>
    </property>
    <property>
        <name>net.topology.table.file.name</name>
        <value>/opt/module/hadoop-3.3.1/etc/hadoop/topology.data</value>
    </property>
</configuration>
```

```bash
vim hdfs-site.xml
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>2</value>
    </property>
    <property>
        <name>dfs.nameservices</name>
        <value>cluster</value>
    </property>
    <property>
        <name>dfs.ha.namenodes.cluster</name>
        <value>nn1,nn2</value>
    </property>
    <property>
        <name>dfs.namenode.rpc-address.cluster.nn1</name>
        <value>hadoop102:9820</value>
    </property>
    <property>
        <name>dfs.namenode.http-address.cluster.nn1</name>
        <value>hadoop102:9870</value>
    </property>
    <property>
        <name>dfs.namenode.rpc-address.cluster.nn2</name>
        <value>hadoop103:9820</value>
    </property>
    <property>
        <name>dfs.namenode.http-address.cluster.nn2</name>
        <value>hadoop103:9870</value>
    </property>
    <property>
        <name>dfs.ha.automatic-failover.enabled.cluster</name>
        <value>true</value>
    </property>
    <property>
        <name>dfs.namenode.shared.edits.dir</name>
        <value>qjournal://hadoop102:8485;hadoop103:8485;hadoop104:8485/cluster</value>
    </property>
    <property>
        <name>dfs.journalnode.edits.dir</name>
        <value>/opt/module/hadoop-3.3.1/data/tmp/journal</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>/opt/module/hadoop-3.3.1/data/namenode</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/opt/module/hadoop-3.3.1/data/datanode</value>
    </property>
    <property>
        <name>dfs.ha.fencing.methods</name>
        <value>sshfence</value>
    </property>
    <property>
        <name>dfs.ha.fencing.ssh.private-key-files</name>
        <value>/home/hadoop/.ssh/id_rsa</value>
    </property>
    <property>
        <name>dfs.ha.fencing.ssh.connect-timeout</name>
        <value>30000</value>
    </property>
    <property>
        <name>dfs.ha.fencing.methods</name>
        <value>sshfence(:22)</value>
    </property>
    <property>
        <name>dfs.client.failover.proxy.provider.cluster</name>
        <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
    </property>
    <property>
        <name>dfs.webhdfs.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>dfs.hosts.exclude</name>
        <value>/opt/module/hadoop-3.3.1/etc/hadoop/excludes</value>
    </property>
    <property>
        <name>fs.trash.interval</name>
        <value>1440</value>
    </property>
    <property>
        <name>fs.trash.checkpoint.interval</name>
        <value>0</value>
    </property>
    <property>
        <name>heartbeat.recheck.interval</name>
        <value>2000</value>
    </property>
    <property>
        <name>dfs.heartbeat.interval</name>
        <value>1</value>
    </property>
    <property>
        <name>dfs.datanode.failed.volumes.tolerated</name>
        <value>0</value>
    </property>
</configuration>
```

```bash
xsync.sh core-site.xml
xsync.sh hdfs-site.xml
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

## 3.验证

```bash
jps
# QuorumPeerMain
# NameNode
# DFSZKFailoverController
# Jps
# JournalNode
# DataNode
```

- [http://hadoop102:9870](http://hadoop102:9870)
- [http://hadoop103:9870](http://hadoop103:9870)
