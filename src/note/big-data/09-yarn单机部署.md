# yarn 单机部署

---

## 0.前置条件

[HDFS 伪分布式部署](04-hdfs伪分布式部署.md)

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
</configuration>
```

## 2.启动服务

```bash
hdfs --daemon start namenode
hdfs --daemon start datanode

yarn --daemon start resourcemanager
yarn --daemon start nodemanager
mapred --daemon start historyserver
```

## 3.验证

```bash
jps
# ResourceManager
# NodeManager
# JobHistoryServer
# DataNode
# NameNode
# Jps
```

- [http://hadoop102:9870/](http://hadoop102:9870/)
- [http://hadoop102:8088/](http://hadoop102:8088/)

## 4.计算测试用例

```bash
cd /opt/module/hadoop-3.3.1/
# 1. PI 测试
hadoop jar ./share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.1.jar pi 10 10
# 2. wordcount 测试
hdfs dfs -put LICENSE.txt /input # 上传测试文件
hadoop jar ./share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.1.jar wordcount /input /output
# 查看结果
hdfs dfs -ls /output
hdfs dfs -cat /output/part-r-00000
```
