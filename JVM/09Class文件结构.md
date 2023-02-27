# 09 Class文件结构

## 1. 概述

### 字节码文件的跨平台性

#### Java语言：跨平台的语言

-   当Java源代码成功编译成字节码后，如果想在不同的平台上面运行，则无需再次编译
-   这个优势不再那么吸引人了。Python、PHP、Perl、Ruby、Lisp等有强大的解释器，天生就是跨平台的
-   跨平台似乎已经成为一门语言必选的特性

####  Java虚拟机：跨语言的平台

**Java虚拟机不和包括Java在内的任何语言绑定，它只与“Class文件”这种特定的二进制文件格式所关联。**无论使用何种语言进行软件开发，只要能将源文件编译为正确的Class文件，那么这种语言就可以在Java虚拟机上执行。可以说，统一而强大的Class文件结构，就是Java虚拟机的基石、桥梁。



<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220603224712532.png" alt="image-20220603224712532" style="zoom:40%;" />

-   所有的JVM全部遵守Java虚拟机规范，也就是说所有JVM环境都是一样的，这样以来字节码文件可用在各种JVM上运行。

#### 符合JVM规范的字节码

想要让一个Java程序正确地运行在JVM中，Java源码就必须被编译为符合JVM规范的字节码。

-   **前端编译器的主要任务**就是负责将符合Java语法规范的Java代码转换为符合JVM规范的字节码文件
-   javac是一种能够将Java源码编译为字节码的前端编译器
-   javac编译器在将Java源码编译为一个有效的字节码文件过程中经历了4个步骤，分别是**词法分析、语法分析、语义解析以及生成字节码**。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220603225443638.png" alt="image-20220603225443638" style="zoom:40%;" />

Oracle的JDK软件包括两部分内容：

1.   一部分是将Java源代码编译成Java虚拟机的指令集的编译器（前端编译器并不包含在Java虚拟机中）
2.   另一部分是用于实现Java虚拟机的运行时环境

### Java的前端编译器

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220603225806032.png" alt="image-20220603225806032" style="zoom:40%;" />

**前端编译器 VS 后段编译器**

Java源代码的编译结果是字节码，那么肯定需要有一种能够将Java源码编译为字节码，承担这个重要责任的就是配置在path环境变量中的**Javac编译器**。javac是一种能够将Java源码编译为字节码的**前端编译器**。

HotSpot VM并没有强制要求编译器只能用javac来编译字节码，其实只要编译结果符合JVM规范都可以被JVM所识别即可。在Java的前端编译器领域，除了javac之外，还有一种被大家经常用到的前端编译器，那就是内置在Eclipse中的**ECJ (Eclipse Compiler for Java)编译器**。和javac的全量式编译不同，ECJ是一种增量编译器。

-   在Eclipse中，当开发人员编写完代码后，使用“CTRL + S”快捷键保存时，ECJ编译器所采用的**编译方案**是把未编译部分的源码逐行进行编译，而非每次都全量编译。因此ECJ的编译效率会比javac更加迅速和高效，当然编译质量和javac相比大致还是一样的。
-   ECJ不仅是Eclipse的默认内置前端编译器，在Tomcat中同样也是使用ECJ编译器来编译jsp文件。由于ECJ编译器是采用GPLv2的开源协议进行源代码公开。所以，大家可以登录Eclipse官网下载ECJ编译器的源码进行二次开发。
-   默认情况下，Intellij IDEA使用 javac 编译器。（还可以自己设置为AspectJ编译器 ajc）

前端编译器并不会直接涉及编译优化等方面的技术，而是将这些具体优化细节移交给HotSpot的JIT编译器负责。

复习：AOT（静态提前编译器，Ahead Of Time Compiler）

javac HelloWorld.java

### 透过字节码指令看代码细节

#### 问题

1.   类文件结构有几个部分
2.   字节码是什么？字节码都有哪些？Integer x =5; int y = 5; 比较 x== y都要经过哪些步骤？

#### 代码举例

**代码举例1:**

```java
public class IntegerTest {
	public static void main(String[] args) {

		Integer x = 5;
		int y = 5;
		System.out.println(x == y); //自动拆箱，调用Integer.intValue()

		//[-128,127]的cache
		Integer i1 = 10;
		Integer i2 = 10;
		System.out.println(i1 == i2); //true

		Integer i3 = 128;
		Integer i4 = 128;
		System.out.println(i3 == i4); //false
	}
}
```

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220603232649129.png" alt="image-20220603232649129" style="zoom:40%;" />

**代码举例2:**

```java
public class StringTest {
	public static void main(String[] args) {
		String str = new String("hello") + new String("world");
		String str1 = new String("helloworld");
		System.out.println(str == str1); //false
	}
}
```

详情可见07StringTable章。

**代码举例3:**

```java
package com.hyf.go;



class Father{
	int x = 10;
	public Father(){
		this.print();
		x = 20;
	}

	public void print() {
		System.out.println("Father.x = " + x);
	}
}

class Son extends Father{
	int x = 30;
	public Son(){
		this.print();
		x = 40;
	}
  @Override
	public void print(){
		System.out.println("Son.x = " + x);
	}
}

public class SonTest {
	public static void main(String[] args) {
		Father f = new Son();
		System.out.println(f.x);
	}
}
```



<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220604010402289.png" alt="image-20220604010402289" style="zoom:40%;" />

子类调用print的时候，father类只进行了默认赋值。

## 2. 虚拟机的基石：Class文件

### 字节码文件里有什么

源代码经过前端编译器编译之后会生成一个字节码文件，字节码是一种二进制的类文件，它的内容是JVM的指令，而不是像C/C++经由编译器直接生成机器码。内部类也会生成单独的字节码文件。

### 什么是字节码指令（byte code）

Java虚拟机的指令由一个字节长度的、代表着某种特定操作含义的**操作码**(opcode)以及跟随其后的零个至多个代表此操作所需参数的**操作数**(operand)所构成。虚拟机中许多指令并不包含操作数，只有一个操作码。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220604011318311.png" alt="image-20220604011318311" style="zoom:40%;" />

### 查看二进制字节码

1.   二进制打开，如用VSCode的二进制查看
2.   jclasslib
3.   javap指令

## 3. Class文件结构

-   官方文档位置：https://docs.oracle.com/javase/specs/jvms/se8/html/jvms

-   Class文件的本质

    任何一个Class文件都对应着唯一一个类或者借口的定义信息，但反过来说，Class文件实际上不一定以磁盘文件的形式存在。Class文件是一组以8位字节为基础单位的**二进制流**。

-   Class文件格式

    Class的结构不像XML等描述语言，由于他没有任何分隔符号。所以在其中的数据项，无论是字节顺数还是数量，都是被严格限定的。哪个字节代表什么含义，长度是多少，先后顺序如何，都不允许被修改。

    Class文件格式采用一种类似于C语言结构体的方式进行数据存储，这种结构中只有两种数据类型，**无符号数**和**表**。

    -   无符号数属于基本的数据类型，以u1、u2、u4、u8来分别代表1个字节、2个字节、4个字节、8个字节的无符号数，无符号数可以用来描述数字、索引引用、数量值或者按照UTF-8编码构成字符串值。
    -   表是由多个无符号整数或者其他表作为数据项够撑的复合数据类型，所有表都习惯地以`_info`结尾。表用于描述有层次关系的复合结构的数据，整个Class文件本质上就是一张表。由于表没有固定长度，所以通常会在其前面加上个数说明。

-   代码举例

    ```java
    public class Demo {
    	private int num = 1;
    
    	public int add(){
    		num = num + 2;
    		return num;
    	}
    }
    ```

-   Class文件结构概述

    Class文件的结构并不是一成不变的，随着Java虚拟机的不断发展，总是不可避免地会对Class文件结构作出一些调整，但是其基本结构和框架是非常稳定的。

    Class文件的总体结构如下：

    -   魔数
    -   Class文件版本
    -   常量池
    -   访问标志
    -   类索引、父类索引、接口索引集合
    -   字段表集合
    -   方法表集合
    -   属性表集合

    ￼￼￼<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/9F388025-E080-4088-929F-C32D9DA561D2.jpeg" alt="9F388025-E080-4088-929F-C32D9DA561D2" style="zoom:40%;" />

    ￼￼￼￼<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220604015358443.png" alt="image-20220604015358443" style="zoom:40%;" />



### 魔数：Class文件的标志

Magic Number

-   每个Class文件开头的四个字节的无符号整数称为魔数（Magic Number）。很多格式的文件都有魔术（不一定是4个字节）

-   它的唯一作用是确定这个文件是否为一个能被虚拟机接受的有效合法的Class文件。即：魔数是Class文件的标识符。

-   魔数值固定为0xCAFEBABE，不会改变

-   如果一个Class文件不以CAFEBABE开头，虚拟机在进行文件校验的时候就会报错：

    <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220604020858902.png" alt="image-20220604020858902" style="zoom:40%;" />

-   使用魔术而不是扩展名来进行识别主要是基于安全方面的考虑。因为文件扩展名可以随意改动。

### Class文件版本号

-   紧接着魔数的四个字节存储的是Class文件的版本号。第5和第6个字节所代表的含义就是编译的副版本号minor_version，而第7和第8个字节就是编译的主版本号major_version。

-   它们共同构成了class文件的格式版本号。譬如某个Class文件的主版本号为M，副版本号为m，那么这个Class文件的格式版本号就可以确定为M.m。例如45.3代表jdk1.1

-   版本号和Java编译器的对应关系如下：

    <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220605012603864.png" alt="image-20220605012603864" style="zoom:40%;" />

-   Java的版本号是从45开始的，JDK1.1之后的每个JDK大版本发布主版本号向上加一。

-   **不同版本的Java编译器编译的Class文件对应的版本是不一样的。目前，高版本的Java虚拟机可以执行由第版本编译器生成的Class文件，但是反之不行，JVM会抛出`java.lang.UnsupportedClassVersionError`异常。（向下兼容）**

-   在实际应用中，由于开发环境和生产环境的不同，可能会导致该问题的发生。因此，需要我们在开发时，特别注意开发编译的JDK版本和生产环境中的JDK版本是否一致。

    -   虚拟机JDK版本为1.k（k >= 2)时，对应的Class文件的版本号范围为 45.0 - 44+k.0（含两端）

### 常量池：存放所有常量

-   常量池(The Constant Pool)是Class文件中内容最为丰富的区域之一。常量池对于Class文件中的字段和方法解析也有着至关重要的作用。

-   随着Java虚拟机的不断发展，常量池的内容也日渐丰富。可以说，常量池是整个Class文件的基石。

-   在版本号之后，紧跟着的是常量池的数量，以及若干个常量池表项

-   常量池中常量的数量是不固定的，所以在常量池入口需要放置一项u2类型的无符号数，代表常量池容量计数值(constant_pool_count)。与Java中语言习惯不一样的是，这个容量计数是从1开始而不是0开始的。

    <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220605014405281.png" alt="image-20220605014405281" style="zoom:40%;" />

    由上表可以见，Class文件使用了一个前置的容量计数器(constant_pool_count)加若干个连续的数据项(constant_pool)的形式来描述常量池内容。我们把这一系列连续常量池数据称为常量池集合。

-   **常量池表项**中，用于存放编译时期生成的各种**字面量**和**符号引用**，这部分内容将在类加载后进入方法区的**运行时常量池**中存放。

#### 常量池计数器(constant_pool_count)

-   由于常量池的数量不固定，所以需要放置两个字节来表示常量池容量计数值

-   常量池容量计数值(u2)类型：**从1开始，**表示常量池中有多少项常量。即constant_pool_count=1表示常量池中有0个常量项。

-   Demo的值为：

    <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220605015106837.png" alt="image-20220605015106837" style="zoom:40%;" />

    其值为0x0016，也就是22

    需要注意的是，这实际上只有21项常量。索引范围为1-21。为什么呢？

    >   通常在代码中索引都是从0开始，但是这里的常量池却是从1开始，因为它把第0项常量空出来了。这是为了满足后面某些指向常量池的索引值的数据在特定情况下需要表达“不引用任何一个常量池项目”的含义，这种情况可以用索引值0来表示。也相当于一个特殊情况的占用。

#### 常量池表(constant_pool[])

-   constant_pool是一种表结构，以1 ～ constant_pool_count -1 为索引
-   常量池表主要存放两大类常量：**字面量（Literal）**和**符号引用（symbolic references）**
-   它包含了class文件结构及其子结构中引用的所有字符串常量、类或接口名、字段名和其他常量。常量池中的每一项都具备相同的特征。第1个字节作为类型标记，用于确定该项的格式，这个字节成为tag byte（标记字节、标签字节）

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220608132936230.png" alt="image-20220608132936230" style="zoom:40%;" />



##### 字面量和符号引用

在对这些常量解读前，我们需要搞清楚几个概念。

常量池主要存放两大类常量：字面量（Literal）和符号引用（symbolic references）。如下表：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220608133248048.png" alt="image-20220608133248048" style="zoom:40%;" />

**全限定名**

com/hyf/go/Demo这个就是类的全限定名，仅仅是把包名的`.`替换成了`/`，为了使连续的多个全限定名之间不产生混淆，在使用时最后一般都会加入一个`;`表示全限定名结束。全类名则是`.`。

**简单名称**

简单名称是指没有类型和参数修饰的方法或字段名，上面例子中的类的`add()`方法和`num`字段的简单名称分别是`add`和`num`。

**描述符**

<u>描述符的作用是用来描述字段的数据类型、方法的参数列表（包括数量、类型以及顺序）和返回值。</u>根据描述符规则，基本数据类型（byte、char、double、float、int、long、short、boolean）以及代表无返回值的void类型都用一个大写字符来表示，而对象类型则用字符L加对象的全限定名来表示，如下表：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220608134302093.png" alt="image-20220608134302093" style="zoom:40%;" />

注意long用`J`来表示。

用描述符来描述方法时，按照先参数列表，后返回值的顺序，参数列表按照参数的严格顺序放在一组小括号`()`内。如方法`java.lang.String.toString()`的描述符为`()Ljava/lang/String;`，方法`int abc(int[] x, int y)`的描述符为`([II) I`。

>   补充说明：
>
>   虚拟机在加载Class文件时才会进行动态类型链接，也就是说，Class文件中不会保存各个方法和字段的最终内存信息，因此，这些字段和方法的符号引用不经过转换是无法直接被虚拟机使用的。**当虚拟机运行时，需要从常量池中获得对应的符号引用，再在类加载的解析阶段将其替换为直接引用，并翻译到具体的内存地址中。**
>
>   符号引用与直接引用的区别和关联：
>
>   -   符号引用：符号引用以**一组符号**来描述所引用的目标，符号可以是任何形式的字面量，只要使用时能无歧义地定位到目标即可。**符号引用与虚拟机实现的内存布局无关，**引用的目标并不一定已经加载到了内存中。
>   -   直接引用：直接引用可以时直接**指向目标的指针、相对偏移量或是一个能间接定位到目标的句柄。直接引用是与虚拟机实现的直接内存布局相关的，**同一个符号的引用在不同虚拟机实例上翻译出来的直接引用一般不会相同。如果有了直接引用，那说明引用的目标必定已经存在于内存之中了。

##### 常量类型和结构

常量池中每一项常量都是一个表，JDK1.7之后共有14种不同的表结构数据。如下表格所示：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/BAA01399-1337-4AFB-9830-F7EB3F7B5308.jpeg" alt="BAA01399-1337-4AFB-9830-F7EB3F7B5308" style="zoom:67%;" />

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/56CEBCA8-6EB1-425F-90A5-12D6A55013B3.jpeg" alt="56CEBCA8-6EB1-425F-90A5-12D6A55013B3" style="zoom:67%;" />

-   根据上图每个类型的描述我们也可以知道每个类型是用来描述常量池中哪些内容（主要是字面量、符号引用）的。比如`CONSTANT_Integer_info`是用来描述常量池中字面量信息的，而且只是整型字面量信息。
-   标志为15、16、18的常量项类型是用来支持动态语言调用的（JDK1.7才加入的）
-   细节说明：
    -   `final`修饰的量才会在常量池里，如果是变量则不在。
    -   `CONSTANT_Class_info`结构用于表示类或接口
    -   `CONTANT_MethodHandle_info`结构用于表示方法句柄
    -   `CONSTANT_MethofType_info`结构表示方法类型
    -   `CONSTANT_InvokeDynamic_info`结构用于表示invokedynamic指令所用到的引导方法（bootstrap method）、引导方法所用到的动态调用名称（dynamic invocation name）、参数和返回类型，并可以给引导方法传入一系列称为静态参数（static argument）。

**总结**

-   这14种表（或者常量项结构）的共同点是：表开始的第一位是一个u1类型的标志位（tag），代表当前这个常量项使用的是哪种表结构，即哪种常量类型。
-   在常量池表中，`CONSTANT_Utf8_info`常量项是一种使用改进过的UTF-8编码格式来存储诸如文字字符串、类或者接口的全限定名、字段或者方法的简单名称以及描述符等常量字符串信息。
-   这14种常量项结构还有一个特点是，其中13个常量项占用的字节固定，只用`CONSTANT_Utf8_info`占用字节不固定，其大小由`length`决定。**因为从常量池存放的内容可知，其存放的是字面量和符号引用，最终这些内容都会是一个字符串，这些字符串的大小是在编写程序时才确定，**比如你定义一个类，类名可以取长取短，所以在没编译前，大小是不固定的，编译后，通过utf8编码，就可以知道其长度。

常量池可以理解为Class文件之中的资源仓库，它是Class文件结构中与其他项目关联最多的数据类型（后面很多数据类型都会指向此处），也是占用Class文件空间最大的数据项目之一。

-   常量池为什么要包含这些内容：

    Java代码在进行Javac编译的时候，并不像C/C++那样有“连接“这一步骤，而是在虚拟机加载Class文件的时候进行动态链接。也就是说，**在Class文件中不会保存各个方法、字段的最终内存布局信息，因此这些字段、方法的符号引用不经过运行期转换的话无法得到真正的内存入口地址，也就无法直接被虚拟机使用。**当虚拟机运行时，需要从常量池获得对应的符号引用，再在类创建时或运行时解析、翻译到具体的内存地址之中。关于类的创建和动态链接的内容，在虚拟机类加载过程中有详细说明。

### 访问标识(access_flag)

也叫访问标志、访问标记。

-   在常量池后，紧跟着访问标记。该标记使用两个字节表示，用于识别一些类或者接口层次的访问信息，包括：这个Class是类还是接口；是否被定义为public类型；是否被定义为abstract类型；如果是类的话，是否被声明为final等。各种访问标记如下：

    <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220608152957903.png" alt="image-20220608152957903" style="zoom:40%;" />

-   类的访问权限通常为`ACC_`开头的常量

-   每一种类型的表示都是通过设置访问标记中的32位中的特定位来实现的。比如，若是`public final`的类，则该标记为`ACC_PUBLIC | ACC_FINAL`。

-   使用ACC_SUPER可以让类更准确的定位到父类的方法`super.method()`，现代编译器都会设置并使用这个标记。

**补充说明**

1.   带有ACC_INTERFACE标志的class文件表示的是接口而不是类，反之则表示的是类而不是接口。
     1.   如果一个class文件设置了ACC_INTERFACE标志，那么同时也得设置ACC_ABSTRACT标志，同时它不能再设置ACC_FINAL、ACC_SUPER或ACC_ENUM标志。
     2.   如果没有设置ACC_INTERFACE标志，那么这个class文件可以具有上表中除ACC_ANNTATION外的其他所有标志。当然，互斥的标志除外。
2.   ACC_SUPER标志用于确定类或者接口里面的invokespecial指令使用的是哪一种执行语义。**针对Java虚拟机指令集的编译器都应当设置这个标志。**对于Java SE 8及后续版本来说，无论class文件中这个标志的实际值是什么，也不管class文件的版本号是多少，Java虚拟机都认为每个class文件均设置了ACC_SUPER标志。
     1.   ACC_SUPER标志是为了向后兼容由旧Java编译器所编译的代码而设计的。目前，ACC_SUPER标志在 由JDK 1.0.2之前的编译器所生成的access_flag中是没有确定含义的，如果设置了该标志，那么Oracle的Java虚拟机实现会将其忽略。
3.   ACC_SYNTHETIC标志着一位该类或接口是由编译器生成的，而不是源代码生成的
4.   注解类型必须设置ACC_ANNOTATION标志。如果设置了ACC_ANNOTATION标志，那么必须设置ACC_INTERFACE标志。
5.   ACC_ENUM标志表明该类或父类为枚举类型。

### 类索引、父类索引、接口索引集合

-   在访问标记后，会指向该类的类别、父类类别以及实现的接口，格式如下：

    <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220608155432163.png" alt="image-20220608155432163" style="zoom:40%;" />

-   这三项数据来确定这个类的继承关系。

    -   类索引用于确定这个类的全限定名
    -   父类索引用于确定这个类的父类的全限定名。由于Java语言是单继承，所以只有一个，除了`java.lang.Object`外，所有的Java类都有父类。
    -   接口索引集合就是用来描述这个类实现了哪些接口，这些被实现的接口按`implememts`语句(如果这个类本省是一个接口，则应当是`extends`语句)后的接口顺序出现在接口索引集合中。

1.   **this_class(类索引）**

     2字节无符号整数，指向常量池的索引。它提供了类的全限定名，如com/hyf/go/Demo。this_class的值必须是对常量池表中某项的一个有效索引值。常量池在这个索引处的成员必须为CONSTANT_Class_info类型结构体，该结构体表示这个class文件所定义的类或接口。

2.   **this_class(父类索引）**

     -   2字节无符号整数，指向常量池中的索引。它提供了当前类的父类的全限定名。如果我们没有继承任何类，其默认继承的是java/lang/Object类。同时，由于Java类不支持多继承，所以它只有一个。
     -   superclass指向的父类不能是final

3.   **interfaces**

     -   指向常量池的索引集合。它提供了一个符号引用到所有已实现的接口

     -   由于一个类可以实现多个接口，因此需要以数组的形式保存多个接口的索引，表示接口的每个索引也是一个指向常量池的CONSTANT_Class（当然这里就必须是接口，而不是类）。

     -   interfaces_count(接口计数器)

         interfaces_count项的值表示当前类或接口的直接超接口数量

     -   interfaces[]（接口索引集合）

         interfaces[]中每个成员的值必须是对常量池表中某项的有效索引值，它的长度为interfaces_count。每个成员interfaces[i]必须为CONSTANT_Class_info接口。在interfaces[]中，各成员所表示的接口顺序和对应的源代码中给定的接口顺序（从左到右）一致，即interfaces[0]是最左边的接口。

### 字段表集合

fields

-   用于描述接口或类中声明的变量。字段（fields）包括**类级变量以及实例级变量**，但是不包括方法内部、代码块内部声明的局部变量。
-   字段叫什么名字、字段被定义为什么数据类型，这些都是无法固定的，只能引用常量池中的常量来描述。
-   它指向常量池索引集合，它表述了每个字段的完整信息。比如**字段的标识符、访问修饰符（public、private或protected）、是类变量还是实例变量（static修饰符）、是否是常量（final修饰符）**等。

**注意事项**

-   字段表集合中不会列出从父类或者实现的接口中继承而来的字段，但有可能列出原本Java代码中不存在的字段。例如在内部类中为了保持对外部类的访问性，会自动添加指向外部类实例的字段。
-   在Java语言中字段是无法重载的，两个字段的数据类型、修饰符不管是否相同，都必须使用不一样的名称，但是对于字节码而言，如果两个字段的描述符不一致，那字段重名就是合法的。

#### 字段计数器(fields_count)

fields_count的值表示当前class文件field表成员的个数，使用两个字节来表示。

fields表中每个成员都是一个field_info结构，用于表示该类或接口所声明的所有类字段或者实例字段，不包括方法内部声明的变量，也不包括从父类或者父接口继承的字段。 

#### 字段表(fields [])

-   fields表中每个成员都是一个field_info结构的数据项，用于表示当前类或接口中某个字段的完整描述。

-   一个字段的信息包括如下信息。这些信息中，**各个修饰符都是布尔值**。

    -   作用域（public、private、protected修饰符）
    -   是实例变量还是类变量（static修饰符）
    -   可变性（final）
    -   并发可见性（volatile修饰符，是否强制从主内存读写）
    -   能否序列化（transient修饰符）
    -   字段数据类型（基本数据类型、对象、数组）
    -   字段名称

-   字段表结构

    字段表作为一个表，同样有它自己的结构

    <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220608162655193.png" alt="image-20220608162655193" style="zoom:40%;" />

**字段表访问标识**

一个字段可以被各种关键字修饰，比如：作用域修饰（public、private、protected）、static修饰符、final修饰符、volatile修饰符等。因此，其可以像类的访问标识那样，使用一些标志来标记字段。字段的访问标识有如下这些：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220608163526885.png" alt="image-20220608163526885" style="zoom:40%;" />



**字段名索引**

根据字段名索引的值，查询常量池中的指定索引项即可。

**描述符索引**

描述符的作用是用来描述字段的数据类型、方法的参数列表（包括数量、类型以及顺序）和返回值。根据描述符的规则，基本数据类型（老八样）及代表无返回值的void类型都用一个大写字符来表示，而对象则用字符`L`加对象的全限定名来表示：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220608163719902.png" alt="image-20220608163719902" style="zoom:40%;" />



**属性表集合**

一个字段还可能拥有一些属性，用于存储更多的额外信息。比如初始化值、一些注释信息等，属性个数存放在attribute_count中，属性具体内容存放在attributes数组中。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220608164308841.png" alt="image-20220608164308841" style="zoom:40%;" />

说明：对于常量属性而言，attrubute_length值恒为2。

### 方法表集合

methods：指向常量池索引集合，它完整描述了每个方法的签名。

-   在字节码文件中，**每一个method_info项都对应着一个类或者接口中的方法信息，**比如方法的访问修饰符（public、privated、protected），方法的返回值类型以及方法的参数信息等。
-   如果这个方法不是抽象的或者不是native的，那么字节码中会体现出来
-   一方面，methods表只描述当前类或接口中声明的方法，不包括从父类或父接口继承的方法。另一方面，methods表有可能会出现由编译器自动添加的方法。最典型的便是编译器产生的方法信息（比如：类、接口）初始化方法`<clinit>()`和实例初始化方法`<init>()`）。

**使用注意事项**

在Java语言中，要重载（Overload）一个方法，除了要与原方法具有相同的简单名称之外，还要求必须拥有一个与原方法不同的特征签名，特征签名就是一个方法中各个参数在常量池中的字段符号引用的集合，也就是因为返回值不会包含在特征签名之中，因此Java语言里无法仅仅依靠返回值的不同来对一个已有方法进行重载。但在Class文件格式中，特征签名的范围更大一些，只要描述符不是完全一致的两个方法就可以共存。也就是说，如果两个方法有相同的名称和特征签名，但返回值不同，那么也是可以合法共存于同一个class文件中。

也就是说，尽管Java语法规范并不允许在一个类或者接口中声明多个方法签名相同的方法，但是和Java语法规范相反，字节码文件中却恰恰允许存放多个方法签名相同的方法，唯一的条件就是这些方法之间的返回值不能相同。

#### 方法计数器（methods_count)

methods_count的值表示当前class文件methods表的成员个数。使用两个字节来表示。

methods表中每个成员都是一个method_info结构。 

#### 方法表(methods[])

-   method表中每个成员都必须是一个method_info结构，用于表示当前类或接口中某个方法的完整描述。如果某个method_info结构的access_flags项即没有设置ACC_NATIVE标志，也没有设置ACC_ABSTRACT标志，那么该结构中也应该包含实现这个方法所用的Java虚拟机指令。
-   method_info结构可以表示类和接口中定义的所有方法，包括实例方法、类方法、实例初始化方法和类或接口初始化方法
-   方法表的结构和字段表是一样的，方法表结构如下：（描述符含有返回类型和参数的信息）

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220608175121098.png" alt="image-20220608175121098" style="zoom:40%;" />

**方法表访问标识**

和字段表一样，方法表也有访问标识，而且它们的标志部分相同，部分则不同，方法表的具体访问标志如下：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220609144601284.png" alt="image-20220609144601284" style="zoom:80%;" />


### 属性表集合

attributes

方法表集合之后的属性表集合，**指的是class文件所携带的辅助信息，**比如该class文件的源文件的名称。以及任何带有`RetentionPolicy.CLASS`或者`RetentionPolicy.RUNTIME`的注解。这类信息通常被用于Java虚拟机的验证和运行，以及Java程序的调试，一般无需深入了解。

此外，**字段表、方法表都可以有自己的属性表**。用于描述某些场景专有的信息。

属性表集合的限制没有那么严格，不再要求各个属性表具有严格的顺序，并且只要不与已有的属性名重复，任何人实现的编译器都可以向属性表中写入自己定义的属性信息，但Java虚拟机运行时会忽略掉它不认识的属性。

#### 属性计数器

attributes_count的值表示当前class文件属性表的成员个数。属性表中每一项都是一个attribute_info结构。

#### 属性表

属性表(attributes[])的每个项都必须是attribute_info结构。属性表的结构比较灵活，各种不同的属性只要满足以下结构即可。

**属性表的通用格式**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220609145705667.png" alt="image-20220609145705667" style="zoom:40%;" />

即只需说明属性的名称以及占用位数的长度即可，属性表具体的结构可以去自定义。

**属性类型**

属性表实际上可以有很多类型，上面看到的Code属性只是其中一种，Java 8里定义了23种属性。下面是虚拟机中预定义的属性。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220609150029152.png" alt="image-20220609150029152" style="zoom:40%;" />

**Code属性详解**

Code属性就是存放方法体里面的代码，但是，并非所有方法表都有Code属性。像接口或者抽象方法，它们没有具体的方法体，因此也就不会有Code属性了。

Code属性表的结构，如下图：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220609150118024.png" style="zoom:40%;" />

可以看到Code属性表符合属性表的通用结构，后面是自定义的。

Code中属性计数器，Code属性还可以有属性，同样也符合属性表的通用结构。

**LineNmuber Table_attribute详解**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220609151449473.png" alt="image-20220609151449473" style="zoom:40%;" />

 <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220609152221808.png" alt="image-20220609152221808" style="zoom:40%;" />

LineNumberTable属性是**用来描述Java源码行号与字节码行号之间的对应关系**。这个属性可以用来在调试的时候定位代码执行的行数。

-   **start_PC：即字节码行号，line_number：即Java源代码行号**

在Code属性的属性表中，LineNumberTable属性可以按照任意顺序出现。此外，多个LineNumberTable属性可以共同表示一个行号在源文件中表示的内容，即LineNumberTable属性不需要与源文件的行一一对应。

**LocalVariableTable详解**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220609152639135.png" alt="image-20220609152639135" style="zoom:40%;" />

LocalVariableTable是可选变长属性，位于Code属性的属性表中。它被调试器**用于确定方法在执行过程中局部变量的信息**。在Code属性的属性表中，LocalVariableTable属性可以按照任意顺序出现。Code属性中每个局部变量最多只能有一个该属性。

-   start pc + length表示这个变量在字节码中的生命周期起始和结束的偏移量（this生命周期从0到结尾10）
-   index就是这个变量在局部变量表中的slot（槽位可复用）
-   name就是变量名称
-   Descriptor表示局部变量的类型描述。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220609153103540.png" alt="image-20220609153103540" style="zoom:40%;" />



**SourceFile属性**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220609154535757.png" alt="image-20220609154535757" style="zoom:40%;" />

属性长度始终为2。

总共长度固定为8个字节。

### 小结

本章主要介绍了Class文件的基本格式。

随着Java平台的不断发展，在将来，Class文件的内容也一定会做进一步的扩充，但是其基本的格式和结构不会做重大调整。

从Java虚拟机的角度来看，通过Class文件，可以让更多的计算机语言支持Java虚拟机平台。因此，Class文件结构不仅仅是Java虚拟机的执行入口，也是Java生态圈的基础和核心。



## 4. 使用javap指令解析Class文件



### 解析字节码的作用

通过反编译生成的字节码文件，我们可以深入的了解Java代码的工作机制。但是，自己分析类文件结构太麻烦了，除了第三方的jclasslib之外，oracle官方也提供了工具：javap。

javap是jdk自带的反解析工具。它的作用就是根据class字节码文件，反解析出当前类对应的code区（字节码指令）、局部变量表、异常表和代码行偏移量映射、常量池等信息。

通过局部变量表，我们可以查看局部变量的作用域范围、所在槽位等信息，甚至可以看到槽位复用等信息。

### javac -g操作

解析字节码文件得到的信息中，有些信息（如局部变量表、指令和代码行偏移量映射表、常量池中方法的参数名称等等）需要在使用javac编译成class文件时，指定参数才能输出。

比如：直接javac xxx.java，就不会在生成对应的局部变量表等信息，如果使用`javac -g xx.java`	就可以生产所有相关信息了，如果使用IEDA、Eclipse在默认情况下会自动生成局部变量表、指令和代码行偏移量映射表等信息。

### javap用法

javap的用法格式：javap \<options\> \<classes\>

其中classes就是要反编译的class文件。

在命令行输入javap或者javap -help可以看到javap的options有如下选项：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220609170220617.png" alt="image-20220609170220617" style="zoom:40%;" />

-   `-version`：版本信息，其实是当前javap所在jdk的版本信息，不是class在哪个jdk下生成的。
-   java -c ： 输出方法的Code属性。
-   java -v：输出的信息较全。(但也不包括私有方法和字段)
-   java -p -v：输出的信息最全。

### 使用举例

构造器的表示不同，在javap反编译的字节码文件中，构造器为原本名字，jclasslib则是init方法。

### 总结

1.   通过javap指令可以查看一个java类反汇编得到的Class文件版本号、常量池、访问标识、变量表、指令代码行号表等信息。不显示类索引、父类索引、接口索引类集合、\<clinit\>()（静态代码块）、\<init\>()等结构。
2.   通过对前面例子代码反汇编文件的简单分析，可以发现，一个方法的执行通常会涉及下面几块内存的操作。
     1.   java栈中：局部变量表，操作数栈
     2.   java堆：通过对象的地址引用去操作
     3.   常量池
     4.   其他如帧数据区、方法区的剩余部分等情况，测试中没有显示出来。
3.   一般，我们比较关注java类中每个方法的反汇编中的指令操作过程，这些指令都是顺序执行的，可以参考官方文档查看每个指令的含义。