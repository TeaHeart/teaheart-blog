# hive 基本操作

---

## 0.前置条件

[Hive 安装](12-hive安装与操作.md)

## 1.启动服务

```bash
hdfs --daemon start namenode
hdfs --daemon start datanode
yarn --daemon start resourcemanager
yarn --daemon start nodemanager
mapred --daemon start historyserver
hive --service metastore &
hive
```

## 2.准备数据

```bash
vim ~/buyer_log
```

```bash
461	10181	2010-03-26 19:45:07	123.127.164.252	1
462	10262	2010-03-26 19:55:10	123.127.164.252	1
463	20001	2010-03-29 14:28:02	221.208.129.117	2
464	20001	2010-03-29 14:28:02	221.208.129.117	1
465	20002	2010-03-30 10:56:35	222.44.94.235	2
```

```bash
vim ~/buyer_favorite
```

```bash
10181	1000481	2010-04-04 16:54:31
10001	1001597	2010-04-07 15:07:52
20001	1001560	2010-04-07 15:08:27
20042	1001368	2010-04-08 08:20:30
20067	1002061	2010-04-08 16:45:33
```

## 3.创建表并导入数据

```sql
create table buyer_log(id string,buyer_id string,dt string,ip string,opt_type string)
row format delimited fields terminated by '\t'  stored as textfile;
create table buyer_favorite(buyer_id string,goods_id string,dt string)
row format delimited fields terminated by '\t'  stored as textfile;
load data local inpath '/home/hadoop/buyer_log' into table buyer_log;
load data local inpath '/home/hadoop/buyer_favorite' into table buyer_favorite;
```

## 4.常规操作

```sql
select * from buyer_log limit 2;
select * from buyer_favorite limit 2;
select b.buyer_id from buyer_log b where b.opt_type=1 limit 2;
select b.buyer_id from buyer_log b where b.opt_type=1 limit 3;
select l.dt,f.goods_id from buyer_log l,buyer_favorite f where l.buyer_id = f.buyer_id limit 5;
```

## 5.多表插入

```sql
create table buyer_log1 like buyer_log;
create table buyer_log2 like buyer_log;
from buyer_log
insert overwrite table buyer_log1 select *
insert overwrite table buyer_log2  select *;
```

## 6.多目录输出

```bash
from buyer_log
insert overwrite local directory '/tmp/out' select *
insert overwrite local directory '/tmp/out1' select *;
```

## 7.shell 脚本调用 Hive 查询语句

```bash
cd ~
vim sh1.sh
```

```bash
#!/bin/bash
hive -e 'show tables;'
```

```bash
chmod +x sh1.sh
./sh1.sh
```

## 8.准备数据

```bash
vim ~/goods_visit
```

```bash
1010000	4
1010001	0
1010002	0
1010003	0
1010004	0
```

```bash
vim ~/order_items
```

```bash
425	292	1010060	999	10.4	10.4	10389.6
426	292	1001716	999	16.8	16.8	16783.2
427	293	1010060	2	10.4	10.4	20.8
428	294	1010060	6	10.4	10.4	62.4
```

## 9.创建表并导入数据

```bash
create table goods_visit(goods_id string,click_num int)
row format delimited fields terminated by '\t'  stored as textfile;
load data local inpath'/home/hadoop/goods_visit' into table goods_visit;
create table order_items(item_id string,order_id string,goods_id string,goods_number string,
shop_price string,goods_price string,goods_amount string)
row format delimited fields terminated by '\t'  stored as textfile;
load data local inpath '/home/hadoop/order_items' into table order_items;
```

## 10.Order by, Sort by, Group by, Distribute by, Cluster by

```bash
select * from goods_visit order by click_num desc limit 4;
set mapred.reduce.tasks=3;
select * from order_items sort by goods_id;
select dt,count(buyer_id) from buyer_favorite group by dt;
set mapred.reduce.tasks=3;
insert overwrite local directory '/tmp/out3' select * from buyer_favorite distribute by buyer_id;
set mapred.reduce.tasks=3;
select * from buyer_favorite cluster by buyer_id;
```

## 11.UDF

- pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>pers.teaheart</groupId>
    <artifactId>hive</artifactId>
    <packaging>jar</packaging>
    <version>1.0</version>

    <properties>
        <maven.compiler.source>8</maven.compiler.source>
        <maven.compiler.target>8</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <!-- https://mvnrepository.com/artifact/org.apache.hive/hive-exec -->
        <dependency>
            <groupId>org.apache.hive</groupId>
            <artifactId>hive-exec</artifactId>
            <version>3.1.3</version>
        </dependency>
    </dependencies>

</project>
```

- Year.java

```java
package pers.teaheart.hive;

import org.apache.hadoop.hive.ql.exec.Description;
import org.apache.hadoop.hive.ql.exec.UDF;
import org.apache.hadoop.hive.serde2.io.TimestampWritable;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

@Description(name = "year", value = "_FUNC_(date) - Returns the year of date", extended = "date is a string in the format of 'yyyy-MM-dd HH:mm:ss' or " + "'yyyy-MM-dd'.\n" + "Example:\n " + "  > SELECT _FUNC_('2017-03-08', 1) FROM src LIMIT 1;\n" + "  2017")
public class Year extends UDF {
    private final SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
    private final Calendar calendar = Calendar.getInstance();
    private final IntWritable result = new IntWritable();

    public IntWritable evaluate(Text dateString) {
        if (dateString == null) {
            return null;
        }
        try {
            Date date = formatter.parse(dateString.toString());
            calendar.setTime(date);
            result.set(calendar.get(Calendar.YEAR));
            return result;
        } catch (ParseException e) {
            return null;
        }
    }

    public IntWritable evaluate(TimestampWritable t) {
        if (t == null) {
            return null;
        }
        calendar.setTime(t.getTimestamp());
        result.set(calendar.get(Calendar.YEAR));
        return result;
    }
}
```

```bash
# 编写完打成Jar包并上传, 复制到$HIVE_HOME/lib下
cd $HIVE_HOME/lib
cp ~/hive-1.0.jar .
```

```bash
# 定义函数并使用
hive
create temporary function udf as 'hive.udf.YEAR';
select udf(buyer_favorite.dt) from buyer_favorite;
drop temporary function udf;
```
