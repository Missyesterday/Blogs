# 《Effective C++》笔记

>   关于记笔记的方式：
>
>     -   对于能理解的内容，就按我的理解方式写下
>     -   对于暂时不能理解的内容，就把书上的原文和代码摘录
>     -   如果对于某个知识点有了新的理解随时补充
>
>     所以笔记中的内容夹杂了书面语和口语。



>   写在前面：
>
>   久闻大名，经常在各种博客的引用文献上看到，相当于「专家经验之积累」。
>
>   两个网站：
>
>     https://cplusplus.com
>
>     https://zh.cppreference.com/w/



## 0导读

**copy构造函数和copy assignment 操作符：**

-   copy构造函数被用来「以同类型对象**初始化**自我对象」。
-   copy assignment操作符被用来「从另一个同类型对象**拷贝其值到自我对象**」



**copyAssignment.cpp**

```cpp
/*  
 *  Description : copy构造函数和copy assignment操作符
 *  Created by 旋风冲锋龙卷风 on 2023/01/31 19:40
 *  个人博客 : http://letsgofun.cn/
 */
//

#include <iostream>

using namespace std;

class Widget
{
private:
    int m_x;
    int m_y;
public:
    Widget(int mX, int mY) : m_x(mX), m_y(mY)
    {
        cout << "调用两个参数的构造函数" << endl;
    }

    Widget() : m_x(0), m_y(0)
    {
        cout << "调用默认构造函数" << endl;
    }

    //拷贝构造函数
    Widget(const Widget& rhs) : m_x(rhs.m_x), m_y(rhs.m_y)
    {
        cout << "调用copy 构造函数" << endl;

    }

    //copy assignment操作符重载
    Widget& operator=(const Widget& rhs)
    {
        m_x = rhs.m_x;
        m_y = rhs.m_y;
        cout << "调用copy assignment操作符的重载" << endl;
        return *this;
    }
    friend ostream &operator<<(ostream &os, const Widget &widget)
    {
        os << "m_x: " << widget.m_x << " m_y: " << widget.m_y;
        return os;
    }
};

void test01()
{
    Widget w1;//调用默认构造函数
    Widget w2(w1); //调用copy构造函数
    w1 = w2; //调用copy assignment操作符
    
    //如果有一个新的对象被定义,一定会有构造函数被调用,而不可能调用赋值操作
    Widget w3 = w1;//调用copy构造函数
    cout << w3 << endl;
}
int main()
{
    test01();
    return EXIT_SUCCESS;
}
```



<mark>pass by value会引发拷贝构造函数！</mark>所以尽量用 Pass-by-reference-to-const。这句话实在是太太太重要了！

```cpp
//passed by value, aka值传递, 这个赋值动作是Widget的拷贝构造函数完成
void func(Widget w)
{
}
void test02()
{
    Widget w;
    func(w);
}
```



## 1. 让自己习惯C++

### 条款01: 视C++为一个语言联邦

最初，C++只是C加上一些面向对象特性：C++最初的名称就是C with Classes。

但是如今的C++越来越成熟，已经是一个多重泛型编程语言（multiparadigm programming language），一个同时支持过程形式（procedural）、面向对象形式（object-oriented）、函数形式（functional）、泛型形式（generic）、元编程形式（metaprogramming）的语言。

**我们应该把C++视为一个由相关语言组成的联邦而非单一语言**，C++主要由4个次语言组成：

-   C。C++本质上还是以C为基础，区块（blocks）、语句（statements）、预处理器（preprocessor）、内置数据类型（built-in data types）、数组（arrays）、指针（pointers）等统统来自C。C的局限：没有模版、异常和重载（overloading）......
-   Object-Oriented C++。这部分也就是C with Class所诉求的：classes，封装（encapsulation)、继承（inheritance）、多态（polymorphism）、virtual函数（动态绑定）。
-   Template C++。这是C++的泛型编程（generic programming）部分。templates威力强大，它们带来的所谓模版元编程是一种崭新的编程泛型。
-   STL。STL是一个标准模版库。它有六大组件：容器、迭代器、算法、分配器、适配器、函数对象组成。



当你从某个次语言切换到另一个，可能编码规范是不同的。例如，对于内置类型（使用C）而言，传值比传引用高效，但是使用Object-Oriented C++的时候，对于自定义类，传const引用往往更好。但是STL又不一样，迭代器和函数对象都是在C指针之上塑造，所以对于STL的迭代器和函数对象而言，传值更合适。

>   传引用本质上也是传指针，甚至比传指针效率要低，迭代器和函数对象本质上就是指针，所以传值更合适。

>   所以请记住：
>
>   C++高效编程守则视状况而变化，取决于你使用C++的哪一部分。



### 条款02: 尽量以`const`,`enum`,`inline`替换`#define`

 `#define`不被视为语言的一部分，它是预处理器处理的。所以这个条款也可以称为「宁可以编译器替换预处理器」。



**用常量代替宏**

```cpp
#define PI 3.14//宏一般全大写
const double Pi = 3.14; //一般常量首字母大写
```

预处理器「盲目地将宏名称`PI`替换为`3.14`，可能导致目标码出现多份`3.14`，该用常量不会出现这种情况」。

用常量替换宏，有两个特殊情况：

1.   如果定义一个C风格的常量字符串，需要写`const`两次：`const char * const name = "SWH"`。但事实上建议使用`string`：`const string name = "SWH"`
2.   对于class专属常量，需要把常量的作用域限制在class内，所以它得是class的一个成员；同时**为了保证此常量只有一份，它还必须是`static`成员

```cpp
/*  
 *  Description : 
 *  Created by 旋风冲锋龙卷风 on 2023/01/31 22:17
 *  个人博客 : http://letsgofun.cn/
 */
//

#include <iostream>

using namespace std;

class GamePlayer
{
public:
    static const int NumTurns; //声明,定义和初始化在类外
    static const int C = 3; //声明,且没有定义,初始化再类内
	constexpr static const double d_B = 3.13; //
    static int B;
};
int GamePlayer::B = 1;
const int GamePlayer::NumTurns = 3; //定义

void test01()
{
    // const int* p = &(GamePlayer().NumTurns);
    // cout << *p << endl;
    cout << GamePlayer::NumTurns << endl;
    GamePlayer g;
}
int main()
{
    test01();
    return EXIT_SUCCESS;
}
```

注意，上面的`NumTurns`和`C`都是声明式而非定义式。真正的定义式在类外。通常C++要求对使用的任何东西都提供一个定义，但是如果它是一个「class专属常量由是static且为整数类型」，则需要特殊处理，只要不取它的地址，就可以只声明而不定义。但是如果要取某个「class专属常量」的地址，则必须使用提供额外的定义（上面的代码给出了类外的定义），如果在类内声明时给定了初始值，则在类外定义的时候不要再给初值（初始值只能给一次）。

还有一个细节，如果在类内初始化一个static const非整数类型，例如double，需要加`constexpr`关键字。

「In-class initializer for static data member of type 'const double' requires 'constexpr' specifier」

![类的静态成员4](https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/%E7%B1%BB%E7%9A%84%E9%9D%99%E6%80%81%E6%88%90%E5%91%984.svg)



>   无法使用`#define`创建一个class专属常量（成员），因为`#define`不重视作用域，除非`#undef`，它没有封装性。但是const成员变量可以被封装。



需要注意的是，按照上面的图，普通的static 数据成员（非const）不能用来定义类内的数组大小。其实这个问题的本质是，编译器在编译的时候，没有看到数组的大小，所以如果是在类内初始化的const static int可以用来定义数组大小，而类外初始化的const static int无法定义数组大小。

所以普通的非const的 static数据成员无法定义类内数组大小，因为普通的非const 的static数据成员是禁止在类内初始化。

所以在这里，可以使用「the enum hack」来解决这个问题。



```cpp
class C
{
private:
    enum {NumTurns = 4};
    int c[NumTurns];
};
```

**如果为枚举符号赋值，则它们必须是整数。**

枚举的定义：

```
enum <类型名> {<枚举常量表>};
```

the enum hack省略了类型名，它的好处：

1.   它的行为更像`#define`而不是类内`const`，它不能被指针或者引用来refer to，但是他又有封装特性。
2.   使用enum hack不会导致“不必要的内存分配”
3.   它是模版元编程的基本技术



**不要使用宏函数**

```cpp
#define CALL_WITH_MAX(a, b) f((a) > (b) ? (a) : (b))
//尽管已经加了很多小括号
```

如果使用：

```cpp
CALL_WITH_MAX(++a, b);
```

a可能被++两次！

所以，用`inline`代替宏函数。



### 条款03：尽可能使用`const`

`const`是非常神奇的东西，它可以修饰很多东西，还有顶层`const`和底层`const`之分，关于这一点可以看《C++Primer》P53。

但是需要注意，下面的类型是一样的：

```cpp
const Person* p;
Person const *p;//底层const的另一种写法
```

>   这个第二种方法属实是有点少见，第一眼我还以为是顶层`const`，但是只要`const`在`*`左边就都是底层`const`。



 STL中的`const_iterator`是底层`const`，不能改变迭代器指向的值，但是可以改自身，如果希望迭代器所指向的东西不被改变，可以：

```cpp
const vector<int>::iterator it = v.begin();
```



`const`可以和函数声明产生非常多的应用，`const`可以和函数返回值、各参数、函数自身（仅限于成员函数）产生关联。



**函数值返回`const`**

```cpp
class A
{

};

const A operator*(const A& lhs, const A& rhs)
{
    return lhs;
}
```



可以防止：

```cpp
A a, b ,c;
(a * b) = c; //因为const不能被修改，所以会报错
```



#### `const`成员函数

1.   保证该成员函数不会修改对象的内容
2.   `const`的对象可以调用`const`成员函数，但是不能调用「非`const`成员函数」



首先，学过C++的都知道，每个成员函数都会隐式传递一个`this`指针指向调用这个函数的对象，<mark>`this`指针是一个顶层`const`的指针</mark>，它不能修改指向，但是可以修改内容。`const`成员函数的`const`就是修饰`this`的，相当于给`this`指针加了底层`const`，不能修改对象的内容了。



```cpp

class TextBlock
{
public:
    TextBlock(const string &text) : text(text)
    {}

    char& operator[](size_t pos)
    {
        return text[pos];
    }

    const char& operator[](size_t pos) const
    {
        return text[pos];
    }
private:
    string text;
};

void test02()
{
    TextBlock tb("hello");
    cout << tb[0] << endl; //调用普通版本的[]
    tb[0] = 'r'; //可以写
    

    const TextBlock ctb("hello"); 
    cout << ctb[0] << endl; //调用const版本的[]
    // ctb[0] = 'x'; //错误!, 不能写
}
```



上面的`non-const`的函数能作为左值的原因是它返回的是「引用」：《C++ Primer》P202：“只有调用一个「返回引用」的函数得到左值，其余得到右值，我们可以为返回类型是「非常量引用」的函数的结果赋值。”如果返回的是值（by value），则是`text[0]`的副本，赋值没有任何意义，也会报错。



>   不由得让我有了疑问：
>
>   如果一个对象是`const`的，那么它的成员是`const`的吗？
>
>   ~~答案应该是肯定的，因为上面 `const`版本的`operator[]`重载返回的就是`const char`。~~
>
>   这个问题把我绕进去了，写了很多测试代码。我的理解是，如果一个对象是`const`的，那么它的所有成员变量也是「顶层`const`」的。



#### bitwise constness 和 logical constness

bitwise constness阵营属于原教旨主义派，不修改对象成员中任何一个bit。

其实是可以使用`const`成员函数，修改对象中的内容的：

```cpp
class CTextBlock
{
public:
    //没有改变成员变量的值, const函数返回了非const的引用
    //注意这里只有C字符串能这样操作, string是不可以值,只能返回const引用
    char& operator[](std::size_t position)const {
        return pText[position];
    }
private:
    char *pText;
public:
    CTextBlock(char *pText) : pText(pText)
    {}
};

void test05()
{
    const CTextBlock ctb("Hello");
    char *pc = &ctb[0];//调用[]取得一个普通指针
    *pc = 'J'; //修改const对象的内容
}
```

上面的例子竟然真的修改了，我还测试了`int`类型数组，发现也可以这样操作，但是`string`是不可以的。

>   `const`成员函数居然返回了非`const`的引用！事实上，书中指出这种操作是不合适的，还是应该返回`const`引用。
>
>   对于这段，我的理解是，如果一个对象是`const`的，那么它的所有成员变量也是「顶层`const`」的，所以，pText就是`char * const`，`pText`的指针不能变，但是指针指向的内容可以修改，也就是上图。



所以logical constness的拥护者就有话说了：「你既然这么想修改`const`对象的内容，那就修改好了！」

C++推出了 `mutable`关键字，使得被`mutable`关键字修饰的成员变量在`const`函数中也能被修改。



#### 在`const`和`non-const`成员函数中避免重复

就是，如果`non-const`成员函数和`const`成员函数的功能相同，可以用`const`成员函数调用`non-const`成员函数来减少代码量。

```cpp
    char& operator[](size_t pos)
    {
        //下面两个是一样的
        //第一个return更为简洁
        return const_cast<char&>(static_cast<const TextBlock&>(*this)[pos]);
        //第二个return需要知道this是TextBlock* const类型的指针
        //return const_cast<char&> (static_cast<const TextBlock *const>(this)->operator[](pos));
    }

    const char& operator[](size_t pos) const
    {
        //边界判断
        //其他代码等
        //...
        return text[pos];
    }
```



上面进行了两次转换，`static_cast<>`为`*this`添加底层`const`，`const_cast<>`为`const operator[]`的返回值移除底层`const`。

需要注意：一定不能让`const`成员函数调用`non-const`成员函数，因为后者可能会修改内容。



>   **总结：**
>
>   -   将某些东西声明为`const`可以帮助编译器帧测出错误用法。`const`可以被用在任何作用域中的对象、函数参数、函数返回类型、成员函数本体。
>   -   编译器强制实施`bitwise constness`，但是自己编写程序应该使用「概念上的常量性」
>   -   当`const`和`non-const`成员函数有着实质等价的实现时，令`non-const`版本调用`const`版本可以避免代码重复。



### 条款04：确定对象被使用前已先被初始化



#### 对内置类型手动初始化

在C++中，写下：

```cpp
int x;
```

在某些语境下`x`保证初始化（为0），但在其他语境下并不保证。

```cpp
class Point
{
    int x, y;
}
Point p;
```

`p`的成员变量有时候被初始化（为0），有时候不会。

读取未初始化的值会导致不明确的行为，在某些平台上甚至会终止程序运行，也有可能读入一些「半随机」bits，污染正在进行读取动作的对象。



「对象的初始化动作什么时候一定发生，什么时候不一定发生」是一个很复杂的规则，最好的方法就是，**永远在使用对象之前将它初始化，对于 「无任何成员的内置类型」，必须手工初始化**。例如：

```cpp
void test01()
{
    int x = 0;
    const char* text = "A C-style string"; //对指针进行手工初始化

    double d;
    cin >> d; //以读取 inputstream的方式完成初始化
}
```

值得注意的是，对于`d`，初始化是用输入流完成的。数组需要初始化。



#### 成员初始化列表

**对于内置类型以外的任何其他东西，初始化的责任由构造函数（constructors）承担**。这个规则很简单，但是需要区分「赋值（assignment）」和「初始化（initialization）」的区别。

```cpp
class Person
{
public:
    Person(const string &name, const string &addr, const vector<int>& IPs)
    {
        age = 0;
        this->name = name;
        this->addr = addr;
        this->IPs = IPs;
    }

private:
    int age;
    string name;
    string addr;
    vector<int> IPs;
};
```

C++规定，对象的成员变量的初始化动作发生在进入构造函数本体之前。所以上面的构造函数中，`name`, `addr`, `IPs`都是赋值，初始化的发生时间更早，发生与这些成员的「默认构造函数」**被自动调用之时**。但是这对内置类型无效，在这个赋值操作之前，它不一定被初始化并获取初值。所以作者将这种初始化称之为「伪初始化」（pseudo-initialization）。

>   所以上述代码的调用顺序：
>
>   -   先递归调用成员的默认构造函数（如果成员也包含子成员的话就递归调用，先调用最内层的默认构造函数）
>   -   再进行`Person`构造函数中的赋值操作



所以推荐使用**成员初始化列表**（member initialization）替换构造函数中的赋值操作。虽然在上述例子中结果相同，但是效率会更高。

```cpp
Person(int age, const string &name, const string &addr, const vector<int> &iPs) : age(age), name(name), addr(addr),IPs(iPs)
{

}
```

它的用传入的实参，调用拷贝构造函数，通常比「默认构造+拷贝赋值」效率更高。

如果想调用成员的默认构造函数，可以在初始化列表的`()`中不填写内容，但是对于内置数据类型还是要写上具体的数值显式初始化。

```cpp
Person() : age(0), name(), addr(), IPs()
{}
```



作者的建议是：

「总是在初始值列表中列出所有成员变量」。这样可以避免遗忘「内置数据类型」必须显示初始化。

>   这不由得让我想到一个问题，如果某个类中存在数组成员，如何给使用初始化列表给数组初始化？
>
>   需要注意的是：
>
>   -   不能用直接用指针给数组赋值或初始化
>   -   数组的初始化是`{}`
>
>   那么问题就解决了，初始化列表初始化数组时：
>
>   -   用`{}`代替`()`
>   -   不能使用变量初始化，只能显示指定初始值。



同时如果成员变量是`const`或者`reference`，那么它们必须要初值（初始化），不能被赋值。所以初始化列表还是很有必要的。



#### 成员初始化顺序

C++有着十分固定的「成员初始化顺序」。

-   父类比子类初始化早
-   类内成员变量总是**以其声明次序初始化**

```cpp
class A
{
public:
    int a;
    int b;
public:
    A(int val) : b(val), a(b)
    {}
};

void test03()
{
    A a(1);
    cout << a.a << endl; // 0
    cout << a.b << endl; // 1
}
```

哪怕写成` A(int val) : b(val), a(b)`，也是先初始化`a`，再初始化b。这时例子中a和b不相等。所以初始化成员列表的值要和声明的顺序一致。



#### 跨编译单元的初始化顺序

「不同编译单元内定义之`non-local static对象`的初始化顺序」

>   所谓`static`对象，并不是加了`static`修饰的对象，而是寿命从被构造出来直到程序结束为止的对象。所以stack和heap-based对象都被排除，`static`对象包括：
>
>   -   全局对象
>   -   定义于`namespace`作用域的对象
>   -   在类内、函数内、file作用域内被声明为`static`的对象
>       -   函数内的`static`对象是`local static`对象（它们对于函数而言是local）
>       -   其他`static`对象是`non-local`对象。
>
>   程序结束（`main()`函数结束）时，`static`对象会被自动销毁（调用析构函数）。

关于各种作用域，可以看这个[链接](https://zh.m.wikibooks.org/zh-hans/C%2B%2B/作用域)

所谓「编译单元」（transation unit）是指产出单一目标文件的源代码，基本上可以认为是单一源码文件加上其所含入的头文件。



真正问题就是：如果某个编译单元内的某个 `non-local static`对象的初始化动作使用了另一个编译单元内某个`non-local static`对象，而后者可能尚未初始化，因为C++没有明确规定它们的初始化顺序。



C++保证，函数内的`local static`对象会在「该函数被调用期间」首次遇上改对象定义式的时候被初始化。所以我们可以使用「函数调用返回一个引用指向`local static`对象」来解决这个问题。这也是单例模式的一个实现手法。如果从未调用这个函数，就不会引发构造和析构。



但是对于多线程环境，就有点麻烦。



>   总结：
>
>   -   为内置类型对象手工初始化，因为C++不保证初始化它们。
>   -   构造函数最好使用初始化列表，初始化列表中的成员变量，排列顺序和类内的声明顺序相同。
>   -   用`local static`对象替换`non-local static`对象。



## 2. 构造/析构/赋值运算

### 条款05：了解C++默默编写并调用哪些函数

