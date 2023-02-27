# 12 Nginx核心源码

>   提炼有用的代码，放入自己的知识库。



## 1. nginx简介、选择理由、安装和使用

### 1.1nginx简介

nginx是一个web服务器，性能相当优秀，市场份额排在第二位，仅次于出现的最早的Apache。

它可以作为Web服务器，反向代理，负载均衡，邮件代理，所以经常被称为轻量级服务器。纯C语言编写的，并且开源。

nginx号称并发处理百万级别的TCP连接，非常稳定，支持热部署（运行时能升级），高度模块化设计，可以开发自己的模块来增强nginx。第三方业务模块可以用C++开发。

不同平台下nginx可能代码不同，Linux有epool技术，windows使用IOCP。





### 1.2 选择理由

-   单机10万并发，并且同时能够保持高效的服务，nginx充分挖掘了linux的性能，使用epoll技术，高并发只是占用更多内存就能做到。
-   使用了：内存池、进程池、线程池、事件驱动等。
-   学习这种大师级别的代码



### 1.3 安装nginx，搭建web服务器

#### 1.3.1 **安装前提**

-   epoll 内核版本为2.6或者以上
-   gcc编译器、g++编译器
-   pcre库：函数库，支持解析正则表达式
-   zlib库：压缩解压缩功能



#### 1.3.2 **nginx源码下载和目录结构**

nginx官网：[http://www.nginx.org](http://www.nginx.org)



nginx的几个版本：

-   mainline版本：版本号中间数字一般为奇数。更新快，一个月内就会发布一个新版本，有最新功能，bug修复等，稳定性差一点
-   stable版本：稳定版本，版本号中间数字一般为偶数版本，经过了长时间的测试，比较稳定，这种版本发布周期长
-   Legacy版本：遗留版本，以往发布的稳定版或者mainline版本



安装方式：

-   可以通过命令行直接安装二进制版本，但是不灵活，不好添加第三方模块
-   通过编译nginx版本可以把第三方模块加载进来

下载路径：[https://nginx.org/download/nginx-1.14.2.tar.gz](https://nginx.org/download/nginx-1.14.2.tar.gz)



源码树形结构图：

```
.
├── auto
├── CHANGES
├── CHANGES.ru
├── conf
├── configure
├── contrib
├── html
├── LICENSE
├── man
├── README
└── src
```

-   `auto/`：编译相关的脚本，可以执行文件configure会用到这些脚本
    -   `cc/`：检查编译器的脚本
    
    -   `lib/`：检查依赖类型的脚本
    
    -   `os/`：检查操作系统类型的脚本
    
    -   `type/`：检查平台类型的脚本
    
-   `CHANGES`：这个版本修复的bug，新增的功能
-   `CHANGES.ru`：俄语版CHANGES
-   `conf/`：默认的配置文件
-   `configure`：编译nginx前必须编译此脚本，生成一些必要的中间文件
-   `contrib/`：脚本和工具，例如vim高亮工具
-   `html/`：两个缺省的html页面，一个index.html,一个错误的50x.html
-   `LICENSE`：协议
-   `man/`：帮助文档
-   `objs/`：执行了configure生成的中间文件目录
    -   `ngx_modules.c`中的内容决定了我们编译nginx的时候会有哪些模块呗编译到nginx中来
-   `Makefile`：编译规则文件，执行`make`命令时用到
-   `src/`：nginx源代码目录
    -   `core/`：核心代码
    -   `event/`：事件模块代码
    -   `http/`：http（web服务）模块相关代码
    -   `mail`：邮件模块相关代码
    -   `os`：系统相关代码
    -   `stream`：流处理相关代码


#### 1.3.3 nginx编译和安装

1.   执行`configure`来进行编译之前的配置工作，生成一个`objs`目录

     使用`./configure --help`查看参数：

     -   `--prefix`：指定最终安装的目录，默认值`/usr/local/nginx`，是下面所有路径的根目录
     -   `--sbin-path`：指定可执行文件目录，默认是`sbin/nginx`
     -   `--conf-path`：用来指定配置文件了目录，默认是`conf/nginx.d`
     -   `-with-xxx`：xxx模块默认不会加载到nginx中，需要加上这个参数才加载到nginx
     -   `-without-xxx`：xxx模块默认会加载到nginx中，加上这个参数则不会加载到nginx

2.   `make`编译，在`objs/`下生成nginx可执行文件

3.   `make install`安装，把可执行文件和配置文件拷贝到指定目录下，也就是`/usr/local/nginx`



#### 1.3.4 nginx的启动和简单使用

进入`/usr/local/nginx/sbin`，`sudo ./nginx`，默认监听的是80端口。

使用`ps -ef | grep nginx`：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230227143614535.png" alt="image-20230227143614535" style="zoom:50%;" />

-   `worker process`：把html的内容发送到客户端
-   `master process`：可能就是监听80端口的进程



## 2. nginx整体结构、进程模型

### 2.1 nginx整体结构

#### 2.1.1 master进程和worker进程

使用`ps -ef | grep nginx`：

1.   第一列代表进程所属用户：

     启动后nginx有一个master进程和一个worker进程，worker进程属于`nobody`用户，权限很低，防止被入侵。master进程属于`root`用户。

2.    第二列是pid，

3.    第三列是ppid（父进程id）：

      worker进程是master进程用`fork()`函数创建出来的。


#### 2.1.2 nginx进程模型

一个master进程，一到多个worker进程，这种工作机制来对外服务的，这种工作机制保证了nginx**稳定、灵活**地运行。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230227145702098.png" alt="image-20230227145702098" style="zoom:40%;" />

master进程：

-   负责监控，不处理具体业务，专门用来管理和监控worker进程，角色是监工，比较清闲

worker进程：

-   用来处理业务

master和worker之间的通信：

-   信号
-   共享内存

稳定性体现之一：

-   master进程能发现worker进程挂了，能迅速`fork()`出一个新的worker进程，worker进程的数量由配置文件指定。



#### 2.1.3 调整worker进程数量

worker进程几个合适呢？

公认做法：多核计算机，就让每个worker运行在一个单独的内核上，最大限度地减少CPU进程切换的成本，提高系统效率。

>   查看CPU是几核的：
>
>   M1是8核。也就是8个processor，而不是8个CPU。
>
>   `grep -c processor /proc/cpuinfo`

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230227153046069.png" alt="image-20230227153046069" style="zoom:50%;" />

例如上图某个工作站，有两个CPU，每个CPU有4个core，每个core还能有虚拟出两个逻辑处理器（超线程技术/sigbling），每个逻辑处理器就是一个processor（最细小的单位，也就是处理器的个数）。



在`/usr/local/nginx/conf/nginx.conf`文件中修改`worker_processes  2;`，再次启动nginx，发现存在两个worker 进程。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230227154611304.png" alt="image-20230227154611304" style="zoom:40%;" />

### 2.2 进一步了解nginx进程模型

一个master进程多个worker进程的进程模型优点：「稳定+灵活」。

#### 2.2.1 nginx重载配置文件

nginx可以在不重启的情况下对服务器进行升级，客户端没有感知。

-   修改`/usr/local/nginx/conf/nginx.conf`文件
-   `./nginx -s reload`
    -   `-s`代表发送一个信号:`send signal to a master process: stop, quit, reopen, reload`

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230227155405103.png" alt="image-20230227155405103" style="zoom:40%;" />

可以看到worker进程的pid被修改了，但是master进程没有变化。

#### 2.2.2 nginx热升级

如果要更新nginx服务器，不想中止原来的服务，这种技术叫「热升级」，nginx甚至还可以降版本，（热回滚）。需要master和worker的通信。

#### 2.2.3 nginx的关闭

可以直接`kill`掉master进程。

也可以：
- `./nginx -s stop`：暴力退出
- ``./nginx -s quit`：不接受新连接退出。

#### 2.2.4 总结

为什么不用多线程模型？多线程模型的弊端：

多线程是共享内存的，如果某个线程报错，一定会影响其他线程，导致整个服务器程序崩溃。



## 3. nginx学习方法

### 3.1 准备过程

源码在`src/`目录下，使用VSCode查看源码。

**nginx源码入口函数：**

`src/core/nginx.c`



创建一个自己的linux下的c语言程序：`/root/cpp_code/nginx/nginx.c`。



### 3.2 nginx源码学习方法

