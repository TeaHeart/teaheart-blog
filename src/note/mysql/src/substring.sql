DROP TABLE IF EXISTS tb_app;

CREATE TABLE tb_app
(
    id   varchar(10) NOT NULL COMMENT 'ID',
    name varchar(200) DEFAULT NULL COMMENT '名称',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4;



insert into tb_app (id, name)
values ('0000001', 'Testx00001');
insert into tb_app (id, name)
values ('0100001', 'Test100001');
insert into tb_app (id, name)
values ('0100002', 'Test200001');
insert into tb_app (id, name)
values ('0200001', 'Test300001');
insert into tb_app (id, name)
values ('0200002', 'TesT400001');