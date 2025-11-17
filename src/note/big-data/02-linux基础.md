# linux 基础

---

## 1.克隆虚拟机并修改主机名 IP 地址

1. 克隆 hadoop100 为 hadoop102
2. [修改 IP 地址](<01-linux平台搭建.md#5.配置 Linux 静态 IP(可选)>)
3. [修改主机名](<01-linux平台搭建.md#6.修改主机名称(可选)>)

## 2.配置 ssh 免密登录

[配置 ssh 免密登录](<01-linux平台搭建.md#8.ssh 免密登录(可选)>)

## 3.验证

```powershell
ping hadoop102
ssh hadoop@hadoop102
```
