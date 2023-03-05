1.   bashrc是在系统启动后就会自动运行。
2.   profile是在用户登录后才会运行。
3.   进行设置后，可运用source bashrc命令更新bashrc，也可运用source profile命令更新profile。
4.   一般修改bashrc，有的linux版本可能没有profile这个文件
5.   `/etc/bashrc`和`/etc/profile`适用于所有用户，单个用户的bashrc和profile在`~/`目录下。
6.   别名命令放到`/etc/bashrc`中