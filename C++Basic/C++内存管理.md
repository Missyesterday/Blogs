# 15. C++内存管理

>   从平地到万丈高楼

## 第一讲 primitives（原始的东西）

不同版本的编译器的容器背后的分配器都不同。

Doug Lea从1986年起潜心研究`malloc`算法。 所有的内存管理动作最终都会走向`malloc()`。Linux的glibc直接使用他的malloc算法，其他平台也或多或少受到了他的影响。

### 1.1 C++应用程序使用memory的途径

现在内存远没有当年紧张，可能一个字节都要考虑到，可谓「锱铢必较」。

其实所用到的很多东西，也没必要做内存管理了，在标准库的层面已经解决了。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230412232446741.png" alt="image-20230412232446741" style="zoom:50%;" />

`new`,`new[]`,`new()`,`::operator new()`都是C++提供的基本工具，C++标准库的容器 。所有的动作都到了`malloc/free`，更底层的OS层面也有一些接口。



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230412233520822.png" alt="image-20230412233520822" style="zoom:50%;" />

-   `malloc`是标准C库的函数
-   `new`是C++的关键字
-   `::operator new()`是操作符（也是一个函数），全局函数。
-   `allocate()`是C++标准库，没有重载的概念，可以自己自由设计，让容器使用。

```cpp
void* p3 = ::operator new(512);
::operator delete(p3);
```

这两个全局函数直接调用`malloc`和`free`。

clang编译器下分配器的直接使用：

```cpp
//下面两个函数都是非静态的，需要通过object调用
//分配3个int
int* p4 = allocator<int>().allocate(3);
allocator<int>().deallocate(p4, 3);
```

归还的时候，有一件很痛苦的事情，不仅需要指定指针，还需要记住分配了几个。这种事情只有容器能够做到，容器很清楚。

C++标准库提供的allocators的接口是不同的，上面的是Clang编译器下的情况（和MSVC相同）。



但是在旧版本的`alloc`，在新版本中称为`__pool_alloc`（内存池）。事实上GNUC下有7、8个分配器。



### 1.2 new关键字

new做了两个操作：

1.   分配内存
2.   调用构造函数

假如有`Complex`类，我们使用`new`：

```cpp
Complex* pc = new Complex(1,2);
```

等价于下面三行：

```cpp
Complex* pc;
try
{
    //这个函数可以被重载，没有定义就是全局的情况
    void* mem = operator new(sizeof(Complex));
    pc = static_cast<Complex*>(mem);
    //通过指针调用构造函数
    //注意：只有编译器可以这样调用构造函数，VC6似乎可以通过编译
    //可以使用定位new代替
    pc->Complex::Complex(1,2);
    // new(p)Complex(1,2);
}
catch (std::bad_alloc)
{
 	//如果alloc失败，则不调用构造函数   
}
```



`operator new()`调用了`malloc()`函数。`operator new`有一个机制，就是当调用`malloc()`失败的时候，可以调用`newHandler`（侯捷说的应该是这个单词）， 来释放一些内存。

`operator new()`有两个参数，第一个参数是大小，第二个参数与异常的抛出有关，表示这个函数是不会抛出异常的。

### 1.3 delete关键字

`new`和`delete`是对应的。

编译器会把`delete`分为两个步骤：

1.   调用析构函数，直接用指针调用析构函数是可以的

     ```cpp
     pc->~Complex();
     ```

2.   调用`operator delete()`释放内存

     这一步会调用`free()`



>   构造函数不能被直接调用，想直接调用构造函数，可以使用placement new
>
>   析构函数可以被直接调用



### 1.4 array new, array delete

```cpp
Complex* pca = new Complex[3];
delete[] pca;
```

-   array new 会调用三次ctor，**同时array new只能调用默认构造函数**
-   如果`delete`没有`[]`，只会调用一次dtor

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230413101642398.png" alt="image-20230413101642398" style="zoom:50%;" />

`malloc`分配的时候会带一块`cookie`，告诉`free()`这一块内存的大小。

**所以，如果使用array new，但是`delete`的时候，没有带`[]`，内存也会被完整回收，但是析构函数不会被调用三次，所以如果类中有指针，那么指针所指向的内存不会被完整回收，内存泄漏也是发生在这个地方。**

所以对于复数类型Complex而言，`delete`不带`[]`是不会发生内存泄漏的，但是写代码的时候还是要养成好的习惯。构造和析构的顺序是相反的。



再来看看placement new：

```cpp
A* buf = new A[3];
A* tmp = buf;
for(int i = 0; i < 3; ++i)
    new(tmp++)A(i);
```

相当于，在指针的位置调用构造函数。

### 1.5 array new与内存布局

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230413103403620.png" alt="image-20230413103403620" style="zoom:50%;" />

可以看到：

-   最上方和最下方有两块cookie，被称为「上cookie」和「下cookie」。负责记录整块的大小。上下cookie是一样的。
-   在Debug模式下会有一个「Debugger Header」
-   同时整块的大小必须是16的倍数

在`delete`的时候，加或者不加`[]`对`int`类型没有影响。



**对于复杂一些的类型**

`Demo`类型有三个int。`61h`是一个十六进制数，记录这一个块的大小。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230413104425735.png" alt="image-20230413104425735" style="zoom:50%;" />

### 1.6 placement new

但是定位new需要分配好的空间。

```cpp
char *buf = new char[sizeof(Complex) * 3];
Complex* pc = new(buf)Complex(1,2);

//...
delete[] pc;
```

定位new 也分为三步：

```cpp
void* mem = operator new(sizeof(Complex), buf);
pc = static_cast<Complex*>mem;
pc->Complex::Complex(1,2);
```

`buf`需要的是「已经分配好的内存」。所以`operator new()`什么都没干，直接返回`buf`。

>    其实placement new等价于直接调用构造函数。



-   没有所谓的`placement delete`，因为`placement new`没有分配内存。
-   也可以把`placement new`对应的`operator delete`称为`placement delete`



### 1.7 重载 operator new和operator delete

#### C++应用程序分配内存的途径

内存管理的很多概念都是很细微的。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230413114937580.png" alt="image-20230413114937580" style="zoom:40%;" />

-   从上图可以发现，每个类可以定义自己的`operator new()`和`operator delete()`。这样就可以在`operator new`中使用内存池了。**但是最终都是调用`malloc`和`free`**。
-   全局的`operator new`也可以重载，但是很少见，修改这一块会影响非常多的层面。
-   左下角的代码是从技术角度上模拟`new`和`delete`。





#### C++容器分配内存的途径

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230413115615099.png" alt="image-20230413115615099" style="zoom:50%;" />

-   容器没有使用默认的new和delete，而是使用了`construct()`来构造，`destroy()`来析构，内存分配的动作被放到了分配器中来。



#### 重载全局`::operator new`和`::operator delete`

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230413140520369.png" alt="image-20230413140520369" style="zoom:50%;" />

-   重载全局的函数不能放到任何一个`namespace`中。
-   除了重载普通版本之外，同时还可以重载array版本的`operator new()`和`operator delete()`。
-   **需要注意，重载全局版本的`operator new`和`operator delete`影响很大**



#### 重载类中的`operator new`和`operator delete`

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230413140947986.png" alt="image-20230413140947986" style="zoom:50%;" />

-   我们写好类中的`operator new()`和`operator delete()`，但是实际上是编译器来调用。如上图所示。
-   `operator delete()`有两个参数，第二个参数是可选的。
-   这两个函数还需要加上`static`关键字（上图没有加上），因为调用这两个函数是正在「创建对象的过程中」，所以没有this指针，或者说this指针没初始化。



**array new和array delete同理**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230413141416617.png" alt="image-20230413141416617" style="zoom:50%;" />

#### 举例



如果调用者在`new`和`delete`前面加上`::`，那么就会绕开自己重载的函数，调用全局版本的函数。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230413142144253.png" alt="image-20230413142144253" style="zoom: 67%;" />

>   -   全局的`operator new`
>   -   局部的`operator new`
>   -   定位`new`
>   -   array new
>
>   上述四种new都可以重载。



#### 重载`new()`

`new`后面加一个`()`就变成了定位`new`，需要说明的是，这个`()`里面不一定只能放一个指针，可以放任意的东西。（重载）。一个指针的版本是标准库是先写好的。

我们认为所有的带有`()`的`new`都是placement new。所以里面的参数都是各种各样的，但是参数需要不同，**其中第一个参数必须是`size_t`**，如果第一个参数写错，编译器会报错。

同时也可以重载「类的成员`operator delete()`」，写出多个版本，但是它们绝对不会被`delete`调用。<u>只有当`new`所调用的ctor抛出异常，才会调用这写重载版本的`operator delete()`。</u> 它只可能这样被调用，主要用来**归还未能完全创建成功的对象所占用的内存**。

被重载调用的`operator new`，如果抛出异常（在构造函数中），会调用对应版本的`operator delete()`。同时有的编译器还会提醒`operator new()`和`operator delete()`需要一一对应。



string就重载了`operator new`，可以额外分配一段内存。



>   在写new关键字的时候，不许填入`operator new`的第一个参数`size_t`，在`new()`填入的是`operator new()`从第二个参数开始的其他参数。



### 1.8 针对某个class的内存管理

`malloc()`并不慢，但是减少`malloc()`的调用次数总是好的。

我们可以在类中重载`operator new()`和`operator delete()`函数（运算符）。

**内存管理的目标：**

-   降低空间浪费
-   加快分配速度

>   思考：cookie在什么时候创建？
>
>   



**在《C++ Primer》中，有一个例子，**类中有`static`指针，指向一个单链表，这个链表维护一块内存。

`operator new()`的操作：

1.   如果没有空闲内存，则分配一大块内存，加入链表中
2.   返回链表第一个元素，链表++



`operator delete()`操作：

1.   把指针回收到单向链表中



上述例子就是一个小型的内存池，这个内存池只针对这个class使用。

这样，使用new分配内存，就不会带着cookie，而如果使用全局new，会带着cookie，但是这样有指针的开销。



**《Effective C++》中介绍了另外一个技巧：**

>   operator new的size_t参数是编译器计算类的大小并传入的。

使用嵌入式指针（embedding point）技巧，来减少空间的浪费。



由于`operator delete()`操作没有`free()`，只是把内存回收到链表中，那么如果要归还内存，该怎么做？

答案是没办法归还。虽然没有归还，但是这样不能叫「内存泄漏」，因为指针都还在操作者手上。



**所以有了第三个版本的分配器**：

从软件工程的角度来看并不合适。所以这个版本把分配和回收内存的动作抽取出来，放到一个class中。

这个类被称为`allocator`，这个类不再重载函数，而是设计两个函数`allocate()`和`deallocate()`。

而在自己设计的类中，有一个静态的`allocator`的成员，这样所有的工作就交给`allocator`去做。



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230413153310540.png" alt="image-20230413153310540" style="zoom:50%;" />

这样的写法就干净多了，在自己写的类中，我们再也不与内存分配细节纠缠不清。所有的分配和回收都交给`allocator`去完成。



所谓的`allocator`，就是有一个指针，专门用来指向内存池中空闲空间的链表。

-   `allocate()`每次分配多块内存，标准库中这个值（块数）是20
-   `deallocate()`

>   标准库的allocator就是采用这中版本，只不过标准库其中一个的allocator有16个链表，而非1个，也就是说标准库可以16中不同大小的分配。
>
>   标准库的allocator给所有的容器使用。

**版本四的适配器：**

对于上图的部分，可以写一个`#define`，之后的任何一个class，都可以加上这两个macro（里面一个，外面一个）。

MFC里面用的就是宏。



### 1.9 new handler

当`operator new()`没能分配出用户所申请的memory，会抛出一个`std::bad_alloc`异常，某些老编译器可能返回0。

使用`new(nothrow) Foo`可以使得「分配失败强制返回0」。 

C++会在抛出异常之前，会（不止一次）调用一个自己指定的函数：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230413233545441.png" alt="image-20230413233545441" style="zoom:50%;" />

new_handler是一个返回void同时没有参数的函数，我们可以使用`set_new_handler()`函数来设置使用`new_handler`，然后operator new抛出异常之前，都会调用`new_handler()`函数。`set_new_handler()`函数的返回值是「先前的`new_handler()`」。

并且调用`new_handler`是在循环中调用的：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230413233725248.png" alt="image-20230413233725248" style="zoom:50%;" />

>   调用`new_handler`的意思是，编译器看你有没有什么分配失败的补救措施，所以`new_handler()`函数一般有两个选择：
>
>   1.   让更多的内存可用
>   2.   调用`abort()`或者`exit()`

```cpp
#include <iostream>
using namespace std;

void noMoreMemory()
{
    cerr << "out of memory";
    abort();
}
int main()
{
    set_new_handler(noMoreMemory);
    int*p = new int[100000000000000];
    assert(p);
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
```

输出`out of memory`。

上述例子中的`new_handler()`如果没有调用`abort()`，则不会离开程序，一直`cerr()`。

在C++中，只有下面函数有默认版本：

-   默认构造函数
-   拷贝构造函数
-   拷贝复制函数
-   析构函数

`=default`和`=delete`函数还可以用在`operator new/new[]`和`operator delete/delete[]`。

也就是说`operator new`也有默认版本吗？

实验发现，对于上面四个operator，可以加`=delete`关键字，但是不能添加`=default`关键字，某个类加了`=delete`关键字之后，就不能`new`一个该类型的对象了。



## 第二讲 std::allocator（标准库中的分配器）



>   西北有高楼 上与浮云齐

要学习的标准库的分配器相当于一座高楼。

`malloc`得到的区块，还带着一块`cookie`，同时据说`malloc`很慢，但实际上不慢。

如果区块比较小，那么浪费率就高。

**如何去除cookie？**



### 2.1 VC6下的标准分配器

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230414000447408.png" alt="image-20230414000447408" style="zoom:50%;" />

VC6中的`allocate()`和`deallocate()`没有特殊设计，只是调用`::operator new()`和`operator delete()`。

VC6下所有容器的第二个模版参数都默认是`allocator`。



### 2.2 BC5下的标准分配器

和VC6下完全一致。



### 2.3 G2.9下的标准分配器

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230414002954346.png" alt="image-20230414002954346" style="zoom:50%;" />

G2.9下的`allocator()`也类似，没有特殊设计，但是头文件的注释中说：不要使用这个`allocator()`。



**G2.9容器使用的分配器，是`std::alloc`**

`alloc`是一个类型，调用如下：

```cpp
void *p = alloc::allocate(512);
```

512代表512个字节。



但是G4.9版本默认使用的是，G4.9还有很多扩充的allocator。



### 2.4 G4.9下的标准分配器

同样没有特殊设计。

为什么不使用`__gun_cxx::__pool_alloc`呢，也就是G2.9的所谓`alloc`。

使用G2.9版本的分配器可以节省cookie的空间。

```cpp

//用来测试标准分配器是否有cookie
template<typename Alloc>
void cookie_test(Alloc alloc, size_t n)
{
    typename Alloc::value_type *p1, *p2, *p3;
    p1 = alloc.allocate(n);
    p2 = alloc.allocate(n);
    p3 = alloc.allocate(n);
    cout << "p1 = " << p1 << endl << "p2 = " << p2 << endl << "p3 = " << p3 << endl;
}

void test01()
{
    cookie_test(std::allocator<double>(), 1);
}
```

理论上来说，一个double8个字节，每个指针的距离应该是8个字节。

输出：

```txt
p1 = 0x600000dd0040
p2 = 0x600000dd0050
p3 = 0x600000dd0060
```

可以看出Clang14.0版本的每次`allocate()`都会带cookie，也就是可能直接调用了`malloc()`函数。



### 2.5 G2.9 std::alloc运行模式

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230414010139877.png" alt="image-20230414010139877" style="zoom:50%;" />

-   这可能是比较好的分配器版本，可以视为一个内存池。**图上每一小块的内存都是没有cookie的，只是每一大块还是带了cookie。**
-   上图右边是容器，左边是分配器的行为，分配器提供了两个函数`allocate()`和`deallocate()`。
-   一个分配器维护16条链表，每个链表对应一个大小的区域（8的倍数），超过最大的大小，`allocator`就调用`malloc()`来服务。如果容器要的内存不是8的倍数，会被调整到8，这个设计在所有的分配器都是一样的。
-   如果需要分配32字节的内存，那么第三个位置就会分配「20个32字节的区域，和一个大小相同的区域（32*20），但是不切割」。至于为什么是20，没有明确的文档说明。当容器继续需要内存，只需要移动第三个位置的指针即刻，如果没有内存了，分配器再向malloc要20个。
-   如果容器向分配器要64字节的内存，那么需要第7个位置，此时会用到之前分配的「没有用到的内存」，并分割成64字节一块，传回给容器使用（所有的都回去）。
-   如果又有新的容器需要96字节的内存，那么分配器就找到第11个位置，同时发现没有「战备池」，所以就分配两块内存：「96*20」和「一块大小相同但是没有分割的内存」。
-   当容器要归还内存的时候，就会调用`deallocate()`，内存就会被归还到 「对应的单链表上」
-   如果某个容器每次需要256个字节，那么这种情况就会归`malloc()`管，每一块内存都带了cookie。



>   同时链表中的指针，都是嵌入式指针（embedded pointers），只有它是链表中的元素时，指针才是指向下一块空闲内存的；当它被分配给容器使用时，指针的区域也会被容器占用。归还的时候指针又指向下一块空闲内存。
>
>   所有的商业级别的内存管理都是用嵌入式指针来做，这样可以节省一个指针的内存。
>
>   也有一个缺点就是：当需要的字节数小于一个指针的大小，那么就只能浪费剩下的内存了：「指针大小 - 需要的字节数」被浪费。



#### 2.5.1 std::alloc运行一瞥 01

**初始的情况：**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230414093930173.png" alt="image-20230414093930173" style="zoom:50%;" />

几个细节：

-   里面有一个`free_list`，这是一个「链表数组」，对应16个不同的区域
-   所谓`alloc`，其实是一个typedef，它的真实类是`__default_alloc_template<>`

#### 2.5.2 std::alloc运行一瞥 02

**客户（容器）申请32个字节：**注意分配器的客户是容器，如果代码中直接使用分配器的话，需要指定分配的内存的大小，归还的时候要指定大小。但是容器可以很方便做到这一点，因为容器的第一个模版参数是「数据的类型」。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230414094126504.png" alt="image-20230414094126504" style="zoom:50%;" />

几个细节：

-   在实现的时候，总是把分配的内存放到「战备池」（pool）中，然后再从pool中挖出适当的空间到链表来。哪怕第一次分配也是这样。所谓pool的空间，就是`start_free`和`end_free`指针中间的区域。
-   这一整块是用`malloc()`拿的，所以带了cookie
-   总共申请了1280个字节，pool中剩余640字节。



#### 2.5.3 std::alloc运行一瞥03

**如果容器申请64个字节：**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230414095640767.png" alt="image-20230414095640767" style="zoom:50%;" />

-   由于pool中有余量，所以取pool中的内存切割，共切割「10 * 64」个字节。从pool中切割出来区块，如果大于20，也只能切割出20，数量在1到20之间。
-   如果pool中切割不出来一个完整的区域，那么就发生了「碎片」。



#### 2.5.4 std::alloc运行一瞥04

**如果容器申请96字节：**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230414100113900.png" alt="image-20230414100113900" style="zoom:50%;" />

-   先看11对应的指针，为空；再看pool，pool为空，所以向`malloc()`申请空间：「20 * 96 * 2」加上一个「追加量RoundUp」。追加量就是把「目前的申请总量 除以 16（右移4）」。但是切割还是最多切割20个。
-   这个RoundUp，可能是为了处理用户对于内存「越要越大，越要越快」的需求。所以分配器申请的空间的对应的扩大。
-   所以pool中还剩下2000字节。
-   可以看到3和7区域有一根线，这不是指针，这表示它们是连在一起的。



>   一个问题始终在我头上盘旋：如何归还空间？



#### 2.5.5 std::alloc运行一瞥05

**如果客户需要88个字节：**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230414100834051.png" alt="image-20230414100834051" style="zoom:50%;" />

-   先看11对应的指针，为空，再看pool，大小为2000。所以划分，最多划分20个，所以划分了20个，使用一个，还剩下19个。pool中剩下「2000 - 88 * 20 = 240」字节的内存。
-   上图的画面代表我们在代码中创建了四个容器，每个容器的大小各不相同。这些动作总共用了两次malloc，有两个cookie。



#### 2.5.6 std::alloc运行一瞥06

**客户连续申请三次88:**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230414101225848.png" alt="image-20230414101225848" style="zoom:50%;" />

-   88是10号链表负责，10号链表发现自己还有19个空余区块，则直接从10号链表取出三个空间返回。一次返回一块，总共三次。
-   此时pool仍然是240



#### 2.5.7 std::alloc运行一瞥07

**这一次客户申请8:**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230414101405484.png" alt="image-20230414101405484" style="zoom:50%;" />

-   8由0号链表负责，0号链表为空，所以再看pool，pool中有240个字节（可以划分20个8有余），所以划分20个区块「20 * 8」给0号链表，第一个给客户使用，0号链表还有19个块剩余。
-   pool此时还剩下80。pool的实现是两根指针之间的区域。



#### 2.5.8 std::alloc运行一瞥08

**客户申请104：**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230414102814500.png" alt="image-20230414102814500" style="zoom:50%;" />

-   此时程序中有了<u>7种大小不同的容器</u>，所以104应该对应12号链表，指针为空，此时

