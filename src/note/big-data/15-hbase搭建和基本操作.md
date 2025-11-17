# hbase 搭建和基本操作

---

# 0.前置条件

[HDFS 伪分布式部署](04-hdfs伪分布式部署.md)

# 1.上传 hbase 安装并配置环境变量

[hbase](https://archive.apache.org/dist/hbase/)

```powershell
scp .\hbase-2.4.4-bin.tar.gz hadoop@hadoop102:/opt/software
```

```bash
cd /opt
tar -zxvf software/hbase-2.4.4-bin.tar.gz -C module/
sudo vim /etc/profile.d/my_env.sh
```

```bash
# hbase-2.4.4
export HBASE_HOME=/opt/module/hbase-2.4.4
export PATH=$PATH:$HBASE_HOME/bin
```

```bash
source /etc/profile
hbase version

cd /opt/module/hbase-2.4.4/lib/client-facing-thirdparty
mv ./slf4j-log4j12-1.7.30.jar ./slf4j-log4j12-1.7.30.jar.bak
```

# 2.配置

```bash
cd /opt/module/hbase-2.4.4/conf/
vim hbase-site.xml
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>hbase.rootdir</name>
        <value>hdfs://hadoop102:9000/hbase</value>
    </property>
    <property>
        <name>hbase.wal.provider</name>
        <value>filesystem</value>
    </property>
    <property>
        <name>hbase.zookeeper.property.datadir</name>
        <value>/opt/module/hbase-2.4.4/data/zookeeper</value>
    </property>
    <!--文件中已有的配置-->
    <property>
        <name>hbase.cluster.distributed</name>
        <value>true</value>
    </property>
    <property>
        <name>hbase.unsafe.stream.capability.enforce</name>
        <value>false</value>
    </property>
    <property>
        <name>hbase.tmp.dir</name>
        <value>./tmp</value>
    </property>
</configuration>
```

## 3.启动服务

```bash
start-all.sh

start-hbase.sh
```

## 4.验证

```bash
jps
```

[http://hadoop102:16010/](http://hadoop102:16010/)

## 5.hbase shell 基本操作

```bash
version
status
whoami
list
create 'log','f1'
exists 'log'
desc 'log'

disable 'log'
alter 'log',{NAME=>'f1',TTL=>'2592000'}
enable 'log'

put 'log','rowkey001','f1:col1','value1'
put 'log','rowkey001','f1:col2','value2'
put 'log','rowkey002','f1:col1','value1'

get 'log','rowkey001', 'f1:col1'
get 'log','rowkey001', {COLUMN=>'f1:col1'}

scan 'log'
scan 'log',{LIMIT=>1}

count 'log', {INTERVAL => 10, CACHE => 200}

delete 'log','rowkey001','f1:col2'
deleteall 'log','rowkey002'
truncate 'log'
```
