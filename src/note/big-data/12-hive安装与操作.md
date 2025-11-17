# hive 安装与操作

---

## 0.前置条件

[yarn 单机部署](09-yarn单机部署.md)

## 1.上传 Hive 安装并配置环境变量

[hive](https://dlcdn.apache.org/hive/)

```powershell
scp .\apache-hive-3.1.2-bin.tar.gz hadoop@hadoop102:/opt/software
```

```bash
tar -zxvf software/apache-hive-3.1.2-bin.tar.gz -C module/
sudo vim /etc/profile.d/my_env.sh
```

```bash
# apache-hive-3.1.2-bin
export HIVE_HOME=/opt/module/apache-hive-3.1.2-bin
export PATH=$PATH:$HIVE_HOME/bin
```

```bash
source /etc/profile
hive --help
```

## 2.安装 mysql 并配置(mariadb)

```bash
cd /etc/yum.repos.d/
sudo mkdir bak
sudo mv *.repo bak/
```

```bash
[base]
name=local
baseurl=file:///run/media/hadoop/cdrom/
enabled=1
gpgcheck=0
```

```bash
yum clean all
sudo yum install -y mariadb*
sudo systemctl enable mariadb
sudo systemctl start mariadb
mysqladmin -uroot password 123456
mysql -uroot -p123456
```

```bash
set names utf8;
grant all on *.* to hive@'localhost' identified by '123456';
```

## 3.准备驱动

```bash
select version();
exit;
cd ~
wget http://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/Connector-J/mysql-connector-java-5.1.49.tar.gz
tar -zxvf mysql-connector-java-5.1.49.tar.gz
cp ./mysql-connector-java-5.1.49/mysql-connector-java-5.1.49-bin.jar /opt/module/apache-hive-3.1.2-bin/lib/
```

## 4.配置 hive

```bash
cd /opt/module/apache-hive-3.1.2-bin/conf/
vim hive-site.xml
```

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive/warehouse</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:mysql://localhost:3306/hive?createDatabaseIfNotExist=true</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>com.mysql.jdbc.Driver</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>hive</value>
    </property>
    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>123456</value>
    </property>
</configuration>
```

```bash
schematool -dbType mysql -initSchema
```

## 5.开启服务

```bash
hdfs --daemon start namenode
hdfs --daemon start datanode

yarn --daemon start resourcemanager
yarn --daemon start nodemanager
mapred --daemon start historyserver

hive --service metastore &
hive
```

## 6.验证

```bash
vim ~/test.txt
```

```bash
2,li4,19
3,wang5,20
```

```bash
hive
show databases;
create database myhive;
use myhive;
create table  student(id int, name string, age int) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',';
desc student;
insert into student values (1,'zhang3',18);
select * from student;
exit;
```

```bash
hive
use myhive;
load data local inpath '/home/hadoop/test.txt' into table student;
select * from student;
```
