# zookeeper 基本操作

---

## 0.前置条件

[zookeeper 分布式部署](06-zookeeper分布式部署.md)

## 1.启动服务并用客户端连接

```bash
zkServer.sh start
zkServer.sh status
zkCli.sh
```

## 2.基本操作

```bash
ls /
create /test # 创建节点
create /test/children test # 创建节点并并赋值
create -e /test/tmp aaa # 创建临时节点
set /test/children 200ok #修改节点值
stat /test/tmp # 查看节点状态
deltet
delete /test/tmp # 删除节点
```

## 3.管理操作

```bash
vim /opt/module/apache-zookeeper-3.7.0-bin/conf/zoo.cfg
```

```bash
# 添加一行
4lw.commands.whitelist=*
```

```bash
zkServer.sh restart
echo conf | nc hadoop102 2181 | head
echo srvr | nc hadoop102 2181 | head
echo mntr | nc hadoop102 2181 | head
echo rouk | nc hadoop102 2181 | head
```

## 4.扩容和缩容

- 扩容
  1. 克隆 hadoop100 为新的 hadoop105
  2. [修改 IP 地址](<01-linux平台搭建.md#5.配置 Linux 静态 IP(可选)>)
  3. [修改主机名](<01-linux平台搭建.md#6.修改主机名称(可选)>)
  4. [修改 hosts](<01-linux平台搭建.md#7.修改 hosts 文件(可选)>) , 给所有虚拟机添加一行 `192.168.100.105 hadoop105`
  5. [安装 zookeeper](06-zookeeper分布式部署.md)
  6. 给所有虚拟机的 zoo.cfg 添加一行`server.4=hadoop105:2888:3888`
  7. 重启所有虚拟机的 zkServer
- 缩容
  1. 关闭要下线的虚拟机的 zkServer 服务
  2. 删除剩余虚拟机 zoo.cfg 对应的配置
  3. 重启所有虚拟机的 zkServer
