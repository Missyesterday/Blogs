

# STL简介
在大一大二学习数据结构这门课程的时候，每学习一个数据结构和算法的时候都会想有没有一个统一的标准，答案是有的，STL(Standard Template Library,标准模板库)，是惠普实验室开发的一系列软件的统称。现在主要出现在 c++中，**但其实在c++之前该技术已经存在很长时间了**。从名字就可以看出STL不止适用于某一种特定的数据结构，为了提高复用率，大量使用了模版类和模版函数。
STL有如下特性：

 - STL 是 C++的一部分，编译器自带STL，不需要额外安装。
 - STL 具有高可重用性，高性能，高移植性，跨平台的优点。
 - 程序员可以把STL看作黑盒，不用考虑实现过程（当然还是要懂），只要会用就行。
STL分为容器、算法和迭代器。容器和算法通过迭代器进行无缝连接。在此基础上，STL 提供六大组建： **容器 算法 迭代器 仿函数 适配器 空间配置器**。
## 容器
个人理解中，容器就是数据结构，也就是数据抽象的存放形式以及它们之间的逻辑关系，比如vector、deque、set、map等。从实现上看，STL中的容器都是类模版。

## 算法

没什么好说的，就是提供了很多常用的算法，比如排序(sort)、查找(find)、复制(copy)等。在STL中，实现方式为模版函数。
## 迭代器
这个是最抽象也是最难理解的。首先从定义上来看：迭代器就是连接容器和算法的工具，那么在面向对象的C++中，也是一个模版类。从名字上看，迭代器实现遍历功能，它是一种将operator* , operator-> , operator++,operator–等指针相关操作予以重载的模版类。
STL中的容器有不同的特性，比如有的能随机存取，有的不能随机存取，因此每种容器的迭代器都不相同。
值得一提的是，普通的指针也是一种迭代器，我们可以吧迭代器看作特殊的指针。

```cpp
void test01()
{
    int array[5] = {1, 2, 3, 4, 5};

    int *p = array;//指针指向数组首地址

    for(int i = 0; i < 5; i++)
        cout << *(p++) << endl;
    for(int i = 0; i < 5; i++)
        cout << p++ << endl;

}
```
运行结果如下：
![](https://img-blog.csdnimg.cn/ad3cf2c09e8440839ccb9542521214a7.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBA5peL6aOO5Yay6ZSL6b6Z5Y236aOO,size_9,color_FFFFFF,t_70,g_se,x_16#pic_center)
上面的代码中p指针初始化指向数组首地址也就是数据1，p++就可以指向下一个数据的地址，而实际上p++并不止加1，而是增加了4个字节也就是sizeof(int),这也是为什么要重载operator* , operator-> , operator++,operator–运算符的原因。


# vector
vector翻译为单端数组，它的数据结构如图：
![在这里插入图片描述](https://img-blog.csdnimg.cn/18a7972846ac43a09cd3e7c5c7b9877f.png?x-oss-process=image/watermark,type_ZHJvaWRzYW5zZmFsbGJhY2s,shadow_50,text_Q1NETiBA5peL6aOO5Yay6ZSL6b6Z5Y236aOO,size_20,color_FFFFFF,t_70,g_se,x_16)
可见它只能尾端出。
与数组的区别是：数组是静态的，在最初的定义阶段就已经确定好了空间，比如我们写一句：

```cpp
int arr[100];
```
那么我们就不能在arr数组中放入大于100个元素，我们只能开辟更大的空间。而vector动态的，它有自己开辟空间的策略

## 1.构造vector
### 默认构造函数
```cpp
vector<T> v; //默认构造函数,T代表数据类型
```

操作int数据类型
```cpp
 vector<int> v;//声明一个容器 这个容器存放int类型的数据
    v.push_back(10);
    v.push_back(20);
    v.push_back(30);
    v.push_back(40);
    v.push_back(50);
```

操作自定义类型

```cpp
class Person
{
public:
    Person(const string &mName, int mAge) : m_Name(mName), m_Age(mAge) {}

    string m_Name;
    int m_Age;
};

void test03()
{
    vector<Person> v;
    Person p1("张三", 10);
    Person p2("李四", 20);
    Person p3("王五", 30);
    v.push_back(p1);
    v.push_back(p2);
    v.push_back(p3);
```
### 其他构造函数
函数1:
```cpp
    vector(v.begin(), v.end());//将v[begin(), end())区间中的元素拷贝给本身。
```
这个方法可以把数组赋值给vector

```cpp
int arr[] = {1, 3, 5, 5, 5};
    vector<int> v1(arr, arr + sizeof(arr)/sizeof(int));
```
也可以把一个vector的值复制到另一个vector

```cpp
vector<int> v2(v1.begin(), v1.end());
```
begin()和end()返回这个vector的头和尾



函数2:

```cpp
vector(n, elem);//构造函数将n个elem拷贝给本身。
```
如：
```cpp
vector<int> v3(10, 100);//10个100
```
v3中有10个100

函数3:拷贝构造函数

```cpp
vector(const vector &vec);//拷贝构造函数。
```

## 2.遍历方法
### 2.1 利用迭代器遍历容器中的数据
```cpp
//    利用迭代器遍历容器中的数据
    vector<int>::iterator  itBegin = v.begin();//指向容器的初始位置
    vector<int>::iterator itEnd = v.end();//指向容器的最后一个位置的下一个位置

    while(itBegin != itEnd)
    {
        cout << *itBegin << endl;//取值类似于指针
        itBegin++;
    }

```
```cpp
for(vector<int>::iterator it = v.begin(); it != v.end(); it++)
        cout << *it << endl;
```
上面两种方法都可以访问v中的数据。
记住***it的数据类型就是<>中的int**。
### 2.2 利用迭代器逆序遍历容器中的数据
注意逆序也是++
```cpp
 for(vector<int>::reverse_iterator it = v.rbegin(); it != v.rend(); it ++)//逆序也是++，迭代器是reverse_iterator
    {
        cout << *it << endl;
    }
```

vector迭代器是随机访问的迭代器，支持跳跃式访问

```cpp
vector<int>::iterator  itBegin = v.begin();
    itBegin = itBegin + 3;
```
如果上述写法不报错，这个迭代器可以支持随机访问迭代器，如list就不支持
### 2.3 利用for_each()算法

```cpp
void myPrint(int a)
{
    cout << a << endl;
}
for_each(v.begin(), v.end(), myPrint);
```
## 3.容器嵌套
也就是<>中的数据类型也是一个容器

```cpp
void test05()
{
    vector<vector<int>> v;
    vector<int> v1, v2, v3;
    for(int i = 0; i < 5 ; i++)
    {
        v1.push_back(i);
        v2.push_back(i + 10);
        v3.push_back(i + 100);
    }
    v.push_back(v1);
    v.push_back(v2);
    v.push_back(v3);
    for(vector<vector<int>>::iterator it = v.begin(); it != v.end(); it++)
    {
        for(vector<int>::iterator vit = (*it).begin(); vit != (*it).end(); vit++)
        {
            cout << *vit << " ";
        }
        cout << endl;
    }

}
```
## 4.vector的容量和大小
capacity()和siez()函数分别可以查看vector的容量和大小

```cpp
void test01()
{
    vector<int> v;
    for(int i = 0; i < 10000; i++)
    {
        v.push_back(i);
        cout << v.capacity() << endl;//容器的容量 永远大于等于其大小
//        一旦有新空间则原有的迭代器失效
    }

}
```
运行结果如下：
![在这里插入图片描述](https://img-blog.csdnimg.cn/233d0e16881f444e94fe8210043bbf1f.png#pic_center)
可以看到vector的容量是在变化的，但并不是每次增加元素都会增加容量，而是每次增加一倍（**在本人使用的编译器是这样，但不同编译器的vector容量增加的策略不尽相同**）
## 5.其他常用函数
### 5.1 assign()函数

```cpp
assign(beg, end);//将[beg, end)区间中的数据拷贝赋值给本身。
assign(n, elem);//将n个elem拷贝赋值给本身。
```

### 5.2 swap()函数

```cpp
swap(vec);// 将vec与本身的元素互换。
```

### 5.3 reserve()函数

reserve只是提供空间而不能访问
```cpp
reserve(int len);//容器预留len个元素长度，预留位置不初始化，元素不可访问。
```


### 5.4 erease()函数

```cpp
erase(const_iterator start, const_iterator end);//删除迭代器从start到end之间的元素
erase(const_iterator pos);//删除迭代器指向的元素
clear();//删除容器中所有元素
```
### 5.5 resize()函数
重新指定大小，变短就把后面的去掉,变长则默认填充0,如果填上第二个参数则填充第二个参数
```cpp
resize(int num);//重新指定容器的长度为num，若容器变长，则以默认值填充新位置。如果容器变短，则末尾超出容器长度的元素被删除。
resize(int num, elem);//重新指定容器的长度为num，若容器变长，则以elem值填充新位置。如果容器变短，则末尾超出容器长>度的元素被删除
```
### 5.5 巧用swap收缩空间
举一个极端的例子：
我们在v中添加100000个值，然后把v resize成3，那么v的容量很大而size很小，造成大量空间浪费，为了避免这一点，我们可以利用v来构造匿名对象然后swap(v)。

```cpp
void test03(){
    vector<int>v;
    for (int i = 0; i < 100000; i++)
    {
        v.push_back(i);
    }
    cout << "v的容量" << v.capacity() << endl;
    cout << "v的大小" << v.size()  << endl;

    v.resize(3);//
    cout << "v的容量" << v.capacity() << endl;
    cout << "v的大小" << v.size()  << endl;
//    容量比大小大太多

    vector<int>(v).swap(v);//()代表用v初始化匿名对象，而swap是交换指针，而匿名对象当前行会释放

    cout << "v的容量" << v.capacity() << endl;
    cout << "v的大小" << v.size()  << endl;
//    此时v的大小和容量都是3


}
```

