# JVM调优工具



------

## JProfiler

### 基本概述

#### 特点

-   使用方便
-   提供模版
-   支持jdbc、nosql、servlet、socket等进行分析
-   CPU、Thread、Memory分析功能强大
-   支持离线、在线分析
-   支持监控本地、远程JVM
-   跨平台



#### 主要功能

1.   **方法调用**

     对方法调用的分析可以帮助了解程序正在做什么，并找到提高其性能的方法

2.   **内存分配**

     通过分析堆上对象，引用链和垃圾收集能修复内存泄漏问题，优化内存使用

3.   **线程和锁**

     JProfiler提供多种针对线程和锁的分析试图发现多线程问题

4.   **高级子系统**

     许多性能问题都发生在更高的语义级别上。例如，对于JDBC调用，可能需要找出执行最慢的SQL语句。JProfiler支持对这些子系统进行集成分析。

### 安装和配置

1.   在JProfiler中集成idea
2.   在idea中绑定JProfiler

### 具体使用

#### 数据采集方式

JProfiler的数据采集分为两种：Sampling（样本采集）和Instrumentation（重构模式）

-   Instrumentation：这是JProfiler的全功能模式。在class加载之前，JProfiler把相关功能代码写入到需要分析的class的bytecode中，对正在运行的JVM有一定影响。
    -   优点：功能强大。在此设置中，调用堆栈的信息是准确的。
    -   缺点：若要分析的class较多，则对应的性能影响较大，CPU开销可能很高（取决于Filter的控制）。因此使用此模式一般配合Filter使用，只对特定的类或包进行分析。
-   Sampling：类似于样本统计，每隔一定时间（5ms）将每个线程栈中方法栈中的信息统计出来。
    -   优点：对CPU的开销非常低，对应用影响小（即使不配置任何Filter）
    -   缺点：一些数据/特性不能提供（例如：方法的调用次数、执行时间）

>   注：JProfiler本身没有指出数据的采集类型，这里的采集类型是针对方法调用的采集类型。因为JProfiler的绝大多数核心功能都依赖方法调用采集的数据，所以可以直接认为JProfiler的数据采集类型。

如果正在运行，则使用Sampling

#### 遥感监测Telemetries

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220711064734476.png" alt="image-20220711064734476" style="zoom:40%;" />

#### 内存视图Live Memory

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220711063627406.png" alt="image-20220711063627406" style="zoom:40%;" />

-   记录对象 Record Objects：查看特定时间段内对象的分配，并记录分配的调用堆栈。会降低系统性能，查看内存泄漏的时候才使用。
-   分配访问树 Allocation Call Tree：显示一颗请求树或者方法、类、包或对已选择类带有注释的分配信息的J2EE组件
-   分配热点 Allocation  Hot Spots：显示一个列表，包括方法、类、或分配已选类的J2EE组建。可以标注当前值并显示差异值。对于每个热点都可以显示它的跟踪记录树
-   类追踪器 Class Tracker：类跟踪视图可以包含任意数量的图表，显示选定的类和包的实例与时间

分析：内存中对象的情况

-   频繁创建的Java对象：死循环、循环次数过多
-   存在大对象：读取文件时，byte[]应该边读边写。如果长时间不写出的话，会导致byte[]过大。
-   存在内存泄漏

#### 堆遍历器 Heap Walker

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220711065404778.png" alt="image-20220711065404778" style="zoom:40%;" />

#### CPU 视图 CPU Views

在需要时调用

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220711065747892.png" alt="image-20220711065747892" style="zoom:40%;" />

#### 线程Threads

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220711065926452.png" alt="image-20220711065926452" style="zoom:40%;" />

线程分析主要关系的三个问题：

1.   web容器的线程最大数。例如：Tomcat的线程容量应该略大于最大并发数。
2.   线程阻塞。
3.   线程死锁





## Arthas

### 基本概述

#### 背景

jvisualvm和jprofiler都是图形化界面，而Arthas（阿尔萨斯）是命令行交互模式。

https://arthas.aliyun.com/zh-cn/

java -jar arthas-boot.jar

[ERROR] The telnet port 3658 is used by process 9415 instead of target process 11729, you will connect to an unexpected process.

需要stop上一次连接



## JMC



