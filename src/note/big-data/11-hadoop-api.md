# hadoop-api

---

## 0.前置条件

[HDFS 伪分布式部署](04-hdfs伪分布式部署.md) 或 [HDFS-HA](08-hdfs-ha.md)

## 1.安装插件

1. 在 windows 上下载并安装 hadoop，并配置环境变量
2. 下载对应[hadoop winutils](https://github.com/cdarlint/winutils), 并放在`$env:HADOOP_HOME/bin`下
3. 在 IDEA 插件商店搜索 big data tools 并安装

## 2.编写项目

- pom.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>pers.teaheart</groupId>
    <artifactId>hdfs</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <maven.compiler.source>8</maven.compiler.source>
        <maven.compiler.target>8</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <!-- https://mvnrepository.com/artifact/org.apache.hadoop/hadoop-client -->
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-client</artifactId>
            <version>3.3.1</version>
            <scope>provided</scope>
        </dependency>

        <!-- https://mvnrepository.com/artifact/junit/junit -->
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.13.2</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

</project>
```

- HdfsUtils.java

```java
package pers.teaheart.hadoop;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.*;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URI;
import java.net.URISyntaxException;

public class HdfsUtils {
    private static final String HDFS_HOST = "hdfs://hadoop102:9000";
    public static FileSystem hdfs;
    public static FileSystem local;

    static {
        try {
            System.setProperty("HADOOP_USER_NAME", "hadoop");
            Configuration conf = new Configuration();
            hdfs = FileSystem.get(new URI(HDFS_HOST), conf);
            local = FileSystem.getLocal(conf);
        } catch (IOException | URISyntaxException e) {
            e.printStackTrace();
        }
    }

    public static boolean mkdirs(String path) throws IOException {
        return hdfs.mkdirs(new Path(path));
    }

    public static FSDataOutputStream create(String path) throws IOException {
        return hdfs.create(new Path(path));
    }

    public static void copyFromLocalFile(String src, String dst) throws IOException {
        hdfs.copyFromLocalFile(new Path(src), new Path(dst));
    }

    public static FileStatus[] listStatus(String path) throws IOException {
        return hdfs.listStatus(new Path(path));
    }

    public static FileStatus getFileStatus(String path) throws IOException {
        return hdfs.getFileStatus(new Path(path));
    }

    public static BlockLocation[] getFileBlockLocations(String file) throws IOException {
        FileStatus fileStatus = getFileStatus(file);
        return hdfs.getFileBlockLocations(fileStatus, 0, fileStatus.getLen());
    }

    public static void creatAndWrite(String path, Object obj) throws IOException {
        OutputStream os = create(path);
        os.write(obj.toString().getBytes());
        os.close();
    }

    public static void putAndMerge(String src, String dst) throws IOException {
        FileStatus[] files = local.listStatus(new Path(src));
        OutputStream os = create(dst);
        for (FileStatus file : files) {
            InputStream is = local.open(file.getPath());
            byte[] buffer = new byte[1 << 10];
            for (int len; (len = is.read(buffer)) != -1; ) {
                os.write(buffer, 0, len);
            }
            is.close();
        }
        os.close();
    }
}
```

- HdfsUtilsTest.java

```java
package pers.teaheart.hadoop;

import org.apache.hadoop.fs.BlockLocation;
import org.apache.hadoop.fs.FileStatus;
import org.junit.Test;

import java.io.IOException;
import java.io.OutputStream;

public class HdfsUtilsTest {

    @Test
    public void mkdirsTest() throws IOException {
        System.out.println("HdfsUtilsTest.mkdirsTest");
        System.out.println(HdfsUtils.mkdirs("/tmp"));
    }

    @Test
    public void createTest() throws IOException {
        System.out.println("HdfsUtilsTest.createTest");
        OutputStream os = HdfsUtils.create("/tmp/c.txt");
        System.out.println(os);
        os.close();
    }

    @Test
    public void copyFromLocalFileTest() throws IOException {
        System.out.println("HdfsUtilsTest.copyFromLocalFileTest");
        HdfsUtils.copyFromLocalFile("D:/test/1.txt", "/tmp/1.txt");
    }

    @Test
    public void listStatusTest() throws IOException {
        System.out.println("HdfsUtilsTest.listStatusTest");
        FileStatus[] files = HdfsUtils.listStatus("/");
        for (FileStatus file : files) {
            System.out.println(file);
        }
    }

    @Test
    public void getFileStatusTest() throws IOException {
        System.out.println("HdfsUtilsTest.getFileStatus");
        System.out.println(HdfsUtils.getFileStatus("/tmp/1.txt"));
    }

    @Test
    public void getFileBlockLocationsTest() throws IOException {
        System.out.println("HdfsUtilsTest.getFileBlockLocationsTest");
        BlockLocation[] locations = HdfsUtils.getFileBlockLocations("/tmp/1.txt");
        for (BlockLocation location : locations) {
            System.out.println(location);
        }
    }

    @Test
    public void creatAndWriteTest() throws IOException {
        System.out.println("HdfsUtilsTest.creatAndWriteTest");
        HdfsUtils.creatAndWrite("/tmp/write", "write 测试");
    }

    @Test
    public void putAndMergeTest() throws IOException {
        System.out.println("HdfsUtilsTest.putAndMergeTest");
        HdfsUtils.putAndMerge("D:/test", "/tmp/merge");
    }
}
```

## 3.hdfs 验证

```bash
hdfs dfs -ls -R /
hdfs dfs -cat xxx
```
