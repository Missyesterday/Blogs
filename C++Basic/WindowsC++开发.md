# WindowsC++开发

## 1. 获取某个文件夹下所有文件，并获取权限

>   第一个需求（严格意义上来说也不是需求，练练手），就直接面向需求写代码了。



```cpp
#include <io.h>
int access(const char* filename, int mode);
```

### `_finddata_t`结构体和`_findfirst()`函数

```cpp
struct _finddata_t {
    unsigned    attrib;
    time_t      time_create;   
    time_t      time_access;   
    time_t      time_write;
    _fsize_t    size;
    char        name[260];
};
long _findfirst(const char*, struct _finddata_t*);
int _findnext(long, struct _finddata_t*);
```

`_findfirst`函数：

-   第一个参数为文件名，可以用通配符来匹配。
-   第二个参数为结构体`_finddata_t`，里面有几个成员：
    -   `atttrib`文件属性，一般是宏，如`_A_ARCH`存档、`_A_RDONLY`只读、`_A_SUBDIR`文件夹等。如果判断一个文件是否有这个属性用`&`来判断，增加则用`|`，删除用`& ~xxx`（个人猜想）
    -   中间三个分别代表「创建时间」、「最近一次访问时间」和「最后被修改的时间」
    -   `_fsize_t`文件大小
    -   `name`文件名儿
-   返回值，成功返回「匹配到的所有文件句柄（文件描述符？）」，失败返回-1。其中传入参数`_finddata_t`会返回第一个匹配到的文件

`_findnext()`函数：

-   第一个参数为`long`，其实就是`_findfirst()`的返回值
-   第二个参数为`_finddata_t`类型，这是一个传入参数，传出的是传入文件的下一个文件
-   返回值：成功返回0，失败返回`-1`，所以用这个来判断是否查找成功




```cpp

_finddata_t file;
long lf;
//输入文件夹路径
if ((lf=_findfirst(cate_dir.c_str(), &file)) == -1) {
    cout<<cate_dir<<" not found!!!"<<endl;
} else {
    while(_findnext(lf, &file) == 0) {
        //输出文件名
        //cout<<file.name<<endl;
        if (strcmp(file.name, ".") == 0 || strcmp(file.name, "..") == 0)
            continue;
        files.push_back(file.name);
    }
}
_findclose(lf);
```



##  2. 显式并修改某个文件的ACL

>   需求：
>
>   1.   显示某个文件的ACL的所有ACE，并显示继承关系
>   2.   支持修改某个文件的ACE

>   看到需求后，动手的时候存在一些模糊的问题：
>
>   1.   继承关系显示一层，还是树形显示到顶？

### 2.1 虚拟机的三种模式

-   还原模式

    类似于网吧，每次关机都会抹去用户的数据，但是机器固定（用户每一次都是同一台机器）

-   专有模式

    用户的机器固定，但是可以保存用户的数据

-   池模式

    使用模式类似于还原模式，不会保留用户的数据，但是机器不固定（引入了池的概念）


目前问题在于，使用「池模式」，不同用户的权限可能不同，但是池模式中所有机器的状态是固定的，需要修改文件（注册表）的权限。



### 2.2 理论和术语

在Windows下的对象，不一定是文件，进程、命名管道、打印机、网络共享、或是注册表等等，都可以是对象，并且都可以设置用户访问权限，并用一个「安全描述符」（Security Descriptor）来保存权限设置信息，简称SD，这是一个结构体：

```cpp
typedef struct _SECURITY_DESCRIPTOR {
  BYTE                        Revision;
  BYTE                        Sbz1;
  SECURITY_DESCRIPTOR_CONTROL Control;
  PSID                        Owner;
  PSID                        Group;
  PACL                        Sacl;
  PACL                        Dacl;
} SECURITY_DESCRIPTOR, *PISECURITY_DESCRIPTOR;
```

-   `Owner`：所有者的安全描述符（SID）
-   `GROUP`：对象所在的组（SID）
-   `DACL`：Discretionary Access Control List，指出了「允许或拒绝」「某用户或用户组」的存取控制「列表」，当一个进程需要访问「安全对象」，系统就会检查DACL来决定进程的访问权限。如果这个「安全对象」没有DACL，那么就是说这个对象是「任何人都可以拥有**完全的访问权限**」。
-   `SACL`：System Access Control List，指出在该对象上的一组存取方式（如读写运行等）的存取控制权限细节的列表，，也就是控制对「对象的某个属性的访问日志的**记录**」与否。
-   还有其自身的一些控制位。所以使用`GetFileSecurity()`函数



SID：SID也就是安全标识符（Security Identifiers），是标识用户、组和计算机帐户的唯一的号码。

ACL：Access Control List，访问控制列表，由DACL和SACL组成，ACL中的每一项，被称为ACE（Access Control Entry）。

每个ACE显示的是一个SID对这个对象拥有什么权限，同时ACE还有继承关系。

程序不用维护SD结构体，这个由系统维护。可以使用API来**获取并设置**SD中的信息。

「安全对象」指的是拥有SD的Windows对象，所有的被命名的Windows的对象都是安全对象，一些没有命名的对象是安全对象，如：进程和线程，也有安全描述符SD。在很多创建安全对象的操作中，都需要传递一个SD参数，如`CreateFile()`和`CreateProcess()`函数。`GetNamedSecurityInfo, SetNamedSecurityInfo，GetSecurityInfo, SetSecurityInfo`等函数可以获取对象上的安全设置，或者修改对象上的安全设置。



### 2.3 增加权限

**为文件夹（目录）增加一个AllowedACE**

1.   通过用户名取得SID
2.   获得某个文件（目录）相关的安全描述符SD，使用`GetFileSecurity()`函数
3.   初始化一个新的SD
4.   从`GetFileSecurity()`返回的SD中取DACL
5.   获得DACL的内存大小，根据旧的DACL的大小加上一个ACE的大小，再加上一个SID的大小，最后减去两个字节
6.   为新的ACL分配内存并初始化新ACL的结构
7.   拷贝旧的ACE到新的DACL中
     1.   这一步需要检查是否是「非继承的ACE」
     2.   如果当前要复制的ACE是否是从父目录中继承而来，那么我们要添加的ACE应该在已有的非继承的ACE之后，和所有的继承ACE之前。因为NTFS文件权限**对于NTFS文件夹权限具有优先权，当用户或组对某个文件夹以及该文件夹下的文件有不同的访问权限时，用户对文件的最终权限是用户被赋予访问该文件的权限**。类似于泛化和特化。
     3.   还需要检查要拷贝的ACE的SID和需要加入的ACE的SID相同，一个用户在只能有一个ACE，如果有，我们覆盖掉它，<u>所以，增加ACE其实隐含了一个覆盖操作。</u>
8.   退出循环的时候，代表已经遍历到分界线了，把要增加的ACE添加到这个地方，然后继续把继承的ACE复制到后面：
     1.   首先需要清楚，前面的循环拷贝了所有的非继承且SID为其他用户的ACE
     2.   加入增加的ACE，这里又有两个函数可以做这个操作：
          1.   `AddAccessAllowedAce()`和`AddAccessAllowedAceEx()`函数，后者可以设置一个`ACE_HEADER`的结构这个结构可以定制是否允许这个ACE被子目录继承

9.   拷贝从父目录继承而来的ACE
10.   把新的ACL设置到新的SD中，把老的SD中的控制标记拷贝到新的SD中
11.   调用`SetFileSecurity()`把新的SD设置设置到文件的安全属性中



1.   如果要加入一个Access-Denied 的ACE，可以使用AddAccessDeniedAce函数
2.   如果要删除一个ACE，可以使用DeleteAce函数
3.   `AddAccessAllowedAceEx()`之类的添加ACE的函数，**会把要添加的ACE添加到DACL的末尾，这点非常重要**，而`AddAce()`函数则需要指定「添加的位置」。
4.   `SetEntriesInAcl()`能完成类似于`AddAccessAllowedAceEx()`的功能，这个函数将任何新的访问被拒绝的 ACE 放置在新 ACL 列表的开头。 此函数将任何新的允许访问的 ACE 置于任何现有访问允许的 ACE 之前。`SetEntriesInAcl()`函数使用`EXPLICIT_ACCESS`结构体，这个结构体可以为多个ACE提供简单的方式来设置访问控制，



>   所以，增加ACE其实隐含了覆盖操作。

**增加一个Denied-ACE**

逻辑大体上相似，但是Denied-ACE是插入在ACL最开头，并且不会覆盖原有的相同SID的ACE。所以如果添加两个一样权限的ACE，只有「allow 或 deny」不同的时候，如果先添加的是allow，则会出现「允许和拒绝」并存的情况，但是拒绝会在前面。



>   需要注意的是
>
>   GENERIC_READ权限在添加时，会转换为下面的权限：
>
>   -   READ_CONTROL
>   -   FILE_READ_DATA
>   -   FILE_READ_ATTRIBUTES
>   -   FILE_READ_EA
>   -   SYNCHRONIZE

可参见[https://learn.microsoft.com/zh-cn/windows/win32/api/winnt/ns-winnt-generic_mapping](https://learn.microsoft.com/zh-cn/windows/win32/api/winnt/ns-winnt-generic_mapping)，没有中文版，只有英文版。

### 2.4 查看所有的ACE

DACE中有不同类型的ACE，

```cpp

```

ACCESS_ALLOWED_ACE是Windows安全描述符中的一种类型，它定义了允许某个用户或组访问资源的权限。Mask是ACCESS_ALLOWED_ACE结构中的一个字段，它指定了允许的权限掩码，即允许哪些权限。以下是ACCESS_ALLOWED_ACE可能的Mask取值和它们的含义：

-   DELETE：允许删除对象或文件。
-   READ_CONTROL：允许读取对象的安全描述符。
-   WRITE_DAC：允许修改对象的安全描述符。
-   WRITE_OWNER：允许修改对象的所有者。
-   SYNCHRONIZE：允许等待对象句柄的同步操作。
-   STANDARD_RIGHTS_REQUIRED：需要为所有对象类型指定的标准权限。
-   STANDARD_RIGHTS_READ：允许读取对象的标准权限。
-   STANDARD_RIGHTS_WRITE：允许写入对象的标准权限。
-   STANDARD_RIGHTS_EXECUTE：允许执行对象的标准权限。
-   SPECIFIC_RIGHTS_ALL：所有指定的访问权限。
-   ACCESS_SYSTEM_SECURITY：允许读取或修改对象的系统安全性。
-   MAXIMUM_ALLOWED：允许请求的最大权限。
-   GENERIC_READ：允许读取对象的特定权限。
-   GENERIC_WRITE：允许写入对象的特定权限。
-   GENERIC_EXECUTE：允许执行对象的特定权限。
-   GENERIC_ALL：允许读取、写入和执行对象的特定权限。

以上是ACCESS_ALLOWED_ACE的可能Mask取值。在实际使用中，需要根据需要选择合适的权限掩码。



ACCESS_ALLOWED_ACE中可能的Flags取值

-   CONTAINER_INHERIT_ACE：允许ACE在容器对象上继承。
-   FAILED_ACCESS_ACE_FLAG：指定ACE记录了一个失败的访问尝试，即这个ACE规定的权限被拒绝了。
-   INHERIT_ONLY_ACE：指定ACE只能在子对象中继承，而不能在目标对象上应用。
-   INHERITED_ACE：指定ACE已经从父对象继承，而不是直接应用于目标对象。
-   NO_PROPAGATE_INHERIT_ACE：指定ACE不会在子对象上继续继承。
-   OBJECT_INHERIT_ACE：允许ACE在非容器对象上继承。



### 2.5 删除ACE

根据SID删除ACL中的ACE（包括Allowed和Denied）。

逻辑就是：把原来的ACL中的ACE复制到新的ACL中，遇到SID与指定要删除的SID 相同的 ACE，就跳过。



### 2.6 优化代码

1.   命名优化（匈牙利命名法）
2.   避免内存泄漏（使用`goto`语句）
3.   写好接口说明



## 3. 虚拟桌面管理

核心：UPM+软件分发

### 3.1 虚拟机类型

虚拟机有「专用模式」和「还原模式」，后者还有一个「池模式」。还原模式可以选择「用户盘」，可以对数据（桌面、我的文档）重定向到用户盘中。

所谓UPM，就是用户配置管理，对于还原模式，用户希望保留一部分数据，例如浏览器的浏览记录、桌面、输入法的个人词库等。

目前测试，这个功能只对还原模式（非池）有效。实现就是在登陆后，进入桌面前，对登陆做一个拦截，把用户个人盘的数据导入（重定向）到虚拟机的盘上，这样用户是无感的（个人猜测）。

开启个人盘之后，桌面上的新建文件还在；图标位置回到了初始位置；Chrome的书签不在了，同时设置的默认浏览器为chrome没有保留，但是chrome的用户浏览记录在。

原来Chrome是配置项中的一项，所以为什么历史记录在呢？

还原模式默认将桌面和我的文档重定向到个人盘，其余的系统盘中的用户配置可以手动在「策略组」中配置。



### 3.2 重定向

所谓重定向，就是用户绑定一个个人盘（这是先觉条件），相当于用户自己的个人空间。系统盘在还原模式下不会保留数据，但是有很多用户配置项需要保留（桌面，下载，书签等等），需要把这些系统盘中的用户数据重定向到个人盘（D盘）。

对于「桌面」和「我的文档」采用注册表的方式重定向，直接打开「属性」观察发现这两个文件夹就在D盘下。而对于其他的自定义目录，就需要在更底层实现了，打开「属性」观察这些重定向的文件还是在C盘中，但是实际上是在D盘下，有点链接，但是不是链接，链接是有链接属性的，但是这个没有，从任何角度看这个文件夹都是在C盘，但是打开D盘某个文件夹，发现实际上文件是在D盘。



### 3.3 用户配置文件

在Windows中，用户配置指的是「存储在当前用户文件夹中」的「个人文件和设置」。这些个人文件包括 文档、图片、音乐、视频、桌面、下载和其他文件夹，以及 应用程序数据、配置和其他设置。

-   `%userprofile%`：当前用户的用户文件夹路径，也被称为「用户配置文件夹」，一般为`C:\Users\用户名`（Windows Vista、7、8、10）
-   `%appdata%`：当前用户的应用程序数据文件夹路径，里面有应用程序的数据文件和设置，配置文件、缓存、日志等。一般为`C:\Users\用户名\AppData\Roaming`
-   `local

## 4. 组

组分为「通讯组」和「安全组」，下面只谈「安全组」。

安全组根据**作用范围**分为：

-   全局组（Global group）
-   通用组（Universal group）
-   域本地组（Domain Local group)



组的类型由属性「groupType」决定。

>   现在最大
