# GDB调试 redis 和 nginx

## 1.  调试准备

### 1.1 被调试的程序需要带调试信息

-   -g 选项：表示编译时带上调试选项。如果没有加上这个选项，gdb 会提示`no debugging symbols found`
-   在实际调试时，还建议关闭编译器的优化，编译器的优化有五个级别：`O0~O4`,`O0`表示不优化，O4 级别最高，最好是使用`O0`也就是不优化

```cpp
int func()
{
    int a = 1;
	int b = a + 1;
	int c = a + b;
	return a + b + c;
}

```

例如上面的函数，调用的时候，编译器可能在编译的时候直接算出这个值，不同版本的编译器的效果不同。

### 1.2 启动 GDB 调试

>   启动！

有三种方法可以启动 GDB 调试：

1.   gdb filename
2.   gdb attach pid
3.   gdb filename corename

#### 方法 1 ：直接调试目标程序

这种方式是通过 gdb 启动一个程序进行调试，也就是说这个程序还没有启动，gdb 中输入`run/r`才启动。

#### 方法 2：附加进程

很多情况下，程序已经启动了，这时候如果想调试程序但是不想重启需要第二种方法，使用`gdb attach pid`来将 GDB 调试器附加到我们的**进程**上（也需要附带调试信息），然后按`c`就可以继续运行了。

如果想结束调试并让程序继续进行，可以使用`detach`命令再`quit`。



#### 方法 3： 调试 core 文件--定位进程崩溃问题

如果在程序崩溃的时候，产生 core 文件，需要用`ulimit -c unlimited`将 core 文件不限制大小，但是这个设置重启就失效了，可以添加到`/etc/profile`或者`~/.bashrc`中。

使用 GDB 调试 core 文件的命令是：

```bash
gdb filename corename
```

输入命令后，就可以看到程序崩溃在哪个文件的哪一行，输入`bt`命令可以查看调用堆栈。但是如果多个程序崩溃，corename默认是`core.pid`，此时，我们无法找到 pid 对应的进程（已经崩溃了），可以自定义 corename，或者在程序运行的时候，把 pid 和进程名写到「某个文件中」。

## 2. GDB 常用命令

### 2.1 普通命令

#### break/b 命令

-可以通过多种方式添加断点：

-   b functionname：通过函数名，例如 `b main`
-   b LineNo：通过行号，如果没有指定文件名，则默认在当前停的文件
-   b filename:LineNo：通过文件名+行号

#### run/r 命令

对应 run，启动

#### tb 命令

t 表示 temporary，临时断点，用一次就消失的断点

#### c 命令

continue，运行到下一个断点。

#### bt 和 frame 命令

backtrace 可以查看当前线程的调用堆栈，会显示函数调用堆栈，并显示堆栈的编号，可以通过`frame 堆栈编号`的形式切换堆栈。

#### info b

可以通过 info b 查看断点，了解断点的触发次数，并对断点进行修改。

#### list

查看断点附近的代码

#### print

打印变量的值

#### ptype

查看变量的类型

### 2.2 多线程命令

#### info 和 thread 命令

删掉所有断点，`r`启动，并`ctrl+c`中断程序，然后使用`info threads`查看当前所有线程的信息和它们的中断位置：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230911150100537.png" alt="image-20230911150100537" style="zoom:50%;" />

可以看到它们都处于`pthread_cond_wait()`的位置。表示有一个主线程和三个工作线程，（LWP XXX）表示线程 ID，主线程阻塞在`epoll_wait()`，工作线程阻塞在`pthread_cond_wait()`的地方。

 `*`表示gdb 当前作用于哪个线程，输入`bt`可以查看这个线程的调用堆栈：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230911150601418.png" alt="image-20230911150601418" style="zoom:50%;" />



使用`thread 线程编号`可以切换到指定的线程，`bt`可以查看这个线程的堆栈：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230911151215247.png" alt="image-20230911151215247" style="zoom:50%;" />

## 3. GDB 调试多线程

调试多线程的基础就是需要熟悉多线程的知识。

### 3.1 分析 redis-server 中的线程

线程 1 是主线程，由 main 函数调用而来，我们切换到线程2，`bt`显示：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230911152705254.png" alt="image-20230911152705254" style="zoom:50%;" />

注意下面两个栈帧是系统调用，我们需要在项目中的代码，`bioProcessBackgroundJobs`就是线程的入口函数，在项目中可以找到用`pthread_create()`创建的线程入口函数就是`bioProcessBackgroundJobs`，同时`pthread_create()`创建子线程的函数是`bioInit()`，我们可以给`bioInit()`函数打个断点，然后重启。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230911153337196.png" alt="image-20230911153337196" style="zoom:50%;" />

可以看到`bioInit()`是`InitServerLast()`调用的，`bioInit()`创建了工作现场。

>   对于不熟悉的 C++项目，都可以用上述方法分析，当然需要建立在了解业务的场景的情况下。

### 3.2 调试时控制线程切换

在调试多线程的时候，很多时候我会希望执行流一直在某一个线程中执行，而不切换到其他线程。

一般工作线程（除了主线程）的执行流程可能就是一个`while(1)`的死循环：

```cpp
void* threadFunc(void* arg)
{
    while(1)
    {
        //code
    }
}
```

多线程的时候，使用`n`可能会触发别的线程也执行，而别的线程使用同一套线程函数，使用相同的断点，所以不是我们期望的当前线程 A。还有一个情况就是，我们单步调试线程 A的时候，我们不希望别的线程修改A 中的值。

gdb提供了一个将程序执行流程锁定在当前调试线程的命令选项`scheduler-locking`，这个选项有三个值：`on, step, off`：

```gdb
set scheduler-locking on/step/off
```

-   on 用来锁定当前线程，只观察这个线程的运行情况，其他线程处于暂停状态
-   step：也是锁定当前线程，但是只对 next 和 step 命令有效，如果使用`util,finish,return`等调试命令，其他线程也有机会运行。
-   off 用于释放当前线程

## 4. GDB 调试多进程

### 4.1 使用 gdb attatch 到子进程上

然后和调试单进程一样

### 4.2 使用 follow-fork 选项

我们可以使用`set follow-fork parent/child`来设置当进程 fork 出一个新的子进程时，gdb 是继续调试父进程还是子进程，默认是`parent`。

