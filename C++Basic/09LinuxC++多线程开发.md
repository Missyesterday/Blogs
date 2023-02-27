# LinuxC/C++多线程

## 1. 线程

### 1.1 线程概述

-   与进程（process）类似，线程（thread）是允许应用程序并发执行多个任务的一种机制。一个进程可以包含多个线程。同一个程序中所有的线程均会独立执行相同程序，**且共享同一份全局内存区域**，其中包括初始化数据段、未初始化数据段，以及堆内存段。（传统意义上的UNIX进程只是多线程程序的一个特例，该进程只包含一个线程）
-   进程是CPU分配资源的最小单位，线程是操作系统调度执行的最小单位。
-   线程是轻量级的进程（LWP：light weight process），在Linux环境下线程的本质仍是进程
-   查看指定进程的LWP号：`ps -Lf pid`



### 1.2 线程和进程的区别

-   进程间的信息难以共享。由于除去只读代码段外，父子进程并未共享内存，因此必须采用一些进程间通信方式，在进程间进行信息交互。
-   调用`fork()`来创建进程的代价相对较高，即使采用写时复制技术，仍然需要复制诸如内存页表和文件描述符之类的多种进程属性，这意味着`fork()`调用在时间上的开销不菲。
-   线程之间能够方便、快速地共享信息。只需要将数据复制到共享（全局或堆）变量即可。
-   创建线程比创建进程通常要快10倍甚至更多。线程间是共享虚拟地址空间的，无需采用写时复制来复制内存，也无需复制页表。



### 1.3 线程和进程虚拟地址空间

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230202110737691.png" alt="image-20230202110737691" style="zoom:40%;" />

创建线程共享上面的虚拟地址空间，但有一些变化：

1.   text段分成多个小段，每个线程一份
2.   栈空间分成多个小块，主线程和子线程都有自己的区域

其余的（共享库、堆等）都是直接共享一份。



### 1.4 线程之间共享和非共享的资源

**共享资源：**

-   进程ID和父进程ID
-   进程组ID和会话ID
-   用户ID和用户组ID
-   文件描述符表
-   信号处理机制（注册信号处理）
-   文件系统的相关信息：文件权限掩码（umask）、当前工作目录
-   虚拟地址空间（除栈、.text）



**非共享资源：**

-   线程ID
-   信号掩码（阻塞信号集，每个线程都有自己的阻塞信号集）
-   线程特有数据
-   `error`变量
-   实时调度策略和优先级
-   栈，本地变量和函数调用链接信息



### 1.5 NPTL

-   当Linux最初开发时，在内核中并不能真正支持线程。但是它的确可以通过`clone()`系统调用将进程作为可调度的实体。这个调用创建了调用进程（calling process）的一个拷贝，这个拷贝与调用进程共享相同的地址空间。LinuxThreads项目使用这个调用来完全在用户空间模拟对线程的支持。不幸的是，这种方法又一些缺点，尤其是在信号处理、调度和进程间同步等方面都存在问题。另外，这个线程模型也不符合POSIX的要求。
-   要改进LinuxThreads，需要内核的支持，并且重写线程库。有两个相互竞争的项目开始来满足这些要求。一个包括IBM的开发人员团队开展了NGPT（Next-Generation POSIX Threads）项目。同时，Red Hat的开发人员开展了NPTL项目。NGPT在03年被放弃了，所以现在用的都是NPTL。
-   NPTL（Native POSIX Thread Library），是Linux线程的一个新实现，它克服了LinuxThreads的缺点，也符合POSIX的需求，在性能和稳定性方面都提供了重大的改进。
-   查看当前pthread库版本：`getconf GNU_LIBPTHREAD_VERSION`。

我的pthread版本是：`NPTL 2.17`



### 1.6 创建线程

一般情况下， main函数所在的线程被称为「主线程」（main线程），其余的线程叫子线程。

程序中默认只有一个进程，`fork()`函数调用会有2个进程。

程序中默认只有一个线程，`pthread_create()`函数调用就有两个线程。

```cpp
#include <pthread.h>
int pthread_create(pthread_t *thread, const pthread_attr_t *attr,
                   void *(*start_routine) (void *), void *arg);
```

-   功能：创建一个子线程
-   参数：
    -   `pthread_t *thread`：传出参数，线程创建成功后的子线程的线程ID。
    -   `const pthread_attr_t *attr`：设置的线程的属性，一般使用默认值，`NULL`。
    -   `start_routine`：函数指针，这个函数是子线程需要处理的逻辑代码。
    -   `void *arg`：给第三个参数（函数指针）使用，给函数传参。
-   返回值：
    -   如果成功，返回0
    -   如果失败，返回**错误号**（而不是-1），同时`*thread`是未定义的。
        -   这个错误号和之前的`errno`不太一样，实现方式相同，但是不是同一体系，不能用`perror()`输出。它叫` error number`，而之前是`errrno`。
        -   获取错误号的信息：`char*  strerror(int errnum)`。



**pthread_create.c**

```cpp
#include <pthread.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>

void* callback(void* arg)
{
    printf("child thread ...\n");
    return NULL;
}

int main()
{
    pthread_t tid;
    //创建子线程
    int ret = pthread_create(&tid, NULL, callback, NULL);

    if(ret != 0 )
    {
        char* str = strerror(ret);
        printf("error : %s\n", str);
    }

    for(int i = 0; i < 5; ++i)
    {
        printf("%d\n", i);
    }
    
    //需要让子线程来抢占! 否则return 0进程退出了,子线程可能无法执行
    sleep(1);
    return 0;

}
```



所有和线程相关的程序，编译的时候要加上`-l pthread`或`-pthread`，man文档中使用的是后者，更为推荐使用第二个。



### 1.7 终止线程

```cpp
#include <pthread.h>
void pthread_exit(void *retval);
```

-   功能：终止一个线程，在哪个线程中调用，就表示终止哪个线程。
-   参数：
    -   `retval`：需要传递一个指针，作为返回值，可以在`pthread_join()`中获取到。
-   返回值：没有返回值。



**pthread_exit.c**

```cpp
#include <pthread.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>

void* callback(void* arg)
{
    //获取当前线程的线程id, aka LWPID
    printf("child thread id : %ld\n", pthread_self());

}

int main()
{
    //创建一个子线程
    pthread_t tid;
    int ret = pthread_create(&tid, NULL, callback, NULL);

    if(ret != 0)
    {
        char* str = strerror(ret);
        printf("error: %s\n", str);
    }

    //主线程
    for(int i = 0; i < 5; ++i)
    {
        printf("%d\n", i);
    }
    
    printf("tid : %ld, main thread id : %ld\n", tid, pthread_self());

    //让主线程退出,当主线程退出时,不会影响其他正常运行的线程
    pthread_exit(NULL);
    return 0;
}
```



不同操作系统的`pthread_t`实现类型不同，所以不能直接用`==`比较，可以使用：

```cpp
int pthread_equal(pthread_t t1, pthread_t t2);
```

来比较两个线程id是否相等。



### 1.8 连接一个终止进程

```cpp
#include <pthread.h>
int pthread_join(pthread_t thread, void **retval);
```

-   功能：和一个已经终止的线程进行连接。回收子线程的资源：
    -   这个函数是阻塞函数，如果没有子线程终止，则一直等待
    -   调用一次只能回收一个子线程
    -   一般在主线程中去使用
-   参数：
    -   `thread`：需要回收的子线程的id
        -   `retval`：二级指针，接收子线程退出时的返回值。二级指针是因为`pthread_exit()`推出的是一个指针，想要「修改这个指针的指向」则要用二级指针传递。
-   返回值：
    -   成功返回0
    -   错误返回错误号



### 1.9 分离一个线程

```cpp
#include <pthread.h>
int pthread_detach(pthread_t thread);
```



-   功能：分离一个线程，被分离的线程在终止的时候，会自动释放资源，返回给系统。不需要另一个线程调用`pthread_join()`。
    -   不能多次分离一个线程，会产生不可知的后果
    -   不能连接一个已经分离的线程，会报错。
-   参数：需要分离的线程id
-   返回值：成功返回0，失败返回错误号



**pthread_detach.c**

```cpp
#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void* callback(void* arg)
{
    printf("child thread id : %ld\n", pthread_self());
    return NULL;
}

int main()
{
    pthread_t tid;

    int ret =  pthread_create(&tid, NULL, callback, NULL);
    if(ret != 0)
    {
        char* str = strerror(ret);
        printf("error : %s\n", str);
    }

    //输出子线程和主线程的id
    printf("tid : %ld, main tid : %ld\n", tid, pthread_self());

    //设置子线程分离,子线程分离后, 子线程结束时对应的资源就不需要主线程去释放
    pthread_detach(tid);

    //设置分离以后, 再连接
    ret = pthread_join(tid, NULL);
    if(ret != 0)
    {
        char* str = strerror(ret);
        printf("error : %s\n", str); //会输出 error : Invalid argument
    }

    pthread_exit(NULL);
}
```



### 1.10 线程取消

```cpp
#include <pthread.h>
int pthread_cancel(pthread_t thread);
```

-   功能：发送一个取消请求给线程，取消线程（让线程终止）。

    -   取消某个线程可以终止其运行

    -   取消并不是立马取消的，而是要该线程执行到一个「取消点（cancellation point）」，线程才会终止。

    -   可以`man pthreads`查看有哪些取消点。大概是系统定义好的一些系统调用。我们可以粗略的理解为从用户区到内核区的切换，这个位置称之为取消点。

        



**pthread_cancel.c**

```cpp
#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void* callback(void* arg)
{
    printf("child thread id : %ld\n", pthread_self());
    for(int i = 0; i < 5; ++i)
    {
        printf("child ; %d\n", i);
    }
    return NULL;
}

int main()
{
    pthread_t tid;

    int ret =  pthread_create(&tid, NULL, callback, NULL);
    if(ret != 0)
    {
        char* str = strerror(ret);
        printf("error : %s\n", str);
    }

    //取消线程
    pthread_cancel(tid);


    //输出子线程和主线程的id
    printf("tid : %ld, main tid : %ld\n", tid, pthread_self());

    for(int i = 0; i < 5; ++i)
    {
        printf("%d\n", i);
    }

    pthread_exit(NULL);
}
```

子线程不是立马终止，而是走到取消点的时候才结束。

printf 会调用 write在stdout里面写数据，而write是要进行一个用户态到内核态的切换的。所以`printf()`应该是一个取消点。



### 1.11 线程属性

线程属性有一些操作函数,初始化和销毁:

```cpp
#include <pthread.h>

int pthread_attr_init(pthread_attr_t *attr);
int pthread_attr_destroy(pthread_attr_t *attr);
```

-   初始化和释放线程属性的资源
-   `attr`代表属性变量

设置和获取分离属性：

```cpp
#include <pthread.h>

int pthread_attr_setdetachstate(pthread_attr_t *attr, int detachstate);
int pthread_attr_getdetachstate(pthread_attr_t *attr, int *detachstate);
```

-   设置和获取线程分离的状态属性
-   `attr`代表属性变量
-   `detachstate`代表选项。默认是不分离的，可以加入的。

其实除了这几个，还有很多设置线程属性的方法，例如`pthread_attr_getstacksize()`可以看线程栈的大小，默认大小是`thread stack size : 8388608`。

**pthread_attr.c**

```cpp

#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void* callback(void* arg)
{
    printf("child thread id : %ld\n", pthread_self());
    return NULL;
}

int main()
{
    //创建一个线程属性变量
    pthread_attr_t attr;
    //初始化属性变量
    pthread_attr_init(&attr);

    //设置属性,表示设置线程分离
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);


    pthread_t tid;

    int ret =  pthread_create(&tid, NULL, callback, NULL);
    if(ret != 0)
    {
    ¦   char* str = strerror(ret);
    ¦   printf("error : %s\n", str);
    }

    //获取线程大小
    size_t size;
    pthread_attr_getstacksize(&attr, &size);
    printf("thread stack size : %d\n", size);
    //输出子线程和主线程的id
    printf("tid : %ld, main tid : %ld\n", tid, pthread_self());
    //释放线程属性资源
    pthread_attr_destroy(&attr);
    pthread_exit(NULL);

}

```

## 2. 线程同步

### 2.1 线程不同步的例子

在程序的底层是不可能把一张票卖给多个人的

下面的例子，卖票结果最终会出现负数和多个线程卖同一张票。但是我的代码没有显示出多个线程卖同一张票的情况。

**sell_tickets.c**

```cpp
 /*
     使用多线程实现买票的案例。
     有3个窗口，一共是100张票。
 */

 #include <stdio.h>
 #include <pthread.h>
 #include <unistd.h>

 // 全局变量，所有的线程都共享这一份资源。
 int tickets = 100;

 void * sellticket(void * arg) {
     // 卖票
     while(tickets > 0) {
         usleep(5000);
         printf("%ld 正在卖第 %d 张门票\n", pthread_self(), tickets);
         tickets--;
     }
     return NULL;
 }

 int main() {

     // 创建3个子线程
     pthread_t tid1, tid2, tid3;
     pthread_create(&tid1, NULL, sellticket, NULL);
     pthread_create(&tid2, NULL, sellticket, NULL);
     pthread_create(&tid3, NULL, sellticket, NULL);

     // 回收子线程的资源,阻塞
     pthread_join(tid1, NULL);
     pthread_join(tid2, NULL);
     pthread_join(tid3, NULL);

     // 设置线程分离。
     // pthread_detach(tid1);
     // pthread_detach(tid2);
     // pthread_detach(tid3);

     pthread_exit(NULL); // 退出主线程

     return 0;
 }

```

必须保证原子性。



### 2.2 线程同步的概念

-   线程的主要优势在于，能够通过「全局变量」来共享信息。不过，这种便捷的共享是有代价的：
    -   必须确保多个线程不会同时修改同一变量，
    -   或者某一个线程不会读取正在由其他线程修改的变量
-   「临界区」是指访问某一共享资源的「代码片段」，并且这段代码的执行应为原子操作，也就是同时访问同一共享资源的其他线程不应该中断该片段的执行。
-   线程同步：即当有一个线程在对内存进行操作时，其他线程都不可以对着干内存地址进行操作，知道该线程完成操作，其他线程才能对该内存地址进行操作，而其他线程处于等待状态。



### 2.3 互斥锁（量）

-   为避免线程更新共享变量出现问题，可以使用互斥量（mutex 是 mutual exclusion的缩写）来确保同时仅有一个线程可以访问某项资源。可以使用互斥量来保证对任意共享资源的原子访问。

-   互斥量有两种状态：已锁定（locked）和未锁定（unlocked）。任何时候，最多只有一个线程可以锁定该互斥量。试图对已锁定的某一个互斥量再次加锁，将可能阻塞线程或者报错失败，具体取决于加锁时使用的方法。

-   一旦线程锁定互斥量，随即成为该互斥量的所有者，只有所有者才可以给互斥量解锁。一般情况下，对每一共享资源（可能由多个相关变量组成）会使用不同的互斥量，每一线程在访问同一资源时将采用如下协议：

    -   针对共享资源锁定互斥量
    -   访问共享资源
    -   对互斥量解锁

-   如果多个线程试图执行这一块代码（临界区），只有一个线程能持有该互斥量（其他线程将遭到阻塞），即同时只有一个线程能进入这段代码区域：

    <img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230204163503341.png" alt="image-20230204163503341" style="zoom:40%;" />

**相关函数：**

互斥量的类型是：`pthread_mutex_t`

>   `restrict`是一个C语言的修饰符，被修饰的指针不能由另外一个指针进行操作。例如下面的函数中`attr`只有`attr`可以操作。

```cpp
#include <pthread.h>
int pthread_mutex_init(pthread_mutex_t *restrict mutex,
                       const pthread_mutexattr_t *restrict attr);
```

-   初始化互斥量
-   参数：
    -   `mutex`：需要初始化的互斥量变量
    -   `attr`：互斥量相关属性，NULL



```cpp
int pthread_mutex_destroy(pthread_mutex_t *mutex);
```

-   释放互斥量的资源



```cpp
#include <pthread.h>

int pthread_mutex_lock(pthread_mutex_t *mutex);
int pthread_mutex_trylock(pthread_mutex_t *mutex);
int pthread_mutex_unlock(pthread_mutex_t *mutex);
```

-   分别代表；
    -   加锁（阻塞的，如果有一个线程加锁了，那么其他的线程只能阻塞等待）
    -   尝试加锁（如果加锁失败，不会阻塞，会直接返回）
    -   解锁



重写卖票案例：

**mutex.c**

```cpp
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

// 全局变量，所有的线程都共享这一份资源。
int tickets = 1000;

// 创建一个互斥量
pthread_mutex_t mutex;

void * sellticket(void * arg) {

    // 卖票
    while(1) {

        // 加锁
        pthread_mutex_lock(&mutex);

        if(tickets > 0) {
            usleep(60000);
            printf("%ld 正在卖第 %d 张门票\n", pthread_self(), tickets);
            tickets--;
        }else {
            // 解锁
            pthread_mutex_unlock(&mutex);
            break;
        }

        // 解锁
        pthread_mutex_unlock(&mutex);
    }



    return NULL;
}

int main() {

    // 初始化互斥量
    pthread_mutex_init(&mutex, NULL);

    // 创建3个子线程
    pthread_t tid1, tid2, tid3;
    pthread_create(&tid1, NULL, sellticket, NULL);
    pthread_create(&tid2, NULL, sellticket, NULL);
    pthread_create(&tid3, NULL, sellticket, NULL);

    // 回收子线程的资源,阻塞
    pthread_join(tid1, NULL);
    pthread_join(tid2, NULL);
    pthread_join(tid3, NULL);

    pthread_exit(NULL); // 退出主线程

    // 释放互斥量资源
    pthread_mutex_destroy(&mutex);

    return 0;
}
```



### 2.4 死锁

-   有时，一个线程需要同时访问两个或者更多不同的共享资源，而每个资源又由不同的互斥量管理。当超过一个线程加锁同一组互斥量时，就有可能发生死锁。
-   两个或两个以上的进程在执行过程中，因争夺共享资源而造成的一种互相等待的现象，若无外力作用，它们都将无法推进下去。此时称系统处于死锁状态或系统产生了死锁。
-   死锁的几种场景：
    -   忘记释放锁
    -   重复加锁（只能加一次锁）
    -   多线程多锁，抢占锁资源

**deadlock1.c**

演示了两个锁死锁：

```cpp
#include <pthread.h>
#include <stdio.h>
#include <time.h>
#include <unistd.h>

//创建2个互斥量
pthread_mutex_t mutex1, mutex2;
void* workA(void* arg)
{
    pthread_mutex_lock(&mutex1);
    sleep(1);
    pthread_mutex_lock(&mutex2);
    printf("workA...\n");

    pthread_mutex_unlock(&mutex2);
    pthread_mutex_unlock(&mutex1);
    return NULL;
}

void* workB(void* arg)
{
    pthread_mutex_lock(&mutex2);
    sleep(1);
    pthread_mutex_lock(&mutex1);
    printf("workB...\n");

    pthread_mutex_unlock(&mutex1);
    pthread_mutex_unlock(&mutex2);
    return NULL;
}



int main()
{
    pthread_t tid1, tid2;
    //初始化两个互斥量
    pthread_mutex_init(&mutex1, NULL);
    pthread_mutex_init(&mutex2, NULL);

    //创建两个线程
    pthread_create(&tid1, NULL, workA, NULL);
    pthread_create(&tid1, NULL, workB, NULL);

    //回收子线程资源
    pthread_join(tid1, NULL);
    pthread_join(tid2, NULL);

    //释放互斥
    pthread_mutex_destroy(&mutex1);
    pthread_mutex_destroy(&mutex2);
    return 0;
}
```



### 2.5 读写锁

-   当有一个线程已经持有互斥锁时，互斥锁将所有试图进入临界区的线程都阻塞住。但是考虑一种情况，当前持有互斥锁的线程只是要读访问共享资源，而同时有其他几个线程也想读取这个共享资源，但是由于互斥锁的拍他性
-   在对数据的读写操作中，更多的是读操作，写操作较少，例如对数据库数据的读写应用，为了满足能够允许多个读出，但只允许一个写入的需求，线程提供了读写锁来实现。
-   读写锁的特点：
    -   如果有其他线程读取数据，则允许其他线程执行读操作，但不允许写操作。
    -   如果有其他线程写数据，则其他线程都不允许读、写操作。
    -   写是独占的，写的优先级高

**读写锁的类型：**`pthread_rwlock_t`

它也有类似`pthread_mutex_t`的相关函数，还有一些特殊的函数：

```cpp
  pthread_rwlock_wrlock(&rwlock);
  pthread_rwlock_wrlock(&rwlock);
```

分别代表上读写锁。



**rwlock.c**

```cpp
//8个线程操作同一个全局变量
//3个线程不定时写这个全局变量， 5个线程不定时读这个全局变量
#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

int num = 1;
pthread_mutex_t mutex;
pthread_rwlock_t rwlock;

void* writeNum(void* arg)
{
    while(1)
    {
        pthread_rwlock_wrlock(&rwlock);
        num++;
        printf("++wrtid, tid : %ld, num : %d\n", pthread_self(), num);
        pthread_rwlock_unlock(&rwlock);
        usleep(100);
    }
    return NULL;
}

void* readNum(void* arg)
{
    while(1)
    {
        pthread_rwlock_rdlock(&rwlock);
        printf("====== read, tid : %ld, num : %d\n", pthread_self(), num);
        pthread_rwlock_unlock(&rwlock);
        usleep(100);
        
    }
    return NULL;
}

int main()
{

    pthread_rwlock_init(&rwlock, NULL);
    pthread_t wtids[3], rtids[5];

    for(int i = 0; i < 3; ++i)
    {
        pthread_create(&wtids[i], NULL, writeNum, NULL);
    }

    for(int i = 0; i < 5; ++i)
    {
        pthread_create(&rtids[i], NULL, readNum, NULL);
    }

    //设置线程分离
    for(int i = 0; i < 3; ++i)
    {
        pthread_detach(wtids[i]);
    }

    for(int i = 0; i < 5; ++i)
    {
        pthread_detach(rtids[i]);
    }

    //释放的位置存疑
    pthread_rwlock_destroy(&rwlock);
    pthread_exit(NULL);
    printf("这句话被打印");//事实上这句话不会被打印
    
    return 0;
}
```



### 2.6 生产者消费者模型

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230204201031451.png" alt="image-20230204201031451" style="zoom:40%;" />

有几个问题：

-   容器满了还再生产就浪费了，生产者要通知消费者消费。
-   容器为空，消费者不能继续消费，消费者要通知生产者生产。
-   同时有多个生产者和消费者如何保证数据安全？



**prodcust.c**

```cpp
//生产者消费者模型（粗略版本）

#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>

struct Node
{
    int num;
    struct Node* next;
};

struct Node* head = NULL;

void* producer(void* arg)
{
    while(1)
    {
        //不断创建新的节点，添加到链表中
        struct Node* p = (struct Node*)malloc(sizeof(struct Node));

        p->next = head;
        head = p;
        p->num = rand() % 1000;
        printf("add node, num : %d, tid : %ld\n", p->num, pthread_self());
        usleep(100);
    }
    return NULL;
}

void* customer(void* arg)
{
    while(1)
    {
        struct Node * tmp = head;
        head = head->next;
        printf("del node, num : %d, tid : %ld\n", tmp->num, pthread_self());
        free(tmp);
        usleep(100);
    }
    return NULL;
}


int main()
{
    //创建5个生产者线程和5个消费者线程
    pthread_t ptids[5], ctids[5];
    for(int i = 0; i < 5; ++i)
    {
        pthread_create(&ptids[i], NULL, producer, NULL);
        pthread_create(&ctids[i], NULL, customer, NULL);


    }

    for(int i = 0; i < 5; ++i)
    {
        pthread_detach(ptids[i]);
        pthread_detach(ctids[i]);
    }

    pthread_exit(NULL);
    
    return 0;

}
```

代码会出现错误，因为两个线程同时对链表进行读写，在customer中添加：

```cpp
 if(head == NULL)
            continue;
```

可以解决段错误问题，但是还有问题，就是消费者如果没有数据就会一直`while`等待。



**这时需要用到条件变量**。



### 2.7 条件变量

-   条件变量的类型：`pthread_cond_t`，注意条件变量不是锁。

某个条件满足之后引起阻塞 或者 解除阻塞。它也有初始化`init`和摧毁`destroy`。

```cpp
int pthread_cond_destroy(pthread_cond_t *cond);
int pthread_cond_init(pthread_cond_t *restrict cond,
                      const pthread_condattr_t *restrict attr);
```

-   初始化和释放



```cpp
int pthread_cond_timedwait(pthread_cond_t *restrict cond,
                           pthread_mutex_t *restrict mutex,
                           const struct timespec *restrict abstime);
int pthread_cond_wait(pthread_cond_t *restrict cond,
                      pthread_mutex_t *restrict mutex);
```

-   `pthread_cond_wait`：阻塞函数，调用了该函数，线程会阻塞。当这个函数调用阻塞的时候，会对互斥锁进行解锁，当不阻塞的时候，继续向下执行，会重新加锁！
-   `pthread_cond_timedwait`：等待多长时间，线程只会阻塞指定的时间。



```cpp
int pthread_cond_broadcast(pthread_cond_t *cond);
int pthread_cond_signal(pthread_cond_t *cond);
```

-   `pthread_cond_broadcast`：唤醒所有等待的线程
-   `pthread_cond_signal`：唤醒一个或多个等待的线程



**改进后的pthread_cond.c**

```cpp
#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>

// 创建一个互斥量
pthread_mutex_t mutex;
// 创建条件变量
pthread_cond_t cond;

struct Node{
    int num;
    struct Node *next;
};

// 头结点
struct Node * head = NULL;

void * producer(void * arg) {

    // 不断的创建新的节点，添加到链表中
    while(1) {
        pthread_mutex_lock(&mutex);
        struct Node * newNode = (struct Node *)malloc(sizeof(struct Node));
        newNode->next = head;
        head = newNode;
        newNode->num = rand() % 1000;
        printf("add node, num : %d, tid : %ld\n", newNode->num, pthread_self());
        
        // 只要生产了一个，就通知消费者消费
        pthread_cond_signal(&cond);

        pthread_mutex_unlock(&mutex);
        usleep(100);
    }

    return NULL;
}

void * customer(void * arg) {

    while(1) {
        pthread_mutex_lock(&mutex);
        // 保存头结点的指针
        struct Node * tmp = head;
        // 判断是否有数据
        if(head != NULL) {
            // 有数据
            head = head->next;
            printf("del node, num : %d, tid : %ld\n", tmp->num, pthread_self());
            free(tmp);
            pthread_mutex_unlock(&mutex);
            usleep(100);
        } else {
            // 没有数据，需要等待
            // 当这个函数调用阻塞的时候，会对互斥锁进行解锁，当不阻塞的，继续向下执行，会重新加锁。
            pthread_cond_wait(&cond, &mutex);
            pthread_mutex_unlock(&mutex);
        }
    }
    return  NULL;
}

int main() {

    pthread_mutex_init(&mutex, NULL);
    pthread_cond_init(&cond, NULL);

    // 创建5个生产者线程，和5个消费者线程
    pthread_t ptids[5], ctids[5];

    for(int i = 0; i < 5; i++) {
        pthread_create(&ptids[i], NULL, producer, NULL);
        pthread_create(&ctids[i], NULL, customer, NULL);
    }

    for(int i = 0; i < 5; i++) {
        pthread_detach(ptids[i]);
        pthread_detach(ctids[i]);
    }

    while(1) {
        sleep(10);
    }

    pthread_mutex_destroy(&mutex);
    pthread_cond_destroy(&cond);

    pthread_exit(NULL);

    return 0;
}

```



### 2.8 信号量

-   信号量的类型`sem_t`，里面有一个值，每访问一次，值就减少一。

```cpp
#include <semaphore.h>
int sem_init(sem_t *sem, int pshared, unsigned int value);
int sem_destroy(sem_t *sem);
```

-   初始化和销毁（释放资源）。`value`就是里面的值
-   参数：
    -   `sem`传递的信号量
    -   `pshared`：这个值代表信号量是用在线程之间还是进程之间，也就是多进程和多线程都可以使用。
        -   0代表在线程之间进行操作
        -   非0的值代表在进程之间使用
    -   `value`：信号量中的值

```cpp
int sem_wait(sem_t *sem);
int sem_trywait(sem_t *sem);
int sem_timedwait(sem_t *sem, const struct timespec *abs_timeout);
```

-   `wait`对信号量里面的值减1，如果信号量的值为0，则阻塞直到信号量中的值大于0。也可以看作对信号量加锁。
-   `trywait`就是尝试，如果信号量的值为0也不阻塞。
-   `timewait`就是阻塞多长时间



```cpp
 int sem_post(sem_t *sem);
```

-   对里面的值+1，也就是对信号量解锁。



```cpp
int sem_getvalue(sem_t *sem, int *sval);
```

-   获取里面的值



生产者的信号量初始为容器大小，消费者信号量初始为0，这一对信号量是「此消彼长」的关系。

使用信号量可以保证有数据，消费者可以不用判断。

**sem.c**

```cpp
#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>
#include <semaphore.h>

// 创建一个互斥量
pthread_mutex_t mutex;

///创建两个信号量
sem_t psem;
sem_t csem;


struct Node{
    int num;
    struct Node *next;
};

// 头结点
struct Node * head = NULL;

void * producer(void * arg) {

    // 不断的创建新的节点，添加到链表中
    while(1) {
        //调用一次-1
        sem_wait(&psem);
        pthread_mutex_lock(&mutex);
        struct Node * newNode = (struct Node *)malloc(sizeof(struct Node));
        newNode->next = head;
        head = newNode;
        newNode->num = rand() % 1000;
        printf("add node, num : %d, tid : %ld\n", newNode->num, pthread_self());
        

        pthread_mutex_unlock(&mutex);
        //对消费者的信号量+1
        sem_post(&csem);
        usleep(100);
    }

    return NULL;
}

void * customer(void * arg) {

    while(1) {
        //保证有数据
        sem_wait(&csem);
        pthread_mutex_lock(&mutex);
        // 保存头结点的指针
        struct Node * tmp = head;
        // 判断是否有数据
        // 保证有数据,不需要判断
        head = head->next;
        printf("del node, num : %d, tid : %ld\n", tmp->num, pthread_self());
        free(tmp);
        pthread_mutex_unlock(&mutex);

        sem_post(&psem);
    }
    return  NULL;
}

int main() {

    pthread_mutex_init(&mutex, NULL);
    //生产者的信号量初始化为8
    sem_init(&psem, 0, 8);
    //消费者的信号量初始化为0
    sem_init(&csem, 0, 0);


  // 创建5个生产者线程，和5个消费者线程
    pthread_t ptids[5], ctids[5];

    for(int i = 0; i < 5; i++) {
        pthread_create(&ptids[i], NULL, producer, NULL);
        pthread_create(&ctids[i], NULL, customer, NULL);
    }

    for(int i = 0; i < 5; i++) {
        pthread_detach(ptids[i]);
        pthread_detach(ctids[i]);
    }

    while(1) {
        sleep(10);
    }

    pthread_mutex_destroy(&mutex);

    pthread_exit(NULL);

    return 0;
}

```





