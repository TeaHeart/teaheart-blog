-- Active: 1740894750177@@127.0.0.1@1433@seeyon
DROP DATABASE IF EXISTS seeyon;
CREATE DATABASE seeyon COLLATE Chinese_PRC_90_CI_AI;
ALTER DATABASE seeyon SET COMPATIBILITY_LEVEL = 140;
ALTER DATABASE seeyon SET RECOVERY SIMPLE;
ALTER DATABASE seeyon SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE seeyon SET READ_COMMITTED_SNAPSHOT ON;
ALTER DATABASE seeyon SET MULTI_USER;
SELECT is_read_committed_snapshot_on FROM sys.databases WHERE name = 'seeyon';
select * FROM sys.databases;
sp_configure 'show advanced options', 1;
reconfigure;
sp_configure 'max server memory', 4096;
reconfigure;
