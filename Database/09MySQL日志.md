# MySQL 日志

更新语句的流程会涉及到 undo log（回滚日志）、redo log（重做日志）、binlog（归档日志）：

-   **undo log（回滚日志）**：是 InnoDB 存储引擎生成的日志，实现了事务中的**原子性**，主要**用于事务回滚和 MVCC。**
-   **redo log（重做日志）：**是 InnoDB 存储引擎生成的日志，实现了事务中的**持久性**，主要**用于掉电等故障恢复。**
-   **binlog （归档日志）**：是 Server 层生成的日志，主要**用于数据备份和主从复制。**



## 1. undo log

undo log 是一种用于撤销回退的日志。在事务没有提交之前，MySQL 回先记录更新前的数据到 undo log 日志文件中，当事务回滚时，可以利用 undo log 来进行回滚：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230830200958828.png" alt="image-20230830200958828" style="zoom:50%;" />

每当 InnoDB 引擎对一条记录进行操作（修改、删除、新增）时，要把回滚时需要的信息都记录到undo log 中：

-   在**插入**一条记录时，要把这条记录的主键值记录下来，这样回滚之后只需要把这个主键值对应的记录**删除**就好了。
-   在**删除**一条记录时，需要把这条记录中的内容都记录下来，这样之后回滚时再把由这些内容组成的记录**插入**到表中就好了
-   在**更新**一条记录时，要把被更新的列的旧值记录下来，这样之后回滚是再把这些列**更新为旧值**就好了。

在需要回滚时，就读取 undo log 里的数据，然后和原操作取反就好了；不同的操作记录的产生的 undo log 的格式也是不同的。

一条记录的每一次更新操作产生的 undo log 格式都有一个`roll_pointer`指针和一个`trx_id`事务 id：

-   通过`trx_id`可以知道该记录是被哪个事务修改的
-   通过`roll_pointer`指针可以将这些 undo log 串成一个链表，这个链表被称为「版本链」，如图：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230830202518494.png" alt="image-20230830202518494" style="zoom:40%;" />

**另外 undo log 还有一个作用，通过 undo log + ReadView 实现 MVCC（多版本并发控制）。**

对于「读提交」和「可重复读」隔离级别的事务来说，它们的「快照读」（普通`select`语句）是通过 ReadView + undo log 来实现的，它们的区别在于创建 ReadView 的时机不同：

-   「读提交」隔离级别在每个`select`都会生成一个新的 ReadView，意味着事务期间多次读取同一条数据，前后两次读的数据可能会出现不一致，因为可能这期间另外一个事务修改了该记录并提交。
-   「可重复读」隔离级别则是在事务启动时生成一个 ReadView，然后整个事务期间都在使用这个 ReadView，这样就保证了在事务期间独到的数据都是事务启动前的记录。

这两个隔离级别是通过「事务的 ReadView里的字段」和「记录中两个隐藏列（`trd_id`和`roll_pointer`）」的比对，如果不满足「**可见性**」，就会顺着 undo log 版本链里找到满足其「可见性」的记录，从而控制并发事务访问同一个记录时的行为，被称为 MVCC。

因此，undo log 的两大作用：

-   **实现事务回滚，保障事务的原子性。**事务处理过程中，如果出现了错误或者用户`rollback`，MySQL 可以利用 undo log 中的历史数据将数据恢复到事务开始之前的状态。
-   **实现 MVCC（多版本并发控制）关键因素之一。**MVCC 是通过 undo log + ReadView 实现的，MySQL 在执行「快照读」（普通`select`语句）的时候，会根据事务的 ReadView 里的信息，顺着 undo log 版本链找到满足其「可见性」的记录。

## 2. Buffer Pool

### 2.1 为什么要 Buffer Pool

MySQL 的数据都是存在磁盘中的，我们更新一条记录的时候，需要从磁盘读取，然后在内存中修改这条记录，修改完之后，会先**缓存起来**。为此 InnoDB 存储引擎设计了一个「**缓冲池**」（Buffer Pool），来提高数据库的读写性能：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230830210304963.png" alt="image-20230830210304963" style="zoom:20%;" />

可以看到 MySQL 进程中的 InnoDB 中有一个「Buffer pool」，说明 Buffer Pool 在内存中：

-   当读取数据时，如果数据存在于 Buffer Pool 中，客户端就会直接读取 Buffer Pool 中的数据，否则再去磁盘中读取。
-   当修改数据时，首先修改的是 BufferPool 中数据所在的页，然后将其设置为「脏页」，最后由后台线程将「脏页」写入到磁盘中。

### 2.2 Buffer Pool 有多大

Buffer Pool 是在 MySQL 启动的时候，向操作系统申请的一片连续的内存空间，默认配置下 Buffer Pool 只有`128MB`，可以通过`innodb_buffer_pool_size`参数来设置 Buffer Pool 的大小，一般建议设置成可用物理内存的 60%到 80%。

### 2.3 Buffer Pool 缓存什么

InnoDB 会将存储的数据划分为若干个页，以页作为磁盘和内存交互的基本单位，MySQl 中一个页默认大小为`16KB`，所以 Buffer Pool也要按页来划分。

在 MySQL 启动的时候，**InnoDB 会为 Buffer Pool 申请一片连续的内存空间，然后按照「16KB」大小划分出一个一个页，Buffer Pool 中的页被称为「缓存页」**。此时这些缓存页都是空闲的。这些内存都是虚拟内存，只有被访问后，操作系统才会触发缺页中断，将物理地址和虚拟地址建立映射关系。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230830211924098.png" alt="image-20230830211924098" style="zoom:40%;" />

Buffer Pool 中有「索引页」、「数据页」、「Undo 页」、「插入缓存页」、「自适应哈希索引」和「锁信息」等：

-   「undo 页」：开启事务后，InnoDB 层更新记录前，首先要记录相应的 undo log，如果是更新操作，需要把被更新的列的旧值记录下来，也就是要生成一条 undo log，undo log 会写入 Buffer Pool 中的 undo 页面。

当我们查询一条记录时， InnoDB 会把整个页面的数据加载到 BufferPool 中，而不是缓冲一条。

## 3. redo log

Buffer Pool 提高了读写效率，但是它是基于内存的，而内存是不可靠的，断电「脏页」还没写入到磁盘就会丢失。

为了防止断电导致数据丢失，当有一条记录需要更新的时候，InnoDB引擎就会先更新内存（同时标记为脏页），然后将本次对这个页的修改以「redo log」的形式记录下来，**这个时候就算完成更新了。**

InnoDB 引擎会在适当的时候，由后台线程将混存在 Buffer Pool 的脏页刷新到磁盘里，这就是**WAL( Write-Ahead Logging)技术。WAL 计数指的是，MySQL 的写操作并不是立刻写在磁盘上，而是先写日志，然后再合适的时候再写到磁盘上。**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230830235041066.png" alt="image-20230830235041066" style="zoom:40%;" />

### 3.1 什么是 redo log

redo log 是`物理日志`，记录了某个数据页做了什么修改，比如**对 A 表空间中 Y 数据页 Z 偏移量的地方做了 X 更新，**每当执行一个事务就会产生这样的「物理日志」。

**在事务提交的时候，只需要先把 redo log 持久化到磁盘即可**，可以不需要等到将缓存到 Buffer Pool 里的脏页数据持久化到磁盘。

当系统崩溃时，虽然脏页数据没有持久化，但是 redo log 已经持久化，MySQL 重启后，可以根据 redo log 的内容，将所有数据恢复到最新的状态。



### 3.2 被修改的 undo 页面，需要记录对应 redo log 吗

需要。开启事务后，InnoDB 层更新记录前，首先要记录对应的 undo log，如果是更新操作，需要把被更新的列的旧值记录下来，也就是要生成一条 undo log，undo log 会写入到 Buffer Pool 中的 Undo 页面。

不过，**在内存修改该 undo 页面后，需要记录对应的 redo log。**

### 3.3 undo log 和 redo log 的区别

这两种日志都是属于 InnoDB 存储引擎的日志，区别在于：

-   redo log 记录了此次事务「完成后」的数据状态，记录的是更新**之后**的值
-   undo log 记录了此次事务「开始前」的数据状态，记录的是更新**之前**的值

事务提交之前发生了崩溃，重启后会通过 undo log 回滚事务，事务提交之后发生了崩溃，重启后会通过 redo log 恢复事务：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230831000641998.png" alt="image-20230831000641998" style="zoom: 35%;" />

所以 redo log + WAL，InnoDB 就可以保证提交的记录不会丢失，保证了「持久性」

### 3.4 redo log 为什么要写到磁盘

redo log 要写到磁盘，数据也要写到磁盘，为什么要多次一举？

写入 redo log 的方式使用了追加操作，所以磁盘是**顺序写**，而写入数据需要先找到写入位置，然后才写到磁盘，所以磁盘操作是**顺序写。**

磁盘的「顺序写」比「随机写」高效的多，因此 redo log 写入磁盘的开销更小。

这也是 WAL 技术的另一个特点：**MySQL 的写操作从磁盘的「随机写」变成了「顺序写」，**提升语句的执行性能，这是因为 MySQL 的写操作并不是立刻更新到磁盘上，而是先记录在日志上，然后再核实的时间再更新到磁盘上。



### 3.5 redo log 是直接写入到磁盘吗？

**不是。**

执行一个事务的过程中，产生的 redo log 不是直接写入到磁盘，因为这样会产生大量的 IO 操作，redo log 也有自己的缓存「redo log buffer」，每当产生一条redo log 的时候，会先写入到 「redo log buffer」，后续再持久化到磁盘：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230831230916906.png" alt="image-20230831230916906" style="zoom:30%;" />

### 3.6 redo log什么时候刷盘

主要有如下时机：

-   MySQL 正常关闭时
-   当「redo log buffer」中记录的写入量大于 redo log buffer 内存空间的一半时，会触发落盘
-   InnoDB 后台线程每隔一秒，将 redo log buffer 持久化到磁盘
-   每次事务提交时都会将缓存在 redo log buffer里的 redo log 直接持久化到磁盘（这个策略可通过参数修改）



`innodb_flush_log_at_trx_commit`参数用来控制刷盘的时机：

单独执行一个更新语句时，InnoDB 会自己启动一个事务，在执行更新语句的时候，生成的 redo log 先写入到 redo log buffer 中，然后等待事务提交的时候，再将缓存在 redo log buffer 中的 redo log 按组的方式「顺序写」到磁盘。

上面这种 redo log 刷盘时机是在事务提交时候的默认行为，除此之外，InnoDB 还提供了另外两种策略，由参数`innodb_flush_log_at_trx_commit`控制，可取的值有 0、1、2，这三个值代表的策略如下：

-   当设置该参数为 0 时，表示每次提交事务时，还是将 redo log 留在 redo log buffer 中，该模式下在事务提交时不会主动触发写入磁盘的操作。
-   当设置该参数为 1 时，表示每次事务提交时，都将缓存在 redo log buffer 中的 redo log 直接持久化到磁盘，这样可以保证 MySQL 异常重启之后数据不会丢失。
-   当设置该参数为 2 时，表示每次事务提交时，都只是将 redo log buffer 里的 redo log**写到 redo log 文件，注意写入到「redo log 文件」不等于写入到磁盘，**这是因为操作系统的文件系统中有个 Page Cache，而是写入到了操作系统的文件缓存。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/innodb_flush_log_at_trx_commit.drawio.png.webp" alt="innodb_flush_log_at_trx_commit.drawio.png" style="zoom:50%;" />

那么参数为 0 或 2 的时候，什么时候才将 redo log 写入到磁盘？

InnoDB 的后台线程，每隔一秒：

-   针对参数 0，会把缓存在 redo log buffer 中的 redo log，通过调用`write()`写到操作系统的 Page Cache，然后调用`fsync()`持久化到磁盘。**所以参数为 0 的策略，MySQL 进程的崩溃会导致上一秒所有事务数据的丢失。**
-   针对参数 2，调用`fsync()`，将缓存在操作系统的 Page Cache 里的 redo log 持久化到磁盘。**所以参数为 2 的策略，比 0 更安全，因为 MySQL 进程的崩溃并不会丢失数据，只有在操作系统崩溃或者系统断电的情况下，上一秒所有的事务数据才可能丢失。**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230831232638774.png" alt="image-20230831232638774" style="zoom:40%;" />



这三个参数的数据安全性和写入性能比较如下：

-   数据安全性：1 \> 2 \>0
-   写入性能：0 \>2 \>1

### 3.7 redo log 文件写满了怎么办



## 4. binlog

undo log 和 redo log 都是InnoDB 存储引擎生成的，MySQL 在完成一条更新操作之后，Server 层还会生成一条 binlog，等之后事务提交之后，会将该事务执行过程中产生的所有 binlog 统一写入到 binlog 文件。

binlog记录了所有数据库表结构变更和表数据修改的日志，不会记录查询类的操作，例如`select`和`show`。

最开始，MySQL 没有 InnoDB，默认的存储引擎是 MyISAM，但是 MyISAM 并没有 crash-safe 的能力，binlog 日志只能用与归档，而 InnoDB 是另一家公司以插件的形式引入的，所以 redo log 和 binlog 并存。



### 4.1 redo log 和 bin log 有什么区别

**1. 适用对象不同**

-   binlog 是 MySQL 的 Server 层实现的日式，所以所有引擎都可以用
-   redo log 是 InnoDB 存储引擎实现的日志

**2. 文件格式不同**

-   binlog 有三种格式类型，分别是`STATEMENT`（默认格式）、`ROW`、`MIXED`，区别如下
    -   STATEMENT：每一条修改数据的 SQL 都会被记录到 binlog 中（相当于记录了逻辑操作，所以针对这种格式，binlog 可以称为逻辑日志），主从复制中的 slave 端再根据 SQL 重现。但 STATEMENT 有动态函数的问题，比如用了 uuid 和 now 这些函数，在主库上执行的结果并不是在从库执行的结果，会导致数据不一致。
    -   `ROW`：记录行数据最终被修改成什么样了（这种格式的日志，就不能被称为逻辑日志了），不会出现 STATEMENT 下动态函数的问题。但是 ROW 的缺点就是一每行数据的变化结果都会被记录，比如执行批量 update 语句，更新多少行数据就会产生多少记录，使得 binlog 文件过大，而 STATEMENT 格式下只会记录一个 update 语句；
    -   MIXED：视具体情况使用 ROW 模式和 STATEMENT 模式
-   redo log 是物理日志，记录的是在某个数据页做了什么修改，例如在 「A 表空间的 B 数据页的 C 偏移量的地方做了 D 更新」。

**3. 写入方式不同**

-   binlog 是追加写，写满一个文件，就创建一个新的文件继续写，不会覆盖以前的日志，保存的是全量的日志。
-   redo log 是循环写，日志空间大小是固定，全部写满就从头开始，保存未被刷入磁盘的脏页日志。

**4.用途不同**

-   binlog 用于备份恢复、主从复制
-   redo log 用于掉电恢复等故障

>   如果不小心删除了整个数据库的数据，不能用 redo log 文件恢复，只能用 binlog 文件恢复，因为 redo log 是循环写，binlog 保存的是全量的日志。



### 4.2 主从复制的实现

MySQL 的主从复制依赖于 binlog，也就是记录 MySQL 上的所有变化并以二进制的形式保存在磁盘上。复制的过程就是将 binlog 中的数据从主库传输到从库上。

这个过程一般是**异步**的，也就是主库上执行事务操作的线程不会等待复制 binlog 的线程同步完成。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230904003422713.png" alt="image-20230904003422713" style="zoom:50%;" />

MySQL 集群的主从复制有 3 个阶段：

-   **写入 binlog**：主库写 binlog 日志，提交事务，并更新本地存储数据。
    MySQL 主库在收到客户端提交事务的请求之后，会先写入 binlog，再提交事务，更新存储引擎中的数据，事务提交完成后，返回给客户端「操作成功」的响应。

-   **同步 binlog**：把 binlog 复制到所有从库上，每个从库把 binlog 写到「暂存日志」中。

    从库有一个专门的 IO 线程，连接主库的 log dump 线程，来接收主库的 binlog 日志，再把 binlog 信息写入「relay log」的中继日志里，再返回给主库「复制成功」的响应。

-   **回放 binlog**：回放 binlog，并更新存储引擎中的数据。

    从库会创建一个用于回放 binlog 的线程，去读「relay log」中继日志，然后回放 binlog 更新存储引擎中的数据，最终实现主从数据的一致性。

在完成主从复制之后，就可以在写数据时只写主库，在读数据时只读从库，这样即使写请求会锁表或者锁记录，也不会影响度请求的执行。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230904005332822.png" alt="image-20230904005332822" style="zoom:50%;" />

#### 从库是不是越多越好

当然不是。

从库数量增加，从库连接到主库的 IO 线程也多，主库需要创建同样多的 log dump 线程来处理复制的请求，对主库资源消耗较高。

一般一个主库就 2~3 个从库。

#### MySQL 的主从复制模型

主要有三种

-   **同步复制：**MySQL 主库提交事务的线程要等待所有从库的复制成功响应，才返回客户端结果。
-   **异步复制（默认模型）**：MySQL 主库提交事务的线程并不会等待 binlog 同步到各从库，就返回客户端结果。这种模式主库宕机，数据就会丢失。
-   **半同步复制：**MySQL5.7 版本之后增加的一种复制方式，介于两者之间，事务线程不用等待所有的从库复制响应成功，只要一部分复制成功响应回来就行。例如「一主二从」的集群，只要数据复制到任意一个从库上，主库的事务线程就可以返回客户端。



## 5. 两阶段提交

### 5.1 为什么需要「两阶段提交」

事务提交之后，redo log 和 binlog 都要持久化到磁盘，但这两个是独立的逻辑，可能出现「半成功」的状态，这样就造成两份日志之间的逻辑不一致。



### 5.1 两阶段提交的过程



