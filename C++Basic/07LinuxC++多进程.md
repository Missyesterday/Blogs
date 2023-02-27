## 07. Linux多进程开发

## 01. 进程概述

### 1.1 程序和进程

程序是包含一系列信息的「文件」，这些信息描述了如何在运行时创建一个进程：

-   二进制格式标识：每个程序文件都包含用语描述可执行文件格式的元信息。内核利用此信息来解释文件中的其他信息。（ELF可执行链接格式）
-   机器语言指令：对程序算法进行编码。
-   程序入口地址：标识程序开始执行时的起始指令位置。
-   数据：程序文件中包含的变量初始值和程序使用的字面量值（比如字符串）
-   符号表以及重定位表：描述程序中函数和变量的位置及名称。这些表格有多重用途，其中包括调试和运行时的符号解析。
-   共享库和动态链接信息：程序文件所包含的一些字段，列出了程序运行时需要使用的共享库，以及加载共享库的动态链接器的路径名。
-   其他信息：程序文件中还包含许多其他信息，用以如何创建进程。
-   程序是正在运行的程序的实例，



进程是正在运行的程序的实例：

-   进程是一个具有一定独立功能的程序关于某个数据集合的一次运行活动。它是操作系统动态执行的基本单元，在传统的操作系统中，进程既是基本的分配单元，也是基本的执行单元。
-   可以用一个程序来创建多个进程，进程是由内核定义的抽象实体，并为该实体分配用以执行程序的各项系统资源。从内核角度看，进程由用户内存空间和一系列内核数据结构组成，其中用户内存空间包含了程序代码以及代码所使用的变量，而内核数据结构则用于维护进程状态信息。记录在内核数据结构中的信息包括许多与进程相关的标识号（IDs）、虚拟内存表、打开文件的描述符、信号传递以及处理的有关信息、进程资源使用及限制、当前工作目录和大量其他信息。



### 1.2 单道、多道程序设计

-   单道程序，即计算机内存中只允许一个程序运行。
-   多道程序设计技术是在计算机内存中同时存放几道相互独立的程序，使它们在管理程序控制下，相互穿插运行，两个或两个以上程序在计算机系统中同处于开始到结束之间的状态，这些程序共享计算机系统资源。引入多道程序设计的根本目的是为了提高CPU的利用率。
-   对于一个单CPU系统来说，程序同时处于运行状态只是一种宏观上的概念，他们虽然都已经开始运行，但就微观而言，任意时刻，CPU上运行的程序只有一个。
-   在多道 程序设计模型中，多个进程轮流使用CPU。而当下常见的CPU为纳秒级，一秒可以执行大概10亿条指令，由于人的反应速度是毫秒级，所以看似同时运行。



### 1.3 时间片

-   「时间片」（timeslice）又称为 量子 （quantum）或 处理器片 （processor slice），是操作系统分配给每个正在运行的进程微观上的一段CPU时间。事实上，虽然一台计算机通常可能有多个CPU，但是同一个CPU永远不可能同时运行多个任务。在只考虑一个CPU的情况下， 这些进程”看起来像“同时运行的，实则是轮番穿插运行，由于时间片很短 （在Linux上为5ms到800ms），用户不会感受到。
-   时间片由操作系统内核的调度程序分配给每个进程。首先，内核会给每个进程分配相等的初始时间片，然后每个进程轮番地执行相应的时间，当所有进程都处于时间片耗尽的状态时，内核会重新为每个进程计算并分配时间片，如此往复。



### 1.4 并行和并发

-   并行（parallel）：在同一时刻，有多条指令在多个处理器上同时执行
-   并发（concurrency）：在同一时刻只能有一条指令执行，但多个进程指令被快速的轮换执行，使得在宏观上具有多个进程同时执行的结果，但在微观上并不是同时执行的，只是把时间分成若干段，使多个进程快速交替执行。
-   并发是两个队列交替使用一台咖啡机
-   并行是两个队列同时使用两台咖啡机



### 1.5 进程控制块（PCB）

-   为了管理进程，内核必须对每个进程所作的事情进行清楚的描述。内核为每个进程分配一个PCB（Processing Control Block）进程控制块，维护进程相关的信息，Linux内核的进程控制块是`task_struct`结构体。
-   这个结构体定义在`usr/src/linux-headers-xxx/include/linux/sched.h`文件中，其中有很多内部成员，例如：
    -   进程id：系统中每个进程有唯一的id，用`pid_t`类型表示，其实就是一个非负整数
    -   进程的状态：有就绪、运行、挂起、停止等状态
    -   进程切换时需要保存和恢复的一些CPU寄存器
    -   描述虚拟地址空间的信息
    -   描述控制终端的信息
    -   当前工作目录（Current Working Directory）
    -   umask掩码
    -   文件描述符表，包含很多指向`file`结构体的指针
    -   和信号相关的信息
    -   用户id和组id
    -   会话（session）和进程组
    -   进程可以使用的资源上限（Resource Limit）



`ulimit -a`可以查看当前系统可以使用资源的上限。



## 02. 进程状态转换

### 2.1 进程的状态

进程状态反映进程执行过程的变化。这些状态随着进程的执行和外界条件的变化而转换。在三态模型中，进程状态分为三个基本状态：就绪态，运行态，阻塞态。在五态模型中，进程分为：新建态，就绪态，运行态，阻塞态，终止态。

-   运行态：进程占有处理器正在运行
-   就绪态：进程具备运行条件，等待系统分配处理器以便运行。当进程已分配到除CPU外的所有必要资源后，只要再获得CPU，便可立即执行。在一个系统中处于就绪状态的进程可能有多个，通常将他们排成一个队列，称为就绪队列。
-   阻塞态：又称为「等待态」（wait）或「睡眠态」（sleep），指进程不具备运行条件，正在等在某个事件的完成。
-   新建态：进程刚被创建时的状态，尚未进入就绪队列
-   终止态：进程完成任务到达正常结束点，或出现无法克服的错误而异常终止，或被操作系统及有终止权的进程所终止时所处的状态。进入终止态的进程以后不再执行，但依然保留在操作系统中等待善后。一旦其他进程完成了对终止态进程的信息抽取之后，操作系统将删除改进程。



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230120193449043.png" alt="image-20230120193449043" style="zoom:40%;" />





### 2.2 进程相关命令

-   查看进程

    `ps`命令

    a：显示终端上所有进程，包括其他用户的进程

    u：显示进程的详细信息

    x：显示没有控制终端的进程

    j：列出作业控制相关的信息

-   `STAT`参数的含义：

    <img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230120194615528.png" alt="image-20230120194615528" style="zoom:40%;" />

SID就是Session ID（会话ID）。



`kill`命令有64个信号，9是强制kill。



### 3.3 进程号和相关函数

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230120202758255.png" alt="image-20230120202758255" style="zoom:40%;" />

注意当前终端也是一个进程，运行一个程序则它的父进程是当前终端。



## 03. 进程创建

### 3.1 fork函数

系统允许一个进程创建新进程，新进程就是子进程，如此往复，形成进程树的结构。

`fork`函数：

```cpp
#include <unistd.h>

pid_t fork(void);
```

fork用于创建子进程，如果成功，则在父进程中返回子进程的PID，如果返回的是0，则是在子进程中返回的，-1则代表失败。fork的返回值会返回两次，一次在父进程中，一次在子进程中。在父进程中返回创建的子进程的PID，在子进程中返回0，这样就能区分父进程和子进程。在父进程中返回-1则代表创建子进程失败，并会设置errno。



创建子进程失败的两个主要原因：

1.   当前系统的进程数已经达到了系统规定的上限，这时errno的值被设置为EAGAIN
2.   系统内存不足，这时errno的值被设置为ENOMEM



```cpp
#include <unistd.h>
#include <sys/types.h>
#include <stdio.h>
    
int main()
{   
    //测试fork函数,用于创建子进程
    //创建子进程
    pid_t pid = fork();
   

    //判断是父进程还是子进程
    if(pid == 0)
    {
        printf("当前是子进程, pid = %d, ppid = %d\n", getpid(), getppid());
    }
    
    if(pid > 0)
    {
        printf("pid = %d\n", getpid());
        printf("当前是父进程, pid = %d, ppid = %d\n", getpid(), getppid());
    }
    
    for(int i = 0; i < 1000000; ++i)
    {
        printf("i : %d, pid : %d\n", i, getpid());
    }
    return 0;
}
```



### 3.2 父子进程虚拟地址空间

子进程会复制一个父进程的虚拟地址空间，fork以后，子进程的用户区数据和父进程一样，内核区也会拷贝，但是pid是不同的，以及栈空间返回值不同，子进程栈空间返回0，父进程返回大于0的值。但是其他变量会复制过去，而这两个变量之间没有任何关系互不影响。



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230126000453073.png" alt="image-20230126000453073" style="zoom:40%;" />

实际上，更准确来说，Linux的`fork()`使用是写时拷贝（copy-on- write）实现的，写时拷贝是一种可以推迟甚至避免拷贝数据的技术。内核此时并不复制整个进程的地址空间，而是让父子进程共享同一个地址空间。只用在需要写入的时候才复制地址空间，从而使各个进程拥有各自的地址空间。也就是说，资源的复制是在需要写入的时候才会进行，在此之前，只有以只读方式共享。

注意：fork之后父子进程共享文件。fork产生的子进程与父进程相同的文件描述符指向相同的文件表，引用计数增加，共享文件偏移指针。

一句话：「读时共享，写时拷贝」



### 3.3 多进程GDB调试

**父子进程的区别：**

-   父子进程的fork函数返回值不同
    -   父进程返回的是子进程的pid
    -   子进程返回的是0
-   PCB中的一些数据也有区别：
    -   当前进程的PID
    -   当前进程的父进程PID，也就是PPID
    -   信号集也不同



**父子进程共同点：**

-   某些状态下，子进程刚被创建出来，还没有执行任何写数据的操作
    -   用户区的数据
    -   文件描述符表（在内核区中的PCB里面）



**父子进程对变量是不是共享？**

-   刚开始的时候是共享的，如果修改了数据就不共享了
-   读时共享，写时拷贝



使用GDB调试的时候，默认只能跟踪一个进程，可以在`fork()`函数调用之前，通过指令设置GDB调试工具跟踪父进程或者是跟踪子进程，默认跟踪父进程。

**如果断点打在子进程，则停在子进程的断点处，父进程执行完毕；如果断点打在父进程处则相反。**

设置调试父进程或者子进程：`set follow-fork-mode [parent(默认) | child]`，可以使用`show follow-fork-mode`查看信息。

设置调试模式：`set detach-on-fork [on | off]`，默认为on，表示调试当前进程的时候，其他的进程继续运行，如果为off，调试当前进程的时候，其他进程被GDB挂起（也就是停在`fork`的地方）



-   查看调试的进程：`info inferiors`
-   切换当前调试的进程：`inferior id`
-   使进程脱离GDB调试（也就是直接执行完这个进程）：`detach inferiors id`







## 04. `exec`函数族

函数族指的是一系列功能相似的函数。



### 4.1 简介

-   `exec`函数族的作用时根据指定的文件名找到可执行文件，并用它来**取代**调用进程的内容，换句话说，就是在调用进程内部执行一个可执行文件。这样显然有些不合理，所以一般`exec`函数和`fork`一起用，先fork一个子进程再替换。替换的是用户区的数据而不是内核区的数据。
-   `exec`函数族的函数执行成功后不会返回，因为调用进程的实体，包括代码段，数据段和堆栈等都已经被新的内容取代，只留下进程ID等一些表面上的信息仍保持原样，类似于「金蝉脱壳」，看上去还是旧的躯壳，却已经注入了新的灵魂，只有调用失败了，他们才会返回-1，从原程序的调用点接着往下执行。

`exec`函数族至少包括以下函数：

```cpp
int execl(const char *path, const char *arg, ...);
int execlp(const char *file, const char *arg, ...);
int execle(const char *path, const char *arg,...);
int execv(const char *path, char *const argv[]);

//...
int execve(const char *filename, char *const argv[], char *const envp[]);
```

只有`execve`是linux的系统函数，其余的都是标准C库的函数，它们都是封装了`execve`。

-   参数：
    -   `-path`：需要执行的文件的路径或名称，可以是相对路径也可以是绝对路径（建议写绝对路径，关系到执行文件时的路径）
    -   `-arg`：是执行可执行文件的参数列表，第一个参数一般没有什么作用，为了方便，一般写的是执行的程序名。从第二个参数开始往后，就是程序执行所需要的参数列表，参数最后需要以`NULL`结束（哨兵）。
-   返回值：
    -   仅仅在出错的时候返回-1。
    -   调用成功没有返回值。
-   lvep的意义：
    -   `l(list)`：参数地址列表，以`NULL`结束
    -    `v(vector)`：存有各参数地址的指针数组的地址
    -   `p(path)`：按PATH环境变量指定的目录搜索可执行文件
    -   `e(environment)`：存有环境变量字符串地址的指针数组的地址，表示给程序新的环境变量

### 4.2 使用

**`execv`的使用：**

```cpp
#include <unistd.h>
#include <stdio.h>

int main()
{
    //创建一个子进程, 在子进程中执行exec函数族的函数

    pid_t pid = fork();

    if(pid > 0)
    {
        // 父进程
        printf("i am parent, pid : %d\n", getpid());
    
    }
    else if(0 == pid)
    {
        execl("hello", "hello", NULL);

        printf("i am child process\n");
    }

    for (int i = 0; i < 10; ++i)
    {
        printf("i = %d\n", i);
    }

    return 0;
}
```

上面的代码，`for`循环只会在父进程中执行一次，子进程也不会输出`i am child process`，因为`execl`函数会替代子进程的内容，子进程会输出`hello`可执行文件的内容。



如果想执行Linux中的系统命令，例如`ps -aux`，`execl`可以写成：

```cpp
execl("/bin/ps", "ps", "aux", NULL);
```



**`execlp`的使用：**

`execlp`传入的第一个参数`file`是需要执行的可执行文件的文件名，例如执行`ps`直接写`ps`而不是`/bin/ps`。它回到环境变量中查找指定的可执行文件，如果找到了则执行，没找到则失败。

```cpp
    else if(0 == pid)
    {
        execlp("ps", "ps", "aux", NULL);
        printf("i am child process\n");
    }

```

所以`execlp`不能执行`hello`，因为环境变量没有配置。



## 05. 进程控制



### 5.1 进程退出

关于进程退出，有两个函数：

```cpp
#include <stdlib.h>
void exit(int status);

#include <unistd.h>
void _exit(int status);
```

`exit`是标准C库里的，`_exit`是Linux系统函数。`status`参数是进程退出时的状态信息。在父子进程中，子进程退出，父进程可以得到子进程的退出状态(status)。子进程退出能释放用户区的数据，但是对于内核区的某些数据，需要父进程来释放。

例如`main`函数的`return 0`也是一个退出状态，返回给调用它的进程。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230126145720684.png" alt="image-20230126145720684" style="zoom:40%;" />

`exit()`比`_exit()`多了两步，同时也会调用`_exit()`，一般都会使用标准C库的`exit()`函数。



```cpp
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

int main()
{
    printf("hello\n");
    printf("world");

    exit(0);
    return 0;
}
```

`exit`会刷新缓冲区，两个`printf`语句都会输出。



```cpp
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

int main()
{
    printf("hello\n");
    printf("world");

    _exit(0);
    return 0;
}
```

`\n`会自动刷新缓冲区，`_exit()`不会刷新缓冲区。由于没有刷新第二条`printf`的缓冲区，第二条`printf`不会输出。



### 5.2 孤儿进程

-   父进程运行结束，但是子进程还在运行（未运行结束），这样的子进程就称为孤儿进程（Orphan Process）
-   每当出现一个孤儿进程的时候，内核就把孤儿进程的父进程设置为`init`，而`init`进程会循环地`wait()`它的已经退出的子进程。这样，但一个孤儿进程结束其生命周期的时候，`init`进程就会处理它的善后工作。
-   因此孤儿进程不会有什么危害。



**举例：**

```cpp
#include <unistd.h>
#include <sys/types.h>
#include <stdio.h>
    
int main()
{   
    //测试fork函数,用于创建子进程
    //创建子进程
    pid_t pid = fork();
   

    //判断是父进程还是子进程
    if(pid == 0)
    {
        sleep(1);
        printf("当前是子进程, pid = %d, ppid = %d\n", getpid(), getppid());
    }
    
    if(pid > 0)
    {
        printf("当前是父进程, pid = %d, ppid = %d\n", getpid(), getppid());
    }
    
    for(int i = 0; i < 3; ++i)
    {
        printf("i : %d, pid : %d\n", i, getpid());
    }
    return 0;
}
```



输出：

```shell
[root@izwz91cjr7mviwi4efbqupz lesson20]# ./orphan 
当前是父进程, pid = 4571, ppid = 4292
i : 0, pid : 4571
i : 1, pid : 4571
i : 2, pid : 4571
[root@izwz91cjr7mviwi4efbqupz lesson20]# 当前是子进程, pid = 4572, ppid = 1
i : 0, pid : 4572
i : 1, pid : 4572
i : 2, pid : 4572

```

为什么父进程结束会出现命令提示符，父进程死亡之后就切换到了前台，但是子进程此时还有输出，就会继续输出。同时子进程的`ppid`是1，也就是`init`，由它来回收。



### 5.3 僵尸进程

-   每个进程结束之后，都会释放自己地址空间中的用户区数据，内核区的PCB没有办法自己释放掉，需要父进程区释放。
-   进程终止的时，父进程尚未回收，子进程残留资源（PCB）存放于内核中，变成僵尸进程（Zombie）。
-   僵尸进程不能被`kill -9`杀死。
-   这样就导致，如果父进程不调用`wait()`或`waitpid()`的话，那么保留的那段信息就不会释放，其PID就会一直被占用，但是系统所能使用的进程号时有限的，如果有大量的产生僵尸进程，将会因为没有可用的进程号而导致系统不能产生新的进程，这也就是僵尸进程的危害，应该避免。



**举例：**

```cpp
#include <unistd.h>
#include <sys/types.h>
#include <stdio.h>
    
int main()
{   
    //测试fork函数,用于创建子进程
    //创建子进程
    pid_t pid = fork();
   

    //判断是父进程还是子进程
    if(pid == 0)
    {
        printf("当前是子进程, pid = %d, ppid = %d\n", getpid(), getppid());
    }
    
    if(pid > 0)
    {
        while(1)//父进程没有回收，导致子进程变成僵尸进程
        {
            printf("当前是父进程, pid = %d, ppid = %d\n", getpid(), getppid());
            sleep(1);
        }
    }
    
    for(int i = 0; i < 3; ++i)
    {
        printf("i : %d, pid : %d\n", i, getpid());
    }
    return 0;
}
```



4646就是子进程的pid，可以看到它是一个僵尸进程，同时没有办法被`kill -9`解决。我们可以`kill`掉父进程，子进程被`init`托管来解决这个问题。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230126155532177.png" alt="image-20230126155532177" style="zoom:40%;" />



### 5.4 进程回收

-   在每个进程退出的时候，内核释放该进程的所有资源，包括打开的文件、占用的内存等。但是仍然为其保留一定的信息，这些信息主要指进程控制块PCB的信息（包括PID、退出状态、运行时间等）。
-   父进程可以通过调用`wait()`或`waitpid()`得到它的退出状态的同时彻底清除这个进程。
-   `wait()`和`waitpid()`的功能一样，区别在于：`wait()`函数会阻塞（也就是等待子进程结束），`waitpid()`可以设置不阻塞（即使子进程没有结束也会清除），`waitpid()`还可以指定等待哪个子进程结束。
-   注意：一次`wait()`或`waitpid()`调用只能清理一个子进程，清理多个子进程应该使用循环。



```cpp

#include <sys/types.h>
#include <sys/wait.h>

pid_t wait(int *status);

pid_t waitpid(pid_t pid, int *status, int options);
```

-   功能：等待任意一个子进程结束，如果任意一个子进程结束了，此函数会回收子进程的资源。
-   参数：
    -   `status`：进程退出时的状态信息，传入的是一个`int *`，这是一个传出参数。
-   返回值：
    -   成功返回被回收的子进程的pid
    -   失败返回-1（所有的子进程都结束了，或者调用函数失败/出错了）

调用`wait()`的函数会被挂起（阻塞），直到它的**一个子进程退出**或者收到一个不能被忽略的信号才被唤醒（继续执行）。如果没有子进程了，函数立刻返回-1；如果子进程都已经结束了，也会立即返回-1。





```cpp
#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

int main()
{
    // 有一个进程,创建五个子进程(兄弟关系)  
    pid_t pid;
    for(int i = 0; i < 5; ++i)
    {
        pid = fork();
        if(pid == 0)
        {
            //如果这个进程是子进程,则break,不然创建的子进程会是指数个
            break;
        }
    }
    if(pid > 0)
    {
        //父进程
        while(1)
        {
            printf("parent, pid = %d\n", getpid());
            int ret = wait(NULL);
            printf(" child die, pid = %d\n", ret);
            sleep(1);
        }
    }
    else if(0 == pid)
    {
        //子进程
        while(1)
        {
            printf("child, pid = %d\n", getpid());
            sleep(1);
        }
    }
    return 0;
}
```



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230126163941281.png" alt="image-20230126163941281" style="zoom:40%;" />

出现僵尸进程。



**`waitpid()`函数：**

```cpp
#include <sys/types.h>
#include <sys/wait.h>

pid_t waitpid(pid_t pid, int *status, int options);
```

-   功能：可以回收指定进程号pid的子进程，可以设置为是否阻塞。
-   参数：
    -   `pid`：
        -   \< -1：某个进程组的组ID的负数，例如想回收进程组2的所有进程，则传入`-2`
        -   =-1：回收任意一个的子进程，相当于调用`wait()`，也是最常用的
        -   =0：回收当前进程组的所有子进程
        -   \>0：代表要回收的某个子进程的PID
    -   `status`：与`wait`中相同
    -   `options`：设置阻塞或非阻塞
        -   0：阻塞
        -   宏值：`WNOHANG`,`WUNTRAcED`等
-   返回值：
    -   \> 0返回子进程的pid
    -   =0 非阻塞情况下才会返回0，表示还有子进程存活
    -   -1表示错误或者没有子进程

`wait(s)`相当于调用`waitpid(-1, s, 0)`。

>   关于进程组：
>
>   1）可以打个比方，以家族企业的创业为例，每个进程可以比喻成家族企业的每个成员。 
>
>   2）如果从创业之初，所有家族成员都安分守己，循规蹈矩，默认情况下，就只会有一个公司、一个部门。但是也有些“叛逆”的子弟，愿意为家族公司开疆拓土，愿意成立新的部门。
>
>    3）这些新的部门就是新创建的进程组。如果有子弟“离经叛道”，甚至不愿意呆在家族公司里，他别开天地，另创了一个公司，那这个新公司就是新创建的会话组。由此可见，系统必须要有改变和设置进程组 ID 和会话 ID 的函数接口，否则，系统中只会存在一个会话、一个进程组。

### 5.5 退出信息相关宏函数

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230126164901357.png" alt="image-20230126164901357" style="zoom:40%;" />

```cpp
#include <stdio.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <stdlib.h>
int main()
{
    // 有一个进程,创建五个子进程(兄弟关系)  
    pid_t pid;
    for(int i = 0; i < 5; ++i)
    {
        pid = fork();
        if(pid == 0)
        {
            //如果这个进程是子进程,则break,不然创建的子进程会是指数个
            break;
        }
    }
    if(pid > 0)
    {
        //父进程
        while(1)
        {
            printf("parent, pid = %d\n", getpid());
            // int ret = wait(NULL);
            int st;
            int ret = wait(&st);
            if(-1 == ret)
            {
                break;
            }
            if(WIFEXITED(st))
            {
                //是不是正常退出
                printf("退出的状态码: %d\n", WEXITSTATUS(st));
            }
            if(WIFSIGNALED(st))
            {
                //是不是异常终止
                printf("被哪个信号干掉: %d\n", WTERMSIG(st));
            }
            printf(" child die, pid = %d\n", ret);
            sleep(1);
        }
    }
    else if(0 == pid)
    {
        //子进程
            printf("child, pid = %d\n", getpid());
            sleep(1);
            exit(1);
    }
    return 0;
}
```

可以在子进程中`exit()`退出，默认是0，正常退出，如果子进程没有`exit`而是死循环，可以使用信号kill掉。



## 06. 进程间通信

### 6.1 进程间通讯概念

-   进程是一个独立的资源分配单元，不同进程（这里所说的进程通常指的是用户进程）之间的资源是独立的，没有关联，不能在一个进程中直接访问另一个进程的资源。
-   但是，进程不是孤立的，不同的进程需要进行信息的交互和状态的传递等，因此需要进程间通信（IPC：Inter Process Communication）
-   进程间通信的目的：
    -   数据传输：一个进程需要将它的数据发送给另一个进程。
    -   通知事件：一个进程需要向另一个或一组进程发送消息，通知它（它们）发生了某种事件（如进程终止时需要通知父进程）。
    -   资源共享：多个进程之间共享同样的资源。为了做到这一点，需要内核提供互斥和同步机制。
    -   进程控制：有些进程希望完全控制另一个进程的执行（如Debug进程），此时控制进程希望能够拦截另一个进程的所有陷入和异常，并能够及时知道它的状态改变。



>   同步就是指一个进程在执行某个请求的时候，若该请求需要一段时间才能返回信息，那么这个进程将会一直等待下去，直到收到返回信息才继续执行下去； 异步是指进程不需要一直等下去，而是继续执行下面的操作，不管其他进程的状态。 当有消息返回时系统会通知进程进行处理，这样可以提高执行的效率。



### 6.2 Linux进程间通信方式

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230126195416017.png" alt="image-20230126195416017" style="zoom:40%;" />



### 6.3 匿名管道

-   管道也叫「无名（匿名）管道」，它是UNIX系统IPC（进程间通信）的最古老的形式，所有的UNIX系统都支持这种通信机制。
-   统计一个目录中文件的数目命令：`ls | wc -l`，为了执行该命令，shell创建了两个进程来分别执行`ls`和`wc -l`。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230126195824917.png" alt="image-20230126195824917" style="zoom:40%;" />

>   `|`称为管道符。



### 6.4 管道的特点

-   管道其实是一个在内核内存中维护的缓冲期，这个缓冲器的存储能力是有限的，不同操作系统的大小不一定相同。
-   管道拥有文件的特质：读操作，写操作，匿名管道没有文件实体，「有名管道」有文件实体，但不存储数据。可以按照操作文件的方式对管道进行操作。
-   一个管道是一个字节流，使用管道时不存在消息或者消息边界的概念，从管道读取数据的进程可以读取任意大小的数据块，而不管写入进程写入管道的数据块的大小是多少。
-   通过管道传递的数据是顺序的，从管道中读取出来的字节的顺序和它们被写入管道的顺序是完全一样的。
-   在管道中的数据的传递方向是单向的，一端用于写入，一端用于读取，管道是半双工的。
-   在管道读取数据是一次性操作，数据一旦被读走，它就从管道中被抛弃，释放空间以便写更多的数据，在管道中无法使用`lseek()`来随机访问数据。
-   匿名管道只能在具有公共祖先的进程（父进程与子进程，或者两个兄弟进程，具有亲缘关系）之间使用。

  

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230126202117495.png" alt="image-20230126202117495" style="zoom:40%;" />





### 6.5 为什么可以使用管道进行IPC

最重要的原因是：父子进程之间可以共享文件描述符，指向同一个文件，对于管道也是如此。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230126202627868.png" alt="image-20230126202627868" style="zoom:40%;" />



### 6.6 管道的数据结构

环形队列：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230126202907061.png" alt="image-20230126202907061" style="zoom:40%;" />



### 6.7 匿名管道的使用

**创建匿名管道：**

使用`pipe`系统调用：

```cpp
#include <unistd.h>
int pipe(int pipefd[2]);
```

-   功能；创建一个匿名管道，用来进程间通信
-   参数：`pipedf`数组的第0个元素指向读端，第1个元素指向写端，所以这是一个传出参数。（它们都是文件描述符）
-   返回值：成功0，失败-1。
-   注意：匿名管道只能用于具有关系的进程之间的通信。



子进程写入数据道管道，父进程读取：

```cpp
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>

//子进程发送数据给父进程，父进程读取到数据输出
int main()
{
    //在fork之前创建一个管道
    int pipefd[2];
    int ret = pipe(pipefd);
    if(-1 == ret)
    {
        perror("pipe");
        exit(0);
    }
    //创建子进程
    pid_t pid = fork();
    if(pid > 0)
    {
        //父进程

        //从管道的读取端获取数据
        char buf[1024] = {0};
        read(pipefd[0], buf, sizeof(buf));
        printf("parent recv : %s, pid : %d\n", buf, getpid());
    }
    else if(pid == 0)
    {
        //子进程
        sleep(10);
        //写入数据到管道
        char *str = "hello, i am child";
        write(pipefd[1], str, strlen(str));
    }

    return 0;
}
```

管道默认是阻塞的，如果管道中没有数据，read阻塞，如果管道满了，write阻塞。

但是上面的代码有问题，如果没有`sleep(1)`，则会出现自己发自己读的结果：

```shell
child recv : hello, i am child, pid : 13632
child recv : hello, i am child, pid : 13632
```



**查看管道缓冲区大小：**

```shell
ulimit -a
```



```shell
core file size          (blocks, -c) 0
data seg size           (kbytes, -d) unlimited
scheduling priority             (-e) 0
file size               (blocks, -f) unlimited
pending signals                 (-i) 7282
max locked memory       (kbytes, -l) 64
max memory size         (kbytes, -m) unlimited
open files                      (-n) 65535
pipe size            (512 bytes, -p) 8
POSIX message queues     (bytes, -q) 819200
real-time priority              (-r) 0
stack size              (kbytes, -s) 8192
cpu time               (seconds, -t) unlimited
max user processes              (-u) 7282
virtual memory          (kbytes, -v) unlimited
file locks                      (-x) unlimited
```

当前pipe是8个512 字节，也就是4k。



**查看管道缓冲大小函数：**

```cpp
#include <unistd.h>
long fpathconf(int fd, int name);
```



```cpp
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>

int main()
{
    int pipefd[2];
    int ret = pipe(pipefd);

    long size = fpathconf(pipefd[0], _PC_PIPE_BUF);
    printf("pipe size =  %ld\n", size);
    return 0;
}
```

输出的结果也是4096.



### 6.8 利用管道实现`ps -aux | grep xx`

```cpp
/* 
    实现 ps -aux | grep xxx
    父子进程间通信
    子进程： ps -aux, 子进程结束后，将数据发送给父进程
    父进程：获取到数据，grep过滤

    pipe()
    execlp()
    子进程将标准输出stdout_fileno重定向到管道的写端： dup2()
 */
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>

int main()
{
    //创建一个管道
    int fd[2];
    int ret = pipe(fd);
    if(-1 == ret)
    {
        perror("pipe");
        exit(0);
    }

    //创建子进程，必须要在创建管道之后
    pid_t pid = fork();
    
    if(pid > 0)
    {
        //父进程
        //关闭写端
        close(fd[1]);
        //从管道中读取数据，
        char buf[1024] = {0};

        int len = -1;
        while((len = read(fd[0], buf, sizeof(buf) - 1)) > 0)
        {
            //过滤数据然后输出
            printf("%s", buf);
            memset(buf, 0, 1024);
        }
        wait(NULL);

    }
    else if(0 == pid)
    {
        //子进程
        //关闭读端
        close(fd[0]);
        
        //文件描述符的重定向 stdout_fileno -> fd[1]
        //dup2是将fd2复制为fd1，可以想象为对第二个参数的重定向
        dup2(fd[1], STDERR_FILENO);
        //printf("hello world\n");
        //执行ps aux
        execlp("ps", "ps", "aux", NULL);
        perror("execlp");
        exit(0);
    }

    else
    {
        perror("fork");
        exit(-1);
    }
    return 0;
}
```



子进程执行`ps -aux`向父进程发送数据，父进程使用`grep`过滤（上述代码未实现过滤，直接输出）。



### 6.9 管道读写的特点

使用管道的时候，需要注意以下几种特殊的情况（假设都是阻塞I/O操作）

1.   所有指向管道写端的文件描述符都关闭了（管道写端的引用计数为0），有进程从管道的读端读数据，那么管道中剩余的数据被读取以后，再次`read`会返回0，就像读到文件末尾一样。
2.   如果有指向管道写端的文件描述符没有关闭（管道的写端引用计数大于0），而持有管道写端的进程也没有往管道中写数据，这个时候有进程从管道中读取数据，那么管道中剩余的数据被读取后，再次`read`会阻塞，直到管道中有数据可以读了，才读取数据并返回（读到的字节个数）。
3.   如果所有指向管道读端的文件描述符都关闭了（管道读端的引用计数为0），这个时候有进程向管道中写数据，那么该进程会收到一个信号`SIGPIPE`，通常会导致进程异常终止。
4.   如果有指向管道读端的文件描述符没有关闭（管道的读端引用计数大于0），而持有管道读端的进程也没有从管道中读数据，这时有进程向管道中写数据，那么在管道被写满的时候，再次`write`会阻塞，直到管道中有空位置才能再次写入数据并返回。



**总结：**

读管道：

-   管道中有数据，`read`返回实际读到的字节数。
-   管道中无数据：
    -   写端被全部关闭，`read`返回0（相当于读到文件末尾）
    -   写端没有完全关闭，`read`阻塞等待，知道有数据



写管道：

-   管道读端全部被关闭，进程异常终止，收到`SIGPIPE`信号。
-   管道读端没有全部关闭：
    -   管道满了，`write`会阻塞
    -   管道没有满，`write`写入数据，并返回实际写入的字节数。



### 6.10 设置管道非阻塞

管道也是文件，用文件描述符控制，所以我们可以使用`fcntl`来修改。

```cpp
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
//子进程发送数据给父进程，父进程读取到数据输出
/* 
    设置管道非阻塞
    int flags = fcntl(fd[0], F_GETFL);
    flags |= O_NONBLOCK //修改flag
    fcntl(fd[0], F_SETFL, flags);//设置新的flag
 */
int main()
{
    //在fork之前创建一个管道
    int pipefd[2];
    int ret = pipe(pipefd);
    if(-1 == ret)
    {
        perror("pipe");
        exit(0);
    }
    //创建子进程
    pid_t pid = fork();
    if(pid > 0)
    {
        //父进程
        printf("i am parent process, pid : %d\n", getpid());

        //关闭写入端
        close(pipefd[1]);
        //设置管道非阻塞
        int flags = fcntl(pipefd[0], F_GETFL); 
        flags |= O_NONBLOCK;
        fcntl(pipefd[0], F_SETFL, flags);
        //从管道的读取端获取数据
        char buf[1024] = {0};
        while(1)
        {
            int len = read(pipefd[0], buf, sizeof(buf));
            printf("len: %d\n", len);
            printf("parent recv : %s, pid : %d\n", buf, getpid());
            sleep(1);

            //如果没有清空buf，则在不阻塞状态下会一直输出
            memset(buf, 0, 1024);
            //向管道中发送数据
            // char *str = "hello, i am parent";
            // write(pipefd[1], str, strlen(str));
            // sleep(1);
        }
    }

    else if(pid == 0)
    {
        //子进程
        printf("i am child process, pid : %d\n", getpid());
        //关闭读端
        close(pipefd[0]);
        char buf[1024] = {0};
        //写入数据到管道
        while(1)
        {
            //向管道中发送数据
            char *str = "hello, i am child";
            write(pipefd[1], str, strlen(str));
            sleep(5);

            // read(pipefd[0], buf, sizeof(buf));
            // printf("child recv : %s, pid : %d\n", buf, getpid());
        }
    }

    return 0;
}
```

输出：

```txt
len: 17
parent recv : hello, i am child, pid : 17521
len: -1
parent recv : , pid : 17521
len: -1
parent recv : , pid : 17521
len: -1
parent recv : , pid : 17521
len: -1
parent recv : , pid : 17521
```



### 6.11 有名管道简介

-   匿名管道，由于没有名字，只能用于亲缘关系的进程间通信。为了克服这个缺点，提出了有名管道（FIFO），也叫命名管道、FIFO文件。FIFO就是先进先出。
-   有名管道（FIFO）不同于匿名管道之处在于它提供了一个路径名与之关联，以FIFO的文件形式存在于文件系统中，并且其打开方式与打开一个普通文件是一样的，这样即使与FIFO的创建进程不存在亲缘关系的进程，只要可以访问该路径，就能够彼此通过FIFO相互通信。因此，通过FIFO，不相关的进程也能交换数据。
-   一旦打开了FIFO，就能在它上面使用与操作匿名管道和其他文件的系统调用一样的I/O系统调用了（例如`read()`,`write()`,`close()`。与管道一样，FIFO也有一个写入端和读取端，并且从管道中读取数据的顺序和写入的顺序是一样的。
-   有名管道（FIFO）和匿名管道（pipe）的不同点在于：
    -   FIFO在文件系统中作为一个特殊文件存在，但FIFO的内容却存放在内存中。
    -   当使用FIFO的进程退出后，FIFO文件将继续保存在文件系统中以便后续使用。
    -   FIFO有名字，不相关的进程可以通过打开有名管道进行通信。



>   Linux有七种文件，其中管道文件就是FIFO文件。



### 6.12 有名管道的使用

-   通过命令创建有名管道

    -   `mkfifo 名字`

-   通过函数创建有名管道

    -   ```cpp
        #include <sys/types.h>
        #include <sys/stat.h>
        
        int mkfifo(const char *pathname, mode_t mode);
        ```

    -   `pathname`：管道路径

    -   `mode`：文件的权限，和`open()`的`mode`是一样的，是一个八进制的数，以`0`开头，与`umask`操作

    -   成功返回0，失败返回-1

-   一旦使用`mkfifo`创建了一个FIFO，就可以使用`open()`打开它，常见的文件I/O函数都可以用于FIFO。

-   FIFO严格遵循先进先出，对管道及FIFO的读总是从开始处返回数据，对它们的写则把数据添加到末尾。它们不支持例如`lseek()`等文件定位操作。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230128000115564.png" alt="image-20230128000115564" style="zoom:40%;" />

p代表管道文件。



**有名管道的注意事项：**

1.   一个为只读而打开一个管道的进程会阻塞，直到另一个进程为只写打开管道
2.   一个为只写而打开一个管道的进程会阻塞，直到另一个进程为只读打开管道

**读管道：**

-   管道中有数据，`read`返回实际读到的字节数
-   管道中无数据：
    -   管道写端全部关闭：`read`返回0（相当于读到文件末尾，这个比较特殊）
    -   写端没有全部被关闭：`read`阻塞等待。

**写管道：**

-   管道读端全部关闭：进程异常终止（收到一个`SIGPIPE`信号）
-   管道读端没有全部关闭：
    -   管道满了，`write`会阻塞
    -   管道没满，`write`将数据写入，返回实际写入的字节数

**`write.c`：**

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>


int main()
{
    //判断文件是否存在
    int ret = access("test", F_OK);
    if(-1 == ret)
    {
        printf("管道不存在, 创建管道\n");

        ret = mkfifo("test", 0664);

        if(-1 == ret)
        {
            perror("mkfifo");
            exit(0);
        }
    }

    //以只写的方式打开管道
    int fd = open("test", O_WRONLY);
    if(-1 == fd)
    {
        perror("open");
        exit(0);
    }

    //写数据,需要启动read
    for(int i = 0; i < 100; ++i)
    {
        char buf[1024];
        sprintf(buf, "hello, %d\n", i);
        printf("write data : %s\n", buf);
        write(fd, buf, strlen(buf));
        sleep(1);
    }
    close(fd);
    return 0;
}
```



**`read.c`：**

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>

//读取数据
int main()
{
    //打开管道文件
    int fd = open("test", O_RDONLY);
    if(-1 == fd)
    {
        perror("open");
        exit(0);
    }

    //读数据
    while(1)
    {
        char buf[1024];
        int len = read(fd, buf, sizeof(buf));
        if(0 == len)
        {
            //表示写端断开
            printf("写端端开连接");
            break;
        }

        printf("recv buf : %s\n", buf);
    }
    close(fd);
    return 0;
}
```

需要同时打开写端和读端，如果断开一个，则另一个也会断开。



### 6.13 有名管道实现简单聊天

只实现了你发一条我发一条。

**chatA.c**

```cpp
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>


int main()
{
    //1. 判断管道文件是否存在
    int ret = access("fifo1", F_OK);
    if(-1 == ret)
    {
        //文件不存在
        printf("管道不存在, 创建对应的有名管道\n");;
        ret = mkfifo("fifo1", 0664);
        if(-1 == ret)
        {
            perror("mkfifo");
            exit(-1);
        }
    }

    ret = access("fifo2", F_OK);
    if(-1 == ret)
    {
        //文件不存在
        printf("管道不存在, 创建对应的有名管道\n");;
        ret = mkfifo("fifo2", 0664);
        if(-1 == ret)
        {
            perror("mkfifo");
            exit(-1);
        }
    }

    //2. 以只写的方式打开文件
    int fdw = open("fifo1", O_WRONLY);
    if(-1 == fdw)
    {
        perror("open");
        exit(-1);
    }

    printf("打开fifo1成功, 等待写入\n");

    //3. 以只读的方式打开fifo2
    int fdr = open("fifo2", O_RDONLY);
    if(-1 == fdr)
    {
        perror("open");
        exit(-1);
    }

    printf("打开fifo2成功, 等待写入\n");

    char buf[128];
    //循环写读数据
    while(1)
    {
        memset(buf, 0, 128);
        //获取标准输入的数据
        fgets(buf, 128, stdin);
        //写数据
        ret = write(fdw, buf, strlen(buf));
        if(-1 == ret)
        {
            perror("write");
            exit(-1);
        }

        //5. 读取fifo2中的数据
        memset(buf, 0, 128);
        ret = read(fdr, buf, 128);
        if(ret <= 0)
        {
            perror("read");
            break;
        }
        printf("buf : %s\n", buf);
    }
    
    //关闭文件描述符
    close(fdr);
    close(fdw);

    return 0;
}
```



**chatB.c**

```cpp
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>


int main()
{
    //1. 判断管道文件是否存在
    int ret = access("fifo1", F_OK);
    if(-1 == ret)
    {
        //文件不存在
        printf("管道不存在, 创建对应的有名管道\n");;
        ret = mkfifo("fifo1", 0664);
        if(-1 == ret)
        {
            perror("mkfifo");
            exit(-1);
        }
    }

    ret = access("fifo2", F_OK);
    if(-1 == ret)
    {
        //文件不存在
        printf("管道不存在, 创建对应的有名管道\n");;
        ret = mkfifo("fifo2", 0664);
        if(-1 == ret)
        {
            perror("mkfifo");
            exit(-1);
        }
    }

    //2. 以只读的方式打开文件
    int fdr = open("fifo1", O_RDONLY);
    if(-1 == fdr)
    {
        perror("open");
        exit(-1);
    }

    printf("打开fifo1成功, 等待读取\n");

    //3. 以只写的方式打开fifo2
    int fdw = open("fifo2", O_WRONLY);
    if(-1 == fdw)
    {
        perror("open");
        exit(-1);
    }

    printf("打开fifo2成功, 等待写入\n");

    char buf[128];
    //循环读写数据
    while(1)
    {
        memset(buf, 0, 128);
        //5. 读取fifo2中的数据
        memset(buf, 0, 128);
        ret = read(fdr, buf, 128);
        if(ret <= 0)
        {
            perror("read");
            break;
        }
        printf("buf : %s\n", buf);

        //获取标准输入的数据
        fgets(buf, 128, stdin);
        //写数据
        ret = write(fdw, buf, strlen(buf));
        if(-1 == ret)
        {
            perror("write");
            exit(-1);
        }
    }
    
    //关闭文件描述符
    close(fdr);
    close(fdw);

    return 0;
}
```



### 6.14 内存映射简介

-   内存映射（Memory-mapped I/O）是将磁盘文件的数据映射到内存，用户通过修改内存就可以修改磁盘文件。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230128154350211.png" alt="image-20230128154350211" style="zoom:50%;" />

可以看到文件的存储的映射部分，位于堆和栈之间，也是动态库加载的地方。

如果有两个进程映射一个文件，则可以实现进程之间的通信。



### 6.15 内存映射的系统调用

```cpp
#include <sys/mman.h>
void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset);
```

`mmap`：

-   功能：将一个文件或者设备的数据映射到内存中

-   参数：

    -   `void *addr`：传出参数，我们传入一个NULL就行，具体地址由内核指定（这也是最合适的方式）。它和返回值相同。

    -   `length`：要映射的数据的长度，这个值要>0。建议使用文件的长度（获取文件长度可以用`stat()`或`lseek()`）。如果这个长度没有达到「分页」，默认会取分页的整数倍。

    -   `prot`：对申请的内存映射区的操作权限，它有下面几种权限：

        -   ```
            PROT_EXEC  Pages may be executed.可执行
            
            PROT_READ  Pages may be read.读
            
            PROT_WRITE Pages may be written.写
            
            PROT_NONE  Pages may not be accessed. 没有权限
            ```

        -   要操作映内存，必须要有读权限。可以有多个权限，用`|`OR操作结合。

    -   `flags`： flags contained neither `MAP_PRIVATE` or `MAP_SHARED`, or contained both of these values

        -   `MAP_SHARED`：映射区的数据会自动和磁盘文件进行同步，进程间通信，必须要有这个选项
        -   `MAP_PRIVATE`：映射区的数据和磁盘文件不同步，对原来的文件不会修改，会重新创建一个新的文件。（copy on write，写时拷贝，和fork操作一样）。

    -   `fd`：需要映射的文件的文件描述符：

        -   通过`open`得到，`open`的是一个磁盘文件
        -   注意：文件的大小不能为0；`open`指定的权限不能和`prot`参数有冲突（`open`的权限需要大于`prot`参数的权限）。

    -   `offset`：偏移量，表示从文件的某个地方开始偏移，必须是4k的整数倍。一般不用，0表示不偏移，从文件的开头开始操作。

-   返回值：返回创建的内存的首地址，如果失败返回`MAP_FAILED`，这是一个宏：`(void *) -1`。



```cpp
int munmap(void *addr, size_t length);
```

-   功能：释放内存映射
-   参数：
    -   `addr`：要释放的内存的首地址
    -   `length`：要释放的内存大小，和`mmap`中的`length`参数的值一样。



### 6.16 使用内存映射实现进程间通信

1.   有关系的进程（父子进程）
     -   还有没子进程的时候：
         -   通过唯一的父进程，先创建内存映射区
     -   有了内存映射区后，创建子进程
     -   父子进程共享创建的内存映射区
2.   没有关系的进程间通信
     -   准备一个大小不是0的磁盘文件
     -   进程1 通过磁盘文件创建内存映射区
         -   得到一个操作内存的指针
     -   进程2 通过磁盘文件创建内存映射区
         -   得到一个操作内存的指针
     -   使用内存映射区进行通信



**注意：内存映射区通信，是不阻塞的。**



**实现父子进程的通信：**

```cpp
/* 

 */
#include <stdio.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdlib.h>
#include <wait.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>

int main()
{
    //1. 打开文件
    int fd = open("test.txt", O_RDWR);
    //需要判断fd是否打开成功, 这里没写
    
    //获取文件大小,使用lseek
    int size = lseek(fd, 0, SEEK_END);
    
    //2. 创建内存映射区
    void*  ptr = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if(MAP_FAILED == ptr)
    {
        perror("mmap");
        exit(-1);
    }

    //3. 创建子进程
    pid_t pid = fork();

    if(pid > 0)
    {
        //父进程, 读数据
        
        //等待子进程结束
        wait(NULL);
        
        char buf[128];
        strcpy(buf, (char*) ptr);
        printf("read data : %s \n", buf);
    }
    else if(0 == pid)
    {
        //子进程
        strcpy((char*)ptr, "hello, son!");
    }
    
    //关闭内存映射区
    munmap(ptr, size);
    return 0;
}
```



**实现普通进程间的通信：**

**mmapA.c**

```cpp
#include <stdio.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdlib.h>
#include <wait.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>

int main()
{
    //创建一个文件
    int fd = open("test1.txt", O_CREAT | O_RDWR, 0664);
    char * str = "hello, test";
    write(fd, str, strlen(str));
    //获取文件大小
    int size = lseek(fd, 0, SEEK_END);

    //创建内存映射
    void* ptr = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

    if(MAP_FAILED == ptr)
    {
        perror("mmap");
        exit(-1);
    }
    //写入
    // strcpy((char*)ptr, "hello, son!");

    munmap(ptr, size);
    close(fd);
    return 0;
}
```

其实如果用`strcpy`，会覆盖原来的`hello, test`字符串。

**mmapB.c**

```cpp
#include <stdio.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdlib.h>
#include <wait.h>
#include <sys/types.h>
#include <unistd.h>
#include <string.h>

int main()
{
    //创建一个文件
    int fd = open("test1.txt", O_CREAT | O_RDWR, 0664);

    //获取文件大小
    int size = lseek(fd, 0, SEEK_END);

    //创建内存映射
    void* ptr = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

    if(MAP_FAILED == ptr)
    {
        perror("mmap");
        exit(-1);
    }
    //读取
    char buf[128];
    strcpy(buf, (char*)ptr);
    printf("recv data : %s\n", buf);
    munmap(ptr, size);
    close(fd);
    return 0;
}
```



### 6.17 内存映射的注意事项

**如果`mmap`的返回值`ptr`做`++`操作`ptr++`，`munmap`是否能够成功？**

```cpp
void* ptr = mmap(...);
ptr++;
```

`void*`指针在GNU下可以进行++操作的，但是不建议这样做，这样做会导致`munmap`出错。



**如果`open`时`O_RDONLY`，`mmap`时`prot`参数指定`PROT_READ ｜ PROT_WRITE`会怎样？**

错误，`mmap`会返回`MAP_FAILED`。`open`的权限要大于`mmap`的`port`权限，建议是保持一致。



**如果文件偏移量为1000会怎样？**

偏移量必须是4k的整数倍，但是实际上会是分页的整数倍（分页一般是4096）。



**`mmap`什么时候回调用失败？**

-   第二个参数`length`为0
-   第三个参数`prot`只指定了写权限；或者`prot`的权限小于`open`时的权限



**可以`open`的时候`O_CREATE`一个新文件来创建映射区吗？**

这样做是可以的，但是创建的文件大小为0是不行的。

需要对新文件进行扩展：

-   `lseek()`
-   `truncate()`



**`mmap`后关闭文件描述符，对`mmap`映射有没有影响？**

```cpp
int fd = open(...);

mmap(..., fd, ..);
close(fd);
```

在这个时候映射群还是存在的，没有释放这块内存，创建映射区的`fd`关闭没有任何影响，`mmap`会拷贝`fd`



**对`ptr`越界会怎样？**

```cpp
void* ptr = mmap(NULL, 100, ....);
```

这样会有4096个字节，不同系统可能不同。

越界操作非法内存，会产生「段错误」



### 6.18 内存映射完成文件复制

1.   对源文件进行内存映射
2.   创建一个新文件（大小为0），需要拓展为非0
3.   把新文件的数据映射到内存中
4.   通过内存拷贝将一个文件的内存数据拷贝到新的文件内存中
5.   释放资源



**copy.c**

```cpp
#include <stdio.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>

int main()
{
    //打开源文件
    int fd = open("english.txt", O_RDWR);
    if(-1 == fd)
    {
        perror("open");
        exit(0);
    }
    //获取原始文件的大小
    int size = lseek(fd, 0, SEEK_END);

    //创建一个新文件,并拓展
    int fd1 = open("copy.txt", O_CREAT | O_RDWR, 0664);

    if(-1 == fd1)
    {
        perror("open");
        exit(-1);
    }

    //拓展
    truncate("copy.txt", size);
    write(fd1, " ", 1);
    
    //分别内存映射
    void* ptr = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    void* ptr1 = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd1, 0);
    if(MAP_FAILED == ptr)
    {
        perror("mmap");
        exit(0);
    }
    if(MAP_FAILED == ptr1)
    {
        perror("mmap");
        exit(0);
    }
    //拷贝
    memcpy(ptr1, ptr, size);
    
    //释放资源
    munmap(ptr1, size);
    munmap(ptr, size);
    close(fd);
    close(fd1);
    return 0;
}
```



### 6.19 匿名内存映射

所谓「匿名映射」，就是不需要文件实体进行内存映射，只能做父子进程之间的通信。

匿名内存映射，需要把`mmap`的`flags`写成`MAP_ANONYMOUS`（当然还是需要`MAP_SHARED`）。这个映射不需要任何文件，指定了这个参数，`fd`需要指定为`-1`。



**mmap-anon.c**

父进程向子进程发送数据。

```cpp
#include <stdio.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <sys/wait.h>

int main()
{
    // 1. 创建匿名内存映射区
    int length = 4096;
    void* ptr = mmap(NULL, length, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_SHARED, -1, 0);

    if(MAP_FAILED == ptr)
    {
        perror("mmap");
        exit(-1);
    }

    //父子进程间通信
    pid_t pid = fork();

    if(pid > 0)
    {
        //父进程
        strcpy((char*) ptr, "hello, world");
        wait(NULL);
    }
    else if(pid == 0)
    {
        //子进程
        //内存映射是非阻塞的,需要先停一秒
        sleep(1);
        printf("%s\n", (char*) ptr);

    }

    //释放内存映射区
    int ret = munmap(ptr, length);

    if(-1 == ret)
    {
        perror("munmap");
        exit(-1);
    }


    return 0;
}
```



## 07. 信号

### 7.1 信号的概念

-   信号是Linux进程间通信的最古来的方式之一，是事件发生时对进程的通知机制，有时也称之为软件中断，它是在软件层次上对中断机制的一种模拟，是一种异步通信（一个一个）的方式。信号可以导致一个正在运行的进程被另一个正在运行的异步进程中断，转而处理某一个突发事件。

-   发往进程的诸多信号，通常都是源于内核。引发内核为进程产生信号的各类事件如下：
    -   对于前台进程，用户可以通过输入特殊的终端字符来给它发送信号。比如输入`ctrl + c`通常给进程发送一个中断信号（9号信号）。
    -   硬件发生异常，即硬件检测到一个错误条件并通知内核，随即再由发送相应信号给相关进程。比如执行一条异常的机器指令，诸如被0除，或者引用了无法访问的内存区域。
    -   系统状态变化，比如`alarm`定时器到期将引起`SIGALRM`信号，进程执行的CPU时间超限，或者该进程的某个子进程退出。
    -   运行`kill`命令或调用`kill`函数。
    
-   使用信号的两个主要目的是：
    -   让进程知道已经发生了一个特定的事情
    
    -   强迫进程执行它自己代码中的信号处理程序
    
-   信号的特点：
    -   使用简单
    
    -   不能携带大量信息
    
    -   满足某个特定条件才发送
    
    -   优先级比较高
    
-   查看系统定义的信号列表：`kill -l`

-   共有62个信号（32、33缺失），前31个信号为常规信号，其余为实时信号。



### 7.2 Linux信号一览表

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230130165131731.png" alt="image-20230130165131731" style="zoom:40%;" />



### 7.3 信号的5种默认处理动作

-   查看i新年好的详细信息：`man 7 signal`
-   信号的5种默认处理动作：
    -   `Term`：终止进程
    -   `Ign`：当前进程忽略掉这个信号
    -   `Core`：终止进程，并生成一个Core文件（类似于dump文件？）
    -   `Stop`：继续当前进程
    -   `Cont`：继续执行当前被暂停的进程（与`Stop`对应）
-   信号本身的几种状态：产生、未决、递达
-   `SIGKILL`（9号信号）和`SIGSTOP`（19号信号）信号不能被捕捉、阻塞或者忽略，只能执行默认动作。



想要生成core文件，需要`ulimit -c 1024`命令。

**core.c**

```cpp
#include <stdio.h>
#include <string.h>

int main()
{
    char* buf;
    //指针没有指向合法内存
    strcpy(buf, "hello");

    return 0;
}
```



执行产生了core文件后，可以用gdb调试`a.out`，在gdb中使用`core-file core文件`查看错误信息，能显示具体的错误发生在哪一行。



### 7.4 信号相关的函数

```cpp
#include <sys/types.h>
#include <signal.h>
int kill(pid_t pid, int sig);
```

-   功能：给某个进程或者进程组（pid）发送某个信号（sig）

-   参数：pid和sig：

    -   pid：
        -   \> 0则发送给对应的进程pid
        -   \=0：发送给当前进程的进程组
        -   \-1：发送给每一个有权限接收这个信号的进程（例如普通用户不能给系统进程发送信号）
        -   \<-1：发送给某个进程组（取绝对值）
    -   sig：建议使用宏值

-   举例：

    ```cpp
    kill(getpid(), 9);
    kill(getppid(), 9);
    ```



```cpp
int raise(int sig);
```

-   功能：给当前进程发送信号
-   `sig`参数：要发送的信号
-   返回值：成功为0，失败返回-1。
-   等同于`kill(getpid(), sig)`。



```cpp
void abort(void);
```

-   功能：发送`SIGABRT`信号给当前进程，杀死当前进程
-   等同于：`kill(getpid(), SIGABRT)`



```cpp
unsigned int alarm(unsigned int seconds);
```

-   功能：设置定时器。函数调用开始倒计时，当倒计时为0的时候，函数会给当前的进程发送一个信号：`SIGALARM`。同时在终端打印`Alarm clock`或者显示`interrupted by signal 14: SIGALRM`。
    -   `SIGALARM`：默认终止当前的进程，每一个进程有且仅有一个定时器（唯一！）
-   参数：`seconds`倒计时的时长，单位是秒。如果参数为0，表示定时器无效！取消一个定时器，可以通过`alarm(0)`取消（重新调用`alarm()`会导致之前设置的失效）。
-   返回值：
    -   之前没有定时器，返回0；
    -   之前有定时器，返回上一个倒计时剩余的时间。
-   该函数是不阻塞的。



**测试：**

```cpp
//1秒电脑能数多少个数
#include <stdio.h>
#include <unistd.h>

int main()
{
    alarm(1);
    
    int i = 0;
    while(1)
    {
        printf("%d\n", ++i);
    }
}
```

如果重定向到文件中，会比打印到终端多几十上百倍。

>   计算机中：
>
>   实际时间 = 内核时间 + 用户时间 + IO消耗的时间（还有其他）
>
>   进行文件IO操作，比较浪费时间。

定时器和进程的状态无关（采用自然定时法），无论进程处于什么状态，定时器都会计时⌛️。



```cpp
#include <sys/time.h>
int setitimer(int which, const struct itimerval *new_value, struct itimerval *old_value);
```

-   功能：设置定时器。可以替代`alarm()`函数，精度比`alarm`要高，能够达到微秒us，可以实现周期性的定时。

-   参数：

    -   `which`：以什么方式计算时间

        -   `ITMER_REAL`：真实时间（包含了用户时间、内核时间、切换时间、IO等），时间到达会发送`SIGALARM`信号。**常用**。
        -   `ITIMER_VIRTUAL`：虚拟时间（用户时间），时间到达，发送`SIGALRM`。
        -   `ITIMER_PROF`：以该进程在用户态和内核态下所消耗的时间来计算，时间到达，发送`SIGPROF`信号

    -   `new_value`：设置定时器的属性，是`struct itimerval`类型：

        -   `struct itimerval`：

            ```cpp
            struct itimerval { //定时器的结构体
                struct timeval it_interval; /* next value */ //间隔时间
                struct timeval it_value;    /* current value */ //延迟多长时间执行定时器
            };
            //过10秒后，每隔2秒执行一起，2和10分别对应上面两个参数
            
            struct timeval {//时间的结构体
                time_t      tv_sec;         /* seconds */ //秒数
                suseconds_t tv_usec;        /* microseconds */ //微秒
            };
            //代表秒数+微秒数
            ```

            

    -   `old_value`：传出参数。记录上一次定时的时间参数，一般不会使用，指定为`NULL`。

-   返回值：0成功，-1失败，并设置errno。



**setitimer.c**

```cpp
#include <stdio.h>
#include <sys/time.h>
#include <stdlib.h>

int main()
{
    //过三秒后每隔两秒定时一次
    //分配在栈上
    struct itimerval new_value;
    //设置间隔时间
    new_value.it_interval.tv_sec = 2;
    new_value.it_interval.tv_usec = 0;
    
    //设置延迟的时间
    new_value.it_value.tv_sec = 3;
    new_value.it_value.tv_usec = 0;
    
    int ret = setitimer(ITIMER_REAL, &new_value, NULL);
    printf("定时器开始了\n");
    if(-1 == ret)
    {
        perror("setitimer");
        exit(0);
    }
    getchar();
    return 0;
}
```



### 7.5 信号捕捉的函数

默认的`SIGARLM`会终止当前进程，信号捕捉可以用自己的方式处理。



```cpp
#include <signal.h>

typedef void (*sighandler_t)(int);

sighandler_t signal(int signum, sighandler_t handler);
```

`signal()`是一个ANSI C信号处理函数。`signal()`在不同的UNIX和Linux版本有不同的情况，为了避免这种情况，建议使用`sigaction()`函数。

-   功能：设置某个信号的捕捉行为
-   参数：
    -   `signum`：要捕捉的信号，一般用宏值。
    -   `handler`：捕捉到信号要如何处理，是一个函数指针`typedef void (*__sighandler_t) (int)`，`int`类型的参数表示捕捉到的信号的值，可以用宏值
        -   `SIG_IGN`：忽略信号
        -   `SIG_DEF`：使用信号默认的行为，相当于没有捕捉。
        -   回调函数：这个函数是内核调用，程序员只负责写。
-   返回值：
    -   成功，返回上一次注册的信号处理函数的地址，第一次调用返回`NULL`。
    -   失败，返回`SIG_ERR`的宏，并设置错误号errno。



>   回调函数需要程序员实现，不是程序员调用的，而是当信号产生由内核调用（这个情况）。
>
>   函数指针是实现回调的手段，函数实现之后，将函数名放到函数指针位置即可。



<mark>`SIGKILL`和`SIGSTOP`不能被捕捉，不能被忽略。</mark>



**signal.c**

```cpp
#include <stdio.h>
#include <sys/time.h>
#include <stdlib.h>
#include <signal.h>

void myalarm(int num)
{
    printf("捕捉到的信号的编号是 : %d\n", num);
    printf("xxxxxx\n");
}

int main()
{
    //注册信号捕捉,需要写在最前面,防止信号已经发送还没来得及捕捉
    signal(SIGALRM, myalarm);
    
    //过三秒后每隔两秒定时一次
    //分配在栈上
    struct itimerval new_value;
    //设置间隔时间
    new_value.it_interval.tv_sec = 2;
    new_value.it_interval.tv_usec = 0;
    
    //设置延迟的时间
    new_value.it_value.tv_sec = 3;
    new_value.it_value.tv_usec = 0;
    
    int ret = setitimer(ITIMER_REAL, &new_value, NULL);
    printf("定时器开始了\n");
    if(-1 == ret)
    {
        perror("setitimer");
        exit(0);
    }
    getchar();
    return 0;
}
```

过三秒后打印`捕捉到的信号的编号是 : 14`，并每隔两秒再打印一次。





```cpp
#include <signal.h>

int sigaction(int signum, const struct sigaction *act, struct sigaction *oldact);
```

-   作用：与`signal()`相似，检查或者改变一个信号的处理动作。也就是信号捕捉。
-   参数：
    -   `signum`：需要捕捉的信号编号，推荐使用宏值。
    -   `act`：一个`sigaction`结构体指针，捕捉到信号之后相应的处理动作。
    -   `oldact`：上一次对信号捕捉相关的设置，一般不使用，传递一个`NULL`。
-   返回值：成功返回0，失败返回-1。



**sigaction结构体的定义：**

```cpp
struct sigaction {
    void     (*sa_handler)(int); //信号捕捉到之后的处理函数
    void     (*sa_sigaction)(int, siginfo_t *, void *); //函数指针，不常用
    sigset_t   sa_mask; //临时阻塞信号集，在信号捕捉函数执行过程中，会临时阻塞某些信号。函数执行完就不阻塞了。
    
    //指定一个标记，一般用宏值
    //0和SA_SIGINFO用的比较多
    //0表示使用sa_handler
    //SA_SIGINFO表示使用sa_sigaction
    int        sa_flags;

    void     (*sa_restorer)(void); //废弃了
    
};
```



`sigaction()`函数如果`sa_flags`设置为0，只能捕捉一次`SIGALRM`，需要设置为`SA_RESTART`：

[使用sigaction信号捕捉与getchar](https://blog.csdn.net/fan_Mk/article/details/123638182)



**sigaction.c**

```cpp
#include <stdio.h>
#include <sys/time.h>
#include <stdlib.h>
#include <signal.h>

void myalarm(int num)
{
    printf("捕捉到的信号的编号是 : %d\n", num);
    printf("xxxxxx\n");
}

int main()
{
    struct sigaction act;
    act.sa_flags = SA_RESTART;
    act.sa_handler = myalarm;
    //清空临时阻塞信号集
    sigemptyset(&act.sa_mask);
    //注册信号捕捉,需要写在最前面,防止信号已经发送还没来得及捕捉
    sigaction(SIGALRM, &act, NULL);
    
    //过三秒后每隔两秒定时一次
    //分配在栈上
    struct itimerval new_value;
    //设置间隔时间
    new_value.it_interval.tv_sec = 2;
    new_value.it_interval.tv_usec = 0;
    
    //设置延迟的时间
    new_value.it_value.tv_sec = 3;
    new_value.it_value.tv_usec = 0;
    
    int ret = setitimer(ITIMER_REAL, &new_value, NULL);
    printf("定时器开始了\n");
    if(-1 == ret)
    {
        perror("setitimer");
        exit(0);
    }
    //如果sa_flags = 0, 则这里不能用getchar(),要使用死循环
     getchar();
    // while(1)
    {}
    return 0;
}
```

建议使用`sigaction()`，支持POSIX标准，而`signal()`是ANSI C标准。

### 7.6 信号集

-   许多信号相关的系统调用都需要能表示一组不同的信号，多个信号可以使用一个称之为信号集的数据结构来表示，其系统数据类型为`sigset_t`。
-   在PCB中有两个非常重要的信号集。一个称之为"阻塞信号集"（阻塞信号被处理），另一个称之为“未决信号集”（没有递达的信号）。这两个信号集都是内核使用位图机制来实现的。但操作系统不允许我们直接对这两个信号集进行位操作。而需自定义另外一个集合，借助信号集操作函数来对PCB中这两个信号集进行修改。
-   信号的"未决"是一种状态，指的是从信号产生到信号被处理前的这一段时间。
-   信号的“阻塞”是一个开关动作，值得是阻止信号被处理，但不是阻止信号产生。
-   信号的阻塞就是让系统暂时保留信号等着以后发送。由于另外有办法让系统忽略信号，所以一般情况下信号的阻塞只是暂时的，只是为了防止信号打断敏感的操作。



### 7.7 阻塞信号集和未决信号集

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230130211120602.png" alt="image-20230130211120602" style="zoom:40%;" />



1.   用户通过键盘 `Ctrl + C`，给当前进程发送2号信号`SIGINT`，信号被创建
2.   信号产生但是没有被处理（未决）
     -   在内核中将所有的没有被处理的信号存储在一个集合中，这个集合就是「未决信号集」
     -   `SIGINT`信号状态被存储在第二个标志位上
         -   标志位为1，表示信号处于未决状态。
         -   0则代表不是
3.   这个未决状态的信号，需要被处理。处理的时候，会与「阻塞信号集」进行比较：
     -   阻塞信号集默认不阻塞任何信号（全是0），如果某一个位置是1，则这个位置对应的信号被阻塞。
     -   可以手动系统调用决定阻塞哪个信号
4.   在处理的时候和阻塞信号集中的标志位进行查询，看是否对该信号设置了阻塞
     -   如果没有阻塞，这个信号就被处理
     -   如果阻塞，这个信号就继续处于未决状态，知道阻塞解除

>   所以说信号的“阻塞”是一个开关动作。



### 7.8 信号集相关函数

下面信号集相关的函数都是对自定义的信号集进行操作。

```cpp
#include <signal.h>

int sigemptyset(sigset_t *set); //清空信号集中的数据，将信号集中所有的标志位置0，参数是传出参数，是我们需要操作的信号集，返回结果0真-1失败。
int sigfillset(sigset_t *set); //将信号集中所有标志位置1
int sigaddset(sigset_t *set, int signum);//设置信号集中某一个对应的标志位为1，表示阻塞这个信号，signum是需要设置阻塞的那个信号
int sigdelset(sigset_t *set, int signum);//设置某个信号不则色
int sigismember(const sigset_t *set, int signum); //判断某个信号是否阻塞，set是需要操作的信号集，signum表示需要判断的那个信号。 返回值：1：signum被阻塞，0:signum被阻塞，-1：调用失败
```

除了最后一个函数，`sigset_t *set`都是传出参数。



**sigset.c**

```cpp
#include <signal.h>
#include <stdio.h>

int main()
{
    //创建一个信号集
    sigset_t set;

    //清空信号集的内容
    sigemptyset(&set);

    //判断SIGINT是否在信号集set中
    if(sigismember(&set, SIGINT) == 0)
    {
        printf("SIGINT 不阻塞\n");
    }
    else if(sigismember(&set, SIGINT))
    {
        printf("SIGINT 阻塞或者调用函数失败");
    }

    //添加几个信号到信号集中
    sigaddset(&set, SIGINT);
    sigaddset(&set, SIGQUIT);

     //判断SIGINT是否在信号集set中
    if(sigismember(&set, SIGINT) == 0)
    {
        printf("SIGINT 不阻塞\n");
    }
    else if(sigismember(&set, SIGINT))
    {
        printf("SIGINT 阻塞或者调用函数失败");
    }

    //删除
    sigdelset(&set, SIGQUIT);
    if(sigismember(&set, SIGQUIT) == 0)
    {
        printf("SIGQUIT 不阻塞\n");
    }
    else if(sigismember(&set, SIGQUIT))
    {
        printf("SIGQUIT 阻塞或者调用函数失败");
    }

    return 0;
}
```

分别输出「不阻塞、阻塞、不阻塞」。



内核的阻塞信号集是无法直接修改的，

**sigprocmask函数**

```cpp
#include <signal.h>
int sigprocmask(int how, const sigset_t *restrict set, sigset_t *restrict oset);
```

-   功能：查看或者修改阻塞信号集（阻塞信号集也叫「信号掩码（signal mask）」。它的行为取决于第一个参数`how`。
-   参数：
    -   `how`：如何对内核阻塞信号集进行处理：
        -   `SIG_BLOCK`：将用户设置的阻塞信号集添加到内核中（注意不是替换），内核中原来的数据不变。假设内核中原来的阻塞信号集是`mask`，他的操作是`mask | set`。
        -   `SIG_UNBLOCK`：根据用户设置的数据，对内核中的数据进行解除阻塞。相当于` mask &= ~set`。例如原来的数据是`10010`，传入的`set`是`00010`，则结果是`10000`。
        -   `SIG_SETMASK`：覆盖内核中原来的值
    -   `set`：已经初始化好的用户自定义的信号集
    -   `oset`：传出参数，保存设置之前的内核中的阻塞信号集的状态，可以是`NULL`。
-   返回值：成功返回0，失败返回-1。



```cpp
#include <signal.h>
int sigpending(sigset_t *set);
```

-   功能：获取内核中的未决信号集
-   参数：`set`是一个传出参数，保存的是内存中未决信号集的信息
-   返回值：0成功，-1失败。



**编写一个程序，把所有常规信号（1-31）的未决状态打印到屏幕**

设置某些信号是阻塞的，通过键盘产生这些信号：2号信号`Ctrl + c`，3号信号`Ctrl + \`。

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>
int main()
{
    //设置2号信号和3号信号阻塞
    sigset_t set;
    sigemptyset(&set);

    //将2号和3号信号添加到信号集中
    sigaddset(&set, SIGINT);
    sigaddset(&set, SIGQUIT);

    //修改内核中的阻塞信号集
    sigprocmask(SIG_BLOCK, &set, NULL);
    
    int num = 0;
    while(1)
    {
        
        num++;
        //获取当前未决信号集的数据
        sigset_t pendingset;
        sigemptyset(&pendingset);
        sigpending(&pendingset);

        //遍历前32位
        for(int i = 1; i <= 32; ++i)
        {
            if(sigismember(&pendingset, i) == 1)
            {
                printf("1");
            }
            else if ( sigismember(&pendingset, i) == 0)
            {
                printf("0");
            }
            else
            {
                perror("sigismember");
                exit(0);
            }
        }

        printf("\n");
        sleep(1);

        if(10 == num)
        {
            //解除阻塞
            sigprocmask(SIG_UNBLOCK, &set, NULL);
        }
    }

}
```

可以看到如果输入`Ctrl +C`，会显示2号信号，10秒后解除阻塞，程序停止。



### 7.9 内核实现信号捕捉的过程

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230131113813003.png" alt="image-20230131113813003" style="zoom:40%;" />

-   中断、异常、系统调用会进入内核态。
-   如果在处理一个信号时又发送来一个信号，则不会处理第二个信号（被阻塞）。
-   未决信号集中每个信号只能标记一次，如果有多个也只能是1。
-   31个实时信号支持排队。 



### 7.10 SIGCHLD信号

它是17号信号。

-   `SIGCHLD`信号产生的条件
    -   子进程终止时
    -   子进程接受到`SIGSTOP`信号停止时
    -   子进程处在停止态，接收到`SIGCONT`后唤醒时
-   以上三种条件都会给父进程发送`SIGCHLD`信号，父进程默认回忽略该信号

可以用`SIGCHLD`信号解决僵尸进程的问题，在父进程中捕捉`SIGCHLD`信号，收到信号并调用`wait()`来回收资源，而不是阻塞等待。

如果同时有多个相同？信号发送，只会处理一个

```cpp
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <sys/wait.h>

void myFun(int num)
{
    printf("捕捉到的信号 : %d\n", num);

    //回收子进程PCB的资源
    // while(1)
    // {
    //     wait(NULL);
    // }
    
    while(1)
    {
        int ret = waitpid(-1, NULL, WNOHANG);
        if(ret > 0 )
        {
            printf("child process die, pid = %d\n", ret);
        }
        else if(ret == 0)
        {
            //说明还有子进程活着
            break;
        }
        else if(ret == -1)
        {
            //说明没有子进程
            break;
        }
    }

}
int main()
{
    //提前阻塞SIGCHLD, 因为有可能子进程很快结束,而父进程还没有注册完成信号捕捉
    sigset_t set;
    sigemptyset(&set);
    sigaddset(&set, SIGCHLD);
    sigprocmask(SIG_BLOCK, &set, NULL);
    //创建20个子进程
    pid_t pid;
    for(int i = 0; i < 20; ++i)
    {
        pid = fork();
        if(0 == pid)
        {
            //防止子进程再创建子进程
            break;
        }
    }

    if(pid > 0)
    {
        //父进程
        //捕捉子进程死亡时的发出的SIGCHLD信号
        
        //信号捕捉需要时间, 在这个时间如果子进程发送SIGCHLD信号可能捕捉不到
        //所以可以把这段写在外面,但是这样会导致子进程也捕获信号, 
        //也可以在之前先把所有的SIGCHLD阻塞
        struct sigaction act;
        act.sa_flags = 0;
        act.sa_handler = myFun;

        
        //清空临时信号阻塞
        sigemptyset(&act.sa_mask);
        sigaction(SIGCHLD, &act, NULL);

        //注册完信号捕捉以后,解除阻塞
        sigprocmask(SIG_UNBLOCK, &set, NULL);
        while(1)
        {
            printf("parent process pid : %d\n", getpid());
            sleep(2);
        }
    }

    else if(0 == pid)
    {
        //子进程
        printf("child process pid : %d\n", getpid());
    }
    return 0;
}
```

<mark>注意：虽然每次只能处理一个`SIGCHLD`信号，其余的被丢弃，但是`myFun`中的`wait()`不是处理信号的，而是用来回收子进程，循环回收子进程。</mark>



>   `waitpid()`想要回收所有的僵尸进程，只能使用轮询模式，不能使用非阻塞`WNOHANG`。
>
>   `SIGCHLD`和`waitpid()`配合使用，就可以不阻塞父进程来回收子进程，在这里使用`waitpid()`可以跳出来继续执行父进程，而`wait()`不能跳出，具体看代码吧。





## 08. 共享内存

### 8.1 共享内存简介

-   共享内存允许两个或者多个进程共享物理内存的同一块区域（通常称之为段）。由于一个共享内存段回成为一个进程用户空间的一部分，因此这种IPC机制无需内核介入。所需要做的就是让一个进程将数据复制进共享内存中，并且这部分的数据会对其他所有共享同一个段的进程可用。
-   与管道等要求「发送进程」（专门发送数据的进程）将数据从「用户空间的缓冲区」复制进「内核内存」  和 「接收进程」将数据从「内核内存」复制进「用户空间的缓冲区 」相比，这种IPC技术的速度更快。



### 8.2 共享内存的使用步骤

-   调用`shmget()` 「创建一个新内存段」 或 「 取得一个既有内存共享段」（有其他进程创建的共享内存段）。这个调用将返回后续调用中需要用到的共享内存标识符。
-   使用`shmat()`来附上共享内存段，即使该段成为调用进程的虚拟内存的一部分。（关联）
-   此刻在程序中可以像对待其他可用内存一样对待这个共享内存段。为引用这块共享内存，程序需要使用由`shmat()`调用返回的`addr`值，它是一个指向进「程虚拟地址空间」中「该共享内存段起点」的指针。
-   调用`shmdt()`来分离共享内存段。在这个调用之后，进程就无法再引用这块共享内存了。这一步是可选的，进程终止时会自动完成这一步。
-   调用`shmctl()`来删除共享内存段。只有当「当前所有附加内存段的进程」都与之分离之后内存段才会销毁。只有一个进程需要执行这一步。



### 8.3 共享内存操作函数

```cpp
#include <sys/ipc.h>
#include <sys/shm.h>
int shmget(key_t key, size_t size, int shmflg);
```

-   功能：创建一个新的共享内存段，或者获取一个已经存在的共享内存段的标识。新创建的内存段中的数据都会被初始化为0。
-   参数：
    -   `key`：`key_t`是一个整型，通过`key`找到或者创建一个共享内存，一般使用16进制非0值来表示。
    -   `size`：`size_t`也是一个整型，它指定共享内存的大小。共享内存的大小以分页的大小来创建，必须是分页大小的整数倍。
    -   `shmflg`：share memory flag，代表共享内存的一些属性：
        -   访问权限
        -   附加属性：创建共享内存 OR 判断共享内存存在与否
        -   具体来说，可以是：`IPC_CRATE`（创建）,`IPC_EXCL`（判断存在，需要和`IPC_CRATE`一起使用）等宏值。
-   返回值（`int`类型）：
    -   失败，返回-1，设置错误号errno
    -   成功，>0的值，代表共享内存引用的id



```cpp
#include <sys/types.h>
#include <sys/shm.h>
void *shmat(int shmid, const void *shmaddr, int shmflg);
```

-   功能：和当前进程进行关联
-   参数：
    -   `shmid`：共享内存的标识（ID），由`shmget()`返回值获取。
    -   `shmaddr`：申请共享内存的起始地址，指定为`NULL`，代表由内核指定
    -   `shmflg`：对共享内存的操作：
        -   `SHM_EXEC`：执行权限
        -   0：读写权限
        -   `SHM_RDONLY`：读权限，必须要有这个权限，程序才能读。
        -   `SHM_REMAP`
-   返回值：
    -   成功：返回共享内存的首地址
    -   失败：返回`(void *) -1`



```cpp
int shmdt(const void *shmaddr);
```

-   功能：解除当前进程和共享内存的关联
-   参数：
    -   `shmaddr`：共享内存的首地址
-   返回值：成功0，失败-1



```cpp
#include <sys/ipc.h>
#include <sys/shm.h>
int shmctl(int shmid, int cmd, struct shmid_ds *buf); 
struct shmid_ds {
    struct ipc_perm shm_perm;    /* Ownership and permissions */
    size_t          shm_segsz;   /* Size of segment (bytes) */
    time_t          shm_atime;   /* Last attach time */
    time_t          shm_dtime;   /* Last detach time */
    time_t          shm_ctime;   /* Last change time */
    pid_t           shm_cpid;    /* PID of creator */
    pid_t           shm_lpid;    /* PID of last shmat(2)/shmdt(2) */
    shmatt_t        shm_nattch;  /* No. of current attaches */ //关联共享内存的进程数量
    ...
};
```

-   功能：对共享内存进行操作。共享内存要删除才会消失，创建共享内存的进程被销毁了对共享内存的存在是没有影响的。
-   参数：
    -   `shmid`：共享内存的ID。
    -   `cmd`：要做的操作，主要有：
        -   `IPC_STAT`：获取共享内存当前状态
        -   `IPC_SET`：设置共享内存的状态
        -   `IPC_RMID`：标记共享内存被销毁
    -   `buf`：一个`shmid_ds`结构体，表示需要设置或者获取的共享内存的属性信息。
        -   如果`cmd`参数指定`IPC_STAT`：传出参数，`buf`存储数据
        -   如果`cmd`参数指定`IPC_SET`：`buf`中需要初始化数据，设置到内核中
        -   如果`cmd`参数指定`IPC_RMID`：`buf`没有意义



```cpp
key_t ftok(const char *pathname, int proj_id);
```

-   功能：根据指定的路径名和`int`值，生成一个共享内存的`key`，`key`可以用于`shmget`等系统调用
-   参数：
    -   `pathname`：指定一个存在且可访问的文件路径
    -   `proj_id`：`int`类型的值，但是系统调用只会使用其中一个字节（1位）,也就是0～255
        -   所以可以传入一个字符



### 8.4 共享内存实现进程通信

**write_shm.c**

```cpp
#include <stdio.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <string.h>

int main()
{
    //1.创建一个共享内存
    int shmid = shmget(100, 4096, IPC_CREAT | 0664);
    printf("shmid = %d\n", shmid);
    
    //2. 和当前进程进行关联
    //返回共享内存在虚拟内存空间的首地址
    void* ptr = shmat(shmid, NULL, 0);

    //3. 写数据
    char * str = "hello world";
    memcpy(ptr, str, strlen(str) + 1);

    printf("按任意键继续\n");
    getchar();

    //4. 解除关联
    shmdt(ptr);

    //5. 删除共享内存
    shmctl(shmid, IPC_RMID, NULL);
    
    return 0;

}
```



**read_shm.c**

```cpp
#include <stdio.h>
#include <string.h>
#include <sys/ipc.h>
#include <sys/shm.h>

int main()
{
    //1. 获取共享内存
    int shmid = shmget(100, 0, IPC_CREAT);

    printf("shmid = %d\n", shmid);
    //2. 和当前进程进行关联
    void *ptr = shmat(shmid, NULL, 0);

    //读数据
    printf("%s\n", (char *) ptr);

    printf("按任意键继续\n");
    getchar();

    //解除关联
    shmdt(ptr);

    //删除共享内存
    shmctl(shmid, IPC_RMID, NULL);
    return 0;
}
```



### 8.5 共享内存的一些问题

**问题1: 操作系统如何知道一块共享内存被多少个进程关联？**

-   共享内存维护了一个结构体`struct shmid_ds`，这个结构体中有一个成员`shm_nattach`记录了关联的进程的个数。

-   可以用`ipcs`命令来查询IPC的信息：

    -   `-a`：打印当前系统中所有进程间通信方式的信息

    -   `-m`：打印出使用共享内存进行进程间通信的信息

        使用了一个共享内存，`./write`，使用`ipcs -m`打印：

        ```
        
        ------ Shared Memory Segments --------
        key        shmid      owner      perms      bytes      nattch     status      
        0x00000064 32768      root       664        4096       1                       
        ```

        nattch代表连接数，key成为0，代表内存被标记删除，但是还没有删除

    -   `-q`：打印出使用消息队列进行进程间通信的信息

    -   `-s`：打印出使用信号进行进程间通信的信息

-   可以用`ipcrm`删除IPC

    -   `-M shmkey`：移除用`shmkey`创建的共享内存段
    -   `-m shmid`：移除用`shmid`标识的共享内存段
    -   `-Q msgkey`：移除用`msqkey`创建的消息队列
    -   `-q msqid`：移除用`msqid`标识的消息队列
    -   `-s semkey`：移除用`semkey`创建的信号
    -   `-s semid`：移除用`semid`标识的信号



**问题2: 可不可以对共享内存进行多次删除？**

-   可以
-   因为`shmctl`是标记删除共享内存，不是直接删除
-   当和共享内存关联的进程数为0的时候，就真正被删除了。
-   当共享内存的`key`为0的时候，表示共享内存被标记删除了，但是还有进程和共享内存关联。



**问题3: 共享内存和内存映射的区别**

1.   共享内存可以直接创建，内存映射需要磁盘文件（匿名映射除外）
2.   共享内存效率更高（不需要磁盘文件）
3.   内存：
     -   共享内存中所有的进程操作的是同一块共享内存
     -   内存映射：每个进程在自己的虚拟空间有一个独立内存
4.   数据安全：
     -   进程突然退出：
         -   共享内存仍然存在
         -   内存映射区消失
     -   运行进程的电脑宕机了：
         -   数据存储在共享内存中就没有了
         -   内存映射区数据还在，因为磁盘文件中的数据还在，所以内存映射区的数据还存在



**问题5: 生命周期：**

-   内存映射区：进程退出，内存映射区销毁
-   共享内存：进程退出，共享内存还在，需要手动删除（所有的关联的进程数为0）或者关机



## 09. 守护进程

### 9.1 终端

-   在UNIX系统中，用户通过终端登录系统后得到一个shell进程，这个终端成为shell进程的控制终端（Controlling Terminal），进程中，控制终端是保存在PCB中的信息，而`fork()`会复制PCB中的信息，因此shell进程启动的其他进程的控制终端也是这个终端。可以通过`echo $$`查看当前终端的pid。
-   默认情况下（没有重定向），每个进程的标准输入、标准输出和标准错误都指向控制终端，进程从标准输入读也就是读用户的键盘输入，进程往标准输出或标准错误输出写也是输出到显示器上。
-   在控制终端输入一些特殊的控制键可以给**前台进程**发送信号，例如`Ctrl + C`会产生`SIGINT`信号，`Ctrl + \`会产生`SIGQUIT`信号。不能给后台进程发送信号。



### 9.2 进程组

-   进程组和会话（session）在进程之间形成了一种两级层次关系：进程组是一组相关进程的结合，会话是一组相关进程组的集合。进程组和会话是为支持shell作业而定义的抽象概念，用户通过shell 能够交互式地在前台或后台运行命令。进程组和会话可以方便shell管理进程。
-   进程组由一个或多个共享同一进程组标识符（PGID）的进程组成。一个进程组拥有一个进程组首检查，该进程是创建该组的进程，其PID为该进程组的ID，新进程会继承其父进程所属的进程组ID。
-   进程组拥有一个一个生命周期，其开始时间为首进程创建组的时刻，结束时间为最后一个成员进程退出组的时刻（而不是组长进程退出而结束）。一个进程可能会因终止而退出进程组，也可能会因为加入了另外一个进程组儿退出进程组。进程组首进程无需是最后一个离开进程组的成员。



### 9.3 会话

-   会话是一组进程组的集合。会话首进程是创建该新会话的进程，其pid会成为会话id（SID）。新进程会继承其父类的会话id。
-   一个会话中所有进程共享单个控制终端。控制终端会在会话进程首次打开一个终端设备时被建立。一个终端最多可能会成为一个会话的控制终端。一个终端只能对应一个会话。
-   在任一时刻，会话中的其中一个进程组会成为终端的前台进程组，其他进程会成为后台进程组。只有前台进程组中的进程才能从控制终端中读取输入。当用户在控制终端中输入字符生成信号后，该信号会被发送到前台进程组中的所有成员。
-   当控制终端的连接建立起来之后，会话首进程会成为该终端的控制进程。



### 9.4 进程组、会话、控制终端之间的关系

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230201225325223.png" alt="image-20230201225325223" style="zoom:40%;" />

-   查找`2` 输出到`/dev/null`并统计字数在后台运行。
-   同时有一个前台运行的`sort`进程

可以看到有三个进程组，一个会话。



### 9.5 进程组、会话操作函数

-   `pid_t getpgrp(void)`：获取进程的组id
-   `pid_t getpgid(pid_t pid)`：获取指定 pid的进程组
-   `int setpgid(pid_t pid, pid_t pgid)`：设置进程组id
-   `pid_t getsid(pid_t pid)`：获取指定pid的sid
-   `pid_t setsid(void)`：设置sid



### 9.6守护进程

-   守护进程（Daemon Process），是Linux中的后台服务进程。它是一个生存期较长的进程，通常独立于控制终端并且周期性的执行某种任务或等待处理某些发生的时间。一般用`d`结尾，例如`httpd`,`mysqld`等。
-   守护进程具备下列特征：
    -   生命周期很长，守护进程会在系统启动的时候被创建并一直运行直至系统被关闭。
    -   它在后台运行并且不拥有控制终端。没有控制终端确保了内核永远不会为守护进程自动生成任何控制信号以及终端相关的信号（例如：`SIGINT`,`SIGQUIT`），无法被`kill`。
-   Linux的大多数服务器就是用守护进程实现的。例如：Internet服务区`inetd`，Web服务器`httpd`等。



### 9.7 守护进程的创建步骤

1.   执行一个`fork()`，之后父进程退出，子进程继续执行。
2.   子进程调用`setsid()`开启一个新会话。
3.   清除进程的`umask`以确保当守护进程创建文件和目录时拥有所需的权限。
4.   修改进程的当前工作目录，通常会改为根目录`/`
5.   关闭守护进程从其父进程继承而来所有打开着的文件描述符
6.   在关闭了文件描述符0、1、2之后，守护进程通常会打开`/dev/null`，并使用`dup2()`使所有这些描述符指向这个设备
7.   核心业务逻辑



**daemon.c**

```cpp
/*
    写一个守护进程，每隔2s获取一下系统时间，将这个时间写入到磁盘文件中。
*/

#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>
#include <signal.h>
#include <time.h>
#include <stdlib.h>
#include <string.h>

void work(int num) {
    // 捕捉到信号之后，获取系统时间，写入磁盘文件
    time_t tm = time(NULL);
    struct tm * loc = localtime(&tm);
    // char buf[1024];

    // sprintf(buf, "%d-%d-%d %d:%d:%d\n",loc->tm_year,loc->tm_mon
    // ,loc->tm_mday, loc->tm_hour, loc->tm_min, loc->tm_sec);

    // printf("%s\n", buf);

    char * str = asctime(loc);
    int fd = open("time.txt", O_RDWR | O_CREAT | O_APPEND, 0664);
    write(fd ,str, strlen(str));
    close(fd);
}

int main() {

    // 1.创建子进程，退出父进程
    pid_t pid = fork();

    if(pid > 0) {
        exit(0);
    }

    // 2.将子进程重新创建一个会话
    setsid();

    // 3.设置掩码
    umask(022);

    // 4.更改工作目录
    chdir("/root/cpp_code/nowcoder/lesson28");

    // 5. 关闭、重定向文件描述符
    int fd = open("/dev/null", O_RDWR);
    dup2(fd, STDIN_FILENO);
    dup2(fd, STDOUT_FILENO);
    dup2(fd, STDERR_FILENO);

    // 6.业务逻辑

    // 捕捉定时信号
    struct sigaction act;
    act.sa_flags = 0;
    act.sa_handler = work;
    sigemptyset(&act.sa_mask);
    sigaction(SIGALRM, &act, NULL);

    struct itimerval val;
    val.it_value.tv_sec = 2;
    val.it_value.tv_usec = 0;
    val.it_interval.tv_sec = 2;
    val.it_interval.tv_usec = 0;

    // 创建定时器
    setitimer(ITIMER_REAL, &val, NULL);

    // 不让进程结束
    while(1) {
        sleep(10);
    }

    return 0;
}
```



