# Redis6



## 1. NoSQL数据库简介

### 1.2 技术发展

NoSQL是属于解决性能问题的技术。

在早期Web1.0时代，可能一台Web服务器和一台数据库服务器就可以解决所有问题。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220724005057708.png" alt="image-20220724005057708" style="zoom:40%;" />

在Web2.0时代，session的存放是一个问题：

### 1.3 NoSQL数据库

NoSQL（Not Only SQL），泛指**非关系型数据库**。NoSQL不依赖业务逻辑方式存储，而使用key-value模式存储。

-   不遵循SQL标准
-   不支持ACID
-   远超SQL性能

#### NoSQL应用场景

-   对数据高并发读写
-   海量数据的读写
-   对数据高扩展性的

#### NoSQL不适用场景

-   需要事务支出
-   给予SQL

### 

### 1.4 其他类型数据库

-   行式数据库
-   列式数据库
-   图数据库



### 数据库排名

[**http://db-engines.com/en/ranking**](http://db-engines.com/en/ranking)



## 2. Redis 概述安装

-   Redis是一个**开源的key-value存储系统**。
-   和Memcached类似，它支持存储的value类型相对更多，包括**string(字符串)、list(链表)、set(集合)、zset(sorted set --有序集合)和hash（哈希类型）。**
-   这些数据类型都支持push/pop、add/remove及取交集并集和差集及更丰富的操作，而且这些操作都是**原子性**的。
-   在此基础上，Redis支持各种不同方式的**排序。**
-   与memcached一样，为了保证效率，数据都是**缓存在内存中**。
-   区别的是Redis会**周期性**的把更新的**数据写入磁盘**或者把修改操作写入追加的记录文件。
-   并且在此基础上实现了**master-slave(主从)同步**。

### 2.1 应用场景

#### 2.1.1 配合关系型数据库做高速缓存

-   高频次，热门访问的数据，降低数据库IO
-   分布式架构，做session共享

#### 2.1.2 多样的数据结构存储持久化数据

### 2.2 Redis安装

1.   选择redis-6.2.1.tar.gz

2.   准备工作（存在该环境可以跳过）：下载安装最新版的gcc编译器

     ```shell
     yum install centos-release-scl scl-utils-build
     yum install -y devtoolset-8-toolchain
     scl enable devtoolset-8 bash
     ```

     可以通过`gcc --version`查看gcc版本

3.   下载redis-6.2.1.tar.gz放在/opt目录

4.   解压`tar -zxvf redis-6.2.1.tar.gz`，并进入`cd redis-6.2.1`

5.   在/redis-6.2.1目录下分别执行`make`命令和`make install`

6.   安装路径在`/usr/local/bin`

### 2.3 Redis启动

#### 2.3.1 前台启动（不推荐）

使用`redis-server`，前台启动命令行窗口不能关闭，否则服务器停止。

#### 2.3.2 后台启动（推荐）

1.   备份`redis.conf`，拷贝到其他目录：`cp /opt/redis-6.2.1/redis.conf /myredis`
2.   修改`redis.conf`中的daemonize no 改为yes，让服务在后台启动。
3.   启动命令 ： `redis-serve /myredis/redis.conf`
4.   用客户端访问`redis-cli -p <port>`

## 3. 常用五大数据类型

### 3.1 Redis键（key）

-   `keys *`：查看当前库所有的key

-   `exists <key>`：判断某个key是否存在

-   `type <key>`：查看这个key是什么类型

-   `del <key>`：删除指定的key

-   `unlink <key>	`：根据value选择非阻塞删除

    >   仅将keys从keyspace元数据中删除，真正的删除会在后续异步操作。
-   `expire key <t>`：为给定的key设置过期时间，t为秒数
-   `ttl <key>`：查看还有多少秒过期，-1代表永不过期，-2表示已经过期
-   `select`命令切换数据库
-   `dbsize`：查看当前数据库的key的数量
-   `flushdb`：清空当前库
-   `flushall`：清空全部库



### 3.2 Redis字符串（String）

#### 3.2.1 简介

String是Redis最基本的类型，一个key对应一个value。String类型是**二进制安全**的。意味着Redis的string可以包含任何数据。比如jpg图片或者序列化的对象。

String类型是Redis最基本的数据类型，**一个Redis中字符串value最多可以是512M。**

#### 3.2.2 常用命令

-   `set <key> <value>`：添加键值对

    <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910235235454.png" alt="image-20220910235235454" style="zoom:40%;" />

    -   NX：当数据库中key不存在时，可以将key-value添加数据库
    -   XX：当数据库中key存在时，可以将key-value添加数据库，与NX参数互斥
    -   EX：key的超时秒数
    -   PX：key的超时毫秒数，与EX互斥

-   `get <k>`：查询对应键的值

-   `append <key><value>`：将给定的`<value>`追加到原值的末尾

-   `strlen <k>`：获得键的长度

-   `setnx <k> <v>`：当k不存在时，设置k的值

-   ` incr <key>`：将key中存储的数字值增加1，只能对数字值操作，如果为空，新增值为1

-   `decr <key>`：将 key 中储存的数字值减1，只能对数字值操作，如果为空，新增值为1

-   `incrby/decrby <key> <步长>`：将 key 中储存的数字值增减。自定义步长。

>   incr是原子性的，不会被线程调度机制打断
>
>   java的i++不是原子操作，操作不会互相产生影响。

-   `mset`、`mget`、`msetnx`：同时操作多个k-v键值对(中间用空格隔开)
-   `getrange <key> <start> <end>`：获得值的方位，类似java中的`subString`，但是**前包后包**
-   `setrange <key> <start> <value>`：用 `<value>` 覆写`<key>`所储存的字符串值，从`<start>`开始(索引从0开始)。
-   `setex <key> <过期时间(单位s)> <value>`：设置过期时间
-   `getset <key> <value>`：以新换旧

###  数据结构

String的底层为简单动态字符串，类似于Java的ArrayList。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220911000040493.png" alt="image-20220911000040493" style="zoom:40%;" />

内部为当前字符串实际分配的空间capacity一般要高于实际字符串长度len。当字符串长度小于1M时，扩容都是加倍现有的空间，如果超过1M，扩容时一次只会多扩1M的空间。需要注意的是字符串最大长度为512M。

### 3.3 Redis列表（List）

#### 3.3.1 简介

单键多值，底层是一个双向链表，首尾都可以操作，但是对索引下标操作性能比较差。

#### 3.3.2 常用命令

-   `lpush/rpush <k1> <v1> <k2> <v2>`：一个一个放入，而不是一起放入。
-   `lpop/rpop key`：从左边/右边pop出一个值，值在键在，反之亦然。
-   `rpoplpush <key1> <key2>`：从key1列表右边取出一个值放到key2左边。
-   `lrange <k> <start> <end>`：按照索引下标获得元素（从左到右）， 0左边第一个，-1右边第一个，（0 -1表示获取所有）
-   `lindex <key> <index>`：按照索引下标获得元素（从左开始计算）
-   `llen <key>`获得列表长度
-   `linsert <key> before <value> <newvalue>`在value后面插入new value
-   `lrem <key> <n> <value>`：从左边删除n个value
-   `lset <key> <index> <value>`：将列表key下标为index的值替换成value

#### 数据结构

quickList：它将所有的元素紧挨着一起存储，分配的是一块连续的内存。当数据量比较多的时候才会改成quicklist。

首先在列表元素较少的情况下会使用一块连续的内存存储，这个结构是ziplist，也即是压缩列表。

它将所有的元素紧挨着一起存储，分配的是一块连续的内存。

当数据量比较多的时候才会改成quicklist。

因为普通的链表需要的附加指针空间太大，会比较浪费空间。比如这个列表里存的只是int类型的数据，结构上还需要两个额外的指针prev和next。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220911001605396.png" alt="image-20220911001605396" style="zoom:40%;" />

Redis将链表和ziplist结合起来组成了quicklist。也就是将多个ziplist使用双向指针串起来使用。这样既满足了快速的插入删除性能，又不会出现太大的空间冗余。

### 3.4 Redis集合（Set）

#### 3.4.1 简介

Set与list类似，但是可以自动排重。Redis的Set是String类型的无序集合。

Redis的Set是string类型的无序集合。它底层其实是一个value为null的hash表，所以添加，删除，查找的**复杂度都是O(1)**。

#### 常用命令

-   `sadd <key> <value1> <value2>`：将一个或多个 member 元素加入到集合 key 中，已经存在的 member 元素将被忽略
-   `smembers <key>`：取出该集合的所有值
-   `sismember <key> <value>`：判断集合\<key\>中是否含有\<value\>的值，有1，没有0
-   `scard <key>`：返回该集合的元素个数
-   `srem <k> <v1> <v2> ...`：删除集合中的某些元素
-   `spop <key>`：**随机从该集合中吐出一个值**
-   `srandmember <k> <n> `：随机从该集合中取出n个值。不会从集合中删除
-   `smove <source> <destination> <value>`：将集合中的一个值移动到另一个值
-   `sinter <k2> <k2>`：返回两个集合的交集元素
-   `sunion <k1> <k2>`：返回两个集合并集的元素
-   `sdiff <k1> <k2>`：返回两个集合差集的元素（k1中有，k2中没有的元素）

#### 数据结构

Set数据结构是dict字典，字典是用哈希表实现的。

### 3.5 Redis哈希（Hash）

#### 3.5.1 简介

Redis hash 是一个键值对集合。

Redis hash是一个string类型的field和value的映射表，hash特别适合用于存储对象。

类似Java里面的Map<String,Object>

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220911002639279.png" alt="image-20220911002639279" style="zoom:40%;" />

#### 3.5.2 常用命令

 

- `hset <key><field><value>`给<key>集合中的 <field>键赋值<value>
- `hget <key1><field>从<key1>`集合<field>取出 value 
- `hmset <key1><field1><value1><field2><value2>...` 批量设置hash的值
- `hexists<key1><field>`查看哈希表 key 中，给定域 field 是否存在。 
- `hkeys <key>`列出该hash集合的所有field
- `hvals <key>`列出该hash集合的所有value
- `hincrby <key><field><increment>`为哈希表 key 中的域 field 的值加上增量 1  -1
- `hsetnx <key><field><value>`将哈希表 key 中的域 field 的值设置为 value ，当且仅当域 field 不存在 .

#### 3.5.3 数据结构

Hash类型对应的数据结构是两种：ziplist（压缩列表），hashtable（哈希表）。当field-value长度较短且个数较少时，使用ziplist，否则使用hashtable。

### 3.6 Redis有序集合Zset（sorted set）

#### 3.6.1 简介

Redis有序集合zset与普通集合set非常相似，是一个没有重复元素的字符串集合。

不同之处是有序集合的每个成员都关联了一个**评分（score）**,这个评分（score）被用来按照从最低分到最高分的方式排序集合中的成员。集合的成员是唯一的，但是评分可以是重复了 。

因为元素是有序的, 所以你也可以很快的根据评分（score）或者次序（position）来获取一个范围的元素。

访问有序集合的中间元素也是非常快的,因此你能够使用有序集合作为一个没有重复成员的智能列表。

#### 3.6.2 常用命令

-   `zadd <k> <s1> <v1> <s2> <v2> ...`：将一个或多个member元素及其score加入到有序集合key中
-   `zrange <k> <start> <end> [WITHSCORES]`：返回有序集合key中下标在start到end之间的元素，如果带`[WITHSCORES]可以让分数和值一起返回结果集。
-   `zrangebyscore key [min] [max] [withscores] [limit offset count]`： 返回有序集 key 中，所有 score 值介于 min 和 max 之间(包括等于 min 或 max )的成员。有序集成员按 score 值递增(从小到大)次序排列。 
-   `zrevrangebyscore key [max] [min] [withscores] [limit offset count]  `：同上，改为从大到小排列
-   `zincrby <k> <increment> <value>`：为元素的score加上增量
-   `zrem <k> <v>`：删除该集合下指定值的元素
-   `zcount <k> <min> <max>`：统计该集合，分数区间内的元素个数
-   `zrank <k> <v> `：返回该值在集合中的排名，从0开始

>   案例：如何利用zset实现一个文章的访问量的排行？
>
>   1.   `zadd  topn 1000 v1 2000 v2 3000 v3`
>   2.   `zrevrange topn 0 9 withscores`

#### 3.6.3 数据结构

SortedSet(zset)是Redis提供的一个非常特别的数据结构，一方面它等价于Java的数据结构Map<String, Double>，可以给每一个元素value赋予一个权重score，另一方面它又类似于TreeSet，内部的元素会按照权重score进行排序，可以得到每个元素的名次，还可以通过score的范围来获取元素的列表。

zset底层使用了两个数据结构

1.   hash，hash的作用就是关联元素value和权重score，保障元素value的唯一性，可以通过元素value找到相应的score值。
2.   跳跃表，跳跃表的目的在于给元素value排序，根据score的范围获取元素列表。

#### 跳表

![image-20220726005627650](https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220726005627650.png)

## 4. Redis配置文件

自定义目录：/myredis/redis.conf

默认目录：/etc/redis.conf

### 4.1 常用配置选项

#### 4.1.1 bind

默认情况下`bind=127.0.0.1`只能接受本机的访问请求，不写的情况下，无限制接受任何IP地址的访问。将本机访问保护模式设置no

#### 4.1.2 INCLUDE

可以理解为C、Java等程序的导包，在这里代表导入别的配置文件

#### 4.1.3 protected-mode

将本机访问保护模式设置no。如果开启了protected-mode，那么在没有设定bind ip且没有设密码的情况下，Redis只允许接受本机的响应。

#### 4.1.4 port

端口号，默认为6379

#### 4.1.5 daemonize

是否为后台进程，设置为yes

守护进程，后台启动

#### 4.1.6 pidfile

存放pid文件的位置，每个实例会产生一个不同的pid文件

一般放在/var/run目录下



## Redis的发布和订阅

### 5.1 什么是发布和订阅

Redis 发布订阅 (pub/sub) 是一种消息通信模式：发送者 (pub) 发送消息，订阅者 (sub) 接收消息。

 Redis 客户端可以订阅任意数量的频道。

### 5.2 Redis的发布和订阅

## 6. Redis新数据类型

### 6.1 Bitmaps

#### 6.1.1 简介

本身并不是一种数据类型，本质是字符串，主要按位操作。

#### 6.1.2 命令

setbit

如果第一次

#### 6.1.3 Bitmpas与Set对比

在用户量比较大的情况下，Bitmaps可以极大节省空间。

### 6.2 HyperLogLog

#### 6.2.1 简介

在工作当中，我们经常会遇到与统计相关的功能需求，比如统计网站PV（PageView页面访问量）,可以使用Redis的incr、incrby轻松实现。

但像UV（UniqueVisitor，独立访客）、独立IP数、搜索记录数等需要去重和计数的问题如何解决？这种求集合中**不重复元素个数的问题**称为**基数问题**。

#### 命令

pfadd

pfcount

pfmerge：合并一个或多个HyperLogLog

### 6.3 Geospatial

#### 6.3.1 简介

Redis 3.2 中增加了对GEO类型的支持。GEO，Geographic，地理信息的缩写。该类型，就是元素的2维坐标，在地图上就是经纬度。redis基于该类型，提供了经纬度设置，查询，范围查询，距离查询，经纬度Hash等常见操作。

#### 6.3.2 命令

1.   geoadd

     -   两极无法直接添加，一般会下载城市数据，直接通过 Java 程序一次性导入。

     -   有效的经度从 -180 度到 180 度。有效的纬度从 -85.05112878 度到 85.05112878 度。
     -   当坐标位置超出指定范围时，该命令将会返回一个错误。
     -   已经添加的数据，是无法再次往里面添加的。

2.   geopos

3.   geodist

## 7. Jedis操作Redis6

```xml
<dependency>
    <groupId>redis.clients</groupId>
    <artifactId>jedis</artifactId>
    <version>3.2.0</version>
</dependency>
```

## 8. Redis_Jedis_实例

### 完成一个手机验证码功能

要求：

1.   输入手机号，点击发送后随机生成6位数字码，2分钟有效
2.   输入验证码，点击验证，返回成功或失败
3.   每个手机号每天只能输入3次

## 9. Redis整合SprintBoot

```xml
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-web</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-test</artifactId>
			<scope>test</scope>
		</dependency>
		<!-- redis -->
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-data-redis</artifactId>
		</dependency>
		<!-- spring2.X集成redis所需common-pool2-->
		<dependency>
			<groupId>org.apache.commons</groupId>
			<artifactId>commons-pool2</artifactId>
			<version>2.6.0</version>
		</dependency>
```

## 10. Redis\_事务\_锁机制\_秒杀

### 10.1 Redis的事务定义

Redis事务是一个单独的隔离操作：事务中的所有命令都会序列化、按顺序地执行。事务在执行的过程中，不会被其他客户端发送来的命令请求所打断。

Redis事务的主要作用就是**串联多个命令**防止别的命令插队。

### 10.2 Multi、Exec、discard

从输入`Multi`命令开始，输入的命令都会以此进入命令队列中，但不会执行，直到输入Exec后，Redis会讲之前的命令队列中的命令依次执行。

组队的过程中可以通过discard来放弃组队（类似于回滚事务，但是本质不一样）。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220809211350283.png" alt="image-20220809211350283" style="zoom:40%;" />

 **举例：**

组队成功，提交成功：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220809212103553.png" alt="image-20220809212103553" style="zoom:40%;" />

组队成功，提交成功：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220809212243165.png" alt="image-20220809212243165" style="zoom:40%;" />

组队阶段报错，提交失败：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220809213034761.png" alt="image-20220809213034761" style="zoom:40%;" />

组队成功，提交有成功有失败：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220809212600232.png" alt="image-20220809212600232" style="zoom:40%;" />

### 10.3 事务的错误处理

-   组队中某个命令出现了报告错误，执行时整个的所有队列都会被取消。

    <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220809213521714.png" alt="image-20220809213521714" style="zoom:40%;" />

-   如果执行阶段某个命令报出了错误，则只有报错的命令不会被执行，而其他的命令都会执行，不会回滚。

    <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220809213539439.png" alt="image-20220809213539439" style="zoom:40%;" />



### 10.4 事务冲突

#### 10.4.1 例子

存款共10000，同时有三个请求：

-   一个请求想给金额减8000
-   一个请求想给金额减5000
-   一个请求想给金额减1000

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220809231344637.png" alt="image-20220809231344637" style="zoom:40%;" />

产生了冲突

#### 10.4.2 悲观锁

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220809231535355.png" alt="image-20220809231535355" style="zoom:40%;" />

**悲观锁(Pessimistic Lock)**顾名思义，顾名思义，就是很悲观，每次去拿数据的时候都认为别人会修改，所以每次在拿数据的时候都会上锁，这样别人想拿这个数据就会block直到它拿到锁。**传统的关系型数据库里边就用到了很多这种锁机制**，比如**行锁，表锁等，读锁，写锁**等，都是在做操作之前先上锁。

这种锁效率很低，只能有一个操作

#### 10.4.3 乐观锁

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220809231813711.png" alt="image-20220809231813711" style="zoom:40%;" />

通过版本号去操作。所有人都能拿到数据

**乐观锁(Optimistic Lock),** 顾名思义，就是很乐观，每次去拿数据的时候都认为别人不会修改，所以不会上锁，但是在更新的时候会判断一下在此期间别人有没有去更新这个数据，可以使用版本号等机制。**乐观锁适用于多读的应用类型，这样可以提高吞吐量。Redis就是利用这种check-and-set机制实现事务的。**

可以多人同时操作，提高吞吐量。例如多人抢一张票。

#### 10.4.4 WATCH key [key ...]

`[]`代表可选项非必需。

在执行`multi`之前，先执行`watch key1 [key2]`，可以监视一个（或多个）key，如果在事务**执行前这个（或这些）key被其他命令所改动，那么事务将被打断。**

#### 10.4.5 unwatch

取消对所有的key的监视

### 10.5 Redis事务三特性

1.   单独的隔离操作
     -   事务中的所有命令都会序列化、按顺序地执行。事务在执行的过程中，不会被其他客户端发送来的命令请求所打断。 
2.    没有隔离级别的概念 
     -    队列中的命令没有提交之前都不会实际被执行，因为事务提交前任何指令都不会被实际执行
3.   不保证原子性
     -   事务中如果有一条命令执行失败，其后的命令仍然会被执行，没有回滚 

## 11. Redis事务秒杀案例

postfile：

`prodid=0101&`

 `ab -n 1000 -c 100 -p postfile -T application/x-www-form-urlencoded http://192.168.31.147:8080/Seckill/doseckill`

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220902005642788.png" alt="image-20220902005642788" style="zoom:40%;" />

在并发情况下，程序会运行失效。

还可能出现连接超时问题

1.   超卖问题

     使用乐观锁

2.   连接超时问题

     使用连接池解决



### 11.6 解决库存遗留问题

乐观锁造成的库存遗留问题。Redis默认只能使用乐观锁

#### 11.6.1 LUA脚本

Lua是一个小巧的脚本语言，可以被C/C++代码调用，一个完整的Lua解释器只有200k。

#### 11.6.2 LUA脚本在Redis中的优势

LUA脚本是类似redis事务，有一定的原子性，不会被其他命令插队，可以完成一些redis事务性的操作。

但是注意redis的lua脚本功能，只有在Redis 2.6以上的版本才可以使用。

2表示当前用户秒杀过了，0表示秒杀结束了，1表示正常秒杀。

```lua
local userid=KEYS[1]; 
local prodid=KEYS[2];
local qtkey="sk:"..prodid..":qt";
local usersKey="sk:"..prodid.":usr'; 
local userExists=redis.call("sismember",usersKey,userid);
if tonumber(userExists)==1 then 
  return 2;
end
local num= redis.call("get" ,qtkey);
if tonumber(num)<=0 then 
  return 0; 
else 
  redis.call("decr",qtkey);
  redis.call("sadd",usersKey,userid);
end
return 1;

```

## 12. Redis持久化之RDB

### 12.1 总体介绍

Redis提供了两个不同形式的持久化方式

-   RDB(Redis DataBase)
-   AOF(Append Of File)

### 12.2 RDB(Redis DataBase)

#### 12.2.2是什么

在指定的**时间间隔**内将内存中的**数据集快照**写入磁盘。

当前时间点的数据。

#### 12.2.3 如何执行备份

利用到了写时复制技术。

Redis会单独创建（fork）一个子进程来进行持久化，会先将数据写入到 一个临时文件中，待持久化过程都结束了，再用这个临时文件替换上次持久化好的文件。 整个过程中，主进程是不进行任何IO操作的，这就确保了极高的性能 如果需要进行大规模数据的恢复，且对于数据恢复的完整性不是非常敏感，那RDB方式要比AOF方式更加的高效。**RDB的缺点是最后一次持久化后的数据可能丢失**。

#### 12.2.4 Fork

RDB底层用到了写时复制技术。

#### 12.2.5 RDB持久化流程

超过这个时间范围会重新计算。

最后一次持久化后的数据可能会丢失。

##  13. Redis持久化之AOF

### 13.1 AOF(Append Only File)

#### 13.1.1 简介

**以日志形式来记录每个写操作（增量保存），**

#### 13.1.2 AOF持久化流程

1.   客户端
2.   AOF持久化策略
3.   

#### 13.1.3 AOF默认不开启

appendonly yes

如果AOF和RDB同时开启，系统默认读取AOF的数据，数据不会存在丢失。

 

可以对AOF文件进行修复，通过`/usr/local/bin/redis-check-aof-fix appendonly.aof`进行修复。

#### 13.1.6 AOF同步频率设置

-   appendfsync always ：始终同步，每次Redis的写入都会立刻记入日志；性能较差但数据完整性比较好 
-   appendfsync everysec： 每秒同步，每秒记入日志一次，如果宕机，本秒的数据可能丢失。 
-   appendfsync no ：redis不主动进行同步，把同步时机交给操作系统。

#### 13.1.7 Rewrite压缩

#### 13.1.8 优点

-   备份机制更稳健

#### 13.1.9 缺点

-   比起RDB占用更多的磁盘空间
-   恢复备份速度慢

### 13.2 总结

#### 13.2.1 

-   官方推荐两个都启用

## 14. Redis主从复制

### 14.1 简介

主机数据更新后根据配置和策略，自动同步到备机的**master/slaver机制，Master以写为主，Slave以读为主**。

### 14.2 作用

-   读写分离，性能扩展
-   容灾快速恢复

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220904010732505.png" alt="image-20220904010732505" style="zoom:40%;" />

### 14.3 如何设置

1.   拷贝多个`redis.conf`文件`include`（写绝对路径）公共部分 
2.   开启`daemonize yes`
3.   Pid文件名字pidfile
4.   指定端口port
5.   Log文件名字
6.   dump.rdb名字dbfilename
7.   Appendonly关掉或换名字

#### 14.3.1 创建3个redis.conf

配置一主两从，创建三个配置文件：

-   redis6379.conf
-   redis6379.conf
-   redis6381.conf

在从机上执行`slaveof 127.0.0.1 6379`。

### 14.4 常用3招

#### 14.4.1 一主二仆

**从服务器挂掉**

1.   从服务器挂掉重启后就变成了主服务器，而不会自动变成从服务器
2.   当从服务器重启后重新设置为从服务器，将会从头开始复制数据（也就是将主服务器中所有数据复制过来）

**主服务器挂掉**

1.   从服务器仍然是从服务器，不会变成主服务器
2.   主服务器重启之后仍然是主服务器

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220909222441419.png" alt="image-20220909222441419" style="zoom:40%;" />

**主从复制的原理**

1.   当从服务器连上主服务器后，从服务器向主服务器发送进行数据同步的消息。（从服务器发起的）
2.   **主服务器接到从服务器发送过来的同步消息，会将主服务器数据进行持久化（rdb文件），把rdb文件发送到从服务器，从服务器拿到rdb文件后进行数据读取，完成复制。**
3.   每次主服务器进行写操作之后，会与从服务器进行数据同步。（主服务器发起的）

#### 14.4.2 薪火相传

上一个Slave可以是下一个Slave的Master，Slave同样可以接收其他 Slaves的连接和同步请求，那么该Slave作为了链条中下一个的Master, 可以有效减轻Master的写压力,去中心化降低风险。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220909225850789.png" alt="image-20220909225850789" style="zoom:40%;" />



用` slaveof <ip><port>`

中途变更转向:会清除之前的数据，重新建立拷贝最新的。

缺点是一旦某个Slave宕机，后面的slave都没办法备份。

#### 14.4.3 反客为主

当一个master宕机后，后面的slave可以立刻升级为master，其后面的slave不用做任何修改。用 `slaveof no one`  将从机变为主机。

**但是这个过程还是需要手动完成。**

### 14.5 复制原理

### 14.6 哨兵模式(sentinel)

**反客为主的自动版。**该模式能后台监控主机是否故障，如果故障了根据投票数自动将从库转换为主库。

#### 14.6.1 配置过程

1.   首先配置一主二仆

     <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220909230732322.png" alt="image-20220909230732322" style="zoom:40%;" />

2.   自定义/myredis目录下新建sentinel.conf，名字绝对不能错。在sentinel.conf文件中填写

     ```conf
     sentinel monitor mymaster 127.0.0.1 6379 1
     ```

     其中mymaster为监控对象起的服务器名称， **1 为至少有多少个哨兵同意迁移的数量。** 

3.   启动哨兵`redis-sentinel /myredis/sentinel.conf `

     <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220909232253120.png" alt="image-20220909232253120" style="zoom:40%;" />

4.   当主机挂掉，从机选举中产生新的主机

     大概10s左右可以看到哨兵窗口日志，切换了新的主机，**根据优先级别`slave-priority`来选举为主机，原主机重启后变为从机。**

     <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220909232947351.png" alt="image-20220909232947351" style="zoom:40%;" />



#### 14.6.2 复制延时

由于所有的写操作都是先在Master上操作，然后同步更新到Slave上，所以从Master同步到Slave机器有一定的延迟，当系统很繁忙的时候，延迟问题会更加严重，Slave机器数量的增加也会使这个问题更加严重。

#### 14.6.3 故障恢复

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220909233241367.png" alt="image-20220909233241367" style="zoom:40%;" />

-   优先级在redis.conf中默认：slave-priority(不同版本的redis可能是replica-priority) 100，值越小优先级越高
-   偏移量是指获得原主机数据最全的
-   每个redis实例启动后都会随机生成一个40位的runid

#### 14.6.4 主从复制

```java
public static  Jedis getJedisFromSentinel(){
if(jedisSentinelPool==null){
            Set<String> sentinelSet=new HashSet<>();
            sentinelSet.add("192.168.11.103:26379");

            JedisPoolConfig jedisPoolConfig =new JedisPoolConfig();
            jedisPoolConfig.setMaxTotal(10); //最大可用连接数
jedisPoolConfig.setMaxIdle(5); //最大闲置连接数
jedisPoolConfig.setMinIdle(5); //最小闲置连接数
jedisPoolConfig.setBlockWhenExhausted(true); //连接耗尽是否等待
jedisPoolConfig.setMaxWaitMillis(2000); //等待时间
jedisPoolConfig.setTestOnBorrow(true); //取连接的时候进行一下测试 ping pong

jedisSentinelPool=new JedisSentinelPool("mymaster",sentinelSet,jedisPoolConfig);//通过哨兵模式的mymaster找到主服务器
return jedisSentinelPool.getResource();
        }else{
return jedisSentinelPool.getResource();
        }
}

```

## 15. Redis集群

### 15.1 问题

-   容量不够，redis如何进行扩容？
-   并发写，redis如何分摊？

>   都可以用集群解决

**另外，主从模式，薪火相传模式，主机宕机，导致ip地址发生变化，应用程序中配置需要修改对应的主机地址、端口等信息。**

之前通过**代理主机**来解决，但是**redis3.0**中提供了解决方案。就是**无中心化集群**配置。

**代理服务器**可以根据请求来处理服务，但是这种方式所需要的服务器太多。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910094433557.png" style="zoom:40%;" />

**无中心化集群**中任何一台服务器都可以作为集群的入口，它们之间互相连通。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910094625513.png" alt="image-20220910094625513" style="zoom:40%;" />

### 15.2 特点

Redis 集群实现了对Redis的水平扩容，即启动N个redis节点，将整个数据库分布存储在这N个节点中，每个节点存储总数据的1/N。

Redis 集群通过分区（partition）来提供一定程度的可用性（availability）： **即使集群中有一部分节点失效或者无法进行通讯， 集群也可以继续处理命令请求。**

### 15.3 删除持久化数据

删除所有的rbd、aof文件。本机路径不在`/myredis`下，而是在 `/usr/local/bin路径下。

>   问题在于配置文件属性dir ,默认配置是**dir ./  表示**启动server时候的当前目录,也就是说之前测试线启动redis服务是在 /usr/local/bin/ 目录下启动的。
>
>   **重点是 dir 的默认配置一定要改，改成绝对路径，这样就不会存在每次启动服务时所在的目录不一样导致dump文件找不到的问题**



### 15.4 搭建集群

1.   在` /usr/local/bin`路径下删除rdb、aof文件（不同配置的文件路径不同）

2.   创建6个配置文件，分别为6379,6380,6381,6389,6390,6391（后三个为前三个的slaver）

3.   redis cluster配置修改

     ```conf
     include /myredis/redis.conf
     pidfile "/var/run/redis_6379.pid"
     port 6379
     cluster-enabled yes    打开集群模式
     cluster-config-file nodes-6379.conf  设定节点配置文件名
     cluster-node-timeout 15000   设定节点失联时间，超过该时间（毫秒），集群自动进行主从切换。
     
     ```

4.   copy 6 份，并修改为具体端口号的内容 ，使用`:%s/6379/63XX`

5.   启动6个redis服务，节点配置文件在`/usr/local/bin`

6.   合体

     1.   首先进入最开始的redis目录下的src：`cd /opt/redis-6.2.1/src`

     2.   ```shell
          redis-cli --cluster create --cluster-replicas 1 192.168.31.242:6379 192.168.31.242:6380 192.168.31.242:6381 192.168.31.242:6389 192.168.31.242:6390 192.168.31.242:6391
          ```

     3.   **注意此处不要用127.0.0.1，请用真实IP地址；`-replicas 1` 采用最简单的方式配置集群，一台主机，一台从机，正好三组。**

     4.   出现`[OK] All 16384 slots covered.`

### 15.5 集群操作

1.   使用`-c`开启集群策略连接，`redis-cli -c -p 6379`，可以连接任意一个节点。

2.   通过 `cluster nodes` 命令查看集群信息

     <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910110052040.png" alt="image-20220910110052040" style="zoom:40%;" />

### 15.6 redis cluster如何分配这六个节点

一个集群至少要有三个主节点。

选项 `--cluster-replicas 1` 表示我们希望为集群中的每个主节点创建一个从节点。

**分配原则尽量保证每个主数据库运行在不同的IP地址，每个从库和主库不在一个IP地址上。**

### 15.7 slots

一个 Redis 集群包含 16384 个插槽（hash slot）， 数据库中的每个键都属于这 16384 个插槽的其中一个， 

集群使用公式 `CRC16(key) % 16384` 来计算键 key 属于哪个槽， 其中 CRC16(key) 语句用于计算键 key 的 CRC16 校验和 。

集群中的每个节点负责处理一部分插槽。 举个例子， 如果一个集群可以有主节点， 其中：

节点 A 负责处理 0 号至 5460 号插槽。

节点 B 负责处理 5461 号至 10922 号插槽。

节点 C 负责处理 10923 号至 16383 号插槽。

>   类似于散列表，平均分担压力

### 15.8 在集群中录入值

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910150103880.png" alt="image-20220910150103880" style="zoom:40%;" />

不在一个slot下的key-value，**不能使用mget、mset等多键操作。**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910150201072.png" alt="image-20220910150201072" style="zoom:40%;" />



可以通过`{}`来定义组的概念，从而使key中`{}`内相同内容的键值对放到一个slots中去。

```redis
mset name{user} lucy age{user} 20
```

`user`是组的名字。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910150413616.png" alt="image-20220910150413616" style="zoom:40%;" />

#### 查询集群中key的插槽值

`CLUSTER GETKEYSINSLOT <slot><count> `返回 count 个 slot 槽中的键。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910150619228.png" alt="image-20220910150619228" style="zoom:40%;" />

####  查询集群中的值

`CLUSTER GETKEYSINSLOT <slot><count>` 返回 count 个 slot 槽中的键。



### 15.9 故障恢复

如果主节点6379下线，则从节点6379自动升为主节点；若6379恢复，则主节点回来变成从节点。

通过`cluster nodes`查看节点关系。

如果所有某一段插槽的主从节点都宕掉，redis服务是否还能继续? **要看配置文件！**

如果某一段插槽的主从都挂掉，而`cluster-require-full-coverage` 为yes ，那么 ，整个集群都挂掉

如果某一段插槽的主从都挂掉，而cluster-require-full-coverage 为no ，那么，该插槽数据全都不能使用，也无法存储。

redis.conf中的参数 `cluster-require-full-coverage`

### 15.10 集群的Jedis开发

即使连接的不是主机，集群会自动切换主机存储。主机写，从机读。

无中心化主从集群。无论从哪台主机写的数据，其他主机上都能读到数据。

```java
public class JedisClusterTest {
  public static void main(String[] args) { 
     Set<HostAndPort>set =new HashSet<HostAndPort>();
     set.add(new HostAndPort("192.168.31.242",6379)); //无中心化，用任何一个节点都可以执行
     JedisCluster jedisCluster=new JedisCluster(set);
     jedisCluster.set("k1", "v1");
     System.out.println(jedisCluster.get("k1"));
  }
}

```

### 15.11 Redis集群的优缺点

优点：

-   实现扩容
-   分摊压力
-   无中心化配置相对简单

缺点：

-   多键操作是不被支持的
-   多键的Redis事务是不被支持的；Lua脚本不被支持
-   由于集群方案出现较晚，很多公司已经采用了其他的集群方案，而代理或者客户端分片的方案想要迁移至redis cluster，需要整体迁移而不是逐步过渡，复杂度较大。

## 16. Redis 应用问题解决

### 16.1 缓存穿透

#### 16.1.1 问题描述 

key对应的数据在数据源并不存在，每次针对此key的请求从缓存获取不到，请求都会压到数据源，从而可能压垮数据源。比如用一个不存在的用户id获取用户信息，不论缓存还是数据库都没有，若黑客利用此漏洞进行攻击可能压垮数据库。

总而言之：

1.   redis查询不到数据库
2.   出现很多非正常URL访问

最终可能导致服务器崩溃。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910152844876.png" alt="image-20220910152844876" style="zoom:40%;" />

**两个现象：**

1.   应用服务器压力突然变大

2.   redis命中率降低

     缓存中查不到数据，一直到数据库中查询

#### 16.1.2 解决方案

一个一定不存在缓存及查询不到的数据，由于缓存是不命中时被动写的，并且出于容错考虑，如果从存储层查不到数据则不写入缓存，这将导致这个不存在的数据每次请求都要到存储层去查询，失去了缓存的意义。

1.   **对空值缓存：**如果一个查询返回的数据为空（不管是数据是否不存在），我们仍然把这个空结果（null）进行缓存，设置空结果的过期时间会很短，最长不超过五分钟。**这是一种临时方案。**

2.   **设置可访问的名单（白名单）：**使用bitmaps类型定义一个可以访问的名单，名单id作为bitmaps的偏移量，每次访问和bitmap里面的id进行比较，如果访问id不在bitmaps里面，进行拦截，不允许访问。**缺点是效率不高**

3.   **采用布隆过滤器：**  (布隆过滤器（Bloom Filter）是1970年由布隆提出的。它实际上是一个很长的二进制向量(位图)和一系列随机映射函数（哈希函数）。

     布隆过滤器可以用于检索一个元素是否在一个集合中。它的优点是空间效率和查询时间都远远超过一般的算法，缺点是有一定的误识别率和删除困难。)

     **布隆过滤器的命中可能不准确。**

4.   **对Redis进行实时监控：**当发现Redis的命中率开始急速降低，需要排查访问对象和访问的数据，和运维人员配合，可以设置黑名单限制服务。

>   一般这种情况是黑客攻击，还可以报警，让网警帮忙。

### 16.2 缓存击穿

#### 16.2.1 问题描述

key对应的数据存在，但在redis中过期，此时若有大量并发请求过来，这些请求发现缓存过期一般都会从后端DB加载数据并回设到缓存，这个时候大并发的请求可能会瞬间把后端DB压垮。

条件：

1.   数据库访问压力瞬时增加
2.   redis中没有出现大量key过期
3.   redis正常运行

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910153618544.png" alt="image-20220910153618544" style="zoom:40%;" />

原因：

1.   redis中某个key过期了，而有大量访问使用这个key

#### 16.2.2 解决方案

key可能会在某些时间点被超高并发地访问，是一种非常“热点”的数据。这个时候，需要考虑一个问题：缓存被“击穿”的问题。

1.   **预先设置热门数据：**在redis高峰访问之前，把一些热门数据提前存入到redis里面，加大这些热门数据的key时长。

2.   **实时调整：**现场监控哪些数据热门，实时调整key的过期时长

3.   **使用锁：**

     1.   在缓存失效的时候（判断拿出来的值为空），不是立即去load db
     2.   先使用缓存工具的某些带成功操作返回值的操作（例如Redis的SETNX）去set一个mutex key
     3.   当操作返回成功时，再进行load db的操作，并回设缓存，最后删除mutex key
     4.   当操作返回失败，证明有线程在load db，当前线程睡眠一段时间再重试整个get缓存的方法。

     <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910154257859.png" alt="image-20220910154257859" style="zoom:40%;" />

     >   注意区别缓存穿透和缓存击穿

### 16.3 缓存雪崩

#### 16.3.1 问题描述

现象：

1.   数据库压力变大
2.   服务器崩溃

原因：

1.   **在极少时间段内，查询大量key的集中过期情况**

key对应的数据存在，但在redis中过期，此时若有大量并发请求过来，这些请求发现缓存过期一般都会从后端DB加载数据并回设到缓存，这个时候大并发的请求可能会瞬间把后端DB压垮。

缓存雪崩与缓存击穿的区别在于这里针对很多key缓存，前者则是某一个key。

**正常访问：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910155238333.png" alt="image-20220910155238333" style="zoom:40%;" />

**缓存失效瞬间：**

<img src="/Users/heyufan1/Library/Application Support/typora-user-images/image-20220910155300234.png" alt="image-20220910155300234" style="zoom:40%;" />

#### 16.3.2 解决方案

缓存失效时的雪崩效应对底层系统的冲击非常可怕！

解决方案：

1.   **构建多级缓存架构：**nginx缓存 + redis缓存 +其他缓存（ehcache等）
2.   **使用锁或队列：**用加锁或者队列的方式保证来保证不会有大量的线程对数据库一次性进行读写，从而避免失效时大量的并发请求落到底层存储系统上。不适用高并发情况。
3.   **设置过期标志更新缓存：**记录缓存数据是否过期（设置提前量），如果过期会触发通知另外的线程在后台去更新实际key的缓存。
4.   **将缓存失效时间分散开**：比如我们可以在原有的失效时间基础上增加一个随机值，比如1-5分钟随机，这样每一个缓存的过期时间的重复率就会降低，就很难引发集体失效的事件。



### 16.4 分布式锁

#### 16.4.1 问题描述

随着业务发展的需要，原单体单机部署的系统被演化成分布式集群系统后，由于分布式系统多线程、多进程并且分布在不同机器上，这将使原单机部署情况下的并发控制锁策略失效，单纯的Java API并不能提供分布式锁的能力。为了解决这个问题就需要一种**跨JVM的互斥机制来控制共享资源的访问**，这就是分布式锁要解决的问题！

通俗来说，就是需要一把能对集群中所有机器都有效的锁！

**分布式锁主流的实现方案：**

1.   基于数据库实现分布式锁
2.   基于缓存（Redis等）
3.   基于Zookeeper

**每一种分布式锁解决方案都有各自的优缺点：**

1.   性能：Redis最高
2.   可靠性：Zookeeper最高

我们基于Redis实现分布式锁

#### 16.4.2 使用Redis实现分布式锁

1.   设置锁使用`setnx`
2.   释放锁使用`del`
3.   使用`expire`设置key过期时间自动释放，但这个命令和`setnx`放在一起不是原子操作
4.   上锁的时候同时设置过期时间：`set <key> <value> nx ex <secends>`

#### 16.4.3 Code

Redis: set num 0

同时关闭Redis集群。

```java
	@GetMapping("testLock")
	public void testLock(){
		//1获取锁，setne
		Boolean lock = redisTemplate.opsForValue().setIfAbsent("lock", "111");
		//2获取锁成功、查询num的值
		if(lock){
			Object value = redisTemplate.opsForValue().get("num");
			//2.1判断num为空return
			if(StringUtils.isEmpty(value)){
				return;
			}
			//2.2有值就转成成int
			int num = Integer.parseInt(value + "");
			//2.3把redis的num加1
			redisTemplate.opsForValue().set("num", ++num);
			//2.4释放锁，del
			redisTemplate.delete("lock");

		}else{
			//3获取锁失败、每隔0.1秒再获取
			try {
				Thread.sleep(100);
				testLock();
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
```

##### **设置过期时间**

```java
		Boolean lock = redisTemplate.opsForValue().setIfAbsent("lock", "111",3, TimeUnit.SECONDS);

```

**压力测试**

```shell
ab -n 1000 -c 100 http://192.168.31.147:8080/redisTest/testLock
```



##### **UUID防误删除**

场景：如果业务逻辑的执行时间是7s。执行流程如下

1.   index1业务逻辑没执行完，3秒后锁被自动释放。
2.   index2获取到锁，执行业务逻辑，3秒后锁被自动释放。
3.   index3获取到锁，执行业务逻辑
4.   index1业务逻辑执行完成，开始调用del释放锁，这时释放的是index3的锁，导致index3的业务只执行1s就被别人释放。

最终等于没锁的情况。

 

>    解决：setnx获取锁时，设置一个指定的唯一值（例如：uuid）；释放前获取这个值，判断是否与自己的锁的uuid相同

1.   设置UUID

     ```java
     String uuid = UUID.randomUUID().toString();
     		//1获取锁，setne
     		Boolean lock = redisTemplate.opsForValue().setIfAbsent("lock", uuid,3, TimeUnit.SECONDS);
     ```

2.   判断

     ```java
     //判断UUID是否相同
     String localUUID = (String) redisTemplate.opsForValue().get("lock");
     if(localUUID.equals(uuid)){
         redisTemplate.delete("lock");
     }
     ```



##### LUA脚本保证删除的原子性

我们需要上锁和释放之间的操作具有原子性，如果某个请求在规定时间内没有完成操作，锁到了过期时间会自动释放，这是不行的。

LUA脚本支持脚本操作，我们可以使用LUA脚本来保证原子性。

```java
@GetMapping("testLockLua")
public void testLockLua() {
    //1 声明一个uuid ,将做为一个value 放入我们的key所对应的值中
    String uuid = UUID.randomUUID().toString();
    //2 定义一个锁：lua 脚本可以使用同一把锁，来实现删除！
    String skuId = "25"; // 访问skuId 为25号的商品 100008348542
    String locKey = "lock:" + skuId; // 锁住的是每个商品的数据

    // 3 获取锁
    Boolean lock = redisTemplate.opsForValue().setIfAbsent(locKey, uuid, 3, TimeUnit.SECONDS);

    // 第一种： lock 与过期时间中间不写任何的代码。
    // redisTemplate.expire("lock",10, TimeUnit.SECONDS);//设置过期时间
    // 如果true
    if (lock) {
        // 执行的业务逻辑开始
        // 获取缓存中的num 数据
        Object value = redisTemplate.opsForValue().get("num");
        // 如果是空直接返回
        if (StringUtils.isEmpty(value)) {
            return;
        }
        // 不是空 如果说在这出现了异常！ 那么delete 就删除失败！ 也就是说锁永远存在！
        int num = Integer.parseInt(value + "");
        // 使num 每次+1 放入缓存
        redisTemplate.opsForValue().set("num", String.valueOf(++num));
        /*使用lua脚本来锁*/
        // 定义lua 脚本
        String script = "if redis.call('get', KEYS[1]) == ARGV[1] then return redis.call('del', KEYS[1]) else return 0 end";
        // 使用redis执行lua执行
        DefaultRedisScript<Long> redisScript = new DefaultRedisScript<>();
        redisScript.setScriptText(script);
        // 设置一下返回值类型 为Long
        // 因为删除判断的时候，返回的0,给其封装为数据类型。如果不封装那么默认返回String 类型，
        // 那么返回字符串与0 会有发生错误。
        redisScript.setResultType(Long.class);
        // 第一个要是script 脚本 ，第二个需要判断的key，第三个就是key所对应的值。
        redisTemplate.execute(redisScript, Arrays.asList(locKey), uuid);
    } else {
        // 其他线程等待
        try {
            // 睡眠
            Thread.sleep(1000);
            // 睡醒了之后，调用方法。
            testLockLua();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```

##### 总结为了确保分布式锁可用，我们至少要确保锁的实现同时**满足以下四个条件**：

- 互斥性。在任意时刻，只有一个客户端能持有锁。

- 不会发生死锁。即使有一个客户端在持有锁的期间崩溃而没有主动解锁，也能保证后续其他客户端能加锁。

- 解铃还须系铃人。加锁和解锁必须是同一个客户端，客户端自己不能把别人加的锁给解了。

- 加锁和解锁必须具有原子性。

## 17. Redis6.0 新功能

### 17.1 ACL(Access Control List)

#### 17.1.1 简介

Redis ACL是Access Control List（访问控制列表）的缩写，该功能允许根据可以执行的命令和可以访问的键来限制某些连接。

在Redis 5版本之前，Redis 安全规则只有密码控制 还有通过rename 来调整高危命令比如 flushdb ， KEYS* ， shutdown 等。Redis 6 则提供ACL的功能对用户进行更细粒度的权限控制 ：

1.   接入权限:用户名和密码 
2.   可以执行的命令 
3.   可以操作的 KEY

#### 17.1.2 命令

1.   使用`acl list`命令现实用户权限列表

     <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910203104475.png" alt="image-20220910203104475" style="zoom:40%;" />

2.   使用`acl cat`命令

     1.   查看添加权限指令类别
     2.   加参数类型名可以查看类型下具体命令

3.   使用`acl whoami`命令查看当前用户

4.   使用`acl setuser`命令创建和编辑用户

     <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910203316814.png" alt="image-20220910203316814" style="zoom:33%;" />

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910203519733.png" alt="image-20220910203519733" style="zoom:40%;" />

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910203536363.png" alt="image-20220910203536363" style="zoom:40%;" />



### 17.2 IO多线程

#### 17.2.1 简介

IO多线程其实指**客户端交互部分**的**网络IO**交互处理模块**多线程**，而非**执行命令多线程**。Redis6执行命令依然是单线程。

#### 17.2.2 原理架构

Redis 6 加入多线程,但跟 Memcached 这种从 IO处理到数据访问多线程的实现模式有些差异。Redis 的多线程部分只是用来处理网络数据的读写和协议解析，执行命令仍然是单线程。之所以这么设计是不想因为多线程而变得复杂，需要去控制 key、lua、事务，LPUSH/LPOP 等等的并发问题。整体的设计大体如下:

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220910203639120.png" alt="image-20220910203639120" style="zoom:40%;" />

另外，多线程IO默认也是不开启的，需要再配置文件中配置：

```conf
io-threads-do-reads yes 

io-threads 4
```



### 17.3 工具支持 Cluster

之前老版Redis想要搭集群需要单独安装ruby环境，Redis 5 将 redis-trib.rb 的功能集成到 redis-cli 。另外官方 redis-benchmark 工具开始支持 cluster 模式了，通过多线程的方式对多个分片进行压测。
