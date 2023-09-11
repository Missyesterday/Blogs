# lsof 命令

是 list opened filedesciptor，列出打开的文件描述符。在 Linux 系统重，所有与资源句柄相关的东西都可以统一抽象成「**文件描述符**」（filedescriptor，简称 fd）。一个文件句柄是一个 fd，一个 socket 也是 fd。

```bash
lsof -iPn
```



