# CPP

博客都是基于`Clang`\+`LLDB`的配置。

> 为什么不使用`gcc`\+`gdb`？
>
> 因为M1芯片只能安装arm版本的gcc，不能安装arm版本的gdb。

如果使用`gcc`\+`LLDB`的配置，会出现一些问题，例如在导入`iostream`时：

切换为`clang`\+`LLDB`则Error消失。

其实这个应该与LLDB和GDB无关，应该是GCC的版本引起的。

## \-[01C++基础](01C++%E5%9F%BA%E7%A1%80.md)