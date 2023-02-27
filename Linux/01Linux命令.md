## 1.文件处理命令

-   . 代表当前目录&#x20;

<!---->

-   ls -a -l -d（当前目录） -h -i(查看文件的i节点，数字）&#x20;

-   查看list&#x20;

-   mkdir -p 创建目录&#x20;

-   cd  pwd(print woking dir)&#x20;

-   rmdir（remove dir) 删除空目录&#x20;

-   cp(copy)  -r 赋值路径 -p 保留文件属性\[原]\[目标]&#x20;

-   mv(move)  剪切、改名

-   &#x20;rm -r 删除目录	-f 强制执行&#x20;

-   touch 创建文件，不建议创建带空格的文件名&#x20;

-   cat 显示文件内容 -n 显示行号  -A显示所有隐藏字符

-   tac 反向显示

-   more 分页显示文件内容  按f或空格翻页，q退出，但是不能往上翻页 less  和more类似，不过可以往上翻页以及搜索（使用“/关键词”，按n显示下一个匹配的关键字）&#x20;

-   head -n 指定行数 （显示文件的前面几行 ，默认显示前10行）&#x20;

-   tail 格式与head类似，显示文件的最后几行 -f (动态显示，如登陆信息）

-   &#x20;ln(link)	ln  \[源文件] \[目标文件] -s (软链接）

    > &#x20;软链接类似与快捷方式，便于管理&#x20;
    >
    > ![](https://github.com/Missyesterday/Picture/blob/main/e0592b82-b274-4854-8a9b-f76d92e60792.png?raw=true) 文件类型为l（软链接类型）任何用户(所有者，所属组，其他人 UGO）都有全部rwx权限 ,指向原文件来执行,所以软链接权限由原文件来决定 只有10个字节，有箭头指向原文件。 硬链接与原文件一样，与cp命令区别：硬链接和原文件能同步更新，原文件丢失也能访问 ![](https://github.com/Missyesterday/Picture/blob/main/263a49d4-db57-4483-8864-8eaeddbb9ecd.png?raw=true)
    > ![](https://github.com/Missyesterday/Picture/blob/main/e7af55b2-f814-446c-8f7e-e0abbe1b5ff2.png?raw=true)
    > 红色代表丢失
    > 硬链接和原文件的i节点一样，所以能同步更新（可以实时备份，不能跨分区，不能将硬链接指向目录）

## 2.权限管理命令

-   chmod （change mode)  chmod \[{ugoa}{+-=}{rwx}] \[文件或目录]  (同时操作多个成员时用逗号隔开）-R 递归修改（改变目录权限的同时修改目录下所有子目录的权限） 只有root和所有者能改

-   chmod \[mode = 421]\[文件或目录]  （532 ： r-x-wx-w-) <img src="https://github.com/Missyesterday/Picture/blob/main/fd23d7a0-cc6c-418d-ab2f-440762b76fd9.png?raw=true" style="zoom:40%;" />
    对文件删除需要它上一级目录的写权限（对目录的r权限和x权限一般同时存在）

-   chown \[用户]\[文件或目录] 改变文件或目录的所有者（root only）

-   &#x20;chgrp \[所属组]\[文件或目录] 改变所属组&#x20;

-   umask -S  显示、设置文件的缺省权限，Linux默认新建文件不具有可执行权限 umask 显示权限数字 4位 第一位是特殊权限  后三位需要用7相减才能得到真正的权限 也可以修改默认权限

## 3.文件搜索命令

### **find \[搜索范围]\[匹配条件]**&#x20;

-   \-name 根据文件名来搜索 严格区分大小写&#x20;

-   \-iname 不区分大小写

-   &#x20;\-size 指定文件大小 +n 大于 -n小于 n等于 单位是数据块，一个数据块512字节 0.5K 100M = 204800数据块&#x20;

-   \-group 根据所属组来查找 \\

-   下面三个是按照修改时间来查找文件 +代表超过多少时间 -代表多少时间内 单位是分钟

    1.  \-amin 访问时间

    2.  \-cmin 文件属性（ls -l看到的信息）

    3.  \-mmin 文件内容

-   \-a 代表两个条件同时满足

-   \-o 满足一个就行

-   \-type 根据文件类型查找 f文件 d目录 l软链接

-   \-exec/-ok 命令{} ;**{}后有空格**

-   \-ok每次执行前都要询问

-   &#x20;\-inumber 根据i节点序号来删除（用来删除奇怪的文件 ls -i来查询i节点）

> 正则表达式
> \*匹配任意字符
> ？匹配单个字符

### **locate 在文件资料库中查找文件**

locate 文件名 （在文件资料库中查找文件） updatedb手动更新。不能实时查找 一般查找系统文件用locate -i 不区分大小写

### **which 搜索命令所在的目录及别名信息**

还可以得到命令的别名（看有没有默认加 -i不区分大小写）

### **whereis 还可以得到帮助文档和配置文件**

### **grep \[指定字串]\[文件]**

\-i 不区分大小写
\-v 排除指定字串（反向查找）

> grep -v ^# /etc/inittab      ^代表开始（因为注释不一定写在开头） 以#开始的行代表脚本或配置文件的注释

## 4.帮助命令

### **man \[命令或配置文件]**

-   原意：manual（手册）

-   与more/less命令类似 能用“/+关键字”来搜索关键字

-   **用man查看配置文件的时候只需要文件名不需要路径**

> man可以看配置文件的格式和存放信息
> ![](https://github.com/Missyesterday/Picture/blob/main/611a7b98-36ce-4832-804e-e77381a63018.png?raw=true)
> 1:网络服务名称 2:端口/传输协议 3.别名
> ![](https://github.com/Missyesterday/Picture/blob/main/d51f4534-2bc7-4431-abb2-93a08c418099.png?raw=true)
> 帮助类型有两种:
>
> 1.  man1是命令的帮助
>
> 2.  man5是配置文件的帮助
>
> 例如对于passwd 可以man 1或者man 5（记得空格）

### **whatis**

可以只查看命令的简短信息

### **apropos**

可以只查看配置文件的简短信息

-   **--how选项可以查看该命令的简短选项‘**

-   **info命令也可以查看帮助**

### **help查看shell内置命令（找不到路径的命令 which找不到）**

help甚至能找if while

## 5.用户管理命令

### **useradd**

添加新用户

### **passwd 用户名**

设置密码

### **who 查看当前在线用户**

> 信息含义
> ![](https://github.com/Missyesterday/Picture/blob/main/21636fde-084b-4d76-b698-b2f641a508fc.png?raw=true)
> 登陆用户名  登陆终端：tty本地终端 pts远程终端    登陆时间 登陆主机的ip地址

### **w 可以得到更为详细的在线用户信息（资源使用情况）**

> 举例
> ![](https://github.com/Missyesterday/Picture/blob/main/79c2cbb3-d3c2-4f3d-97a3-f0a6293d859c.png?raw=true)
> 第一行代表运行了多久
> IDLE代表空闲多久（什么都没干） PCPU（占用cup时间） WHAT（在干嘛） JCPU（累计占用CPU时间）

## 6.压缩解压命令

### **gzip**

文件格式：.gz
解压缩：gunzip 或 gzip -d

> **注意：gzip只能压缩文件，并且压缩完不会保留原文件**

### **tar \[打包后名称]\[原文件或目录]**

\-c 打包 -v显示信息 -f文件名 -z打包的同时压缩（.tar.gz) -j打包的同时压缩（.tar.gz2)
解压缩：-x 解包 -z解压缩    -j解压缩gz2

### **zip**

**格式上类似于tar**

-   能保留原文件

-   \-r 能压缩目录

-   unzip 解压缩

**bzip2**
![](https://github.com/Missyesterday/Picture/blob/main/14ce4c8b-220d-45ff-ac1d-a4fb8e7199e0.png?raw=true)
解压缩bunzip -k(保留原文件）

## 6.网络命令

### **1.write <用户名>**

给用户发信息，Ctrl + D保存结束。用户必须在线

### **2.wall \[message]**

给所有用户发信息

### **3.ping 选项 IP地址**

\-c 指定发送次数
重点看丢包率

### **4.ifconfig 网卡名称 ip地址**

查看和设置网卡

### **5.mail\[用户名]**

查看发送邮件

### **6.last**

统计所有用户的登陆信息

### **7.lastlog**

统计所有用户的最后一次登陆

### **8.traceroute \[网站名]**

解析ip地址，显示数据包到主机间的路径

### **9.netstat(重要)**

-   \-t TCP协议 （面向连接的协议）&#x20;

-   \-u UDP协议&#x20;

-   \-l 监听&#x20;

-   \-r 路由&#x20;

-   \-n 显示ip地址和端口号 发起端口是随机的，目标端口是固定的

> 如： netstat -tlun 查看本机监听的端口（判断本机开启了哪些服务） netstat -an 查看本机所有的网络连接 netstat -rn 查看本机路由表

### **10.setup**

### **11.mount \[-t 文件系统] 设备文件名 挂载点**

umount 设备文件名 or 挂载点

## 8.关机命令

### **1.shutdown \[选项] 时间**

-   \-c 取消前一个关机命令

-   \-h 关机

-   \-r 重启

-   时间可以用小时：分钟（如果马上关机用now）

推荐使用shutdown，**服务器不能关机只能重启**

### **2.其他关机命令**

1.  halt

2.  poweroff

3.  init 0

### **3.其他重启命令**

1.  reboot

2.  init 6

> 系统的运行级别:
>
> -   0 关机
>
> -   1 单用户（ 启动最小的服务，用来修复）
>
> -   2 不完全多用户（命令行），不含NFS服务（Linux文件共享服务，用户验证机制较弱）
>
> -   3  完全多用户
>
> -   4 未分配
>
> -   5 图形界面（大写X一般指Linux的图形界面）
>
> -   6 重启
>     runlevel 查看当前运行级别和上次运行级别
>     init 指定运行级别

### **4.logout退出登陆**

## **9. 其他命令**

-   du -sh \[filename] #查看文件大小

-   mount /dev/sr0 /mnt/cdrom #挂载命令

-   sl#小火车动画

-   htop #更丰富的界面top命令

-   echo \[选项]\[内容]   -e #支持反斜杠控制字符的转换

-   dos2unix filename #把win下隐藏字符转化为Linux

-   dd if=输入文件 of=输出文件 bs=字节数 count=个数,选项：

    -   bs=字节数 #指定一次输入/输出多少字节，把这些字节看作一个数据块

    -   count=个数 #指定输入/输出多少个数据块

-   grep \[选项]"搜索内容"
    选项：

    -   \-i #忽略大小写

    -   \-n #输出行号

    -   \-v #反向查找

    -   \--color=auto #搜索出的关键字用颜色显示

    -   举例：
        grep "root" /etc/passwd #显示/etc

-   passwd 下包含root关键字的行

-   set #查看所有变量

-   unset name  #删除变量

-   pstree #确定进程树

-   declare \[+/-]\[选项] 变量名
    选项：

    -   \#给变量设定类型属性

    -   \#取消变量的类型属性

    -   \-i #将变量声明为整数类型

    -   \-x #将变量声明为环境变量

    -   \-p #显示指定变量的被声明的类型

-   df #查看分区的使用状况

-   nmap #远程扫描命令，判断apache是否启动

    -   nmap -sT ip地址 #扫描指定服务器上开启的tcp端口
        nmap -sT 192.168.101.107 | grep tcp | grep http | awk '{print \$2}  #判断apache是否启动，见/root/hyf/isApache.sh

-   sudo /etc/init.d/apache2 start  #启动apache

-   w #查看登陆用户

-   nohup #挂起到后台

-   firewall-cmd --permanent --zone=public --add-port=7000/tcp：开启端口

-   sudo firewall-cmd --reload：防火墙重启

-   lsof -i:prot：查看某个端口的占用情况
