# sqoop 搭建与基本操作

---

## 0.前置条件

[Hive 安装与操作](12-hive安装与操作.md)

## 1.上传 sqoop 安装并配置环境变量

[sqoop](http://archive.apache.org/dist/sqoop/)

```powershell
scp .\sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz hadoop@hadoop102:/opt/software
```

```bash
tar -zxvf software/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz -C module/
sudo vim /etc/profile.d/my_env.sh
```

```bash
# sqoop-1.4.7.bin__hadoop-2.6.0
export SQOOP_HOME=/opt/module/sqoop-1.4.7.bin__hadoop-2.6.0
export PATH=$PATH:$SQOOP_HOME/bin
```

```bash
source /etc/profile
```

## 2.配置

```bash
cd /opt/module/sqoop-1.4.7.bin__hadoop-2.6.0/conf/
cp sqoop-env-template.sh sqoop-env.sh
cp sqoop-site-template.xml sqoop-site.xml
vim sqoop-env.sh
```

```bash
export HADOOP_COMMON_HOME=/opt/module/hadoop-3.3.1
export HADOOP_MAPRED_HOME=/opt/module/hadoop-3.3.1
export HIVE_HOME=/opt/module/apache-hive-3.1.2-bin
```

```bash
cd /opt/module/sqoop-1.4.7.bin__hadoop-2.6.0/
cp /opt/module/apache-hive-3.1.2-bin/lib/mysql-connector-java-5.1.49-bin.jar .
cp /opt/module/apache-hive-3.1.2-bin/lib/commons-lang-2.6.jar .
cp /opt/module/apache-hive-3.1.2-bin/lib/hive-common-3.1.2.jar .
cp /opt/module/apache-hive-3.1.2-bin/lib/hive-shims* .
```

## 3.验证

```bash
sqoop help
sqoop list-databases --connect jdbc:mysql://localhost:3306/ --username hive --password 123456
```

## 4.启动服务

```bash
hdfs --daemon start namenode
hdfs --daemon start datanode
yarn --daemon start resourcemanager
yarn --daemon start nodemanager
mapred --daemon start historyserver
hive --service metastore &
hive
```

## 5.导出数据

```bash
mysql -uroot -p123456
create database if not exists sqoop charset=utf8;
use sqoop
create table if not exists buyer_log(id varchar(10),buyer_id varchar(10),dt varchar(32),ip varchar(32),opt_type varchar(10));
exit;

sqoop export --connect jdbc:mysql://localhost:3306/sqoop --username hive --password 123456 --table buyer_log --num-mappers 1 --export-dir /user/hive/warehouse/buyer_log --input-fields-terminated-by '\t'

mysql -uroot -p123456
use sqoop;
select * from buyer_log;
```

## 6.导入数据

```bash
hive
drop table buyer_log;
exit;

sqoop import --connect jdbc:mysql://localhost:3306/sqoop --username hive --password 123456 --table buyer_log --num-mappers 1 --hive-import --create-hive-table --hive-table buyer_log

hive
select * from buyer_log;
```
