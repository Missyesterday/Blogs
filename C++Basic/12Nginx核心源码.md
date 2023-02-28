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



## 3. 学习之前需要掌握

### 3.1 准备过程

源码在`src/`目录下，使用VSCode查看源码。

**nginx源码入口函数：**

`src/core/nginx.c`



创建一个自己的linux下的c语言程序：`/root/cpp_code/nginx/nginx.c`。

### 3.2 终端和进程的关系

#### 3.3.1 终端

bash, zsh等同理。

每多一个新连接，都会有一个`-bash`进程，`pts`代表「虚拟终端」，每连接一个虚拟终端到linux操作系统，就会出现一个bash进程(shell)，用来解释用户输入的命令。

shell本质上也是一个可执行程序运行产生的进程



#### 3.3.2 终端上开启进程

运行的进程就是终端的子进程。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230227214025076.png" alt="image-20230227214025076" style="zoom:40%;" />



每一个进程还属于一个进程组：一个或者多个进程的集合。每一个进程组有一个唯一的进程组ID，可以调用系统函数来创建进程组，加入进程组

session（会话）就是进程组的集合。只要不进行特殊的系统函数调用，一般一个bash上的所有进程都属于一个会话，而这个会话有一个session leader，一般这个shell就是 session leader，可以通过系统调用增加session

```bash
ps -eo pid,ppid,sid,tty,pgrp,comm | grep -E 'bash|PID|nginx'
```

-   如果关闭终端，系统会发送`SIGHUP`信号（终端断开信号），给session leader，也就是这个bash进程
-   bash进程收到`SIGHUP`信号后，会把这个信号发送给session中的所有进程



#### 3.3.4 strace工具

这是一个Linux下调试分析诊断工具：可以跟踪程序执行时进程的系统调用以及所收到的信号；

-   跟踪`nginx`进程：`strace -e trace=signal -p 11184`（可以想象成贴一块膏药到进程上），发送SIGHUP给所在进程组（可能只有一个进程）

`strace`输出：

```bash
+++ killed by SIGHUP +++
```



如果关闭一个shell，则bash先把SIGHUP发送给同一个session中所有进程，然后发送`SIGHUP`给自己。



#### 3.3.5 终端关闭时如何让进程不退出



**忽略`SIGHUP`信号**

我们可以通过忽略`SIGHUP`信号，使得终端关闭，进程依然执行，同时该进程的ppid变成1。

```cpp

 //忽略SIGHUP信号,设置某个信号来的时候处理程序。
 //SIG_IGN: 要求忽略这个信号，请操作系统不要用缺省的方式对待本进程（不要杀掉我）
 signal(SIGHUP, SIG_IGN);

```



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230227223431253.png" alt="image-20230227223431253" style="zoom:40%;" />



**设置一个新的session id**

```cpp

    else if(pid == 0)
    {
        //子进程
        setsid();
        for(;;)
        {
        printf("子进程休息一秒\n");
        sleep(1);
        }
    }
    else if(pid > 0)
    {
        //父进程
        setsid();//父进程的setsid()无效
        for(;;)
        {

        printf("父进程休息一秒\n");
        sleep(1);
        }

    }

```



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230227233945464.png" alt="image-20230227233945464" style="zoom:50%;" />

可以看到两个`nginx`进程，只有一个有新的`sid`，而另一个的`sid`和某个zsh相同。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230227234059256.png" alt="image-20230227234059256" style="zoom:50%;" />

关闭执行`nginx`的zsh，子进程依然存在！成为孤儿进程，PPID为1。

也可以使用`setsid`命令，而且能够使启动的进程在一个新的session中，这样终端关闭时该进程就不会退出

```bash
setsid ./nginx
```

这样进程的sid pid都与之前的无关：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230227234831946.png" alt="image-20230227234831946" style="zoom:50%;" />



**nohup**

`nohup` 也可以忽略`SIGHUP`信号，与之前的忽略`SIGHUP`信号道理相同，用于在后台运行一个命令，即使用户退出登录或关闭终端窗口，命令也能够继续运行，它会把输出重定位到`nohup.out`文件中。只有关闭终端才会出现孤儿进程的效果，没有关闭终端和正常进程一样。



#### 3.3.6 后台运行 `&`

在命令后加一个`&`就是后台运行，在执行的同时终端可以干其他事。

`fg`可以切换到前台。



### 3.3 信号的概念、认识、处理动作

#### 3.3.1 信号的基本概念

进程之间常用通信手段：发送信号，例如`SIGHUP`信号，`kill`命令。nginx很多内容都依赖于信号，例如：热升级等。

-   信号用来通知某一个进程发生了某一个事情：
    -   事情，信号都是突发事件，也就是说信号是「异步发生」的，信号也被称为「软中断」。



**信号如何产生：**

-   某一个进程发送给另外一个进程或者发送给自己；
-   由内核（操作系统）发送给某个进程
    -   在键盘上输入命令`Ctrl + c`，发送一个中断信号，或者`kill`命令
    -   内存访问异常（例如除数为零），硬件都会检测并且通知内核



**信号的名字：**

-   都是以`SIG`开头，UNIX以及类UNIX操作系统（Linux、freebsd、solaris）所支持的信号各不相同，在10到64个之间。

-   信号既有名字，其实也是一些数字，信号是一些正整数常量，需要引入`#include <signal.h>``

-   ``gcc`搜索头文件的路径：

    -   `/usr/local/include/`
    -   `/usr/local/`

-   `gcc`搜索库文件

    -   `/usr/`等

-   在根路径下搜索`signal.h`文件，并在「文件内容」中搜索`SIGHUP`在第几行：

    ```bash
    find / -name "signal.h" | xargs grep -in "SIGHUP"
    ```

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228133128968.png" alt="image-20230228133128968" style="zoom:50%;" />

信号就是一些宏定义，从1开始。



#### 3.3.2 `kill`命令

`kill`命令可以杀死进程，但是有个误解，`kill`的工作是发送信号给进程，而不是所谓「杀死」，如果自己的程序没有特殊处理，操作系统对信号由默认动作，绝大多数都是直接杀死进程，但是例如`SIGSTOP`和`SIGTSP`就是放入后台。

-   `kill`能给进程发送「所有的信号」，默认发送`SIGTERM`（15），可以通过`strace -e trace=signal -p pid`追踪。
-   `kill -n pid`：给pid进程发送n信号。



**重要信号：**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228135349918.png" alt="image-20230228135349918" style="zoom:50%;" />

`-9 SIGKILL`是代码不能处理的信号。同时`-18`继续运行也是在后台运行，需要`fg`。



#### 3.3.3 进程的状态

>    aux是BSD风格显示格式，

进程状态及其含义，`ps`命令的`STAT`列：

| 状态 | 含义                                                      |
| ---- | --------------------------------------------------------- |
| D    | 不可中断的休眠状态(通常是I/O的进程)，可以处理信号，有延迟 |
| R    | 可执行状态&运行状态(在运行队列里的状态)                   |
| S    | 可中断的休眠状态之中（等待某事件完成），可以处理信号      |
| T    | 停止或被追踪（被作业控制信号所停止）                      |
| Z    | 僵尸进程                                                  |
| X    | 死掉的进程                                                |
| <    | 高优先级的进程                                            |
| N    | 低优先级的进程                                            |
| L    | 有些页被锁进内存                                          |
| s    | Session  leader（进程的领导者），在它下面有子进程         |
| t    | 追踪期间被调试器所停止                                    |
| +    | 位于前台的进程组                                          |

 

#### 3.3.4 信号处理的相关动作

当某个信号出现时，我们可以按三种方式进行「信号处理」：

1.   执行系统默认动作，绝大部分都是杀死这个进程，少数是停止，或者继续运行
2.   忽略此信号，例如`signal(SIGHUP, SIG_IGN);`就是忽略`SIGHUP`信号，但是`SIGKILL`和`SIGSTOP`无法被忽略或者被捕捉
3.   捕捉该信号，写一个处理函数，信号来的时候用处理函数来处理，当然对`SIGKILL`和`SIGSTOP`无效。



### 3.4 Unix/Linux体系结构、信号变成初步

#### 3.4.1 Unix/Linux操作系统体系结构

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228144208636.png" alt="image-20230228144208636" style="zoom:50%;" />

类Unix操作系统分为两个状态：

1.   用户态
2.   内核态



-   操作系统/内核：用来控制计算机硬件资源，提供应用程序运行的环境。

    程序要么运行在用户态，用么运行在内核态，一般来说运行在用户态，当程序要执行一些「特殊代码」的时候，程序就可能切换到内核态，这种切换由操作系统控制，不需要人为控制。

    也就是说用户态就是最外圈的活动空间。

-   系统调用：一些系统函数（大概200～300个库函数），只需要调用系统函数接口

-   bash和shell的关系：

    -   bash：borne again shell（重新装配的shell），是shell的一种，linux默认用bash，可以改成zsh等

        -   bash也是一个可执行程序，主要作用是：把用户输入的命令翻译给操作系统（命令解释器）
        -   可以在bash上再执行bash，此时`exit`就会退出最上层的bash
        -   bash分隔系统调用和应用程序，有「胶水」的感觉；
    
-   用户态和内核态的切换：

    -   运行于用户态的进程可以执行的操作和访问的资源会受到限制（用户态权限小）
    -   而运行在内核态的进程可以执行任何操作并且在资源的使用上没有限制（内核态权限大）
    -   进程执行的时候大部分时间处于用户态，只有需要内核提供服务时才会切换到内核态，内核态做完事情后，又回到用户态
    -   `malloc()`和`printf()`都会切换，这种状态是操作系统干的，不需要人为介入



>   为什么要区分内核态和用户态：
>
>   -   一般情况下，程序都运行在用户态，权限小，不至于危害到系统的其他部分；当需要进行一些危险操作的时候，系统提供接口来操作
>
>   -   既然这些接口是系统提供的，那么这些接口也是操作系统统一管理的，资源是有限的，如果大家都来访问这些资源，不加以管理，会出现「访问冲突」和「访问资源耗尽导致系统崩溃」。系统提供这些接口，就是为了减少有限的资源的访问和使用上的冲突。例如经典的「卖票问题」：
>
>       <img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228150001535.png" alt="image-20230228150001535" style="zoom:50%;" />
>       
>       



**什么时候出现用户态切换到内核态？**

-   系统调用，例如调用`malloc()`
-   异常时间，比如来了个信号
-   外围设备中断



#### 3.4.2 `signal`函数

信号来了之后，可以忽略，可以捕捉，利用`signal()`来处理这个事情。



**c3/nginx3_4_1.c**

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <errno.h>

int g_mysign = 0;
//这个函数能够修改这个全局变量g_mysign的值
//这是一个不可重入函数
void muNEfunc(int value)
{
    //.....其他处理代码
    g_mysign = value;
    //.....其他处理代码
}

//信号处理函数,系统调用的时候会自动把信号的值传递过来
void sig_usr(int signo)
{
    //int tmpsign = g_mysign;
    muNEfunc(22); //因为一些实际需求必须要在sig_user这个信号处理函数里调用muNEfunc

    int myerrno = errno;

    if(signo == SIGUSR1)
    {
        printf("收到了SIGUSR1信号!\n");
    }
    else if(signo == SIGUSR2)
    {
        printf("收到了SIGUSR2信号!\n");
    }
    else
    {
        //其他信号不太可能执行到这里
        printf("收到了未捕捉的信号%d!\n",signo);
    }


    //g_mysign = tmpsign;
    errno = myerrno;
}

int main(int argc, char *const *argv)
{
    //注册两个信号处理函数
    if(signal(SIGUSR1,sig_usr) == SIG_ERR)  //系统函数，参数1：是个信号，参数2：是个函数指针，代表一个针对该信号的捕捉处理函数
    {
        printf("无法捕捉SIGUSR1信号!\n");
    }
    if(signal(SIGUSR2,sig_usr) == SIG_ERR)
    {
        printf("无法捕捉SIGUSR2信号!\n");
    }
    for(;;)
    {
        sleep(1); //休息1秒
        printf("休息1秒\n");

        muNEfunc(15);
        printf("g_mysign=%d\n",g_mysign);
        //拿g_mysign做一些其他用途；
    }
    printf("再见!\n");
    return 0;
}
```

使用`kill -USR1 pid`对进程发送`SIGUSR1`信号。

进程收到信号，这个事件就会被内核注意到，进入内核态：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228153810149.png" alt="image-20230228153810149" style="zoom:50%;" />

-   信号处理函数是在用户态执行的，再去内核态执行收尾工作
-   最后再回到用户态



#### 3.4.3 可重入函数

所谓的「可重入函数」（或叫异步信号安全），就是在信号处理中是安全的函数：

-   可重入函数：在信号处理程序中保证调用安全的函数，这些函数是可重入的并被称为异步信号安全的

有很多大家周知的函数都是不可重入的，例如`malloc()`和`printf()`，最好在信号处理函数中不要调用「不可重入函数」，还有可能导致`errno`的错误，因为信号处理函数的执行时间是未知的，如果在信号处理函数中改变了`errno`，可能会覆盖主流程的`errno`。

**信号处理函数的注意事项：**

1.   在信号处理函数中，尽量使用简单的语句，做简单的事情，尽量不要调用系统函数以免引起麻烦（这是最好的方法，就改改局部变量就行）

2.   如果必须要在信号处理函数中调用一些系统函数，那么要保证在信号处理函数中调用的 系统函数 一定要是「可重入的」

3.   如果必须要在信号处理函数中调用那些可能修改`errno`的值的系统函数，那么就得事先备份`errno`的值，从信号处理函数返回之前，在信号处理函数的返回值前将`errno`恢复。

     ```cpp
     void fun(int signo)
     {
         int myerrno = errno;
         //信号处理
         errno = myerrno;
         return ;
     }
     ```

     

#### 3.4.4 不可重入函数（错用演示）

在信号处理函数和main函数中都无限循环`malloc()`：

**c3/nginx3_4_2.c**

```cpp
#include <stdio.h>
#include <stdlib.h>  //malloc
#include <unistd.h>
#include <signal.h>

//信号处理函数
void sig_usr(int signo)
{
    //这里也malloc，这是错用，不可重入函数不能用在信号处理函数中；
    int* p;
    p = (int *) malloc (sizeof(int)); //用了不可重入函数；
    free(p);

    if(signo == SIGUSR1)
    {
        printf("收到了SIGUSR1信号!\n");
    }
    else if(signo == SIGUSR2)
    {
        printf("收到了SIGUSR2信号!\n");
    }
    else
    {
        printf("收到了未捕捉的信号%d!\n",signo);
    }

}

int main(int argc, char *const *argv)
{
    if(signal(SIGUSR1,sig_usr) == SIG_ERR)  //系统函数，参数1：是个信号，参数2：是个函数指针，代表一个针对该信号的捕捉处理函数
    {
        printf("无法捕捉SIGUSR1信号!\n");
    }
    if(signal(SIGUSR2,sig_usr) == SIG_ERR)
    {
        printf("无法捕捉SIGUSR2信号!\n");
    }
    for(;;)
    {
        //sleep(1); //休息1秒
        //printf("休息1秒\n");
        int* p;
        p = (int *) malloc (sizeof(int));
        free(p);
    }
    printf("再见!\n");
    return 0;
}
```

一旦在信号处理中用了不可重入函数，可能导致程序错乱，导致再发送信号没用了，进程的状态变成`S+`也就是休眠。

**这种错误在实际操作中很难发现。**

>   `signal()`因为兼容性和可靠性等一些历史问题，不建议使用，官方建议使用`sigaction()`来代替。



