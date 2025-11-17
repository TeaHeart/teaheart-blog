DROP TABLE IF EXISTS tb_longhash;

CREATE TABLE tb_longhash
(
    id        int(11) NOT NULL COMMENT 'ID',
    name      varchar(200) DEFAULT NULL COMMENT '名称',
    firstChar char(1) COMMENT '首字母',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;



insert into tb_longhash (id, name, firstChar)
values (1, '七匹狼', 'Q');
insert into tb_longhash (id, name, firstChar)
values (2, '八匹狼', 'B');
insert into tb_longhash (id, name, firstChar)
values (3, '九匹狼', 'J');
insert into tb_longhash (id, name, firstChar)
values (4, '十匹狼', 'S');
insert into tb_longhash (id, name, firstChar)
values (5, '六匹狼', 'L');
insert into tb_longhash (id, name, firstChar)
values (6, '五匹狼', 'W');
insert into tb_longhash (id, name, firstChar)
values (7, '四匹狼', 'S');
insert into tb_longhash (id, name, firstChar)
values (8, '三匹狼', 'S');
insert into tb_longhash (id, name, firstChar)
values (9, '两匹狼', 'L');