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
>
>   坚决不用`signal()`!



### 3.5 信号编程进阶、`sigprocmask()`函数

如果在信号处理函数正在执行的时候，又来了一个「相同的信号」，此时系统还会执行对应的信号处理函数吗？

不会，需要排队。

#### 3.5.1 信号集

一个进程必须记住当前阻塞了哪些信号，需要「信号集」的数据类型，这种类型能表示60多种信号。

如果信号集对应的位置为1，则代表正在处理该信号，再来一个相同的信号就会「排队」，在执行期间，不管来多少个相同的信号，都只会合并成一次。

在linux中用`sigset_t`结构类型表示信号集：

```cpp
typedef struct
{
    unsigned long sig[2];
}sigset_t;
```

信号集一共能表示64个信号，0表示信号没来，1表示信号来了。

一个进程里面会有一个信号集，这个信号集用来记录当前屏蔽（阻塞）了哪些信号，如果把这个信号集中某个信号位设置为1，那么同类信号会被屏蔽，不会传递给该进程。



#### 3.5.2 信号集相关函数

-   `sigemptyset()`：清空信号集，把64位全部清零，表示64个信号都没有来
-   `sigfillset()`：填充信号集，把信号集中所有信号都设置为1，与`sigemptyset()`相反
-   `sigaddset()`和`sigdelset()`可以在信号集中 「增加或删除」 特定信号。
-   `sigprocmask()`和`sigismember()`
    -   `sigprocmask()`函数能设置该进程阻塞信号集中的内容
    -   `sigismember()`函数



#### 3.5.3 `sigpromask()`等信号函数范例



```cpp
#include <stdio.h>
#include <stdlib.h>  //malloc
#include <unistd.h>
#include <signal.h>

//信号处理函数
void sig_quit(int signo)
{   
    printf("收到了SIGQUIT信号!\n");
}

int main(int argc, char *const *argv)
{
    sigset_t newmask,oldmask; //信号集，新的信号集，原有的信号集
    if(signal(SIGQUIT,sig_quit) == SIG_ERR)  //注册信号对应的信号处理函数,对应键盘"ctrl+\" 输入
    {        
        printf("无法捕捉SIGQUIT信号!\n");
        exit(1);   //退出程序，参数是错误代码，0表示正常退出，非0表示错误，但具体什么错误，没有特别规定，这个错误代码一般也用不到，可以先不管；
    }

    sigemptyset(&newmask); //newmask信号集中所有信号都清0（表示这些信号都没有来）；
    sigaddset(&newmask,SIGQUIT); //设置newmask信号集中的SIGQUIT信号位为1，再来SIGQUIT信号时，进程就收不到，设置为1就是该信号被阻塞掉

    //sigprocmask()：设置该进程所对应的信号集
    if(sigprocmask(SIG_BLOCK,&newmask,&oldmask) < 0)  //第一个参数用了SIG_BLOCK表明设置 进程 新的信号屏蔽字 为 “当前信号屏蔽字 和 第二个参数指向的信号集的并集
    {                                                 //一个 ”进程“ 的当前信号屏蔽字，刚开始全部都是0的；所以相当于把当前 "进程"的信号屏蔽字设置成 newmask（屏蔽了SIGQUIT)；
                                                      //第三个参数不为空，则进程老的(调用本sigprocmask()之前的)信号集会保存到第三个参数里，用于后续，这样后续可以恢复老的信号集给线程
        printf("sigprocmask(SIG_BLOCK)失败!\n");
        exit(1);
    }
    printf("我要开始休息10秒了--------begin--，此时我无法接收SIGQUIT信号!\n");
    sleep(10);   //这个期间无法收到SIGQUIT信号的；
    printf("我已经休息了10秒了--------end----!\n");
    if(sigismember(&newmask,SIGQUIT))  //测试一个指定的信号位是否被置位(为1)，测试的是newmask
    {
        printf("SIGQUIT信号被屏蔽了!\n");
    }
    else
    {
        printf("SIGQUIT信号没有被屏蔽!!!!!!\n");
    }
    if(sigismember(&newmask,SIGHUP))  //测试另外一个指定的信号位是否被置位,测试的是newmask
    {
        printf("SIGHUP信号被屏蔽了!\n");
    }
    else
    {
        printf("SIGHUP信号没有被屏蔽!!!!!!\n");
    }

    //现在我要取消对SIGQUIT信号的屏蔽(阻塞)--把信号集还原回去
    if(sigprocmask(SIG_SETMASK,&oldmask,NULL) < 0) //第一个参数用了SIGSETMASK表明设置 进程  新的信号屏蔽字为 第二个参数 指向的信号集，第三个参数没用
    {
        printf("sigprocmask(SIG_SETMASK)失败!\n");
        exit(1);
    }

    printf("sigprocmask(SIG_SETMASK)成功!\n");
    
    if(sigismember(&oldmask,SIGQUIT))  //测试一个指定的信号位是否被置位,这里测试的当然是oldmask
    {
        printf("SIGQUIT信号被屏蔽了!\n");
    }
    else
    {
        printf("SIGQUIT信号没有被屏蔽，您可以发送SIGQUIT信号了，我要sleep(10)秒钟!!!!!!\n");
        int mysl = sleep(10);
        if(mysl > 0)
        {
            printf("sleep还没睡够，剩余%d秒\n",mysl);
        }
    }
    printf("再见了!\n");
    return 0;
}



```

**如果在阻塞信号的时候输入 ctrl + \\**



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228170418272.png" alt="image-20230228170418272" style="zoom:50%;" />

输入的多个`ctrl + \`，会在屏蔽后发送一个`SIGQUIT`信号，先执行`sig_quit()`信号处理函数，再处理`sigprocmask()`。



**如果没有在阻塞的时候输入 ctrl + \\**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228165721621.png" alt="image-20230228165721621" style="zoom:50%;" />

没有显示“收到了`SIGQUIT`信号，同时会打断`sleep()`函数，直接运行到结束。

`sleep()`函数能够被打断:

1.   时间到了
2.   某个信号处理函数使`sleep()`提前结束，此时`sleep()`会返回剩余的时间。



**如果把`sig_quit()信号处理函数修改为：**

```cpp
void sig_quit(int signo)
{
    printf("收到了SIGQUIT信号!\n");
    if(signal(SIGQUIT,SIG_DFL) == SIG_ERR)
    {
        printf("无法为SIGQUIT信号设置缺省处理(终止进程)!\n");
        exit(1);
    }
}

```



意思是：在收到一次`SIGQUIT`信号之后，就用缺省的方式（终止进程）。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228170738109.png" alt="image-20230228170738109" style="zoom:50%;" />

在屏蔽之后再按`ctrl + \`，会直接终止程序，不会输出`sleep()`的剩余时间，但是合二为一的那个`SIGQUIT`信号还是按照信号处理函数的首次执行，输出语句，间接证明在阻塞期间发送多个`SIGQUIT`信号只会执行一次（如果不是的话，阻塞一结束就直接退出了！）



在阻塞期间不发送`SIGQUTI`信号，而是在非阻塞期间发送：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228171210022.png" alt="image-20230228171210022" style="zoom:50%;" />

可以看到第一次执行`SIGUIT`的处理函数会打断`sleep()`，并执行到结束。

>   这个例子来自《APUE》。
>
>   为什么需要注册`SIGQUIT`呢？它不是有默认的处理方法吗?
>
>   因为收到的`SIGQUIT`信号的默认处理是终止进程，屏蔽的信号会阻塞，当屏蔽结束后立即发送过来，执行信号处理函数，所以如果不先注册`SIGQUIT`，使用自己的处理函数，则会立即退出程序。



### 3.6 `fork()`详解

#### 3.6.1 简单认识`fork()`

用来创建进程。

一个可执行程序，执行起来就是一个进程，再执行一次，又是一个进程（多个进程可以共享一个可执行文件），文雅一点：

「进程 定义为程序执行的一个实例」。当该子进程创建时，它从`fork()`函数的返回处开始执行与父进程相同的代码。

`fork()`函数产生了一个与当前进程完全一样的新进程，并和当前进程一样从`fork()`返回。`fork()`就是一分为二。



子进程被杀死前，会向父进程发送`SIGCHLD`信号：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228191418024.png" alt="image-20230228191418024" style="zoom:50%;" />

同时子进程变成「僵尸进程」：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228191605063.png" alt="image-20230228191605063" style="zoom:50%;" />



#### 3.6.2 僵尸进程的产生、解决、`SIGCHLD`信号

**僵尸进程的产生：**

在Unix系统中，一个子进程结束了，但是它的父进程还活着，但是该父进程没有调用`wait() / waitpid()`函数来进行额外处理，则这个子进程就会变成一个僵尸进程。

僵尸进程已经被终止，不干活了，但是依旧没有被内核丢弃，因为内核认为父进程可能还需要子进程的一些信息。

僵尸进程会占用资源（至少会占用一个pid），作为开发人员，坚决不允许僵尸进程存在！



**僵尸进程的解决：**

-   重启电脑
-   手工把僵尸进程的父进程`kill`掉，僵尸进程就会消失



**`SIGCHLD`信号：**

一个进程被终止或者停止时，会向父进程发送`SIGCHLD`信号，所以，对于代码中有`fork()`调用的进程，需要拦截`SIGCHLD`信号，信号处理函数需要调用`waitpid()`：

```cpp
//信号处理函数
void sig_usr(int signo)
{
    int  status;

    switch(signo)
    {
        case SIGUSR1:
            printf("收到了SIGUSR1信号，进程id=%d!\n",getpid());
            break;

        case SIGCHLD:
            printf("收到了SIGCHLD信号，进程id=%d!\n",getpid());
            //waitpid获取子进程的终止状态，这样，子进程就不会成为僵尸进程了；

            //第一个参数为-1，表示等待任何子进程，
            //第二个参数：保存子进程的状态信息
            //第三个参数：提供额外选项，WNOHANG表示不要阻塞，让这个waitpid()立即返回
            pid_t pid = waitpid(-1,&status,WNOHANG); 
            if(pid == 0)       //子进程没结束，会立即返回这个数字，但这里应该不是这个数字
                return;
            if(pid == -1)      //这表示这个waitpid调用有错误，有错误也立即返回出去，我们管不了这么多
                return;
            //走到这里，表示  成功，那也return吧
            return;
            break;
    } //end switch
}
```



#### 3.6.3 `fork()`进一步认识

-   `fork()`产生新进程的速度非常快，`fork()`产生新进程并不会复制原进程的内存空间，而是和父进程一起共享一个内存空间，这个内存空间的特点是：「写时复制」。
-   原来的进程和`fork()`出来的子进程可以同时、自由地读取内存，但是子进程或父进程 对内存进行修改的话， 则内存会复制原来的内存。
-   `fork()`会返回两次，在父进程中返回子进程的pid，在子进程中返回0，父进程和子进程互不影响。

连续两个`fork()`：

```cpp
fork();
fork();
```

会产生4个进程：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228193230694.png" alt="image-20230228193230694" style="zoom:50%;" />



**一个`fork()`的逻辑题：**

```cpp
((fork() && fork()) || (fork() && fork()));
```

上面的代码执行会有几个进程？

>   答案是7个。

`fork()`中，父进程执行到哪，子进程就执行到哪！

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228194855416.png" alt="image-20230228194855416" style="zoom:40%;" />

需要注意对于`&&`而言，出现0后面的就不执行了，对于`||`而言，出现1后面的就不执行了。这个题目还真不是考的`fork()`，考的是逻辑运算的「短路求值」。

#### 3.6.4 `fork()`失败的可能性

一般不会失败，但也有失败的可能，原因有：

-   系统中进程太多，系统最大的pid：32767

-   每隔用户有允许开启的进程总数：`printf("每个实际用户ID的最大进程数=%ld\n",sysconf(_SC_CHILD_MAX));`

    我的机器是7282



### 3.7 文件描述符

#### 3.7.1 文件描述符简介

**文件描述符：**

-   一个正整数，用来标识一个文件
-   当打开一个存在的文件，或者创建一个新文件，操作系统都会返回一个文件描述符（代表该文件）
-   后续对文件操作的函数，都需要到文件对应的文件描述符



#### 3.7.2 三个特殊文件描述符

Linux三个特殊的文件描述符，0，1，2:

-   0：标准输入，键盘，对应常量为`STDIN_FILENO`
-   1：标准输出，屏幕，对应的符号常量为`STDOUT_FILENO`
-   2：标准错误，对应屏幕，对应的符号常量为`STDERR_FILENO`

>   类Unix操作系统，默认从`STDIN_FILENO`读取数据，向`STDOUT_FILENO`写数据，向`STDERR_FILENO`来写错误。
>
>   「一切皆文件」，所以它把标准输入、标准输出、标准错误 都看作文件。
>
>   -   像看待文件一样看待 标准输入、标准输出、标准错误
>   -   像操作文件一样操作标准输入、标准输出、标准错误

同时，程序一旦运行起来，这三个文件描述符：0，1，2会被自动打开，自动指向对应的设备。

文件描述符虽然是数字，但是如果把文件描述符理解成指针（指针里面保存的是地址，地址本质上也是一个数字）

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228205323584.png" alt="image-20230228205323584" style="zoom:40%;" />

下面的代码相当于向屏幕写"aaaabbb"的前6个字符。

```cpp
write(STDIN_FILENO, "aaaabbb", 6);
```



#### 3.7.3 输入输出重定向

-   标准输出文件描述符可以不指向屏幕，可以指向（重定向）一个文件，在命令行中用`>`就可以输出重定向
-   在命令行中使用`<`就可以输入重定向，例如`cat < myinfile`，意思是从`myinfile`读入内容，并通过`cat`显示到标准输出上来，`cat`不加参数就是写入什么，终端显示什么。
-   `cat < myinfile > myoutfile`代表从`myinfile`读入内容，重定向到`myoutfile`中



#### 3.7.4 空设备

`/dev/null`：这是一个特殊的设备文件，丢弃一切写入其中的数据（就像黑洞一样）



#### 3.7.5 `dup2()`函数

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228211936650.png" alt="image-20230228211936650" style="zoom:50%;" />

`dup2()`把第一个参数复制给第二个参数，相当于指针赋值，而不拷贝内容，拷贝前会先关闭，也就是`close`。

`close(fd)`等价于`fd = null`。

### 3.8 守护进程

#### 3.8.1 普通进程运行观察

-   普通进程有对应的终端，如果终端退出，那么对应的进程也就消失了；它的父进程是一个bash
-   终端被占住了，输入各种命令这个终端没有反应

#### 3.8.2 守护进程基本概念

守护进程是一种长期运行的进程，这种进程在后台运行，**并且不和任何的控制终端相关联**。

**基本特点：**

-   生存期长，一般是操作系统启动它就启动，操作系统关闭它才关闭。（不是必须，但一般应该这样做）
-   守护进程和终端无关，也就是说没有控制终端，退出终端不会导致守护进程退出。
-   守护进程在后台运行



Linux操作系统本身有很多守护进程在后台运行，一般我们不用管。



`ps -efj`可以查看工作进程：

-   ppid = 0的内核进程，例如pid=1和2的进程都是和系统启动而启动。
-   cmd列带`[]`的都是内核守护进程，它们都以`kthreadd`为父进程。
-   `init`进程也是系统守护进程，它负责启动各运行层次特定的系统服务，所以很多进程的ppid是init，同时还负责收养孤儿进程。



**共同点总结：**

-   大多数守护进程都是以root权限运行的
-   守护进程没有控制终端TT这列显示
    -   内核守护进程以无控制终端方式启动
    -   普通守护进程可能是守护进程调用了`setsid()`的结果（无控制终端）



#### 3.8.3 守护进程编写规则

1.   调用`umask(0)`，用来限制文件权限，设置为0代表「不让umask设置权限」

2.    `fork()`一个子进程出来，然后父进程退出（固定套路），把终端空出来，不让终端卡住

      `fork()`的目的是让子进程来调用`setsdi()`来建立新会话，子进程不会是进程组组长。目的是让`fork()`出来的子进程有单独的sid，而且子进程也成为了一个新进程组的组长进程，同时子进程脱离终端。

3.    守护进程虽然可以通过终端启用，但是和终端不挂钩。守护进程是在后台运行，所以它不应该从键盘上接受任何东西，也不应该把输出结构打印到屏幕或者终端上来。所以按照规则，我们应该把守护进程的标准输入和输出都重定向到`/dev/null`中去。从而确保守护进程不从键盘接受任何东西，也不把输出结果打印到屏幕（我们不希望守护进程的输出打印到屏幕，也不希望输入的内容输入到守护进程中）。



**nginx中的守护进程创建代码，c3/nginx3_7_2.c**

```cpp
#include <stdio.h>
#include <stdlib.h>  //malloc
#include <unistd.h>
#include <signal.h>

#include <sys/stat.h>
#include <fcntl.h>

//创建守护进程
//创建成功则返回1，否则返回-1
int ngx_daemon()
{
    int  fd;

    switch (fork())  //fork()子进程
    {
    case -1:
        //创建子进程失败，这里可以写日志......
        return -1;
    case 0:
        //子进程，走到这里，直接break;
        break;
    default:
        //父进程，直接退出
        exit(0);
    }

    //只有子进程流程才能走到这里
    if (setsid() == -1)  //脱离终端，终端关闭，将跟此子进程无关
    {
        //记录错误日志......
        return -1;
    }
    umask(0); //设置为0，不要让它来限制文件权限，以免引起混乱

    fd = open("/dev/null", O_RDWR); //打开黑洞设备，以读写方式打开
    if (fd == -1)
    {
        //记录错误日志......
        return -1;
    }
    //先关闭STDIN_FILENO[这是规矩，已经打开的描述符，动他之前，先close]，类似于指针指向null，让/dev/null成为标准输入；
    if (dup2(fd, STDIN_FILENO) == -1)
    {
        //记录错误日志......
        return -1;
    }

    if (dup2(fd, STDOUT_FILENO) == -1) //先关闭STDIN_FILENO，类似于指针指向null，让/dev/null成为标准输出；
    {
        //记录错误日志......
        return -1;
    }

     if (fd > STDERR_FILENO)  //fd应该是3，这个应该成立
    {
        if (close(fd) == -1)  //释放资源这样这个文件描述符就可以被复用；不然这个数字【文件描述符】会被一直占着；
        {
            //记录错误日志......
            return -1;
        }
    }

    return 1;
}

int main(int argc, char *const *argv)
{
    if(ngx_daemon() != 1)
    {
        //创建守护进程失败，可以做失败后的处理比如写日志等等
        return 1;
    }
    else
    {
        //创建守护进程成功,执行守护进程中要干的活
        for(;;)
        {
            sleep(1); //休息1秒
            printf("休息1秒，进程id=%d!\n",getpid()); //你就算打印也没用，现在标准输出指向黑洞（/dev/null），打印不出任何结果【不显示任何结果】
        }
    }
    return 0;
}
```



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228212847801.png" alt="image-20230228212847801" style="zoom:50%;" />

`STAT`中的`s`小写s代表它是session leader 。

对比启动nginx服务器：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230228213126985.png" alt="image-20230228213126985" style="zoom:50%;" />

可以看到nginx的master默认就是以守护进程启动的。

守护进程可以命令启动，也可以借助脚本开机启动。



#### 3.8.4 守护进程不会收到的信号

**`SIGHUP`信号**

守护进程不会收到 来自内核的`SIGHUP`信号，如果守护进程收到了这个信号，那么一定是另外的进程发送给你的。很多守护进程把这个信号作为通知信号，表示配置文件已经发生改变，需要重新读入配置文件。

例如`nginx -s reload pid`和`kill -1 pid`的效果相同。



**`SIGINT`和`SIGWINCH`**

守护进程也不会收到来自内核的`SIGINT`（ctrl + c）和`SIGWINCH`（终端窗口大小改变信号）。

#### 3.8.5 守护进程和后台进程的区别

-   守护进程和终端没有联系，后台进程能往终端上输出（和终端有关联）
-   守护进程关闭终端不受影响，关闭终端后台进程也会退出
-   守护进程是session leader



## 4. 服务器程序框架初步

### 4.1 服务器程序目录规划、makefile编写

#### 4.1.1 信号高级认识范例



