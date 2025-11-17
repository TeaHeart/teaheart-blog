# InnoDB 引擎

---

## 逻辑存储结构

- 存储逻辑结构
    - 表空间(TableSpace)
        - \*.idb, 一个 MySQL 实例可以对应多个表空间, 用于存储记录, 索引等数据
        - 段(Segment)
            - 分为数据段(Leaf node segment), 索引段(Non-leaf node segment), 回滚段(Rollback segment)
            - InnoDB 是索引组织表, 数据段就是 B+Tree 的叶子节点, 索引段就是 B+Tree 的非叶子节点
            - 区(Extend)
                - 表空间的单元结构, 每个去大小为 1M
                - 默认情况下, InnoDB 存储引擎页大小为 16K, 即一个区中有 64 个连续的页
                - 页(Page)
                    - 是 InnoDB 存储引擎磁盘管理的最小单元, 每个页默认大小为 16K
                    - 为了保证页的连续性, InnoDB 存储引擎每次从磁盘申请 4-5 个区
                    - 行(Row)
                        - InnoDB 存储引擎数据是按行存放的
                        - Trx_id
                            - 每次对某条记录进行改动时, 都会把对应的事务 id 赋值给 trx_id 隐藏列
                        - Roll_pointer
                            - 每次对某条记录进行改动时, 都会把旧的版本写入到 undo 日志中, 该指针用于找到修改前的信息

## 架构

- MySQL5.5 版本开始, 默认使用 InnoDB 存储引擎, 它擅长事务处理, 具有崩溃恢复特性, 在日常开发中使用广泛
- 内存结构(In-Memory Structure)
    - 缓冲池(Buffer Pool)
        - 缓冲池时主内存的一个区域, 里面可以缓存磁盘上经常操作的真实数据
        - 在执行增删改查操作时, 先操作缓冲池中的数据(没有则会先从磁盘加载), 然后定时刷新到磁盘, 从而减少 IO
        - 缓冲池以 Page 为单位, 底层采用链表结构管理 Page, 根据状态分为以下三种
            - free page: 空闲 Page, 未被使用
            - clean page: 被使用过 Page, 数据未修改
            - dirty page: 脏页, 被使用过 Page, 数据被修改过, 与磁盘的数据产生了不一致
    - 变更缓冲区(Change Buffer)
        - 更改缓冲区(针对非唯一的二级索引页), 在执行 DML 语句时, 如果这些数据 Page 没有在 Buffer Pool 中, 不会直接操作磁盘,
          而是会将数据变更存在更改缓冲区 Change Buffer, 在未来数据读取时, 再将数据合并恢复到 Buffer Poll 中, 之后刷新到磁盘
        - 与聚集索引不同, 二级索引通常时非唯一的, 并且以相对随机的顺序插入二级索引, 同样, 删除和更新可能会影响树中不相邻的二级索引页
    - 自适应哈希索引(Adaptive Hash Index)
        - 用于优化对 Buffer Pool 数据的查询, InnoDB 存储引擎会监控表上各索引页的查询, 观察到 hash 索引何以提升速度,
          则会建立 hash 索引
        - adaptive_hash_index
    - 日志缓冲区(Log Buffer)
        - 用来保存要写入到磁盘中的 log 日志数据(redo log, undo log), 默认大小是 16M, 日志缓冲区中的日志会定期刷新到磁盘
        - 需要大量 insert, update, delete 的事务可以增大日志缓冲区大小以节省磁盘 I/O
        - innodb_log_buffer_size
        - innodb_flush_log_at_trx_commit
            - 0 每秒刷新一次到磁盘
            - 1 每次提交事务时写入到磁盘
            - 2 每次提交事务写入, 并每秒刷新到磁盘
- 磁盘结构(On-Disk Structure)
    - 系统表空间(System Tablespace)
        - 系统表空间是更改缓冲区的存储区域, 如果表是在系统表空间而不是每个表文件或通用表空间中创建的, 它也可能包含表和索引数据
        - 在 MySQL5.X 版本中还包含 InnoDB 数据字典, undo log 等
        - innodb_data_file_path
        - ibdata1
    - 文件前表(File-Pre-Table Tablespace)
        - 每个表文件表空间包含单个 InnoDB 表的数据和索引, 并存储在文件系统上的单个数据文件中
        - innodb_file_per_table;
        - \*.idb
    - 通用表空间(General Tablespace)
        - 使用 create tablespace 语法创建, 在创建表时, 可以指定该表空间
        - create tablespace 表空间名称 add datafile 文件名.idb engine = 引擎名
        - create table 表名字 (...) tablespace 表空间名称
        - \*.idb
    - 撤销表空间(Undo Tablespaces)
        - MySQL 实例在初始化时会自动创建两个默认的 undo 表空间(16M), 用于存储 undo log
        - undo_001, undo_002, undo_003.ibu, undo_004.ibu,
    - 临时表空间(Temporary Tablespaces)
        - InnoDB 使用会话临时表空间和全局临时表空间， 存储用户创建临时表等数据
        - ibtmp1, temp_1.ibt
    - 双写缓冲区(Double write Buffer Files)
        - InnoDB 引擎将数据页从 Buffer Pool 刷新到磁盘前, 先将数据页写入双写缓冲区文件中, 便于系统异常时恢复数据
        - #ib_16384_0.dblwr, #ib_16384_1.dblwr
    - 重做日志(Redo Log)
        - 记录的是事务提交时的数据也的物理修改, 是用来实现事务的持久性, 由以下两部分组成
            - 重做日志缓冲(Redo log buffer), 内存中
            - 重做日志文件(Redo log), 磁盘中
        - 事务提交后会吧所有修改信息存到日志, 用于在刷新脏页到磁盘中发生错误时, 进行数据恢复
        - 以循环方式写入重做日志
        - ib_logfile0, ib_logfile1
- 后台线程
    - 主线程(Master Thread)
        - 核心后台线程, 负责调度其他线程, 负责将缓冲池中的数据异步刷新到磁盘中, 保持数据的一致性, 还包括脏页刷新,
          合并插入缓存, undo 页的回收...
    - IO 线程(IO Thread)
        - 在 InnoDB 存储引擎中大量使用了 AIO 来处理 IO 请求, 这样可以极大地提高数据库的性能, 而 IO Thread 主要负责这些
          IO
          请求的回调
            - Read thread 4 读操作
            - Write thread 4 写操作
            - Log thread 1 将日志缓冲区刷新到磁盘
            - Insert buffer thread 1 将写缓冲区刷新到磁盘
        - show engine innodb status;
    - 净化线程(Purge Thread)
        - 主要用于回收事务已经提交了的 undo log, 在事务提交之后, undo log 可能不用了, 就将其回收
    - 页面清洁线程(Page Cleaner Thread)
        - 协助 Master Thread 刷新脏页到磁盘的线程, 减轻 Master Thread 的工作压力, 减少阻塞

## 事务原理

- 事务
    - 一组操作的集合, 是不可分割的工作单位, 事务会把所有的操作作为一个整体像系统提交或撤销操作请求, 即要么同时成功,
      要么同时失败
- 事务四大特性
    - **原子性**(Atomicity)
        - undo log
    - **一致性**(Consistency)
        - undo log + redo log
    - **隔离性**(Isolation)
        - lock + mvcc
    - **持久性**(Durability)
        - redo log
- redo log
    - 记录的是事务提交时的数据也的物理修改, 是用来实现事务的持久性, 由以下两部分组成
        - 重做日志缓冲(Redo log buffer), 内存中
        - 重做日志文件(Redo log), 磁盘中
    - 事务提交后会吧所有修改信息存到日志, 用于在刷新脏页到磁盘中发生错误时, 进行数据恢复
- undo log
    - 用于记录数据被修改前的信息, 作用是 提供回滚和 MVCC(多版本并发控制)
    - undo log 和 redo log 记录物理日志不一样, 它是逻辑日志
    - 可以认为 delete 一条记录时, undo log 中会记录一条对应的 insert 记录...
    - 当执行 rollback, 就可以 undo log 中的逻辑记录读取到相应内容并进行回滚
    - Undo log 销毁: undo log 在事务执行时产生, 事务提交时, 并不会立即删除, 因为可能还用于 MVCC
    - Undo log 存储: undo log 采用段的方式进行管理和记录, 存放在 rollback segment 回滚段中, 内部包含 1024 个 undo log
      segment

## MVCC

- 当前读
    - 读取的时记录的最新版本, 读取时还要保证其他并发事务不能修改当前记录, 会对读取的记录进行加锁
    - 对于我们日常的操作, 如 select ... lock in share mode(排他锁), select ... for update, update, insert, delete(
      排他锁)都是一种当前读
- 快照读
    - 简单的 select(不加锁)就是快照读, 读取的时记录数据的可见版本, 有可能是历史数据, 不加锁, 非阻塞
        - Read Committed: 每次 select, 都生成一个快照读
        - Repeatable Read: 开启事务后第一个 select 语句是快照读
        - Serializable: 快照读退化为当前读
- 多版本并发控制(Multi-Version Concurrency Control, MVCC)
    - 维护一个数据的多个版本, 使得读写操作没有冲突, 快照读为 MySQL 实现 MVCC 提供了一个非阻塞读功能
    - MVCC 具体实现, 还需要依赖与数据库中的三个隐式字段, undo log, readView
        - 隐藏字段
            - DB_TRX_ID
                - 最近修改事务 ID, 记录插入这条记录或最后一次修改记录的事务 ID
            - DB_ROLL_PTR
                - 回滚指针, 指向这条记录的上一个版本, 用于配合 undo log, 指向上一个版本
            - DB_ROW_ID
                - 隐藏主键, 如果表结构没有指定主键, 将会生产该隐藏字段
        - Undo Log
            - 回滚日志, 在 insert, update, delete 的时候产生的便于数据回滚的日志
            - 在 insert 时, 产生的 undo log 只在回滚时需要, 在事务提交后, 可以被立即删除
            - update, delete 时, 产生的 undo log 日志在快照读的时候也需要, 不会被立即删除
            - undo log 版本链
                - 不同事务或相同事务中对同一条数据进行修改, 会导致该记录的 undo log 生产一条记录版本链表, 头部是最新的日志,
                  尾部是最旧的日志
        - ReadView
            - 读视图(ReadVew)是快照读 SQL 执行时 MVCC 提取数据的依据, 记录并维护系统当前活跃的事务(未提交的)ID
                - m_ids:
                    - 当前事务活跃的 ID 集合
                - min_trx_id:
                    - 最小活跃事务 ID
                - max_trx_id:
                    - 预分配事务 ID, 当前最大事务 ID+1(事务 ID 是自增的)
                - creator_trx_id:
                    - ReadView 创建者的事务 ID
            - 规则
                - trx_id == creator_trx_id
                    - 可以访问该版本, 数据是当前这个事务更改的
                - trx_id < min_trx_id
                    - 可以访问该版本, 数据已经提交
                - trx_id > max_trx_id
                    - 不可以访问该版本, 该事务实在 ReadView 生成后才开启
                - min_trx_id <= trx_id <= max_trx_id && trx_id not in m_ids
                    - 可以访问该版本, 数据已经提交
                - 不同的事务隔离级别, 生产 ReadView 的时机不同
                    - Read Committed
                        - 在事务中的**每一次**执行快照读时生成
                    - Repeatable Read
                        - 在事务中的**第一次**执行快照读时生成, 后续复用
