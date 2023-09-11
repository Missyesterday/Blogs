# 06 Linux C/C++



## 01. GCC

### 1.1 什么是GCC

-   GCC 原名为 GNU C Compiler
-   GCC现在是GNU Compiler Collection，也就是GNU 编译器套件。它包括了C、C++、OC、Java和Go语言前段，也包括了这些语言的库（例如：libstdc++，libgcj等）
-   GCC不仅支持 C 的许多“方言”，也可以区别不同的C语言标准，例如使用`-std=c99`启动GCC时，编译器使用C99标准
-   gcc/g++ -v



### 1.2 GCC工作流程

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230108011847908.png" alt="image-20230108011847908" style="zoom:40%;" />

-   预处理把头文件展开、删除注释、宏替换等，预处理的代码以`.i`结尾
-   经过编译器变成`.S`结尾的汇编代码
-   汇编器变成目标代码
-   还需要一些库代码、启动代码，经过链接器变成可执行程序：`exe`或`out`



### 1.3 gcc和g++的区别

-   gcc和g++都是GNU（组织）的一个编译器
-   误区一：gcc只能编译 c 代码，g++只能编译c++代码。但事实是两者都可以。
    -   后缀为`.c`的程序，gcc把它当作 C 程序， 但是g++当作是 C++程序
    -   后缀为`.cpp`的，两者都会认为是C++程序，而C++的语法规则更加严谨一些
    -   编译阶段，g++会调用gcc，对于C++代码，二者是等价的，但是因为gcc命令不能自动和C++程序使用的库链接，所以通常使用g++来完成链接，为了统一起见，干脆编译和链接都用g++了。这样就给人一种cpp程序只能用g++的错觉。
-   误区二：gcc不会定义`__cplusplus`宏，而g++会
    -   实际上，这个宏只是标志着编译器将会把代码按照 C 还是 C++语法来解释
    -   如上所述， 如果采用 gcc 编译器来编译 `.c`文件，则该宏就是未定义的，否则就是已定义

-   误区三：编译只能用 gcc，链接只能用 g++
    -   严格来说，这句话不算错误，但是它混淆了概念，应该这样说：编译可以用 gcc/g++，而链接可以用g++或者 `gcc -lstdc++`（表示用C++的标准进行链接）
    -   gcc命令不能自动和C++程序使用的库链接，所以通常使用 g++ 来完成链接。但在编译阶段，g++会自动调用gcc，二者等价。


### 1.4 GCC常用参数选项

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230108012807847.png" alt="image-20230108012807847" style="zoom:40%;" />

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230108140617172.png" alt="image-20230108140617172" style="zoom:40%;" />

写makefile的时候会用到这些参数。



## 02 库

### 2.1 什么是库

-   库是计算机上的一类文件，可以简单的把库文件看作一种代码仓库，它提供给使用者一些可以直接拿来用的变量、函数或类。
-   库是一种特殊的程序，编写库的程序和编写一般的程序区别步伐，只是库不能单独运行。
-   库文件有两种，静态库和动态库（共享库），区别是：静态库在程序的链接阶段被复制到了程序中；动态库在程序的链接阶段没有复制到程序中，而是程序在运行时由系统加载到内存中供程序调用
-   库的好处：
    -   代码保密（C/C++反编译后的代码还原程度是很低的，Java很高）
    -   方便部署和分发



### 2.2 工作原理

-   静态库：gcc进行链接时，会把静态库中（二进制）代码打包到可执行程序中

-   动态库：gcc进行链接时，动态库的代码不会被打包到可执行程序中

-   程序启动之后，动态库会被动态加载到内存中，通过`ldd`（list dynamic dependencies）命令检查动态库的依赖关系

-   如何定位共享库文件？

    当系统加载可执行代码的时候，能够知道其所依赖的库的名字，但是还需要绝对路径。此时需要系统的「动态载入器」来获取该绝对路径。对于elf格式的可执行程序，是由`ld-linux.so`来完成的，它先后搜索elf文件的`DT_RPATH`段、环境变量`LD_LIBRARY_PATH`、`/etc/ld.so.cache`文件列表、`/lib/, /usr/lib`目录找到库文件将其载入内存。

### 2.3 静态库的制作和使用

**命名规则：**

-   Linux：`libxxx.a`
    -   `lib`：前缀（固定）
    -   `xxx`：库名，自己起
    -   `.a`：后缀（固定）
-   Windows：`libxxx.lib`



**静态库的制作：**

-   gcc获得`.o`文件

-   将`.o`文件打包，使用ar工具（archive）：

    ```bash
    ar rcs libxxx.a xxx.o xxx.o
    ```

    r：将文件插入备存文件中

    c：建立备存文件

    s：索引

    一次可以打包多个`.o`文件

一般使用到的库文件放在`lib`目录下。



**静态库的使用：**



```bash
gcc main.c -o app -I ./include/ -l calc -L ./lib
```

-   `-I`代表寻找头文件
-   `-l`指定需要使用的库名，注意库的文件名可能是`libxxx.a`，库名是`xxx`，这里只要`xxx`
-   `-L`指定搜索库的路径
-   这些命令中间可以没有空格，也可以有，例如`-L./lib`也是可以的



### 2.4 动态库的制作和使用

**命名规则：**

-   Linux：`libxxx.so`，它在Linux下是一个可执行文件
-   Windows：`libxxx.dll`



**动态库的制作：**

-   gcc得到`.o`文件，得到和位置无关的代码，利用参数`-fpic/fPIC`，在X86下这两个参数没有区别

    ```bash
    gcc -c -fpic/-fPIC a.c b.c
    ```

-   gcc得到动态库

    ```bash
    gcc -shared a.o b.o -o libcalc.so
    ```



**动态库的使用：**

```bash
 gcc main.c -I include/ -o main -L ./lib/ -l calc
 ./main
```

-   `-I`：寻找头文件的路径
-   `-o`：输出文件名
-   `-L`：寻找库的路径
-   `-l`：指定库名

能编译，不能运行，执行`./main`时会出现动态库加载失败：

```bash
./main: error while loading shared libraries: libcalc.so: cannot open shared object file: No such file or directory
```



使用`ldd`查看`main`动态库依赖：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230108155451928.png" alt="image-20230108155451928" style="zoom:40%;" />

自己写的`libcalc.so`not found，这是需要自己配置`LD_LIBRARY_PATH`环境变量：

```bash
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/cpp_code/nowcodeLession/lesson06/library/lib
```



**方法1：修改环境变量`LD_LIBRARY_PATH`**

把动态库的绝对路径放到`LD_LIRBRARY_PATH`中，此时再`ldd`就能找到。

但是显然上面的配置是临时的，永久配置：

-   用户级别的配置：`~/.bashrc`，需要用`.`或者`source`更新
-   系统级别的配置：`/etc/profile`，同上



**方法2：修改`/etc/ld.so.cache`文件列表**

修改`/etc/ld.so.conf`，注意这里不是直接修改`/etc/ld.so.cache`，将绝对路径直接添加到文件末尾，不需要配置环境变量`LD_LIBRARY_PATH`：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230108164149652.png" alt="image-20230108164149652" style="zoom:40%;" />

再`sudo ldconfig`



**方法3：把动态库文件放到`/lib/`或者`/usr/lib/`目录下**

不推荐使用，这里系统自带的文件太多了，如果自己写的库和系统自带的名字重名，会引发严重后果。



### 2.5 静态库和动态库的对比

**01 程序编译成可执行程序的过程：**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230108164745451.png" alt="image-20230108164745451" style="zoom:30%;" />

-   静态库和动态库的都是在链接阶段作处理



**02 静态库和动态库制作过程：**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230108165036063.png" alt="image-20230108165036063" style="zoom:40%;" />

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230108165046453.png" alt="image-20230108165046453" style="zoom:40%;" />

**03 静态库的优缺点：**

-   优点：
    -   静态库被打包到应用程序中，加载速度快
    -   发布程序无需提供静态库，移植方便
-   缺点：
    -   消耗系统资源，浪费内存
    -   更新、部署、发布麻烦

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230108165808100.png" alt="image-20230108165808100" style="zoom:30%;" />

如上图，程序1和程序2都使用了静态库，则内存中有两份静态库。

**04 动态库的优缺点**

-   优点：
    -   可以实现进程间资源共享（共享库）
    -   更新、部署、发布简单，只需要把动态库重新编译打包，而不需要动自己写的程序
    -   可以控制何时加载动态库
-   缺点：
    -   加载速度比静态库慢
    -   发布程序时需要提供依赖的动态库

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230108170057295.png" alt="image-20230108170057295" style="zoom:33%;" />

注意上图，程序1和程序二中的动态库并不是完整的动态库，只是记录一些动态库的基本信息。



>   一般来说：如果库比较小，用静态库；如果库比较大，用动态库。



## 03 Makefile

### 3.1 什么是Makefile

-   一个工程中的源文件不计其数，其按类型、功能、模块分别放在若干个目录中，Makefile文件定义了一系列规则来指定哪些文件需要先编译，哪些文件需要后编译，哪些文件需要重新编译，甚至进行更复杂的功能操作，因为Makefile文件就像一个shell脚本一样，也可以执行操作系统的命令。
-   Makefile带来的好处就是「自动化编译」，一旦写好，只需要一个make命令，整个工程完全自动编译，极大提高了软件开发的效率。make是一个命令工具，是一个解释Makfile文件中指令的命令工具，一般来说，大多数IDE都有这个命令，比如Delphi的make，Visual C++的nmake，Linux下GNU的make。



### 3.2 Makefile文件名和规则

-   文件名

    -   makefile或Makefile

-   Makefile规则

    -   一个Makefile文件中可以有一个或多个规则，缩进很重要

        ```makefile
        目标 ...: 依赖...
        	命令（shell 命令）
        	... 
        ```

        -   目标：最终要生成的文件（伪目标除外）
        -   依赖；生成目标所需要的文件或是目标
        -   命令：通过执行命令对依赖操作生成目标（命令前必须Tab缩进）

    -   Makefile其他规则都是为第一条规则服务的

如果修改了源文件，可以直接修改再make一次。



### 3.3 工作原理

-   命令在执行之前，需要先检查规则中的依赖是否存在
    -   如果存在，执行命令
    -   如果不存在，继续向下检查其他的规则，如果没有一个规则来生成这个依赖，如果找到了，则执行规则中的命令
-   检测更新，在执行规则中的命令时，会比较目标和依赖文件的时间
    -   如果依赖的时间比目标的时间晚，需要重新生成目标
    -   如果依赖的时间比目标的时间早，目标不需要更新，对应规则中的命令不需要被执行



### 3.4 变量

-   自定义变量
    -   变量名=变量值 `var=hello`
-   预定义变量
    -   AR：归档维护程序的名称，默认值为`ar`
    -   CC：C编译器的名称，默认值为`cc`
    -   CXX：C++编译器的名称，默认值为`g++`
    -   $@：目标的完整名称
    -   $<：第一个依赖文件的名称
    -   $^：所有的依赖文件
    -   上面三个称为自动变量，只能在规则的命令中使用，同时不用加括号
-   获取变量的值
    -   `$(变量名)`

### 3.5 模式匹配

```makefile
%.o : %.c
	gcc -c $< -o $@
```

-   `%`：通配符，匹配一个字符串
-   两个`%`匹配的是同一个字符串





### 3.6 函数

Makefile下函数非常多，下面是经常用到的：

`$(wildcard PATTERN...)`

-   **功能**：获得指定目录下指定类型的文件列表

-   **参数**：PATTERN指的是某个或多个目录下的对应的某种类型的文件，如果有多个目录，一般使用空格间隔

-   **返回**：得到若干个文件的文件列表，文件名之间使用空格间隔

-   **示例**：

    ```makefile
    # 获取当前路径下所有的.c文件和 ./sub/下所有的.c文件
    $(wildcard *.c ./sub/*.c)
    ```

    

    返回值格式：`a.c b.c c.c d.c e.c f.c`



`$(patsubst <pattern>,<replacement>,<text>)`

-   **功能**：查找`<text>`中的单词（单词以空格、Tab、或回车换行分隔）是否符合模式`<pattern>`，如果匹配的话，则用`<replacement>`替换

-   `<pattern>`可以包括通配符`%`表示任意长度的字符串。如果`<replacement>`中也包含`%`，则`<replacement>`中的这个`%`将是`<pattern>`中那个`%`所代表的字串。

-   **返回**：函数返回被替换过后的字符串

-   示例：

    ```makefile
    $(patsubst %.c, %.o, x.c bar.c)
    ```

    返回：`x.o bar.o`



```makefile
#定义变量
src=$(wildcard ./*.c)
objs=$(patsubst %.c, %.o, $(src))
target = app
$(target) : $(objs)
    $(CC) $(objs) -o $(target)

%.o : %.c
    $(CC) -c $< -o $@
.PHONY:clean
clean:
    rm $(objs) -f
```

如果想执行clean中的内容，可以使用`make clean`命令，但是如果你创建一个名为`clean`的文件，则不会更新了，需要声明`clean`为伪目标`.PHONY:`



## 04 GDB调试

### 4.1 什么是GDB

-   GDB是由GNU组织提供的调试工具，同GCC配套组成了一套完整的开发环境，GDB是Linux和许多类Unix系统中标准开发环境。
-   一般来说，GDB主要帮助你完成下面四个方面的功能：
    -   启动程序，按照自定义的要求随心所欲的运行程序
    -   可让被调试的程序在所指定的断点出停住（断点可以是条件表达式）
    -   当程序被停住时，可以检查程序中所发生的事情
    -   可以改变程序，将一个BUG产生的影响修正从而测试其他BUG

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230114011914012.png" alt="image-20230114011914012" style="zoom:50%;" />

GDB的LOGO，一条吃虫子（BUG）的鱼。

### 4.2 准备工作

-   通常，在为调试而编译时，我们会关掉编译器优化选项`-O`，并打开调试选项`-g`，同时`-Wall`在尽量不影响程序行为的情况下选项打开所有warning，也可以发现许多问题。

-   ```bash
    gcc -g -Wall program.c -o program
    ```

-   `-g`选项的作用是在可执行程序中加入源代码的信息，比如可执行程序中第几条机器指令对应源代码的第几行，但并不是把整个源文件嵌入到可执行文件中，所以在调试时必须保证gdb能找到源文件



### 4.3 GDB命令-启动、推出、查看代码

-   启动和退出

    -   gdb可执行程序
    -   quit

-   给程序设置参数/获取设置参数

    ```shell
    set args 10 20
    show args
    ```

-   GDB使用帮助

    ```
    help
    ```

-   查看当前文件代码: `list`或`l`

    ```shell
    list/l #从默认位置显示
    list/l 行号 #显示行号上下文
    list/l 函数 #从指定的函数显示
    l 文件名:函数 #显示某个文件的函数，也可以是行号
    ```

-   设置显示的行数

    ```shell
    show list/listsize
    set list/listsize 行数
    ```

    这里的list是listsize的缩写



### 4.4 GDB命令-断点操作

-   设置断点

    ```shell
    b/break 行号
    b/break 函数名
    b/break 文件名:行号
    b/break 文件名:函数
    ```

-   查看断点：info break

    ```shell
    i/info b/break
    ```

    会显示断点的信息，包括编号：

    ```shell
    Num     Type           Disp Enb Address            What
    1       breakpoint     keep y   0x0000000000400a22 in main() at main.cpp:9
    ```

    Enb就是「有效/无效」，

-   删除断点

    ```shell
    d/del/delete 断点编号
    ```

-   设置断点无效

    ```
    dis/disable 断点编号
    ```

-   设置断点生效

    ```shell
    ena/enable 断点编号
    ```

-   设置条件断点（一般用在循环的位置）

    ```shell
    b/break 10 if i == 5
    ```



### 4.5 GDB命令-调试命令

-   运行GDB程序

    ```shell
    start #程序停在第一行
    run #遇到断点才停
    ```

-   继续运行，到下一个断点才停

    ```shell
    c/continue
    ```

    程序停在这里，这行代码没有执行

-   向下执行一行代码（不会进入函数体）

    ```shell
    n/next
    ```

-   变量操作

    ```shell
    p/print 变量名 #打印变量值
    ptype 变量名 #打印变量类型
    ```

-   向下单步调试（遇到函数进入函数体）

    ```shell
    s/step
    finish #跳出函数体，需要函数剩下的部分没有断点
    ```

-   自动变量操作

    ```shell
    display 变量名 #自动打印指定变量的值
    i/info display
    undisplay 编号
    ```

-   其他操作

    ```shell
    set var 变量名=值
    until #跳出循环
    ```

    

## 05 Linux 文件IO

首先需要明确，我们需要在内存的角度看文件的输入和输出：

-   输入代表从文件中读取数据到内存
-   输出代表从内存写数据到文件



### 5.1 标准C库的IO函数



-   标准C库的IO函数是跨平台的，这些函数会调用不同操作系统的API，也就是这个库对于不同的操作系统是不一样的
-   所以标准C库IO函数是高于Linux的系统API的，他们是调用与被调用的关系。Linux的API又叫系统调用
-   Linux的IO函数更偏底层，建议使用高级的标准C库，因为标准C库的有缓冲区
-   但是网络通信的时候需要使用Linux的API

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230114145708425.png" alt="image-20230114145708425" style="zoom:40%;" />

-   FILE结构体有三个部分
    -   文件描述符：指向对应的文件
    -   文件读写指针位置：读写文件过程中指针的实际位置，所以有两个指针
    -   I/O缓冲区，内存和硬盘的速度不同，需要缓冲区。`fflush`强制刷新缓冲区，写入到文件（硬盘）中。提高了效率，这也是为什么建议使用标准C库。
-   但是Linux的API没有缓冲区，调用一次就读/写一次，因此在网络通信这种实时性要求高的时候使用Linux的系统API



### 5.2 标准C库IO和Linux系统IO的关系

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230114151352348.png" alt="image-20230114151352348" style="zoom:40%;" />

内核部分的`write`和`read`就是Linux的系统IO函数。可能标准C库的IO函数多次读取数据才会执行一次Linux的IO函数。



### 5.3 虚拟地址空间

-   虚拟内存有虚拟地址空间，虚拟地址空间是不存在的，是程序员想象出来的。程序运行起来之后，就会有一个虚拟地址空间，随着程序的停止而消失。
-   程序就是磁盘中的代码，进程就是运行中的程序。
-   虚拟地址空间可以解决应用程序加载到内存空间中会产生的一些问题。
-   虚拟地址空间的大小是由计算机决定的，例如32位的机器就是2的32次方（大约4G），64位机器则是2的48次方。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230114152258796.png" alt="image-20230114152258796" style="zoom:40%;" />

-   虚拟地址空间由CPU的MMU(Memory management unit)映射到真实的物理内存上，虚拟地址空间实际并不会占用4G的内存空间，这个属于CPU管理。
-   虚拟地址空间由用户区和内核区组成。用户不能操作内核区，没有读写权限。用户可以操作堆和栈空间。如果想操作内核区的数据，只能通过Linux 的系统API。
-   从下往上分析虚拟内存空间：
    -   `nullptr`和`NULL`等都是存放在受保护的地址段
    -   代码段主要存放我们写的代码
    -   data存放已经初始化的全局变量，bas存放未初始化的全局变量
    -   堆空间就是存放`new`和`malloc`创建出来的数据，堆空间是从低地址往高地址存
    -   共享库
    -   栈空间比较小，栈空间是从高地址往低地址村
    -   命令行参数就是执行程序的参数，例如main中的argc



### 5.4 文件描述符

`fopen`会返回一个`FILE*`，里面有一个文件描述符。它存在内核区，内核也是一个程序，PCB进程控制块是一个复杂的结构体，用来保存进程相关的数据。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230114155227689.png" alt="image-20230114155227689" style="zoom:40%;" />

-   PCB中有一个「文件描述符表」，这是一个数组， 存储了很多文件描述符，每个文件描述符都可以定位一个文件，这样就可以同时打开多个文件。
-   文件描述符表的默认大小是1024，最多能同时打开1024个文件。
-   文件描述符表的前三个默认是标准输入、标准输出和标准错误，默认是打开状态。这三个都指向当前终端，终端也是一个文件（具体来说是设备文件）。这三个文件描述符的值是0、1、2（文件描述符是int类型），同时对应同一个终端。也就是说不通的文件描述符可以对应同一个文件，可以用`fopen`多次打开一个文件，同时文件描述符的值是不一样的。
-   `fclose`会释放文件描述符。`fopen`会在表里找一个最小的没有被占用的文件描述符。



>   在Linux中，一切皆文件，不管什么硬件，最终都会虚拟成一个文件来管理，例如显示器、网卡、显卡，可以通过文件来管理这些硬件。



### 5.5 Linux系统IO函数



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230114160726274.png" alt="image-20230114160726274" style="zoom:40%;" />



-   标准C库的底层会调用Linux的API，例如`fopen`调用`open`，可以使用`man 2 open`查看`open`的用法

    ```c
           #include <sys/types.h>
           #include <sys/stat.h>
           #include <fcntl.h>
    		//打开一个存在的文件
           int open(const char *pathname, int flags);
    		//创造一个新的文件
           int open(const char *pathname, int flags, mode_t mode);
    
           int creat(const char *pathname, mode_t mode);
    ```

    需要引入三个头文件，前面两个头文件定义了一些需要用到的宏，真正的函数定义在第三个头文件里。

    C语言没有函数重载，上面`open`类似函数重载的效果使用可变参数实现的。

    -   `pathname`是要打开的文件路径

    -   `flags`是对文件的操作权限设置和其他设置

        The argument flags must include one of the following access modes: O_RDONLY, O_WRONLY, or O_RDWR. These request opening the file read-only, write-only, or read/write, respectively.

        可以看到有三种（O_RDONLY, O_WRONLY, or O_RDWR）可选，这与`fopen`是不同的，同时这三个是互斥的。这三种是必选的，还有可选

        -   `O_APPEND`：添加在后面
        -   `O_CREAT`：如果不存在则创造新文件等
        -   这些权限之间用`|`位或操作相连

    -   返回值是`int`类型：RETURN VALUE open() and creat() return the new file descriptor, or -1 if an error occurred (in which case, errno is set    appropriately). 

        返回一个新的文件描述符，如果调用失败返回-1。

    -   errno：属于Linux系统函数库，库里面的一个全局变量，记录的是最近的错误号。可以用`perror`函数打印`errno`的错误描述，需要输入一个s参数（用户描述），例如hello，最终输出的内容是`hello:xxx(实际的错误描述)`

    -   `mode`：这是一个可选项，必须是一个八进制的数，例如`0777`（0开头代表八进制），最终的权限是：`(mode & ~umask).`不同的用户的`umask`是不同的，root用户是`0022`，普通用户是`0002`。其实umask就是抹去一些权限，例如0002就是抹去其他组用户的写权限。最终`0777`会变成`0755`。



**打开一个存在的文件：**

```cpp
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
int main()
{
    int fd = open("./a.txt", O_RDONLY);//假如没有a.txt文件
    if(fd == -1)
    {
        perror("open"); //open: No such file or directory
    }
    //关闭
    close(fd);
    return 0;
}
```



**创建一个新文件：**

```c
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
int main()
{
    //创建一个新文件
    //flags 32位，每一位都是一个标志位，代表一种情况，用 位或 操作可以把不同标记位加起来
    int fd = open("./create.txt", O_RDWR | O_CREAT, 0777);
    if(fd == -1 )
    {
        perror("open");
    }

    close(fd);

    return 0;
}
```

最终`create.txt`的权限就是755（root用户的umask是0022）：

```shell
-rwxr-xr-x 1 root root    0 Jan 14 17:04 create.txt
```



**文件读写：**

```cpp
ssize_t read(int fd, void *buf, size_t count);
```

-   `fd`：文件描述符，通过`open`得到，可以通过文件描述符操作某个文件
-   `buf`：需要读取数据存放的地方，一般是数组的地址（其实是一个传出参数）
-   `count`：指定的数组大小
-   返回值：
    -   如果成功，返回实际读取到的的字节数（>0），返回值是0代表EOF（end of file），表示文件已经读区完毕；
    -   失败返回-1，并且设置`errno`



```cpp
ssize_t write(int fd, const void *buf, size_t count);
```

-   `fd`：文件描述符，通过`open`得到，可以通过文件描述符操作某个数据
-   `buf`：要往磁盘写入的数据，一般是数组
-   `count`：要写的数据的实际大小
-   返回值：
    -   如果成功，返回实际写入的字节数
    -   如果失败，返回-1，并设置`errno`



**实现文件拷贝**

假设当前目录下有一个`english.txt`文件：

```cpp
#include <unistd.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
//       ssize_t read(int fd, void *buf, size_t count);


int main()
{
    //通过open打开 english文件
    int srcfd = open("english.txt", O_RDONLY);
    if(srcfd == -1)
    {
        perror("open");
        return -1;
    }


    //创建一个新的文件（拷贝文件）
    int destfd = open("cpy.txt", O_WRONLY | O_CREAT, 0664);
    if(destfd == -1)
    {
        perror("open");
        return -1;
    }
    //读写
    char buf[1024] = {0};
    int len = 0;
    while((len = read(srcfd, buf, sizeof(buf))) > 0)
    {
        write(destfd, buf, len);
    }


    //关闭文件
    close(destfd);
    close(srcfd);

    return 0;
}

```





**`lseek`函数：**

对应标准C库的`fseek`：

```cpp
 off_t lseek(int fd, off_t offset, int whence);
 int fseek(FILE *stream, long offset, int whence);
```

-   `lseek`是linux系统函数，`fseek`是标准库函数。
-   标准库用的文件指针`FILE*`，`lseek`用的是文件描述符。
-   `offset`是偏移量
-   `whence`是标记：
    -   `SEEK_SET`：设置文件指针的偏移量（由offset指定）
    -   `SEEK_CUR`：设置偏移量：当前位置  + 第二个参数offset的值
    -   `SEEK_END`：设置偏移量：文件大小 + 第二个参数offset的值
-   返回值：返回文件指针的位置



作用：

1.   移动文件指针到头文件：

     ```cpp
     lseek(fd, 0, SEEK_SET);
     ```

2.   获取当前文件指针的位置：

     ```cpp
     lseek(fd, 0, SEEK_CUR);
     ```

3.   获取文件长度：

     ```cpp
     lseek(fd, 0, SEEK_END);
     ```

4.   拓展文件长度，当前文件10b，例如想增加100b：

     ```cpp
     lseek(fd, 100, SEEK_END);//需要写入一次数据才管用
     ```

     ```cpp
     #include <sys/types.h>
     #include <sys/stat.h>
     #include <unistd.h>
     #include <fcntl.h>
     #include <stdio.h>
     int main()
     {
         int fd = open("hello.txt", O_RDWR);
     
         if(fd == -1)
         {
             perror("open");
             return -1;
         }
     
         //拓展文件长度
         int ret = lseek(fd, 100, SEEK_END);
         if(ret == -1)
         {
             perror("lseek");
             return -1;
         }
     
         //  写入一个空数据
         write(fd, " ", 1);
         close(fd);
         return 0;
     
     }
     
     ```

     

>   拓展的功能有什么用呢？
>
>   比如下载一个5G的东西，需要一定的时间，如果磁盘剩余的大小在这段时间内没有5G的空间了，那么就会失败。下载软件可以先扩展文件长度，用0占用5G的空间，再慢慢下载。



**`stat`和`lstat`函数：**

```cpp
 int stat(const char *path, struct stat *buf);
int lstat(const char *path, struct stat *buf);
```



linux系统中也有一个`stat`命令，用来查看文件的信息。

这些函数返回一个文件的相关信息：

-   `pathname`：操作的文件路径
-   `stat *buf`：结构体变量，传出参数，这是一个传出参数
-   如果成功，返回0；如果失败，返回-1，并设置errno



这两个函数的区别在于：

-   如果有一个软连接`a`指向`b`：
-   `stat`：获得的是`b`的信息
-   `lstat`：获得的是`a`的信息



`struct stat`：

```cpp
struct stat {
    dev_t     st_dev;     /* ID of device containing file */
    ino_t     st_ino;     /* inode number */
    mode_t    st_mode;    /* protection,文件类型和权限 */
    nlink_t   st_nlink;   /* number of hard links，硬连接的数量 */
    uid_t     st_uid;     /* user ID of owner */
    gid_t     st_gid;     /* group ID of owner */
    dev_t     st_rdev;    /* device ID (if special file) */
    off_t     st_size;    /* total size, in bytes */
    blksize_t st_blksize; /* blocksize for file system I/O */
    blkcnt_t  st_blocks;  /* number of 512B blocks allocated */
    time_t    st_atime;   /* time of last access */
    time_t    st_mtime;   /* time of last modification */
    time_t    st_ctime;   /* time of last status change */
};
```



`st_mode`变量：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230119124229269.png" alt="image-20230119124229269" style="zoom:40%;" />

文件类型：0开头代表八进制数，然后把八进制数字换成二进制放入上面的数组中。和掩码作与操作可以得到文件类型。想要判断权限则需要作或操作。



**获取某个文件的大小：**

```cpp
#include <sys/stat.h>
#include <unistd.h>
#include <stdio.h>

int main()
{
    struct stat statbuf;
    int ret =  stat("a.txt", &statbuf);
    if(ret == -1)
    {
        perror("stat");
        return -1;
    }

    printf("size: %ld\n", statbuf.st_size);
    return 0;

}
```



### 5.6 模拟实现`ls -l`命令

```shell
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <pwd.h>
#include <grp.h>
//模拟实现ls -l指令
//-rw-r--r-- 1 root root    6 Jan 19 12:59 a.txt
int main(int argc, char* argv[])
{
    //判断输入的参数是否正确
    if(argc < 2)
    {
        printf("%s filename\n", argv[0]);
        return -1;
    }

    //通过stat函数获取传入文件的信息
    struct stat st;
    int ret = stat(argv[1], &st);
    if(ret == -1)
    {
        perror("stat");
        return -1;
    }

    //获取文件类型和访问权限
    char perms[11] = {0}; //用于保存文件类型和文件权限
    switch(st.st_mode & S_IFMT)
    {
        case S_IFLNK:
            perms[0] = 'l';
            break;
        case S_IFDIR:
            perms[0] = 'd';
            break;
        case S_IFREG:
            perms[0] = '-';
            break;
        case S_IFBLK:
            perms[0] = 'b';
            break;
        case S_IFCHR:
            perms[0] = 'c';
            break;
        case S_IFSOCK:
            perms[0] = 's';
            break;
        case S_IFIFO:
            perms[0] = 'p';
            break;
        default:
            perms[0] = '?';
            break;
    }

    //判断文件访问权限
    //文件所有者
    perms[1] = (st.st_mode & S_IRUSR) ? 'r' : '-';
    perms[2] = (st.st_mode & S_IWUSR) ? 'w' : '-';
    perms[3] = (st.st_mode & S_IXUSR) ? 'x' : '-';

    //文件所在组的权限
    
    perms[4] = (st.st_mode & S_IRGRP) ? 'r' : '-';
    perms[5] = (st.st_mode & S_IWGRP) ? 'w' : '-';
    perms[6] = (st.st_mode & S_IXGRP) ? 'x' : '-';
    //其他人
    perms[7] = (st.st_mode & S_IROTH) ? 'r' : '-';
    perms[8] = (st.st_mode & S_IWOTH) ? 'w' : '-';
    perms[9] = (st.st_mode & S_IXOTH) ? 'x' : '-';
    
    //硬连接数
    int linkNum = st.st_nlink;

    //文件所有者的名称
    char* fileUser = getpwuid(st.st_uid)->pw_name;

    //文件所在组
    char* fileGrp = getgrgid(st.st_gid)->gr_name;
    //文件大小
    long int fileSize = st.st_size;
    //获取修改的时间
    char *time = ctime(&st.st_mtime);
    char mtime[512] = {0};
    //去除换行
    strncpy(mtime, time, strlen(time) - 1);
    char buf[1024];
    sprintf(buf, "%s %d %s %s %ld %s %s", perms, linkNum, fileUser, fileGrp, fileSize, mtime, argv[1]);
    printf("%s\n", &buf);
    return 0;

}

```



需要注意`argc`是自动计算传入参数的个数的，`argv`的第0个元素是程序的名字，第1个元素才是自己传入的变量，所以用`argv[1]`取出传入的文件名。



### 5.7 文件属性操作函数

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230119135746039.png" alt="image-20230119135746039" style="zoom:40%;" />

**`accsess`函数：**

```c
#include <unistd.h>
int access(const char *pathname, int mode);
```

作用：判断当前进程是否能访问某个文件，或者某个文件是否存在。

参数：

-   `pathname`：判断的文件路径
-   `mode`：判断的权限，用宏值：
    -   `F_OK`：判断文件是否存在
    -   `R_OK`：判断读权限
    -    `W_OK`：判断写权限
    -    `X_OK`：判断执行权限

成功返回0，失败返回-1。



判断`a.txt`是否存在

```cpp
#include <unistd.h>
#include <stdio.h>

int main()
{
    int ret = access("a.txt", F_OK);
    if(ret == -1)
    {
        perror("access");
        return -1;
    }

    printf("文件存在!\n");

    return 0;
}
```



**`chmod`函数：**

```c
#include <sys/stat.h>

int chmod(const char *path, mode_t mode);
```

-   第一个参数`path`就是文件路径
-   `mode`就是需要修改的权限值，可以是一个八进制数，也可以是宏

修改`a.txt`的权限：

```cpp
#include <sys/stat.h>
#include <stdio.h>
int main()
{
    int ret = chmod("a.txt", 0764);
    if(ret == -1)
    {
        perror("chmod");
        return -1;
    }
    
    return 0;
}
```



**`chown`函数：**

```cpp
#include <unistd.h>

int chown(const char *path, uid_t owner, gid_t group);
```

参数：

-   文件名
-   所有者id
-   所在组id

例如查看`/etc/passwd`文件：

```
root:x:0:0:root:/root:/bin/bash
```

root的所有者和所在组是0和0，也可以用`id`命令查看。修改的时候需要有权限。



**`truncate`函数：**

```cpp
#include <unistd.h>
#include <sys/types.h>

int truncate(const char *path, off_t length);
```

作用：用来缩减或扩展文件的大小至指定的大小

参数：

-   `path`：文件路径
-   `length`：修改后文件的大小，单位是bytes

返回值：成功返回0，失败返回-1。如果增加大小，扩展空字节0，如果缩小，则截断。



### 5.8 目录操作函数

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230119142944187.png" alt="image-20230119142944187" style="zoom:40%;" />



**`mkdir`函数：**

```cpp
#include <sys/stat.h>
#include <sys/types.h>

int mkdir(const char *pathname, mode_t mode);
```

作用：创建一个目录

参数：

-   `pathname`要创建的目录的路径
-   `mode`：权限，八进制数或宏

返回值：成功0，失败-1。



创建一个`aaa`目录：

```cpp
#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>

int main()
{
    int ret = mkdir("aaa", 0777);

    if(ret == -1)
    {
        perror("mkdir");
        return -1;
    }
    return 0;
}
```

虽然给的权限是777，但是最终的权限要和`umask`操作，抹除一些权限，**一个目录要有可执行权限才可以进入！**



**`rmdir`函数：**

```cpp
#include <unistd.h>

int rmdir(const char *pathname);
```

其实没什么用，只能删除空目录。



**`rename`函数：**

```cpp
#include <stdio.h>

int rename(const char *oldpath, const char *newpath);
```

用新路径替换旧的目录。



**`chdir`和`getcwd`函数：**

```cpp
#include <unistd.h>

int chdir(const char *path);
char *getcwd(char *buf, size_t size);
```

`chdir`：

作用：修改进程的工作目录

参数：需要修改的工作目录



`getcwd`：

作用：获取当前工作目录

参数：

-   `buf`：存储的路径，指向的是一个数组
-   `size`：数组的大小

返回值：

-   成功返回一个指向当前工作路径的指针，和`buf`的值相同
-   失败返回`NULL`，同时设置errno，`buf`未定义。



```cpp
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
int main()
{
    //获取当前工作路径
    char buf[128];
    getcwd(buf, sizeof(buf));
    printf("当前的工作目录是：%s\n", buf);

    //修改工作目录
    int ret = chdir("/root/cpp_code/nowcodeLession/lesson14");
    if(ret == -1)
    {
        perror("chdir");
    }

    //创建一个新的文件
    int fd = open("chdir.txt", O_CREAT | O_RDWR, 0664);
    if(fd == -1)
    {
        perror("open");
    }

    close(fd);

    char buf1[128];
    getcwd(buf1, sizeof(buf1));
    printf("当前的工作目录是：%s\n", buf1);
    return 0;
}
```

注意当前工作路径不是程序文件的路径，而是**执行命令的路径**。例如，你在根目录执行`./paht/to/file/chdir`，则工作目录就是根目录。



### 5.9 目录遍历函数

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230119151211374.png" alt="image-20230119151211374" style="zoom:40%;" />

这三个文件在标准C库中，用`man 3`查看。



**`opendir`函数：**

```cpp
#include <sys/types.h>
#include <dirent.h>

DIR *opendir(const char *name);
```

功能：打开一个目录

参数：`name`就是需要打开的目录的名称

返回值：`DIR*`类型，`DIR`类型是一个目录流(directory stream)类型，具体的结构对用户不可见。

如果错误，返回`NULL`。

**`readdir`函数：**

```cpp
#include <dirent.h>

struct dirent *readdir(DIR *dirp);

```

功能：读取目录中的数据，每次调用，都会读取下一个文件。

参数：`dirp`是通过 `opendir`返回的结果

返回值：`struct dirent *`是读取到文件的信息，如果读取失败或者读取到末尾返回NULL。

On Linux, the dirent structure is defined as follows:

```cpp
struct dirent {
    ino_t          d_ino;       /* inode number，此目录进入点的inode */
    off_t          d_off;       /* not an offset; see NOTES，目录文件开头到此目录进入点的偏移 */
    unsigned short d_reclen;    /* length of this record，d_name的长度，不包含NULL字符*/
    unsigned char  d_type;      /* type of file; not supported
                                              by all file system types
                                             d_name所指向的文件类型*/
    char           d_name[256]; /* filename 文件名*/
};

```

Linux中共有下面几种`d_type`：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230119173135424.png" alt="image-20230119173135424" style="zoom:40%;" />

>   打开_GNU_SOURCE这个宏可以打开一些功能，比如为了在Linux系统上编译使用带有检测文件type的宏（S_ISxxxx）



写一个统计传入文件夹中普通文件个数的程序：

```cpp
#define _GNU_SOURCE
#include <sys/types.h>
#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
int getFileNum(const char *);
int main(int argc, char* argv[])
{
    //读取某个目录下所有普通文件的个数
    if(argc < 2)
    {
        printf("%s path\n", argv[0]);
        return -1;
    }
    int num = getFileNum(argv[1]);
    printf("普通文件的个数为: %d\n", num);
    return 0;
}

//用于获取目录下所有普通文件的个数
int getFileNum(const char * path)
{
    //1. 打开目录
    DIR* dir = opendir(path);
    if(dir == NULL)
    {
        perror("opendir");
        exit(0);
    }

    struct dirent *ptr;

    //记录普通文件的个数
    int total = 0;
    //结束条件是readdir不等于NULL
    while((ptr = readdir(dir)) != NULL)
    {
        //获取名称
        char * dname = ptr->d_name;


        //忽略掉. 和..
        if(strcmp(dname, ".") == 0 || strcmp(dname, "..") == 0)
        {
            continue;
        }
        //判断是普通文件还是目录
        if(ptr->d_type == DT_DIR)
        {
            //需要继续读取这个目录
            char newpath[256];
            sprintf(newpath, "%s/%s", path, dname);
            total += getFileNum(newpath);
        }
        if(ptr->d_type == DT_REG)
        {
            //普通文件
            total++;
        }
    }
    //关闭目录
    closedir(dir);
    return total;
}
```



### 5.10 `dup`和`dup2`函数

**`dup`函数：**

```cpp
#include <unistd.h>

int dup(int oldfd);
```

作用：复制一个新的文件描述符，这两个文件描述符指向同一个文件。同时新的文件描述符是从空闲的文件描述符表中找到一个最小的。



```cpp
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>

int main()
{
    int fd = open("a.txt", O_RDWR | O_CREAT, 0664);
    int fd1 = dup(fd);

    if(fd1 == -1)
    {
        perror("dup");
        return -1;
    }

    printf("fd : %d, fd1 : %d\n", fd, fd1);
    close(fd);

    char * str = "hello world";
    int ret =  write(fd1, str, strlen(str));//fd1也能对a.txt进行操作
    if(ret == -1)
    {
        perror("write");
        return -1;
    }
    return 0;
    
}
```



**`dup2`函数：**

```cpp
#include <unistd.h>

int dup(int oldfd);
int dup2(int oldfd, int newfd);
```

`dup2`可以由我们指定的`newfd`来复制，如果`newfd`被打开了，则会先关闭，可以把`dup2`想象成对`newfd`的重定向。

`oldfd`必须是一个有效的文件描述符。

返回的是`newfd`。

```cpp
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>

int main()
{
    int fd = open("1.txt", O_RDWR | O_CREAT, 0664);
    if(fd == -1)
    {
        perror("open");
        return -1;
    }

    int fd1 = open("2.txt", O_RDWR | O_CREAT, 0664);
    if(fd1 == -1)
    {
        perror("open");
    }

    printf("fd : %d, fd2 : %d\n", fd, fd1);
    int fd2 = dup2(fd, fd1);
    if(fd2 == -1)
    {
        perror("dup2");
    }

    //通过fd1去写数据, 实际写的是1.txt
    char* str = "hello dup2";
    int ret = write(fd1, str, strlen(str));
    if(ret == -1)
    {
        perror("write");
        return -1;
    }

    printf("fd : %d, fd1 : %d, fd2 : %d", fd, fd1, fd2);
    close(fd);
    close(fd1);
}
```



### 5.11 `fcntl`函数

```cpp


#include <unistd.h>
#include <fcntl.h>

int fcntl(int fd, int cmd, ... /* arg */ );
```

功能：

-   复制文件描述符
-   设置/获取 文件描述符的状态

参数：

-   `fd`：指定的文件描述符
-   `cmd`：对`fd`进行的操作
    -   `F_DUPFD`：复制文件描述符（类似于`dup`），得到新的文件描述符通过返回值返回
    -   `F_GETFL`：获取指定文件描述符的文件状态flag，获取的flag和通过open函数传递的flag是一个东西
    -   `F_SETFL`：设置文件描述符文件状态flag
        -   必选项：`O_RDONLY`,`O_WRONLY`,`O_RDWR`
        -   可选项：`O_APPEND`,`O_NONBLOCK`等，分别表示追加数据，设置成非阻塞。





>   关于阻塞和非阻塞：
>
>   描述的是函数调用的行为。阻塞函数在调用结果返回之前，当前线程被挂起，得到结果后才会返回；非阻塞则是调用这个函数立即返回，不会阻塞。阻塞就是要等别人。



修改文件权限：

```cpp
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>

int main()
{
    int fd = open("a.txt", O_RDWR);//O_RDWR的写表示覆盖

    //复制文件描述符
    int ret = fcntl(fd, F_DUPFD);

    //修改或获取文件状态的flag
    
    //先获取文件描述符的状态flag,直接修改会覆盖原来的flag
    int flag = fcntl(fd, F_GETFL);
    //修改文件描述符状态的标记，给flag加入 O_APPEND这个标记
    fcntl(fd, F_SETFL, flag | O_APPEND);

    char* str = "你好";
    write(fd, str, strlen(str));
    close(fd);
    printf("%d\n", strlen(str));
    return 0;
}
```



