# linux 平台搭建

---

## 0.虚拟机及 IP 规划

- 虚拟网卡 VMNet8 网段 192.168.100.0/24

|    名称     |         IP         |  描述   |
|:---------:|:------------------:|:-----:|
|  windows  |  192.168.100.1/24  |  物理机  |
|  gateway  |  192.168.100.2/24  | 虚拟网关  |
| hadoop100 | 192.168.100.100/24 | 模板虚拟机 |
| hadoop102 | 192.168.100.102/24 |       |
| hadoop103 | 192.168.100.103/24 |       |
| hadoop104 | 192.168.100.104/24 |       |

## 1.安装 Linux 虚拟机

[CentOS7](https://mirrors.tuna.tsinghua.edu.cn/centos/7/isos/x86_64/)

## 2.配置虚拟网关(可选)

略

## 3.配置 Windows 虚拟网卡(可选)

略

## 4.添加 hadoop 用户并设置 sudo(可选)

```bash
useradd hadoop
passwd hadoop
vim /etc/sudoers
```

```bash
# 在 %wheel  ALL=(ALL)       ALL 下面
hadoop  ALL=(ALL)       NOPASSWD: ALL
```

## 5.配置 Linux 静态 IP(可选)

```bash
sudo vim /etc/sysconfig/network-scripts/ifcfg-ens33
```

```bash
# 删除UUID
IPADDR="192.168.100.100"
GATEWAY="192.168.100.2"
DNS1="192.168.100.2"
```

## 6.修改主机名称(可选)

```bash
sudo vim /etc/hostname
```

```bash
hadoop102
```

## 7.修改 hosts 文件(可选)

```bash
sudo vim /etc/hosts
```

```bash
192.168.100.102 hadoop102
192.168.100.103 hadoop103
192.168.100.104 hadoop104
```

```bash
sudo reboot
```

- windows 相同配置
- C:/Windows/System32/drivers/etc/hosts

## 8.ssh 免密登录(可选)

```bash
# linux
ssh-keygen
ssh-copy-id 127.0.0.1
```

```powershell
# windows
ssh-keygen.exe
scp $env:UserProfile\.ssh\id_rsa.pub hadoop@hadoop100:~/.ssh/keys
```

```bash
# linux
cd ~/.ssh
cat keys >> authorized_keys
```

## 9.集群分发脚本(可选)

```bash
mkdir ~/bin
vim ~/bin/xsync.sh
```

```bash
#!/bin/bash
if [ $# -lt 1 ]
then
    echo "参数不足"
    exit
fi
for host in hadoop102 hadoop103 hadoop104
do
    echo "================ $host ================"
    for file in $@
    do
        if [ -e $file ]
        then
            pdir=$(cd -P $(dirname $file); pwd)
            fname=$(basename $file)
            ssh $host "sudo mkdir -p $pdir"
            rsync -av $pdir/$fname $USER@$host:$pdir
        else
            echo "$file 不存在"
        fi
    done
done
```

```bash
chmod 700 ~/bin/xsync.sh
```

## 10.卸载默认的 Java(可选)

```bash
rpm -qa | grep java-1.8.0
rpm -qa | grep java-1.8.0 | xargs sudo rpm -e --nodeps
```

## 11.上传安装包到 Linux 上(可选)

```bash
cd /opt
sudo mkdir software module
sudo chown hadoop:hadoop module software
```

```powershell
scp .\*.gz hadoop@hadoop100:/opt/software
```

## 12.关闭防火墙(可选)

```bash
sudo systemctl stop firewalld.service
sudo systemctl disable firewalld.service
sudo systemctl status firewalld.service
```
