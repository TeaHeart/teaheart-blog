-- Active: 1740894750177@@127.0.0.1@1433@v5_81_sp2
DROP DATABASE IF EXISTS v5_81_sp2;
CREATE DATABASE v5_81_sp2 COLLATE Chinese_PRC_90_CI_AI;
ALTER DATABASE v5_81_sp2 SET COMPATIBILITY_LEVEL = 140;
ALTER DATABASE v5_81_sp2 SET RECOVERY SIMPLE;
ALTER DATABASE v5_81_sp2 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE v5_81_sp2 SET READ_COMMITTED_SNAPSHOT ON;
ALTER DATABASE v5_81_sp2 SET MULTI_USER;
SELECT is_read_committed_snapshot_on FROM sys.databases WHERE name = 'v5_81_sp2';
select * FROM sys.databases;
sp_configure 'show advanced options', 1;
reconfigure;
sp_configure 'max server memory', 4096;
reconfigure;
