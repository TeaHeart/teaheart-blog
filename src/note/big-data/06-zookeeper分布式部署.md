# zookeeper 分布式部署

---

## 0.前置条件

1. [虚拟机 3 台](02-linux基础.md)
2. [JDK 安装配置](03-java安装配置.md)

|    名称     |         IP         |
|:---------:|:------------------:|
| hadoop102 | 192.168.100.102/24 |
| hadoop103 | 192.168.100.103/24 |
| hadoop104 | 192.168.100.104/24 |

## 1.上传 zookeeper 并解压安装

[zookeeper](https://dlcdn.apache.org/zookeeper/)

```powershell
scp .\apache-zookeeper-3.6.3-bin.tar.gz hadoop@hadoop102:/opt/software
```

```bash
cd /opt
tar -zxvf software/apache-zookeeper-3.6.3-bin.tar.gz -C module/
xsync.sh /opt/module/apache-zookeeper-3.6.3-bin
xsync.sh /opt/module/jdk1.8.0_321
```

## 2.配置环境变量

```bash
sudo vim /etc/profile.d/my_env.sh
```

```bash
# zookeeper-3.6.3
export ZOOKEEPER_HOME=/opt/module/apache-zookeeper-3.6.3-bin
export PATH=$PATH:$ZOOKEEPER_HOME/bin
```

```bash
source /etc/profile
sudo ~/bin/xsync.sh /etc/profild.e/my_env.sh
```

## 3.配置 NTP 服务器

- 相同配置

```bash
sudo vim /etc/chrony.conf
```

```bash
# 注释掉原本的 server0~3 后 添加以下内容
server hadoop102 iburst
```

```bash
sudo ~/bin/xsync.sh /etc/chrony.conf
```

- 不同配置

```bash
# 在hadoop102上再次编辑
sudo vim /etc/chrony.conf
```

```bash
allow 192.168.100.0/24
local stratum 10
```

- 验证

```bash
sudo systemctl restart chronyd
chronyc sources
```

## 4.zookeeper 配置

- 相同配置

```bash
cd /opt/module/apache-zookeeper-3.6.3-bin/conf
cp zoo_sample.cfg zoo.cfg
vim zoo.cfg
```

```bash
dataDir=/opt/module/apache-zookeeper-3.6.3-bin/data

# 末尾添加以下内容
server.1=hadoop102:2888:3888
server.2=hadoop103:2888:3888
server.3=hadoop104:2888:3888
```

```bash
xsync.sh zoo.cfg
```

- 不同配置

|    名称     | myid |
|:---------:|:----:|
| hadoop102 |  1   |
| hadoop103 |  2   |
| hadoop104 |  3   |

```bash
# 这里的目录是刚才配置的dataDir
mkdir /opt/module/apache-zookeeper-3.6.3-bin/data
# 分别为3台虚拟机配置myid
echo 1 > /opt/module/apache-zookeeper-3.6.3-bin/data/myid # hadoop102
echo 2 > /opt/module/apache-zookeeper-3.6.3-bin/data/myid # hadoop103
echo 3 > /opt/module/apache-zookeeper-3.6.3-bin/data/myid # hadoop104
```

## 5.启动并验证

```bash
# 分别为3台虚拟机启动服务
zkServer.sh start
zkServer.sh status
jps
```
