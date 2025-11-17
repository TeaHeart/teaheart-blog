# SQL

---

## DDL(Data Definition Language)

```mysql
show schemas; -- schemas 同 database
show databases;
select database();

create database if not exists `java_basic` charset utf8mb4;
use `java_basic`;

show create database `java_basic`;
drop database if exists `java_basic`;
```

```mysql
use `java_basic`;
show tables;

create table if not exists `student`
(
    `id`     int auto_increment primary key not null comment '编号',
    `name`   varchar(32)                    not null comment '姓名',
    `gender` tinyint unsigned default 0     not null comment '性别'
) comment '学生表';
desc `student`;

show create table `student`;
drop table if exists `student`;
```

|      类型       |       大小       |         描述          |
|:-------------:|:--------------:|:-------------------:|
|    tinyint    |       1        |        极小整形         |
|   smallint    |       2        |         小整形         |
|   mediumint   |       3        |         中整形         |
| int / integer |       4        |         大整形         |
|    bigint     |       8        |        极大整形         |
|     float     |       4        |       单精度浮点数        |
|    double     |       8        |       双精度浮点数        |
|    decimal    | 取决于精度(M)和标度(D) |        精确定点数        |
|  [unsigned]   |       -        |   数值后可加`unsigned`   |
|     char      |     0-255      |        定长字符串        |
|    varchar    |    0-65535     |        变长字符串        |
|   tinyblob    |     0-255      |       短二进制数据        |
|   tinytext    |     0-255      |         短文本         |
|     blob      |    0-65535     |        二进制数据        |
|     text      |    0-65535     |         文本          |
|  mediumblob   |   0-16777215   |       中等二进制数据       |
|  mediumtext   |   0-16777215   |        中等文本         |
|   longblob    |  0-4294967295  |       极大二进制数据       |
|   longtext    |  0-4294967295  |        极大文本         |
|       -       |       -        |          -          |
|     date      |       3        |     YYYY-MM-DD      |
|     time      |       3        |      HH:MM:SS       |
|     year      |       1        |        YYYY         |
|   datetime    |       8        | YYYY-MM-DD HH:MM:SS |
|   timestamp   |       4        | YYYY-MM-DD HH:MM:SS |

```mysql
use `java_basic`;

alter table `student`
    add `age` tinyint unsigned comment '年龄';
desc `student`;

alter table `student`
    modify gender tinyint unsigned comment '性别';
desc `student`;

alter table `student`
    change gender sex tinyint unsigned not null comment '性别';
desc `student`;

alter table `student`
    drop age;
desc `student`;

alter table `student` rename to tb_student;
show tables;

truncate table `tb_student`;
show tables;

drop table if exists `tb_student`;
show tables;
```

## DML(Date Manipulation Language)

```mysql
use `java_basic`;
insert into `student` (`name`, `gender`)
values ('zhang3', 1),
       ('li4', 2);
insert into `student`
values (default, 'wang5', 1),
       (default, 'zhao6', 2);
select *
from `student`;

update `student`
set `gender` = `gender` - 1
where `gender` = 1;
select *
from `student`;

delete
from `student`
where `gender` = 0;
select *
from `student`;
```

## DQL(Data Query Language)

```mysql
-- 准备测试数据
drop database if exists `java_basic`;
create database if not exists `java_basic` charset utf8mb4;
use `java_basic`;
create table if not exists `student`
(
    `id`         int auto_increment primary key not null comment '编号',
    `name`       varchar(32)                    not null comment '姓名',
    `gender`     tinyint unsigned               not null comment '性别',
    `age`        tinyint unsigned               not null comment '年龄',
    `entry_time` datetime                       not null comment '入学时间'
) comment '学生表';

drop procedure if exists add_student;
create procedure add_student(in num int)
begin
    declare
        i int default 0;
    while i != num
        do
            set i := i + 1;
            insert into `student` (`name`, `gender`, `age`, `entry_time`)
            values (concat('student', i),
                    if(rand() < 0.5, 1, 2),
                    18 + rand() * 2,
                    date_add(now(), interval rand() * -30 day));
        end while;
end;

call add_student(10);

alter table `student` rename to `stu_big`;
show tables;

select *
from `student`;
```

```mysql
select *
from `student`;

-- 条件查询
select `id`      `编号`,
       `name` as `姓名`,
       `age`     `年龄`
from `student`
where `gender` = 1;
```

|         符号          |             功能             |
|:-------------------:|:--------------------------:|
|          >          |             大于             |
|         >=          |            大于等于            |
|          <          |             小于             |
|         <=          |            小于等于            |
|          =          |             等于             |
|       != / <>       |            不等于             |
| between ... and ... |       [between, and]       |
|       in(...)       |            多选一             |
|      like ...       |   模糊匹配,\_匹配单个字符,%匹配多个字符    |
|       is null       |           是 NULL           |
|          -          |             -              |
|      and / &&       |             并且             |
|  or / &#124;&#124;  |             或者             |
|       not / !       |             取反             |

```mysql
-- 去重
select distinct case `gender`
                    when 1 then '男'
                    when 2 then '女'
                    else '未知' end as `性别`
from `student`;

-- 聚合函数
select count(`id`) `总人数`
from `student`;
```

| 聚合函数  | 描述  |
|:-----:|:---:|
| count | 计数  |
|  min  | 最小值 |
|  max  | 最大值 |
|  sum  | 求和  |
|  avg  | 平均值 |

```mysql
-- 分组查询
select `gender` as `性别`,
       count(`id`) `人数`
from `student`
group by `gender`
having `人数` > 2;

-- where 和 having
-- where分组前过滤, having分组后过滤
-- where不能对聚合函数进行判断, having可以
```

```mysql
-- 排序
select *
from `student`
order by gender asc,
         age desc;
```

```mysql
-- 分页
select *
from `student`
limit 0, 4;
select *
from `student`
limit 4, 4;
```

## DCL(Data Control Language)

```mysql
use `mysql`;
select *
from `user`;

create user `java_basic`@`localhost` identified by '123456';
grant all on `java_basic`.* to `java_basic`@`localhost`;

create user `any`@`%` identified by '123456';

select *
from user;

alter user 'any'@'%' identified with mysql_native_password by '123';

drop user 'any'@'%';
drop user 'java_basic'@'localhost';
select *
from user;
```

```mysql
create user `any`@`%` identified by '123456';
show grants for 'any'@'%';
grant all on *.* to `any`@`%`;
revoke all on *.* from `any`@`%`;
```

|          权限          |    描述    |
|:--------------------:|:--------:|
| all / all privileges |   所有权限   |
|        select        |   查询数据   |
|        insert        |   插入数据   |
|        update        |   更新数据   |
|        delete        |   删除数据   |
|        alter         |   修改表    |
|         drop         | 删除库/表/视图 |
|        create        | 创建库/表/视图 |
