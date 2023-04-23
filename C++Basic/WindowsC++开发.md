# WindowsC++开发

## 第一个需求，获取某个文件夹下所有文件，并获取权限

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



### 文件、文件夹和注册表

Windows有一个注册表的概念，注册表是一个
