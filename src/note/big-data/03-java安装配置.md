# java 安装配置

---

## 0.卸载默认的 Java(可选)

[卸载默认的 jdk](<01-linux平台搭建.md#10.卸载默认的 Java(可选)>)

## 1.下载解压安装

[java8](https://www.oracle.com/java/technologies/downloads/#java8-linux)

```powershell
scp .\jdk-8u321-linux-x64.tar.gz hadoop@hadoop102:/opt/software
```

```bash
cd /opt
tar -zxvf software/jdk-8u321-linux-x64.tar.gz -C module/
```

## 2.配置环境变量

```bash
sudo vim /etc/profile.d/my_env.sh
```

```bash
# jdk1.8.0_321
export JAVA_HOME=/opt/module/jdk1.8.0_321
export PATH=$PATH:$JAVA_HOME/bin
```

```bash
source /etc/profile
```

## 3.验证

```bash
java -version
```
