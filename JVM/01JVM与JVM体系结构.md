# 01JVM与Java体系结构

Java是跨平台的语言，JVM则是跨语言的平台：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220430134554548.png" alt="image-20220430134554548" style="zoom:67%;" />

JVM只关心字节码文件。Java不是最强大的语言，但是JVM是最强大的虚拟机。 G1和ZGC。

## 虚拟机

虚拟机是软件，来执行一系列虚拟机算计指令。大体上，虚拟机可以分为系统虚拟机和程序虚拟机：

-   VMware就是系统虚拟机
-   程序虚拟机专门为执行单个计算机程序而设计的，典型的代表就是Java虚拟机，在Java虚拟机中执行的指令我们称之为Java字节码指令。

## Java架构模型

由于跨平台性的设计，Java的指令都是根据栈来设计的。不同平台CPU架构不同，所以不能设计为基于寄存器的。优点是跨平台，指令集小，编译器容易实现。

缺点是性能下降，实现同样的功能需要更多的指令。

## JVM的生命周期

### 虚拟机的启动

Java虚拟机的启动时通过引导类加载器（bootstrap class loader）创建一个初始类（initial class）来完成的，这个类是由虚拟机的具体实现指定的。

### 虚拟机的执行

-   一个运行中的JVM有着一个清晰的任务：执行Java程序
-   程序开始执行的时候他才运行，程序结束的时候他停止
-   <u>执行一个所谓的Java程序的时候，真真正正执行的是一个叫做Java虚拟机的进程</u>

### 虚拟机的退出

-   程序正常之行结束
-   程序在执行过程中遇到了异常或错误而异常终止
-   由于操作系统出现错误而导致Java虚拟机进程终止
-   某线程调用`Runtime`类或者`System`类的`exit`方法，或`Runtime`类的`halt`方法，并且Java安全管理器也允许这次`exit`或`halt`操作。
-   除此之外，JNI（Java Native Interface）规范描述了用JNI Invocation API来加载或卸载Java虚拟机时，Java虚拟机的退出情况。

## JVM发展历程

### Sun Classic VM

-   世界上第一款商用Java虚拟机
-   现在的hotspot内置了次虚拟机
-   此款虚拟机只提供了解释器
-   如果使用JIT编译器，就需要进行外挂。但是一旦使用了JIT编译器，JIT就会接管虚拟机的系统。解释器就不再工作。解释器和编译器不能配合工作。

### Exact VM

-   为了解决上一个虚拟机出现的问题，JDK 1.2时，sun提供了此虚拟机
-   Exact Memory Management：准确式内存管理
    -   也可以叫Non-Conservative/Accurate Memory Management
    -   虚拟机可以知道内存中某个位置的数据具体是什么类型
-   具备现代高性能虚拟机的雏形
    -   热点探测
    -   编译器与解释器混合工作模式
-   只在Solaris平台短暂使用，其他平台还是classic vm
    -   最终被hotspot虚拟机替换

### HotSpot VM

-   JDK 1.3时，HotSpot VM成为默认虚拟机
-   目前HotSpot占有绝对的市场地位
    -   JDK 6、JDK 8默认虚拟机都是HotSpot
    -   Sun/Oracle JDK和Open JDK的默认虚拟机（其他两个商用虚拟机没有方法区的概念）
-   从服务器、桌面到移动端、嵌入式都有HotSpot的身影
-   它名称中的HotSpot指的就是它的**热点代码探测技术**
    -   通过计数器找到最具编译价值的代码，触发即时编译或栈上替换
    -   通过编译器与解释器协同工作，在最优化的程序相应时间与最佳执行性能中取得平衡

### BEA的JRockit

-   <u>专注于服务器端的应用</u>
    -   它可以以不太关注程序的启动速度，因此**JRockit内部不包含解释器实现**，全部代码都靠即时编译器编译后执
-   大量行业数据显示，JRockit时世界上最快的JVM（一些超过70%）
-   优势：全面的Java运行时解决方案组合
-   08年被Oracle收购
-   Oracle表达了整合两大优秀虚拟机的工作，大致在JDK 8中完成。整合的方式是在HotSpot的基础上，移植JRockit的优秀特性

### IBM的J9

-   市场定位与HotSpot接近，服务器端、桌面应用、嵌入式等多用途的VM
-   广泛应用于IBM的各种Java产品
-   也是目前有影响力的三大商用虚拟机之一
-   17年左右，IBM发布了开源J9 VM，命名为OpenJ9，交给Eclipse基金会管理，也成Eclipse OpenJ9

>   Open JDK 和Open J9的概念是不同的，Open JDK是JDK 层面的开源，Open J9是虚拟机层面的开源

### KVM和CDC/CLDC HotSpot

-   Oracle在Java ME产品线上的两款虚拟机
-   KVM（Kilobyte）是CLDC-HI早期产品
-   KVM在更低端的设备上还有自己的市场
-   所有虚拟机的原则：一次编译，到处运行

### Azul VM和Liquid VM

-   他们与特定硬件平台绑定、软硬件配合的专有虚拟机
-   比如M1芯片的zulu

### Apache Harmony

-   Apache也曾经推出与JDK 1.5和JDK1.6兼容的Java运行平台
-    虽然没有大规模商用，但是它的Java类库代码吸纳进了Android SDK

### Microsoft VM

-   微软开发的

### Taobao JVM

目前已在淘宝、天猫上线

### Dalvik VM

-   谷歌开发的，应用于Android系统
-   Dalvik VM只能称为虚拟机，而不能称为Jav虚拟机
-   不能直接执行Java的Class文件
-   执行的是编译以后的dex文件

### Graal VM

Run Programs Faster Anywhere

-   Graal VM是跨语言的全栈虚拟机，可以作为“任何语言”的运行平台使用：Java、Kotlin、C、C++、Ruby、Python等

