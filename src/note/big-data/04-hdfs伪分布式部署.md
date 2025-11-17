# hdfs 伪分布式部署

---

## 0.前置条件

[JDK 安装](03-java安装配置.md)

## 1.上传 hadoop 并解压安装

[hadoop](https://archive.apache.org/dist/hadoop/common/)

```powershell
scp .\hadoop-3.3.1.tar.gz hadoop@hadoop102:/opt/software
```

```bash
cd /opt
tar -zxvf software/hadoop-3.3.1.tar.gz -C module/
```

## 2.配置 hadoop 环境变量

```bash
sudo vim /etc/profile.d/my_env.sh
```

```bash
# hadoop-3.3.1
export HADOOP_HOME=/opt/module/hadoop-3.3.1
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:
```

```bash
source /etc/profile
hadoop version
```

## 3.hadoop 配置

```bash
cd /opt/module/hadoop-3.3.1/etc/hadoop/
vim core-site.xml
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://hadoop102:9820</value>
    </property>
    <property>
        <name>hadoop.tmp.dir</name>
        <value>/opt/module/hadoop-3.3.1/data/tmp</value>
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
        <value>1</value>
    </property>
    <property>
        <name>dfs.namenode.name.dir</name>
        <value>/opt/module/hadoop-3.3.1/data/namenode</value>
    </property>
    <property>
        <name>dfs.datanode.data.dir</name>
        <value>/opt/module/hadoop-3.3.1/data/datanode</value>
    </property>
</configuration>
```

## 4.格式化

```bash
hdfs namenode -format # 格式化
```

## 5.启动服务

```bash
hdfs --daemon start namenode
hdfs --daemon start datanode
```

## 6.验证

```bash
jps
```

[http://hadoop102:9870](http://hadoop102:9870)
