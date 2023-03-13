# 一次GDB调试

发送数据，LT不停提醒。第二次给服务器发包时，worker进程就没了。好在这个错误是可以重现的。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230312005436464.png" alt="image-20230312005436464" style="zoom:50%;" />

这个错误显得有些匪夷所思了。只能使用GDB调试。GDB调试比VSCode调试难多了。



## 1. 调试设置

1.   makefile文件中带上-g，所以直接make即可
2.   su root（最好有root权限）
3.   gdb 可执行文件名

>   gdb缺省的情况下，调试的是主进程，7.0以上版本可以调试子进程。本机：
>
>   `GNU gdb (GDB) Red Hat Enterprise Linux 8.2-3.el7`

本项目需要调试子进程，为了让GDB支持多线程调试，需要设置`follow-fork-mode`，这是一个调试多进程的开关，值可以是`parent`或`child`。查看该选项的当前值，在gdb下输入`show follow-fork-mode`。输入`set follow-fork-mode child`就可以调试子进程了。



还需要设置一个选项`detach-on-fork`，取值为`on/off`，默认是`on`，表示只会调试父进程或子进程中的一个，具体调试哪个进程，由`follow-fork-mode`决定。如果`detach-on-fork`，就表示父进程和子进程都可以调试，调试一个进程时，另一个进程会暂停。如果设置为`off`并且`follow-fork-mode`这个选项为`parent`，那么代码中的`fork()`并不会运行，而是处于暂停状态。

为了方便调试，在配置文件中只开启一个子进程，把`detach-on-fork`设置为`on`，`follow--fork-mode`设置为`child`。



同时在处理业务逻辑的调用`ngx_epoll_oper_event`函数打一个断点，使用`b logic/ngx_c_slogic.cxx:204`，`b`代表打断点。

## 2. 开始调试

在做完上面的工作后，使用`run`运行到断点。

使用`ps`命令可以看到master进程和worker进程都运行起来了。

运行客户端`./client`，OK，可以发现GDB停住了

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230312011630503.png" alt="image-20230312011630503" style="zoom:50%;" />

输入`c`继续运行，并再运行客户端：



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230312012305868.png" alt="image-20230312012305868" style="zoom:50%;" />

GDB定位到了这一行有问题，也就是`(this->* (c->rhandler) )(c); `

原因和`epoll_ctl()`有关。