# C++标准库 ----体系结构与内核分析



-   C++标准库不是一个一个单一的函数，C++标准库主要分为6个部件，它们的联系非常紧密

## 第一讲

所谓Generic Programming（GP，泛型编程）就是使用template（模版）为主要工具来编写程序。

>   GP和OOP有着根本差异。

STL是GP最成功的作品，早期STL没有太多继承等OOP。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221210203758426.png" alt="image-20221210203758426" style="zoom:40%;" />



### 1.1 C++ Standard Library 与 Standard Template Library

-   C++ Standard Library： C++标准库
-   Standard Template Library： STL，标准模版库

C++标准库中可能有80%的内容是STL，还有一些零碎的小东西与STL共同组成C++标准库。



**标准库以header files形式呈现：**

-   C++标准库的头文件不带文件名`.h`
-   新式C头文件也不带`.h`，例如`#include<cstdio>`
-   旧式C头文件（带`.h`）仍然可用，例如`#include<stdio.h>`



**关于namespace：**

-   新式headers内组建封装于`namespace std`
    -   例如`vector`的全名为`std::vector`
-   旧式headers内组建不封装于`namespace s

  

### 1.2 重要网站

-   [cplusplus.com](cplusplus.com)
-   [cppreference.com](cppreference.com)
-   [gcc.gnu.org](gcc.gnu.org)



### 1.3 STL六大部件

-   容器(Containers)
-   分配器(Allocators)：帮助容器分配内存
-   算法(Algorithms)
-   迭代器(Iterators)：泛化的指针
-   适配器(Adapters)：
-   仿函数(Functors)

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221210210848251.png" alt="image-20221210210848251" style="zoom:40%;" />





>   可以看到，STL的基础理念和OO就不同，STL的数据和操作是分离的，数据在容器里，操作在算法里。

**代码：**

一个包含了六大部件的代码

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221210212620757.png" alt="image-20221210212620757" style="zoom:40%;" />

```cpp
/*  
 *  Description : STL六大部件
 *  Created by 旋风冲锋龙卷风 on 2022/12/10 21:20
 *  个人博客 : http://letsgofun.cn/
 */
//

#include <iostream>
#include <algorithm>
#include <functional>
#include <vector>
using namespace std;

int main()
{
    int ia[6] = {4, 3, 2, 1, 6, 5};
    vector<int, allocator<int>> vi(ia, ia + 6);
    //输出大于等于4的个数
    cout << count_if(vi.begin(), vi.end(), not1(bind2nd(less<int>(), 4)));
    return EXIT_SUCCESS;
}
```

-   早期版本有80余个算法，现在更多
-   “宾语” == “谓词”



**复杂度， Complexity， Big-oh**

时间复杂度的n必须非常大。



**几个小知识：**

-   前闭后开区间，begin和end的容器不一定是连续空间
-   C++11新标准的范围for循环
-   `auto`关键字：不要随便用，只是为了方便，可以适度使用

### 1.5 容器的分类和测试

大致上分为两类：

-   序列式容器(sequence containers)
-   关联式容器(Associative containers)
-   C++11新增了 unordered_containers，其实应该属于关联式容器，是哈希表

C++的哈希表都是用拉链法处理冲突，也是目前最好的做法，但是冲突不能太多。

>   把测试代码放在一个`namespace`里。
>
>   在用到变量的时候再去定义。



#### 1.5.1 `array`测试

有一个`array`的模版类，需要`array`头文件。

#### 1.5.2 `vector`测试

-   `vector`是两倍增长
-   `size()`是真实个数，`capacity()`是空间大小。
-   `abort()`退出

在侯捷的例子中，在50万个元素中查找，分别使用`find`和`sort`+`bsearch`，结果`find`的速度远超后者（因为`sort`太耗时）。



#### 1.5.3 `list`测试

标准库有一个全局`sort`，某些容器自己也提供了`sort`，当容器自己提供了`sort`用自己提供的更合适。



#### 1.5.4 `forward_list`测试

-   它只有`push_front`，只能使用头插法



#### 1.5.5 `slist`测试

`slist`是gnu的g++扩充的一个容器。



#### 1.5.6 `deque`测试

`deque`其实不是连续的，是不同的`buffer`连接起来的，这些buffer内部是连续的，但是不同的buffer是不连续的。

-   `deque`没有自己的`sort`





#### 1.5.6 `stack`和`queue`测试

-   `stack`和`queue`内部就是使用了`deque`
-   从技术上来讲，`stack`和`queue`可以被称为「容器的适配器」(container adapters)
-   叫做容器也可以
-   也没有`find`

#### 1.5.6 `multiset`测试

-   底层是红黑树
-   容器自己的`find`速度快于全局`::find`
-   插入的时间可能会慢一些，但是查找非常快
-   元素能重复

#### 1.5.7 `multimap`测试

-   key能重复
-   `multimap`不能用`[]`下标操作（因为key可以重复）
-   插入用`pair`



#### 1.5.8 `unordered_multiset`测试

-   底层是哈希表（拉链法解决冲突）
-   在gnu之前叫`hash_multiset`，和现在的没什么区别
-   可以用`bucket_count`查看有多少个`bucket`，也就是哈希表的长度，bucket比元素要多
-   可以用`bucket_size(i)`查看第`i`个bucket有多少个元素



#### 1.5.9 `unorder_multimap`测试

-   与`unorder_multiset`类似，但是key是哈希运算的对象



#### 1.5.10 `set`和`map`测试

-   不允许重复
-   元素是按顺序存储的（map是key）
-   `map`和`unordered_map`允许使用`[]`下标操作，下标是key，值是value



### 1.6 分配器测试

-   使用容器都有一个分配器的参数，这个参数都有默认值
-   有很多分配器
-   但是手动使用分配器在使用的时候需要指定分配和删除的大小，例如`delete`不需要指定指针的大小

```cpp
void test01()
{
    allocator<int> alloc1;
    //分配
    auto p = alloc1.allocate(1);
    //删除
    alloc1.deallocate(p, 1);
}
```





## 第二讲

很喜欢侯捷的一句话：

「源码之前，了无秘密」。

>   第二讲主要讲了分配器和各种容器的探索。

**基础：**

-   C++基本语法
-   模版基础
-   数据结构和算法概念

### 2.1 标准库的版本

有很多不同的版本，例如我本地使用的clang.14.0.0在`/Library/Developer/CommandLineTools/usr/include/c++/v1/`下，和远程服务器使用的gcc4.8.5则在include目录c++下，具体在`.../include/c++/bits`下，有很多stl开头的文件。



### 2.2 OOP 与 GP



**OOP：**

OOP试图将数据和方法关联在一起。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221211165109474.png" alt="image-20221211165109474" style="zoom:40%;" />

**GP：**

GP确实试图将data和method分开：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221211165206151.png" alt="image-20221211165206151" style="zoom:40%;" />

采用Generic Programming，写容器和算法的团队可以闭门造车，其间用iterator沟通即可。

算法使用迭代器确定操作范围，并用迭代器使用容器中的元素。

`list`不能使用`::sort()`全局排序，因为它不是随机访问的。

所有的算法，其中最终**涉及元素本身**的操作，无非就是**比较大小**。



### 2.3 操作符重载和模版

STL大量使用操作符重载和模版。

模版约定俗成用`T`大写T：`template<typename T>`或`template<class T>`，这两个是完全相同的，模版有三大类：

-   写在类前，类称之为「类模版」或「模版类」。在使用的时候必须用`<>`明确告诉编译器T的具体类型，类模版的时候没有「实参推导」。
-   写在函数前，称之为「函数模版」。在使用时编译器会使用「实参推导」，也会调用对应的操作符重载。
-   还有「成员模版」(Member Templates)

>   核心思想是设计的时候不写死，用一个符号代替。

专门有书写C++的模版。



### 2.4 Specialization，特化

在泛化之外特化的版本，**例如：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221228221617377.png" alt="image-20221228221617377" style="zoom:40%;" />

在语法上：特化的语法先抽出`template`中的内容，再绑定特化的类，那么当使用`__type_traits<int>`时，会进入第二个类。

**再来看例子：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221214204914260.png" alt="image-20221214204914260" style="zoom:40%;" />

`__STL_TEMPLATE_NULL`是一个`typedef`，会被转换为`template<>`，这也是特化的标志，当`hash`接受特化的版本时，有独特的设计。

**第三个例子：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221214205234019.png" style="zoom:40%;" />

`allocator`对接收`void`有独特的设计。



**Partial Specialization, 偏特化：**



对应的还有「全特化」(full specialization)。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221214205537856.png" alt="image-20221214205537856" style="zoom:40%;" />

有两个模版参数，偏特化可以只绑定其中一个。上述代码对`bool`作为参数有特殊设计，有某些好处，例如更精简的空间。

上述只是偏特化的一种称为「个数的偏特化」，还有另一种「个数的编特化」：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221214205851260.png" alt="image-20221214205851260" style="zoom:40%;" />

上述代码中，偏特化可以指定接受「指针」（指针的指向无所谓），或者「指针常量」，有独特的设计。

### 2.5 分配器allocators

>   上述的所有，都是前置知识。从这里开始才真正进入STL的世界。
>
>   一上来就是可能别的课程不会提的分配器，👍。分配器是一个幕后英雄的角色，哪怕学会了也不会去重写分配器，但是它十分重要，关系到容器的速度和空间的运用。

#### 2.5.1 `operator new()`和`malloc()`

>   有一个观念，所有的分配动作，最终都会到CRL(C Runtime Library)这个层次下的`malloc()`，不同的操作系统，有不同的API。

在所有的C++平台`new()`都会调用`malloc()`，`malloc()`分配的内存如下图：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221214211820361.png" alt="image-20221214211820361" style="zoom:40%;" />

用户所要求的空间是浅蓝色的部分，但是`malloc()`会分配更多的内存打包好分配，会比要求的空间多了不少东西，附加的部分是固定的，要求的内存越大，附加部分的比例越小。



#### 2.5.2 VC6 STL 对`allocator`的使用

注意，`allocator`在这个语境下是一个类，不同版本的STL可能对其的运用有不同，下图是VC6 STL对`allocator`的使用：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221214212418917.png" alt="image-20221214212418917" style="zoom:40%;" />

VC6 中的`allocator`只是用`new`和`delete`完成`allocate()`和`deallocate()`，没有任何特殊设计。元素越小代表额外开销越大，例如在`vector`中放100万个`int`，可能额外的内存比存放元素本身的空间还要多。这太可怕了！但是VC6的真实情况就是这样。

**分配512ints：**

```cpp
int *p = allocator<int>().allocator(512, (int*)0);
allocator<int>.deallocate(p, 512);
```

不鼓励直接使用分配器。**因为有一个致命伤：归还的时候要写还多少空间！**但是容器去使用就没有这种困扰。



#### 2.5.3 BC5对`allocator`的使用

下图是BC5 STL对`allocator`的使用：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221215202801200.png" style="zoom:40%;" />

所有的容器第二个参数默认都是`allocator`，再来看看 `allocator`类： <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221215202658817.png" alt="image-20221215202658817" style="zoom:40%;" />

看起来和VC 差不多，写法略有区别，作用也一样。那么放小元素的额外开销问题也没有解决。BC5有一个小小的优化：

-   `allocate`函数的第二个参数有一个默认值0。

#### 2.5.4 G2.9对`allocator`的使用

所谓「G2.9」就是GNU C2.9，也就是GCC2.9，也是《STL源码剖析》这本书介绍的版本，`allocator`的实现如下：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221215203614409.png" alt="image-20221215203614409" style="zoom:40%;" />

也就是说VC、BC、GC对`allocator`的定义都一样，对于小元素的额外开销都很大，这也是侯捷老师反复强调的问题，因为现实使用的时候小元素的使用更多。但是GNU C的头文件有一个说明：不要使用这个文件，GNU C的STL是SGI这个公司发展的，SGI STL使用的是另一个`allocator`，这个头文件没有被`include`到任何文件中去（也就是没有在任何容器中使用）。

事实上，上述的分配器都很烂（侯捷原话如此），GC有一个独特设计的分配器：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221228221758912.png" alt="image-20221228221758912" style="zoom:40%;" />

它的主要诉求是减少`malloc()`的次数，减少额外开销，也就是分配的cookie部分（用来记录大小）。但是，容器的元素大小是固定的，所以没必要把每个数据的大小都要记录，也就是说在容器这个场景下没必要使用cookie，尽量减少`malloc()`的次数。



分配器设计了16条链表，第16条链表每个区块负责 16×8个字节（byte），所有的容器的元素大小都会被调整为8的倍数，例如50会调整为56，如果没有挂内存块，才`malloc`，每次拿还是会带一个cookie。malloc分配一个单向链表，这个链表中的元素没有cookie。

>大多数的C++都会在首位加上cookie，大概是8个字节大小。

GC2.9也会有一些缺陷。



#### 2.5.5 GC4.9对`allocator`的使用

这一版本的`allocator`却抛弃了GC2.9的做法，又回到了VC、BC的情况（居然侯捷也不知道为什么会这样）。但是GC2.9版本的`alloc`（在GC4.9称为`__pool_alloc`）保留在ext下，同时它也不在std命名空间下，而是在另一个命名空间下。



下图是clang14.0.0 STL对`allocator`的使用，定义在`alloctor.h`中

![image-20221214212309330](https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221214212309330.png)

 



### 2.6 容器-结构性分析

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221215211304786.png" alt="image-20221215211304786" style="zoom:40%;" />



例如，`set`或`map`里有一个`rb_tree`。蓝色部分是每个对应类对象的大小，这个大小与容器中的元素个数无关，只与容器本身有关。

>   如果A类想用B类的功能，可以继承，也可以拥有。标准库尽量不用继承。



### 2.7 深度探索`list`

>   有很多容器，`list`不是最简单的，但是是最具有代表性的。



<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221215234851471.png" alt="image-20221215234851471" style="zoom:40%;" />

`list`中的数据只有一个`node`，32位电脑一个指针4个字节。`list`本身是个指针，指向一个节点。`list`是一个环状双向链表，当然有头节点。`begin()`指向第0个元素，`end()`指向这个空的头节点。

在2.9版本中，这个节点很奇怪，指向前后两个节点的指针都是`void *`类型。用的是`alloc`分配器。



**`iterator`：**

链表是一个非连续空间，所以这个`iterator`不能是一个指针，因为`iterator`都能++操作，但是指向链表的指针不能++。所以这个`iterator`需要足够“聪明”，当用户对`iterator`++的时候，会自动走向下一个节点。`iterator`是一个「smart pointer」，除了`vector`，所有的`iterator`都是这样的智能指针，同时也是一个类。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221216140806773.png" alt="image-20221216140806773" style="zoom:40%;" />

`iterator`会重载大量操作符，同时传入三个模版参数，几乎所有容器的迭代器都有5个`typedef`，迭代器里有一个成员变量`node`。

**下图是两个++的重载：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221216141216831.png" alt="image-20221216141216831" style="zoom:40%;" />

有参数的++是后置++（这个参数没有意义），没有参数的是前置++。

-   后置++的重载操作就是把node的next赋值给node。
-   前置++的重载操作中使用了其他的操作符重载，但是`*this`没有使用`*`重载，而是使用拷贝构造函数，`*this`被解释为拷贝构造的参数。

C++不允许后++两次，因为第二次++是把临时变量++，与我们的意图不符合；而前置++返回对象的引用，可以连续运算。



**`*`和`->`的重载：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221216144753943.png" alt="image-20221216144753943" style="zoom:40%;" />

-   `*`就是获得`node`中的数据
-   `->`类似



**两个小问题：**

1.   `node`的指针是`void*`类型
2.   `iterator`传入三个模版参数

这两个问题在G4.9中得到解决：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221216145359348.png" alt="image-20221216145359348" style="zoom:40%;" />

在G4.9中，节点的组成分成了两块，一个base，一个子类，指针指向了自己的类型。

但是G4.9 中，继承复杂了很多：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221216145936454.png" alt="image-20221216145936454" style="zoom:40%;" />

看G4.9版本的STL源码挺复杂的，有很多继承和包含。

4.9版本中，`sizeof(list)`是8，而2.9是4。C++中sizeof的大小是该类父类的大小，最后就是`_List_node_base`中两个指针的大小，32位机器是8。

### 2.8 `iterator`设计的原则

「traits」是人为设计的特点。

针对`iterator`有`iterator_traits`（侯捷称之为“萃取机”）。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221217151106071.png" alt="image-20221217151106071" style="zoom:40%;" />

**`iterator`是容器和算法之间的桥梁。**

**`rotate`算法：**

算法提出问题，需要迭代器来回答，这样的提问在C++标准库设计里总共有5种：

-   `iterator_catagory`：迭代器分类
-   `difference_type`：距离的类型
-   `value_type`：值的类型
-   `reference`
-   `pointer`
-   后两种暂未使用

这五种称为迭代器的「相关类型」（associated types），迭代器本身必须定义出来，以便回答算法提问。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221228222103894.png" alt="image-20221228222103894" style="zoom:40%;" />

在算法中直接使用`I::XXX`可以得到结果。`value_type`就是T，`iterator_category`是`bidirectional_iterator_tag`，这是一个独特的表示法，代表一个双向链表。



**Traits 特征，特质：**

理论上来说不需要Traits。但是iterator如果不是class呢？例如native pointer（C++的指针）也是一种iterator，它就无法定义这五个「相关类型」。这时就需要traits：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221216153447370.png" alt="image-20221216153447370" style="zoom:40%;" />

它可以接受class和指针两种形式的迭代器。

>   解决计算机问题：加一个中间层（银色子弹，万能方法）。



实际做法：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221228222130201.png" alt="image-20221228222130201" style="zoom:40%;" />

算法问`iterator_traits`，traits转问I（模版类），利用了「偏特化」来区分指针和类这两种不同的迭代器，**同时会忽略底层const。**

>   为什么呢忽略底层const？
>
>   `value_type`的主要作用是声明变量，但是声明一个无法被赋值的变量没用什么用，所以忽略了底层`const`。



**完整的traits：**

![image-20221216154649614](https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221216154649614.png)

指针使用`random_access_iterator_tag`，有随机访问的特性，其余的都是固定的。



**有很多Traits：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221216154913776.png" alt="image-20221216154913776" style="zoom:40%;" />



### 2.9 深度探索`vector`

`vector`是动态增长的数组。

所有的内存都不能原地扩充：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221216155413327.png" alt="image-20221216155413327" style="zoom:40%;" />

-   所有的版本都是两倍成长。
-   用三个指针控制整个容器，所以vector对象的大小是12（32位机下三个指针的大小，64位机器下是24）。

**`vector`的增长**

以`push_back()`为例：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221216160427376.png" alt="image-20221216160427376" style="zoom:40%;" />

由于`insert_aux()`不止被`push_back()`调用，所以它还是会和`push_back()`一样检查一次。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221216160732370.png" alt="image-20221216160732370" style="zoom:40%;" />

对0特殊处理一下。同时还要将后面的元素的copy过来，因为`insert(p, x)`也会调用这个函数，所以要把后面的元素也复制过来。

元素的拷贝会引发拷贝构造。



**`vector`的迭代器**

很显然`vector`的迭代器是连续的，那么就可以使用指针来代替迭代器。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221216162302286.png" alt="image-20221216162302286" style="zoom:40%;" />

使用Traits就可以得到5个associated type的值。



但是在G4.9 中，又有不同，`vector`有很多继承，很杂乱。

>   public继承是一种「is a」的关系。

 

### 2.10 深度探索`array`和`forward_list`

`array`在C中本来就是存在的，就是所谓数组，但是在STL中还是将其封装起来为一个新的类`array`，使其拥有迭代器，这样算法就可以对数组进行操作了，如果不这么包装，那么数组也就无非享受算法、仿函数等。

下图是C++1.0和C++2.0之间的一个`array`的TR1版本。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221228222224206.png" alt="image-20221228222224206" style="zoom:40%;" />

-   `array`必须指定大小，因为它不能扩充。
-   如果给定0，那么会扩充为1
-   `begin()`返回第0个元素位置，`end()`返回最后一个元素后一个位置
-   它的迭代器是一个指针，不用设计一个类



>   还是一如既往的拷打G4.9版本



`forward_list`和双向链表差不多。



### 2.11 深度探索`deque`

`deque`是一个比较复杂但又很有趣的容器，它并不出现在古典数据结构中。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221221215528950.png" alt="image-20221221215528950" style="zoom:40%;" />

如上图：

-   `deque`是由一段一段的`buffer`缓冲区组成的，在源代码中也称为`node`节点。它对外是不分段的，map是`deque`的控制中心。
-   `deque`的迭代器是一个类，有四个元素`cur` , `first`,  `last`,  `node`分别指向buffer中元素的位置、buffer的边界和在map的位置。
-   `deque`每次++或--都需要判断是否走到了该buffer的边界
-   `start`和`finish`是两个成员变量，也就是`begin()`和`end()`的返回值



<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221228222159481.png" alt="image-20221228222159481" style="zoom:40%;" />

-   `map`两倍成长，`map`是`T**`类型，也就是指向指针的指针。
-   一个迭代器由四个指针构成。一个`deque`由两个迭代器和一个指针和一个sizetype组成
-   模版的第三个参数就是`BufSiz`，就是指定buffer的大小，默认为0。有特殊的语句来处理这个0。

**`deque`的迭代器：**



<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221226144238257.png" style="zoom:40%;" />

-   它是随机访问的：`random_access_iterator_tag`。虽然它是分段的，但是它对外是连续的。



**`deque`的`insert()`函数**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221226144537141.png" alt="image-20221226144537141" style="zoom:40%;" />

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221226144850160.png" alt="image-20221226144850160" style="zoom:40%;" />



`deque`可以往两端扩展，所以，`insert_aux()`会判断距离头还是尾近，选择较短的一端来推动元素空出一个位置。



**迭代器是如何制造连续的假象？**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221226145133388.png" alt="image-20221226145133388" style="zoom:40%;" />

-   `size`的大小就是`finish - start`，迭代器对`-`号做了操作符重载

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221226205555314.png" alt="image-20221226205555314" style="zoom:40%;" />

-   取值`*`就是取`cur`中的元素
-   `-`运算符重载需要知道首尾之间的buffer数量，`node`就是控制中心中的某个元素。还需要加上最后一个buffer和第一个buffer的元素量。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221226210125719.png" alt="image-20221226210125719" style="zoom:40%;" />

-   `++`和`--`的重载：每次`++`都需要先判读是否到达了边界；如果到达了边界，则需要调用`set_node()`跳到下一个buffer，相应的`first`和`last`也要重新设置。`set_node()`其实就是设置`node`，这是一个`deque`迭代器的成员属性。
-   `--`如果跳到上一个缓冲区，则跳到前一个buffer的最末尾位置。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221228222016231.png" alt="image-20221228222016231" style="zoom:40%;" />

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221226230740206.png" alt="image-20221226230740206" style="zoom:40%;" />

-   如何使用`deque`连续移动多个位置：重载`+=`
-   需要在`+`/`-`之后检查是否跨越buffer的边界，考虑目标位置和当前位置不在同一个buffer内的情况。
-   `-=`可以用`+=`一个负数来表示
-   重载`[]`就是返回this+n位置的元素。



>   在G4.9版本的每个容器都是基本有4个class，同时G2.91允许指定buffer的大小，G4.9不能再指定了。总的来说，G4.9版本的`deque`使用更为简单了。
>
>   控制中心是一个`vector`，这里的`vector`有一个细节，那就是在扩充的时候是扩充到**中间**，这样左右两边都有空余。



### 2.12 深度探索`queue`和`stack`

首先关于`queue`和`stack`没什么多说的，一个先进先出，一个先进后出。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221226231928725.png" style="zoom:40%;" />

-   `queue`和`stack`里面封装了`deque`，同时封闭一些不用的功能。除此之外，`list`也可以作为`stack`和`queue`的底层结构，其实本质上只要提供`stack`和`queue`的接口就行。但是默认的`deque`性能更好。

-   `stack`和`queue`都不允许遍历，也不提供迭代器iterator。

-   `stack`可以选择`vector`作为底层结构，`queue`不可以用`vector`作为底层，但是编译器不会检查，只会在实际调用的时候报错

-   当然`stack`和`queue`都不能选择`set`或`map`作为底层结构，但是这样写，编译器是不会报错的。

    ```cpp
    //vector作为stack的底层
    stack<int, vector<int>> c;
    //vector作为queue的底层
    queue<int, vector<int>> q;
    stack<string, set<string>> s;
    ```

### 2.13 深度探索`rb_tree`

关联式容器可以视为一个小型的数据库，关联式容器的底层就是「红黑树」和「哈希表」。

Red-Black tree，也就是「红黑树」是一种平衡二叉搜索树中常被使用的一种，平衡二叉搜索树排列规则有利于搜索和插入。

红黑树提供“遍历”操作以及迭代器，按照`++ite`遍历，能得到排序状态(sorted)，遍历的顺序是「左根右」。

我们不应该使用红黑树的迭代器来改变元素值（因为元素有其排列规则）。编程层面并没有阻绝此事。如此设计是正确的，因为红黑树是set和map的底部支持，而map允许元素的data被改变，只有元素的key不能被改变。

红黑树提供两种insertion操作：`insert_unique()`和`insert_equal()`。前者表示key必须在tree中独一无二，否则插入失败；后者表示节点的key可以重复。



**红黑树的代码：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221227224111424.png" alt="image-20221227224111424" style="zoom:40%;" />

-   `rb_tree`需要五个模版参数：`Value`代表`key`和`data`之和，`KeyOfValue`就是如何取出`key`，`Compare`就是如何比较`key`，`Alloc`就是分配器。
-   `rb_tree`用三个变量记录整体：`node_count`代表红黑树的节点数量；`header`就是一个指针，指向红黑树的头节点；`key_compare`就是传入的函数（仿函数），代表key比较大小的准则。这三个数据的大小在G2.91是9，对齐为4的倍数12。对于任何编译器，大小为0的类创建出来的对象大小永远是1。
-   红黑树也有一个头节点

**如何使用`rb_tree`：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221227225928632.png" alt="image-20221227225928632" style="zoom:40%;" />

-   `identity`类就是传入什么，返回什么，这是GNUC独有的。
-   第四个参数，对于自定义的类，还需要重载`<`。
-   没必要直接使用红黑树

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221228222036244.png" alt="image-20221228222036244" style="zoom:40%;" />

-   在新版本中，分成了多个类
-   这样设计，体现了OO的原则，用一个指针，来表示具体的实现手法，分成了`handle`和`body`。
-   但是`_Rb_tree_impl`不应该public继承`allocator`。
-   新版本红黑树的大小为24  



### 2.14 深度探索`set`和`multiset`

`set`和`multiset`是以红黑树为底层结构，因此具有「元素自动排序」的特性。排序的依据就是key，而`set`和`multiset`的元素的value和key合一：value就是key。

`set`和`multiset`提供“遍历”操作以及`iterator`。按照++ite规则遍历，便能得到排序状态。

我们**无法**使用`set`/`multiset`的`iterator`改变元素值（因为key有严谨的排序规则）。`set`/`multiset`的`iterator`是其底部的RBtree的`const_iterator`，就是为了禁止用户对元素赋值，这里与红黑树略有区别。

`set`的key必须独一无二，所以其`insert()`调用的是rbtree的`insert_unique()`；`multiset`则调用`insert_equal()`。



**`set`的源码：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221227235136029.png" style="zoom:40%;" />

-   只需要三个模版参数
-   变量t就是一颗红黑树，set的所有操作都转向调用t的操作。从这一层面来看，`set`是一个container adapter。
-   `set`的迭代器是红黑树的`const_iterator`，这个迭代器不允许修改内容。



**VC6 `set`：**

VC6没有`identity()`，那么map和set如何使用红黑树？

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221228000119440.png" alt="image-20221228000119440" style="zoom:40%;" />

-   VC6写了一个inner class内部类，相当于G2.91的`identity()`
-   同时`map`自己提供的`find()`也比`::find()`快更多

### 2.15 深度探索`map`和`multimap`

-   `map`和`multimap`以红黑树为底层结构，排序的依据是key
-   按照++迭代器，可以得到排序状态
-   不能使用迭代器修改`map`和`multimap`的key，但是可以修改data。key的类型被设置为`const`，这样就能禁止赋值
-   `map`的key必须独一无二，用红黑树的`insert_unique()`插入；`multimap`的key可以重复，使用红黑树的`insert_equal()`插入



**`map`的源码：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221228190024687.png" alt="image-20221228190024687" style="zoom:40%;" />

-   `map`需要4个模版参数，通常只填前两个
-   变量t就是红黑树类型
-   `value_type`代表key+data，是`pair`类型，同时`map`会自动将key设置为`const`，不能被修改
-   `select1st<value_type>`代表取出第一个元素，也就是取出key
-   `map`的迭代器是红黑树的迭代器，同时没有`const`修饰，这里与`set`不能修改元素的原理不同。



**VC6的`map`:**

VC6没有`select1st()`,这是一个仿函数（也叫函数对象），传入`pair`，返回`pair`中的`first`，VC6自己写了一个。



**使用`multimap`：**

-   `multimap`不能使用`[]`作插入，`map`可以直接使用`[]`插入。



**`map`独特的`[]`操作符重载：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221228191507690.png" alt="image-20221228191507690" style="zoom:40%;" />

-   `map`可以使用`[]`插入或者创建元素，它会调用`insert()`。所以速度虽然稍慢，但是更为直观。
-   如果`[]`中的key不存在，则会创建一个有默认值的value。
-   `lower_bound()`是二分查找的一种版本，返回查找到的第一个位置；如果没找到，则返回最适合插入查找元素的位置。



### 2.16 深度探索`hashtable`

哈希表没有太多数学，有很多经验值。

-   处理哈希冲突有很多方法，工程上常用的是所谓「拉链法」
-   哈希表的bucket对应的链表不能太长，如果哈希表中的元素大于buckets的数量，则「rehashing」：选择当前buckets两倍附近的一个素数作为新的哈希表的长度（也就是buckets的数量），并重新计算位置。这样每个bucket对应的链表也会变短。GNUC这个数值写死了：53, 97, 193....
-   rehashing较为花费时间



**`hashtable`的源码：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221228194215866.png" alt="image-20221228194215866" style="zoom:40%;" />

-   `hashtable`有六个模版参数
-   `HashFcn`就是一个对象反射成一个编号的方式，这个编号称为「hashcode」。
-   `ExtractKey`就是如何从`value`中取出key
-   `EqualKey`就是判断key相等
-   `hashtable`的组成：
    -   三个仿函数，大小都是1
    -   `buckets`是一个`vector`，由三根指针构成，32位机大小为12
    -   `num_element`记录哈希表的数量，为4
    -   总共19，对齐为20
-   迭代器必须有能力知道自己走到bucket的边界了
    -   迭代器的`cur`指向某个节点（上图有误，指向了bucket）
    -   `ht`指向bucket



**使用`hashtable`：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221228195622170.png" alt="image-20221228195622170" style="zoom:40%;" />

-   传入的`EqualKey`必须是一个谓词



**哈希函数的选择：**

在GNUC2.9中，有很多`hash`的偏特化版本，这些都是仿函数。面对数值类型，直接数值本身返回。

**对于字符串：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221228215142765.png" alt="image-20221228215142765" style="zoom:40%;" />

-   字符串的hashcode是尽量不会重复的数据。在GNUC2.9中就是循环遍历，每个数值*5
-   注意，标准库没有提供现成的C++风格的字符串的哈希`hash<std::string>`



**modulus运算：**

也就是「取模操作」。



### 2.17 `hash_set`, `hash_multiset`, `hash_map`和`hash_multimap`

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221228220332803.png" alt="image-20221228220332803" style="zoom:40%;" />

-   C++11之前和之后的命名是不同的
-   buckets的个数一定大于元素个数，可以用`bucket_count()`查看



## 第三讲

### 3.1 什么是C++标准库算法

从语言层面来看：

-   容器Container是类模版class template
-   算法Algorithm是函数模版function template
-   其余四大组件都是类模版

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221229231134390.png" alt="image-20221229231134390" style="zoom:40%;" />

算法看不见容器，对其一无所知，所以，它所需要的一切信息（例如迭代器如何移动）都必须从迭代器取得，而迭代器（由容器提供）必须能够回答算法的所有提问，才能搭配该算法的所有操作。



### 3.2 迭代器的分类（category）

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221229232708698.png" alt="image-20221229232708698" style="zoom:40%;" />

有的迭代器拥有random access随机访问特性，例如`deque`。红黑树是双向的。

标准库的五种`iterator category`是五个类，也是一个个标签，这些标签存在继承关系。

容器提供的迭代器分类不是枚举，也不是12345，而是一个个对象。

可以通过`Iterator_traits`查看迭代器的category。 在模板中获取变量类型可以用`typename`关键字。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221229234103351.png" alt="image-20221229234103351" style="zoom:40%;" />

-   红黑树的迭代器是`bidirectional_iterator`双向迭代器。
-   `input_iterator`和`output_iterator`分别是`istream_iterator`和`ostream_iterator`的category分类。 



**各种容器的迭代器的`iterator_category`的typeid：**

`typeid`是C++提供的一个操作符，返回一个object，可以调用`.name()`，需要`#include <typeinfo>`头文件：

```cpp
cout << typeid(itr).name() << endl;
```

输出取决于不同的library的实现，主要的名称一样，但是前后附加可能略有区别。



**`istream_iterator`的`iterator_category`：**

不同版本的`istream_iterator`的实现不同，但是功能相同。

`ostream_iterator`类似。



### 3.3 迭代器分类（category）对算法的影响

**distance算法：**

两个指针的距离应该用什么类型来表示？用`difference_type`。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221230143947981.png" alt="image-20221230143947981" style="zoom:40%;" />

-   调用`__distance(first, last, category())`用到了临时对象。根据`iterator_category`来决定最终使用哪个计算迭代器距离的函数的版本。
-   如果是`farward_iterator_tag`，没有这个版本的`distance()`函数，最终会调用上图的`input_iterator_tag`的版本，也就是如果没有这个版本，则调用它的父类版本。这也是为什么将category设计成class的原因。



**advance算法：**

这是一个基础的算法，收到一个迭代器i和距离n，将迭代器i移动n个距离。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221230144318350.png" alt="image-20221230144318350" style="zoom:40%;" />

-   根据迭代器是单向、双向、随机访问的分类，采用不同的计算方法。
-   `iterator_category()`函数：传入一个迭代器，返回迭代器的`category`的一个临时对象。`category`是一个类。
-   这里只有三种分类，但是总共有五种（除了output_iterator还有四类），如果没有专门的版本，则调用它父类的版本。



**`copy`算法：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221230145043246.png" alt="image-20221230145043246" style="zoom:40%;" />

-   `copy`算法需要三个变量，来源的起点和终点，output的起点。
-   `copy`分成三个版本，其中又分为多种情况。`copy`内部在不断检查迭代器，来决定最终使用什么版本的copy
-   `copy`先检查来源的起点和终点两个迭代器。最终检查是否是`RandomAccessIterator`。
-   什么是`trivial op=()`?拷贝赋值重要与否？就是自己不写拷贝赋值操作，是不是就是浅拷贝足矣？
-   还有很多trivial的东西，例如析构函数



>   算法的效率和它是否能判断迭代器的分类有重要的关系。



**算法源码中对`iteratro_category`的“暗示”：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221230151312682.png" alt="image-20221230151312682" style="zoom:40%;" />

-   `sort()`算法是快速排序，它需要传入的迭代器具有随机访问特性，但是语言层面不能禁止其他类型的迭代器传入，所以`sort()`算法在模版类的命名时很长，没用`T`而是`RandomAccessIterator`，根据继承关系来讲这是最高级的迭代器。传入其他的迭代器也是可以的，但是在`sort()`算法中对迭代器的跳跃是会报错。
-   其他算法也有对应的“暗示”



### 3.4 一些算法的代码剖析

**先前例子中出现的算法：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221230152519322.png" alt="image-20221230152519322" style="zoom:40%;" />

-   `qsort`是C函数；C++标准库提供的算法一定都是有两个迭代器控制范围。



**`accumulate`算法：**

`accumulate`算法是一个累计算法 

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221230152710184.png" alt="image-20221230152710184" style="zoom:40%;" />

-   它提供了两个版本，通常的算法也提供了两个版本，第二个版本可以自定义操作
-   第一个版本就是累加版本，把所有元素累加到初值`init`上
-   第二个版本则是自定义操作，把所有元素通过自定义的操作累计到`init`初值上
-   数组可以直接用指针作为迭代器
-   传入的操作可以是仿函数、函数、标准库提供的仿函数，只要能被`()`调用即可。
-   通过源码可以看出，每次操作时，初值`init`是第一个操作数，迭代器指向的元素是第二个操作数



**`for_each`算法：**

`for_each()`就是对一个区间的所有元素做你指定的事情。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221230153702326.png" alt="image-20221230153702326" style="zoom:40%;" />

-   `f`是能被`()`调用的东西
-   C++11提供了新的范围for循环



**`replace`,`replace_if`和`replace_copy`算法：**



<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221230154247483.png" alt="image-20221230154247483" style="zoom:40%;" />

-   `replace`有四个参数，头尾迭代器，旧值和新值，如果与旧值相同，则替换为新值
-   `replace_if`也是四个参数，头尾迭代器，一个谓词（返回值为bool类型）和新值。如果元素符合谓词这个判断值，则替换为新值
-   `replace_copy`则是把旧区间的元素等于旧值的都替换成新值，并复制到新的区间。不符合的原值放入新区间



**`count`,`count_if`算法：**

`count`就是计算区间内符合条件的元素。



<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221230154822623.png" alt="image-20221230154822623" style="zoom:40%;" />

-   左边是全局的函数，右边给出了某些容器有同名的成员函数（自己也有`count`和`count_if`算法），自己提供的肯定更快更好。关联式容器都有自己的`count`和`count_if`，因为它们有自己的存储方式。
-   `count_if`也要有一个一元谓词来判断。一元谓词可以是仿函数，也可以是回调函数。



**`find`,`find_if`算法：**

这是一个循序查找。返回第一个符合条件的迭代器。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221230155540682.png" alt="image-20221230155540682" style="zoom:40%;" />

-   返回的是第一个符合条件的迭代器
-   关联式容器有自己的`find`



**`sort`算法：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221230155646811.png" alt="image-20221230155646811" style="zoom:40%;" />

-   `sort()`算法比较庞大
-   `sort()`可以只排序一部分
-   `sort()`也可以指定自己的排序规则，二元谓词即可。
-   如果传入`rbegin()`和`rend()`，则进行逆向排序（从小到大变为从大到小）
-   关联式容器不要排序，只有`list`和`forward_list`自带`sort()`函数。`sort()`算法需要随机访问特性。



**关于逆向迭代器`rbegin()`和`rend()`：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221230160436648.png" alt="image-20221230160436648" style="zoom:40%;" />

-   逆向之后对应的`++`,`--`也会颠倒
-   `rbegin()`和`end()`是同一个位置，但是需要套接一个适配器`reverse_iterator()`。



**`binary_search`算法：**

二分查找必须有序。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221230161018213.png" alt="image-20221230161018213" style="zoom:40%;" />

-   `binary_search`把工作交给`lower_bound()`去做。
-   `lower_bound()`就是找到新元素在有序序列中最低位置，`upper_bound()`同理，找到最高位置。`lower_bound()`就是一个二分查找。
-   `binary_search`还需要判断`lower_bound()`找到的位置是否是val的所在
-   可以在`lower_bound`前检查待查找元素val是否小于第一个元素，如果小，则不用找了。



### 3.5 仿函数functors和函数对象

functor也是最有可能自己编写的一部分。仿函数和函数对象是一个东西。

-   仿函数必须重载`()`
-   仿函数有：算数类、逻辑运算类、相对关系类



GNU C++有一些独有的非标准的仿函数：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221230163057056.png" alt="image-20221230163057056" style="zoom:40%;" />

-   identity：传入什么传出什么
-   select1st：对于pair传出第一个元素first
-   select2nd：对于pair传出第二个元素second
-   但在G4.9版本中名字变了，前面加了下划线





<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221230163403334.png" alt="image-20221230163403334" style="zoom:40%;" />

-   传入仿函数或真正的函数都可以
-   标准库提供的仿函数都有一个继承关系，但是我们自己写的仿函数并没有这个继承，没有继承就没有融入STL的体系中



**仿函数可适配（adaptable）的条件：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221230164116024.png" alt="image-20221230164116024" style="zoom:40%;" />

-   一元仿函数和二元仿函数的对象，大小都是1。
-   STL规定每个adaptable function都应该挑选这两个类来继承一个。例如右边的`less`类继承之后不会增加数据，但是会继承三个`typedef`，所以`less<int>`便有了三个`typedef`，分别是`int`,`int`和`bool`。
-   如果希望自己写的functor是可适配的，就需要继承左边的类中的一个。具体来说，adapter提问，functor回答问题。



###   3.6 存在多种Adapters

Adapter就是把某个已经存在的东西稍微改造一下。Adapter出现在三个地方：

1.   容器适配器
2.   迭代器适配器
3.   仿函数适配器

adapter需要改造某一个东西。在技术上，Adapter不是继承，而是内含，例如仿函数适配器内含了仿函数。

例如`stcak`和`queue`都是`deque`的适配器。

 

### 3.7 仿函数适配器：`binder2nd`

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230101001411486.png" alt="image-20230101001411486" style="zoom:40%;" />

在右上角的一段代码中，`not1(bind2nd(less<int>(), 40))`中的`less<int>`是一个二元谓词，比较`x < y`，但是我们需要比较x和40的大小，可以用`bind2nd`将第二个参数绑定为40。`less<int>()`的小括号`()`**不是函数调用，是产生一个临时对象，这是一个对象！！**每次看到`()`都要考虑到这点。同时`bind2nd`只能修饰仿函数，不能修饰普通函数。ptr_fun可以将普通函数 转为 函数对象

-   `bind2nd`是一个辅助函数，它会返回`binder2nd`对象。
-   函数适配器修饰仿函数，它也会得到一个仿函数
-   `op`就是`less`
-   只有执行到这行代码的时候才会绑定

上面是整体的概念，下面介绍流程：

-   `binder2nd`是一个类模版，它的模版是一个操作`Operation`，具体到上面的例子`Operation`就是`less<int>`，这个用起来比较复杂，所以STL又提供了`bind2nd`函数，这个函数会推导出`op`的类型，这就是辅助函数的价值。
-   `bind2nd`会调用`binder2nd`的构造函数，构造函数把操作`op`和`value`记录下来
-   `count_if`调用`pred`也就是`binder2nd`的对象，也就是调用`binder2nd`的`operator()`，这个小括号重载里会绑定第二个实参。

还有一些细节：

-   如何检查40是`int`类型，靠的就是上图中灰色的部分。
-   把x强制转换成`arg2_type`类型，如果不能转换，则报错（相当于检查的过程）
-   重载`()`传回的结果值的类型和传入的第一个参数x也应该是`less<int>`对应的类型
-   能够回答这三个问题（上图中灰色的code）才能被称为「可适配」(adaptable)，所以自己写的仿函数需要继承`unary_function`或者`binary_function`类（具体可看上一节的图）
-   `binder2nd`也要继承`unary_function`类，因为它也要融入STL体系，也要返回一个仿函数，那么它也有可能被别的适配器修饰，例如上图代码中用`not1()`修饰`bind2nd`修饰过的仿函数。由于作为二元仿函数它的第二个参数已经被绑定了，所以它应该继承`unary_function`类



>   关于`typename`关键字：
>
>   例如上图中有代码:
>
>   ```cpp
>   typedef typename Operation::second_argument_type arg2_type;
>   ```
>
>   在编译时编译器并不知道`Operation`是什么，那么`::`后的内容编译器也不知道是什么，无法通过，`typename`就是告诉编译器后面的是一个类，不要犹豫了，赶紧通过吧！



然而`bind2nd`已经过时了，建议用`bind`取代：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230101005046728.png" alt="image-20230101005046728" style="zoom:40%;" />



### 3.8 函数适配器： not1

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230101005412644.png" alt="image-20230101005412644" style="zoom:40%;" />

-   `not1`代表否定，在右上角的代码中就代表不小于40
-   与`bind2nd`的流程是类似的，创建一个`unary_negate`对象，这个类重载`()`操作符就是返回`!pred(x)`
-   `not1`没有过时



### 3.9 函数适配器：bind

C++11新标准有新适配器`bind`，它可以绑定：

1.   函数
2.   函数对象
3.   成员函数
4.   类中的data

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230102002246272.png" alt="image-20230102002246272" style="zoom:40%;" />

**绑定函数和仿函数：**

-   `my_divide`函数就是一个普通的除法，`MyPair`用来测试3和4
-   需要`using nameplace std::placeholders;`
-   `bind(my_divide, 10, 2)`就相当于绑定了10和2
-   `bind(my_divide, _1, 2)`相当于绑定第二个参数为2，第一个参数保留，所以调用的时候还需要一个参数（未绑定的那个参数）：`fn_half(10)`，这个10就相当于保留的第一个参数
-   `bind(my_divide, _2, _1)`相当于调换了第二参数和第一参数的位置，调用`fn_invert(10, 2)`就是返回 2/10 = 0.2
-   `bind<int>(my_divide, _1, _2)`指定了一个模版参数，相当于定义了返回值的类型为`int`（所以模版参数只会有一个），如果不指定则是默认的`double`
-   仿函数的绑定和函数的绑定是一样的



**绑定类的成员函数和数据：**

-   需要先创建一个对象
-   需要注意绑定成员函数的时候，有一个隐式的参数`*this`，`_1`相当于没有绑定参数，所以调用的时候需要指定
-   而`bind(&MyPair::a, ten_two)`相当于绑定成员变量，需要传入一个**对象**，`ten_two`就是一个`MyPair`对象，返回成员a
-   `bind(&MyPair::b, _1)`相当于没有绑定对象，返回b，所以调用的时候需要传入对象



**bind和bind2nd的区别：**

1.   绑定的可调用对象的参数数量：bind1st、bind2nd函数只能绑定参数数量为2的可调用对象，而bind可以绑定无参数的、以及1~9个参数的可调用对象
2.   绑定的可调用对象是否需要借助模板的转换：bind1st、bind2nd函数需要借助ptr_fun、mem_fun、mem_fun_ref等函数对可调用对象进行转换，而bind函数不需要借助这些模板，bind函数包含这些模板的功能，bind2nd只能绑定函数对象（仿函数），但是bind可以直接绑定函数，成员函数，成员变量。
3.   实参赋值绑定的参数：bind1st、bind2nd会将其中一个参数绑定，然后另一个参数通过调用时实参进行赋值，而bind函数主要看绑定时的参数顺序以及所用的占位符



**一些关于bind和bind2nd的代码：**

```cpp
#include <iostream>
#include <vector>
#include <algorithm>
#include <functional>
using namespace std;
using namespace std::placeholders;

bool myCompareFunc(int a)
{
    return a < 3;
}

bool myCompareFunc2(int a , int b)
{
    return a < b;
}

class myCompareClass : public binary_function<int, int, bool>
{
public:
    bool operator()(int a, int b) const
    {
        return a < b;
    }
};

class MyCompare
{
public:
    bool compare(int a, int b)
    {
        return a < b;
    }
};

void test01()
{
    vector<int> v {1, 2, 3, 4, 5, 6, 7, 8};
    //3
    cout << count_if(v.begin(), v.end(), bind2nd(myCompareClass(), 4)) << endl;

    //而没有pred可以是普通函数
    //2
    cout << count_if(v.begin(), v.end(), myCompareFunc) << endl;

    //ptr_fun可以将普通函数转为函数对象
    //3
    cout << count_if(v.begin(), v.end(), bind2nd(ptr_fun(myCompareFunc2), 4)) << endl;

    //bind可以直接绑定函数, 函数对象, 成员函数等
    //3
    cout << count_if(v.begin(), v.end(), bind(myCompareFunc2, _1, 4)) << endl;
    //3
    cout << count_if(v.begin(), v.end(), bind(myCompareClass(), _1, 4)) << endl;

    //绑定了成员函数不能送入count_if, 因为没有绑定this,
    //目前来看, 如果再绑定的时候显式指定了this, 则_1, _2正常
    //如果在绑定的时候, 没有显式指定this, 则_1代表this形参, _2代表第一个形参
    auto fn = bind(&MyCompare::compare, MyCompare(), _1, _2);
    //但是可以直接调用
    
    //1
    cout << fn( 3, 4) << endl;

    //证明上述论证
    auto fn3 = bind(&MyCompare::compare,_1 , _3, _2);
    //0
    cout << fn3(MyCompare(),3, 4) << endl;

    //绑定了this才可以传入count_if, this是第一个参数
    MyCompare m;
    auto fn2 = bind(&MyCompare::compare, &m, _1, 4);
    //3
    cout << count_if(v.begin(), v.end(), fn2);

}
int main()
{
    test01();
    return 0;
}

```



>   bind函数在绑定成员函数的时候，最好显示指明实例化后的对象的地址。



### 3.10 迭代器适配器：reverse_iterator

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230102224139201.png" alt="image-20230102224139201" style="zoom:40%;" />

-   `begin()`和`rend()`其实指向同一个位置，通过`reverse_iterator`来修改
-   `reverse_iterator`类内部有一个迭代器，也有五个`typedef`与正向迭代器对应
-   但是取值的顺序不同，逆向取的是前一个元素，重载`*`操作符：对逆向取值就相当于「对正向迭代器退一格再取值」`*--tmp`。
-   逆向的++就是正向的`--`，`--`就相当于正向的`++`，`-n`相当于`+n`



### 3.11 迭代器适配器：inserter

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230102224806709.png" alt="image-20230102224806709" style="zoom:40%;" />



**整体一览：**

-   准备了7个元素的数组，赋值（assign）到vector，如果在目的端准备的空间不够，可能会引发错误，inserter就是解决这个问题
-   `foo`和`bar`都是list，所以空间都是插入了多少数据，在例子中为5。
-   不能将链表的迭代器直接`+3`，所以需要使用`advance()`函数，将链表的迭代器前进三个位置
-   如果使用普通的`copy`插入到`it`，则是覆盖，同时会越界。可以使用`inserter()`函数

**具体细节：**

-   `copy`里面已经写死了，该如何修改？
-   `inserter()`函数是一个辅助函数，有两个参数：容器和迭代器。辅助函数用来推导类型
-   `insert_iterator`类重载了`=`assign赋值运算。`=`是作用在左边运算对象上的。
-   上面的几步相当于接管了`=`assing赋值操作，并改为`insert`操作，这样copy就变成插入了，而不会覆盖，同时还会分配空间（`insert`会分配）
-   上面是一个非常巧妙的操作符重载的例子



`return reslut`也需要注意，对应了拷贝构造。

### 3.12 X适配器：ostream_iterator

X代表未知，也许可以称为`ostream`的适配器，因为它用来改造`ostream`

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230102230156987.png" alt="image-20230102230156987" style="zoom:40%;" />

**如何使用：**

将一个`vector`copy到`ostream_iterator`对象，这个对象`out_it`有两个参数`cout`和分割符`,`（这个可以随意修改），这样vector中的元素就会输出到屏幕上。通过修改copy中的操作，将元素输出到屏幕上：

-   先调用`ostream_iterator`的构造函数，delimiter代表分隔符。`cout`是一个`basic_ostream`对象，所以在构造函数中可以取地址`&`

-   `=`赋值操作的源码就是关键

    ```cpp
    *out_stream<<value;
    if(delim != 0) *out_stream << delim;
    ```

    上面的代码就是输出元素和分隔符（如果有的话）

-   同时`++`操作没有任何动作，只返回`*this`，相当于`copy`函数中的`++result`不做任何动作



### 3.13 X适配器：istream_iterator

`istream_iterator`适配器绑定的就是`cin`。



<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230102231655487.png" alt="image-20230102231655487" style="zoom:40%;" />

-   没有任何参数的命名为`eos`，代表一个结束的标志
-   调用一个参数的重载函数会调用`++*this`
-   `++`操作就相当于`cin>>value`，
-   `*`操作则返回读取的`value`
-   `++iit`就相当于再读一次
-   `if(iit != eos)`就相当于判断是否读入（键盘已经输入）
-   不断++迭代器就相当于读取

**copy的例子：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230102232541619.png" alt="image-20230102232541619" style="zoom:40%;" />

-   把`iit`和`eos`作为来源端，它们都是`istream_iterator`
-   创建`iit`的时候就已经会立刻read，所以可以直接读入。也就是说，当你创建一个`cin`的`istream_iterator`就已经开始读入第一个数据了
-   `++first`相当于读取
-   所以非常巧妙，同一个copy，面对不同的适配器有不同表现



>   模版技术也带来一个缺点：
>
>   如果使用模版出了问题，报错会非常长。



## 第四讲

「**勿在浮沙筑高台**」

### 4.1 一个万能的hash函数

**举例：**

`Customer`类有三个成员变量：`fname`,`lanme`和`no`

`Customer`作为元素放入容器内，所以要写一个`CustomerHash`，重载`()`操作符，也可以写成一个普通函数，它们的使用方式不一样：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230102234525568.png" alt="image-20230102234525568" style="zoom:40%;" />

-   左边只要填入类名
-   右边填入函数类型，同时对象还需要指明具体是哪个函数，附带还需要填入大小`20`



<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230102234655843.png" alt="image-20230102234655843" style="zoom:40%;" />

-   如图左上角：hash函数直接把成员的哈希函数相加，这样是可以运行的，但是比较天真naive。
-   从TR1（大概2003年提出的，C++11）也可以直接使用
-   右上角的使用了一个函数`hash_val`，它调用编号1的函数（如图）

**具体细节：**

-   编号1的`hash_val`函数采用了C++11新特性：`template<typename... Types>`，叫做「可变化的模版」相当于任意多种类型，这种函数一般都会迭代：例如传入8个参数，那么会拆成1+7个，以此类推。
-   编号2的`hash_val`函数第一个参数是`size_t`类型，它会重复调用自己，每次传入都会把第一个取出去变化种子seed（调用`hash_combine`函数，采用引用传递），其余的继续传入`hash_val`，所以参数会不断拆解
-   编号3的`hash_val`第一个参数是`size_t`类型，第二个参数是固定的只有一个，也就是最后一只剩1+1的时候才会调用它
-   编号4的`hash_combine`相当于调用基本类型的哈希函数，所有的基本类型都有哈希函数，进行一些复杂的没有逻辑的操作。所以调用`hash_val`只能传入基本数据类型？
-   最后的seed就是hashcode

>   0x9e3779b9是什么？
>
>   通过搜索引擎搜索可知：这是个magic哈希常量
>
>   侯捷老师讲了一句非常幽默的话：「Google在内地不好用」

如果自己不指定哈希函数，那么hashtable会指定固定的一组数据作为buckets增长后的个数。如果自己指定了哈希函数，这个数量就不一定了。

那么元素放到哪个bucket呢？

答案是：`hashcode % bucket_count()`



**可以使用`struct hash`偏特化的形式实现哈希函数：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230103001534950.png" alt="image-20230103001534950" style="zoom:40%;" />

标准库没有为`string`写hash，但是新版本提供了。



### 4.2 Tuple用例

念“他破”或者“tu破"都可以。

tuple与struct是不同的东西。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230105001642803.png" style="zoom:40%;" />

-   `string`的大小就是一根指针的大小，`tuple`的大小就是它内部的元素组合的大小
-   `get<0>(t1)`就是取出t1中第一个元素
-   也可以直接用`make_tuple()`，直接把值放进去，编译器会自动创建对应的tuple，C++11可以用`auto`关键字接受
-   tuple可以比较大小（一个一个的比较），也可以赋值
-   `tie()`函数可以绑定，`tie(i1, f1, s1) = t3`就相当于把`t3`中的三个元素赋值给`i1, f1, s1`
-   `tuple_element<1, TupleType>::type`就是TupleType中第一个元素的类型



**如何实现：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230105003701484.png" alt="image-20230105003701484" style="zoom:40%;" />

-   利用了可变模版语法

-   `tuple`有两个模版参数`Head`和`Tail`，Head只有一个，`Tail...`代表很多个模版参数；

-   `tuple`最核心的就是「**继承Tail版本的自己**」，例如五个模版参数的继承四个模版参数的tuple，以此类推，会依次继承。这很容易想到之前的哈希函数中通过几个函数重载分离这些可变参数。对于没有模版参数的tuple，写一个特化版本的tuple：

    ```cpp
    template<> class tuple<>{};
    ```

-   `Head`类型会声明一个变量。`tuple`的`head()`函数传回第一个元素的值，`tail()`函数传回的是自身`*this`，但是返回类型是`inherited&`，会转型为`inherited`类型，也就是尾部元素组成的tuple类型。



其实上面的代码存在问题，那就是`Head::type`，例如`int`等根本没有`type`，也就不能回答这个问题。可以使用：

```cpp
auto head()->decltype(m_head) {return m_head;}
//或者
Head head() {return m_head;}
```



>   tuple很好用，可以放置任意类型的元素。



### 4.3 type traits

G2.9 版本就有type traits

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230105005717622.png" alt="image-20230105005717622" style="zoom:40%;" />

-   默认的`trivial`相关的都是`false`，都是重要的（trivial的意思是微不足道不重要的）
-   还有很多特化的版本：例如`int`、`double`等基本类型的所有的都不重要，自己也可以为自己的类型写特化版本的`type traits`。带着指针类这些才重要，还有释放锁等也重要。
-   这些`typedef`通常为算法服务，例如`__type_traits<Foo>::has_trivial_type`。
-   但是要为每个类写一个`type traits`，实用性不高，从C++11开始，标准库有了很多新的type traits，更为庞大，也不需要对自己的class写篇特化版本的`type_traits`
-   POD：Plain Old Data，C风格的类，没有函数



**如何使用：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230105012729764.png" alt="image-20230105012729764" style="zoom:40%;" />

-   任何类型都可以使用

**测试type traits**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230105012850118.png" style="zoom:40%;" />

-   `string`类型的输出结果在右边，`string`内部是一个`basic_string<char>`
-   `typeid`是运行时获知变量类型名称，不同编译器的结果可能不同
-   一个类只要带了指针，一定要写析构函数，如果不想作父类，也不要写virtual destructor

**自定义class使用type traits：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230105013438863.png" alt="image-20230105013438863" style="zoom:40%;" />

-   没有函数，是POD：`is_pod`为1



Goo类型有一个virtual destructor：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230105013645361.png" alt="image-20230105013645361" style="zoom:40%;" />

-   `has_virtual_destructor`是1，证明有虚析构函数
-   `is_polymorphic`是1，polymorphic类是有声明或继承一个虚函数的类
-   C++没有关键字用来拒绝继承，Java有



###  4.4 type traits的实现

>   为什么自己写的类的底细（实现细节）能被type traits了解，并且没有与G2.9版本一样写偏特化版本的type traits？

**is_void的实现：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230105014942836.png" alt="image-20230105014942836" style="zoom:40%;" />

首先需要明确的是用模版对类型做操作，而不是变量。

-   需要先`remove_cv`，也就是移除不需要的东西：顶层`const`和`volatile`，通过偏特化实现
-   然后`__is_void_helper`，它对于`void`类型偏特化，为true，对于其他类型使用模版，为false





**is_intergral的实现：**

int long等都是整数型。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230105151517258.png" alt="image-20230105151517258" style="zoom:40%;" />

-   先移除volatile和const关键字
-   再特化`long`,`int`等类型，为true_type



**is_class, is_union, is_enum, is_pod的实现：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230105151756942.png" alt="image-20230105151756942" style="zoom:40%;" />

-   这些都是相同的手法，利用继承交给别的类做
-   但是蓝色的部分都没有代码，可能是编译器在做



**is_move_assignable的实现：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230105152120071.png" alt="image-20230105152120071" style="zoom:40%;" />

同样蓝色的东西也是找不到源代码。

所以当深入到class的内部的时候，可能都是交给编译器去做。



### 4.5 cout

![image-20230105152420228](https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230105152420228.png)

-   `cout`是一个对象，是`_IO_ostream_withassign`类，继承了`ostream`类，`ostream`类中有很多重载
-   `cout`有很多重载`<<`操作符，传入了很多基本数据类型，对于自己的类型，需要自己写操作符重载`<<`



### 4.6 moveable元素对容器速度的影响

`move`也是C++11加入的语法。有move功能和没有move功能的元素对容器速度的影响是很大的。

每次测试都分为有moveable和没有moveable的元素，共300w个元素

**moveable元素对vector容器速度能效的影响：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230105153357018.png" alt="image-20230105153357018" style="zoom:40%;" />

-   CCtor代表copy构造函数，MCtor代表move构造函数
-   上面是有moveable，下面是没有moveable，可以看到有moveable的元素比没有的快了很多
-   `M c11(c1)`就是拷贝构造，`M c12(std::move(c1))`代表move构造，加上move之后比拷贝构造快了非常非常多
-   红黑树也可以用`insert`指定要插入的位置，只不过这个位置是一个提示，元素最终还是落在该落在的地方
-   300W个元素最终拷贝了700W余次



**moveable元素对list的影响：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230105154222455.png" alt="image-20230105154222455" style="zoom:40%;" />

-   list就是一个萝卜一个坑，共调用300W次构造函数
-   同时有没有moveable对list的速度影响不大



**写一个moveable的class：**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230105154537281.png" alt="image-20230105154537281" style="zoom:40%;" />

-   浅拷贝就是move的工作，move和copy的区别只有参数传递的区别，move就是打断原来的指针（这里与浅拷贝不同），把新指针指向空间。



<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20230105160143898.png" alt="image-20230105160143898" style="zoom:40%;" />

M是一个容器，可以通过`typedef typename iterator_traits<typename M::iterator>::value_type V1type`来确定M中元素的类型。

临时对象是一个右值，容器本身是深拷贝的，使用move进行浅拷贝（原来的指针会失效）。vector就是三根指针，分别指向头、尾（size）和capacity的尾。



string带有move功能。



>   写在后面：
>
>   STL确实是一个巨大的宝库，囫囵吞枣看了一遍侯捷的课程之后感觉收益良多，但细节还是理解不够到位，对于C++，还是要多多练习。
>
>   STL对于模版的应用实在是太过于精妙了，偏特化去除`const`和`volatile`关键字，对于基本数据类型的traits等，都让我大开眼界。
>
>   在学习完后，最大的感悟还是刷题的时候对于STL容器和算法的时候更加了然于胸。
> 
>  同时, 不得不说,Typora虽然很好用,但是面对这么多图片的渲染，还是非常吃力的,写到后半段的时候几乎卡的不能正常写.

