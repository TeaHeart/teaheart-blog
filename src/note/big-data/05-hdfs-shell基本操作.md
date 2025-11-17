# hdfs-shell 基本操作

---

## 0.前置条件

[HDFS 伪分布式部署完成](04-hdfs伪分布式部署.md)

## 1.启动

```bash
hdfs --daemon start namenode
hdfs --daemon start datanode
```

## 2.基本操作

```powershell
# windows上传测试文件
scp C:\Windows\Logs\CBS\CBS.log hadoop@hadoop102:~/log.txt
```

```bash
hdfs dfs -mkdir -p /usr/data/input # 创建
hdfs dfs -ls -R / # 查看
hdfs dfs -put ~/log.txt /usr/data/input # 上传到
hdfs dfs -ls -R /
hdfs dfs -cat /usr/data/input/log.txt | head # 查看文件
hdfs dfs -get /usr/data/input/log.txt /tmp/ # 下载
cat /tmp/log.txt | head # 验证
hdfs dfs -mkdir /aa
hdfs dfs -cp /usr/data/input/log.txt /aa # 复制
hdfs dfs -mkdir /a
hdfs dfs -mv /aa/log.txt /a # 移动
hdfs dfs -rm /a/log.txt # 删除
hdfs dfs -mkdir /aa/bb
hdfs dfs -rm -r -f /aa # 删除
hdfs dfs -ls -R /
hdfs dfs -moveFromLocal ~/log.txt /a # 移动本地文件
hdfs dfs -ls -R /
```
