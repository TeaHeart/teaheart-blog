drop table if exists tb_strhash;

create table tb_strhash
(
    name    varchar(20) primary key,
    content varchar(100)
) engine = InnoDB
  DEFAULT CHARSET = utf8mb4;


INSERT INTO tb_strhash (name, content)
VALUES ('T1001', UUID());
INSERT INTO tb_strhash (name, content)
VALUES ('ROSE', UUID());
INSERT INTO tb_strhash (name, content)
VALUES ('JERRY', UUID());
INSERT INTO tb_strhash (name, content)
VALUES ('CRISTINA', UUID());
INSERT INTO tb_strhash (name, content)
VALUES ('TOMCAT', UUID());