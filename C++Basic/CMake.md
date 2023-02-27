# CMake

## 说明

CMake是高级编译配置工具。

当多个人用不同的语言或者编译器开发一个项目，最终要输出一个可执行文件或者共享库(dll, so等等)，这时候可以用CMake！如果不使用CMake，就要每个都gcc编译。

所有的操作都是通过编译`CMakeLists.txt`来完成的！

## 安装

1.   绝大多数linux系统已经安装了CMake
2.   如果没有安装，可以去官网下载安装

## HelloWorld

## 语法

### `PROJECT`关键字

可以用来指定工程的名字和支持的语言，默认支持所有语言

-   `PROJECT(HELLO)` 指定了工程的名字，并且支持所有语言统一建议
-   `PROJECT(HELLO CXX)` 指定了工程的名字，并且支持的语言是C++
-   `PROJECT(HELLO C CXX)` 指定了工程的名字，并且支持的语言是C和C++s

该式隐式定义了两个CMAKE变量

<projectname>_BINARY_DIR，本例中是 HELLO_BINARY_DIR

<projectname>_SOURCE_DIR，本例中是 HELLO_SOURCE_DIR

MESSAGE关键字就可以直接使用者两个变量，当前都指向当前的工作目录，后面会讲外部编译

问题：如果改了工程名，这两个变量名也会改变

解决：又定义两个预定义变量：PROJECT_BINARY_DIR和PROJECT_SOURCE_DIR，这两个变量和HELLO_BINARY_DIR，HELLO_SOURCE_DIR是一致的。所以改了工程名也没有关系

### `SET`关键字

用来显示指定变量的

-   `SET(SRC_LIST main.cpp)` `SRC_LIST`就包含了`main.cpp``
-   `SET(SRC_LIST main.cpp t1.cpp t2.cpp)` `SRC_LIST`就包含了`main.cpp`、`t1.cpp`和`t2.cpp`

### `MESSAGE`关键字

向终端输出用户自定义的信息

主要包含三种信息：

1.   `SEND_ERROR`，产生错误，生成过程被跳过
2.   `SATUS`，输出前缀为`--`的信息
3.   `FATAL_ERROR`，立即终止所有CMAKE过程。

### `ADD_EXECUTABLE`关键字

生成可执行文件

-   `ADD_EXECUTABLE(hello ${SRC_LIST})` 生成的可执行文件名是`hello`，源文件读取`SRC_LIST`中的内容

-   也可以写成`ADD_EXECUTABLE(hello main.cpp)`

上述例子可以简化成

```cmake
    PROJECT(HELLO)
    ADD_EXECUTABLE(hello main.cpp)
```

>   注意：
>
>   工程名HELLO和生成的可执行文件的hello是没有任何关系的



## 语法的基本原则

-   变量使用`${}`读取，但是在`IF`控制语句中可以直接使用变量名
-   `指令(参数1 参数2 ...)`参数使用括号括起，参数之间可以用空格或分号分开。以上面的`ADD_EXECUTABLE`指令为例，如果存在另外一个`func.cpp`源文件，就要写成`add_executable(hello main.cpp func.cpp)`或者`add_executable(hello main.cpp;func.cpp)`
-   指令时大小写无关的，参数和变量是大小写相关的，推荐使用大写指令！

### 语法注意事项

-   `SET(SRC_LIST main.cpp)`可以写成`SET(SRC_LIST "main.cpp")`，如果源文件名中有空格，则必须加双引号
-   `ADD_EXECUTABLE(hello main)` 这样写去掉了`cpp`的后缀，cmake会自动去找`.c`和`.cpp`的后缀，最好不要这样写，可能会有这样两个文件`main.cpp`和`main`

## 内部构建和外部构建

-   上述例子就是内部构建，他产生的临时文件特别多，不方便清理
-   外部构建，就会把生成的临时文件放在`build`目录下，不会对源文件有任何影响，强烈推荐使用外部构建方式

### 外部构建方式举例

1.   建立一个`build`目录，可以在任何地方，但是推荐放在当前目录下
2.   进入`build`，运行`cmake ..`，`..`表示上一级目录，也可以写出`CMakeLists.txt`的绝对路径，生成的中间文件就在`build`路径下了
3.   在`build`目录下，运行`make`来构建工程

注意外部构建的两个变量：

-   `HELLO_SOURCE_DIR` 还是工程路径
-   `HELLO_BINARY_DIR` 编译路径，也就是`build`目录所在的路径

Clion的创建了`cmake-build-debug`作为`build`路径



## 让HelloWorld看起来更像一个工程

1.   为工程添加一个子目录`src`，用来放置工程源代码
2.   添加一个子目录`doc`，用来放置这个工程的文档`hello.txt`
3.   在工程目录添加文本文件`COPYRIGHT`和`README`
4.   在工程目录添加一个`runhello.sh`的脚本，用来调用`hello`二进制
5.   将构建后的目标文件放入构建目录的`bin`子目录
6.   将`doc`目录的内容以及`COPYRIGHT`和`README`安装到`/usr/share/doc/cmake/`

### 将目标文件放入构建目录的`bin`子目录

每个目录下都有`CMakeLists.txt`文件（工程目录和`src`目录）

```bash
[root@localhost cmake]# tree
.
├── build
├── CMakeLists.txt
└── src
    ├── CMakeLists.txt
    └── main.cpp
```

外层的`CMakeLists.txt`：

```cmake
PROJECT(Hello)
ADD_SUBDIRECTORY(src bin)
```

`src`下的`CMakeLists.txt`：

```cmake
SET(LIBHELLO_SRC hello.cpp)
ADD_LIBRARY(hello SHARED ${LIBHELLO_SRC})
```

### `ADD_SUBDIRECTORY`指令

`ADD_SUBDIRECTORY(source_dir [binary_dir] [EXCLUDE_FROM_ALL])`

-   这个指令用于向当前工程添加存放源文件的子目录，并可以指定中间二进制文件和目标二进制存放的位置

-   `EXECLUDE_FROM_ALL`指令是将写的目录从编译中排出，如程序中的`example`

-   `ADD_SUBDIRECTORY(src bin)`

    将`src`子目录加入工程并指定编译输出（包含编译的中间结果）路径为`bin`目录

    如果不进行`bin`目录的指定，那么编译结果（包括中间结果）都将存放在`build/src`目录

### 更改二进制的保存路径

SET 指令重新定义 `EXECUTABLE_OUTPUT_PATH` 和 `LIBRARY_OUTPUT_PATH` 变量 来指定最终的目标二进制的位置

```cmake
SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
SET(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)
```

思考：加载哪个CMakeLists.txt当中

哪里要改变目标存放路径，就在哪里加入上述的定义，所以应该在src下的CMakeLists.txt下写

## 安装HelloWorld

-   一种是从代码编译后直接`make install`安装
-   一种是打包时指定目录安装
    -   简单一点可以：`make install DESTDIR=/tmp/test`
    -   稍微复杂一点可以：`./configure -prefix=/usr`

### 如何安装HelloWorld

使用CMAKE的一个新指令：`INSTALL`

