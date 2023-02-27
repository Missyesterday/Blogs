# **1. 概述**

## 1.1 Shell是什么

<img src="https://github.com/Missyesterday/Picture/blob/main/17ae0a09-dd3c-4825-8828-874146cec778.png?raw=true" style="zoom:40%;" />

-   Shell是一个命令行解释器，它为用户提供了一个向Linux内核发送请求以便运行程序的界面系统级程序，用户可以用shell来启动、挂起、停止甚至是编写一些程序。

-   Shell还是一个功能相当强大的编程语言，易编写，易调试，灵活性较强。Shell是解释执行的脚本语言，在Shell中可以直接调用Linux系统命令。

## 1.2 Shell的分类

-   Bourne Shell，主文件名为sh。

-   C Shell 语法类似于C语言而得名。

-   B Shell 和 C Shell 不兼容。Bourne 家族主要有sh、ksh、**Bash（主流）**、psh、zsh；

-   C家族主要包括csh和tcsh。

-   /etc/shells 包含支持的Shell

# 2. Shell脚本的执行方式

## 2.1 控制字符

<img src="https://github.com/Missyesterday/Picture/blob/main/05768cd4-48f6-4f82-bd25-8639334a3620.png?raw=true" style="zoom:40%;" />

## 2.2 第一个脚本

```shell
vi hello.sh
\#!/bin/Bash     这句话不是注释，是用来表示这个文件是一个Shell脚本

echo -e "heyufan 何宇凡"
```

需要注意的是如果显示文件没找到，把第一行的bash用小写

## 2.2 脚本的执行

-   方法1:  赋予执行权限直接运行\\

    ```shell
    chmod 755 hello.sh
    ./hello.sh
    ```

-   方法2: 通过Bash 调用执行脚本

    -   bash hello.sh	注意Linux的命令没有大写，bash记得用小写

# 3. Bash的基础功能

## 3.1历史命令与补全

-   history \[选项]\[历史保存文件]  -c ：清空历史命令(不要随便用）  -w：把缓存中的历史命令写入历史命令保存文件 ～/.bash\_history\
    历史命令默认保存1000条，可以在环境变量配置文件～/.bashrc中修改。\\

-   !n : 执行第n条命令

-   !! : 执行上一条命令

-   !字符串：重复执行最后一条以该字串开头的命令

-   Tab键补全 ： 按两下可以查看所有

## 3.2 别名与快捷键

### 3.2.1.命令别名

-   alias 别名=‘原命令’  （设置命令别名）

-   alias （查看别名）

-   unalias 别名 （删除别名）
    `别名不要在不确定的情况下覆盖原始命令`

**命令的执行顺序：**

1.  第一顺位执行用绝对路径或相对路径执行的命令

2.  第二顺位执行别名

3.  第三顺位执行Bash的内部命令（没有执行文件）

4.  第四顺位执行按照\$PATH环境变量定义的目录查找顺序找到的第一个命令

归根结底都是绝对路径来执行
让别名永久生效修改 ./root/.bashrc文件

### 3.2.2 Bash常用快捷键

<img src="https://github.com/Missyesterday/Picture/blob/main/917bc35c-2e7d-48ba-84c0-ce7fef52e882.png?raw=true" style="zoom:40%;" />
这些快捷键并不是执行命令（因为例如ctrl+L快捷键就不会在bash\_history文件中写入clear命令）

## 3.3 输入输出重定向

### 3.3.1 标准输入输出

<img src="https://github.com/Missyesterday/Picture/blob/main/5aee002e-1bb0-44f5-8bd4-a2b09f500da0.png?raw=true" style="zoom:40%;" />

### 3.3.2 输出重定向

<img src="https://github.com/Missyesterday/Picture/blob/main/9369d92b-2871-4cb7-a4b7-c5ea09568ae3.png?raw=true" style="zoom:40%;" />
改变输出的方向。有输出的命令才可以输出重定向。记录报错信息需要加上2，2和>>不能加空格。因为需要人工识别命令是否正确，所以意义不大。

<img src="https://github.com/Missyesterday/Picture/blob/main/b44d19b5-0928-40e2-845d-d754220feb10.png?raw=true" style="zoom:40%;" />
命令 &>/dev/null 可以在写脚本时将没有用的输出扔到垃圾箱。

### 3.3.3 输入重定向

-   wc \[选项]\[文件名] -c 统计字节数  -w 统计单词数 -l 统计行数
    <img src="https://github.com/Missyesterday/Picture/blob/main/24581c7a-3230-438e-93e1-277b9c44a553.png?raw=true" style="zoom:67%;" />
    2行 2单词 8个字符（包含回车）

命令<文件  统计文件的信息

## 3.4多命令顺序执行与管道符

### 3.4.1 多命令顺序执行

![](https://github.com/Missyesterday/Picture/blob/main/8f55b1ec-3644-491c-81c5-c76d51bc53cf.png?raw=true)

```shell
date;
dd if=/dev/zero of=/root/hyf/testfile bs=1k count=100000;
date
```

查看复制100M文件需要多久
`ls && echo yes || echo no`
第一条命令没报错就输出yes,报错就输出no（不能反过来）

### 3.4.2 管道符

-   命令1 | 命令2 #命令1的正确输出作为命令2的操作对象

例如：

-   ll -a /etc/ | more  #more命令本来是对文件进行操作的，加上| 可以对命令的输出操作

-   netstat -an | grep ESTABLISHED #查看当前有多少连接

## 3.5 通配符与其他特殊符号

### 3.5.1 通配符

通配符是用来匹配文件名的，与正则表达式有根本的区别
<img src="https://github.com/Missyesterday/Picture/blob/main/82329780-6de7-44ec-8498-c2dd12653f86.png?raw=true" style="zoom:40%;" />
**\[]一定要匹配一个字符**
举例：

-   rm -rf \* #删除当前目录的所有内容

-   ls \*abc #显示以abc结尾的文件

### 3.5.2 Bash中其他特符号

<img src="https://github.com/Missyesterday/Picture/blob/main/dcd2995d-df5b-4e29-8531-0a1ddb413fac.png?raw=true" style="zoom:40%;" />
举例：

-   name=hyf #定义一个值为hyf的变量name **记住不要加空格**

-   echo \$name #会显示hyf

-   echo '\$name' #显示\$name

-   echo "\$name" #显示hyf

-   abc=\$(date)  #abc = 日期

# 4 Bash变量

-   Bash中变量的默认类型都是字符串类型。

-   **变量等号两边不能有空格**

-   变量可以叠加

-   环境变量名建议大写，便于区分

-   变量分为：

    1.  用户自定义变量

    2.  环境变量：保存系统操作环境相关的数据

    3.  位置参数变量：向脚本中传递参数或数据的，变量名不能自定义，变量的作用是固定的

    4.  预定义变量：是Bash中已经定义好的变量，变量名不能自定义，变量作用也是固定的。

## 4.1 用户自定义变量（本地变量）

```shell
name=“he yu fan”
name="\$name"213   #变量叠加 等同于 name=${name}213
```

## 4.2 环境变量

### 4.2.1 环境变量是什么

用户自定义变量只在当前的Shell中生效，而环境变量会在当前Shell和这个Shell的所有子Shell当中生效。如果把环境变量写入相应的配置文件，那么这个环境变量就会在所有的Shell中生效。
例如父Shell和子Shell

### 4.2.2 设置环境变量

-   export 变量名=变量值  #申明变量

-   env  #查看环境变量

-   unset  变量名 #删除变量

### 4.2.3 系统常见环境变量

`PATH：系统查找命令的路径`

```
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games\:/usr/local/games\:/snap/bin
```

如果把脚本拷贝到系统目录中，可以不加路径和系统命令一样执行
一般用PATH=‘\$PATH’路径  #PATH变量叠加

`PS1：定义系统提示符的变量`
<img src="https://github.com/Missyesterday/Picture/blob/main/dcb4c04b-a73a-48ce-81b4-3b73382ebd59.png?raw=true" style="zoom:40%;" />
例如：
 PS1='\[\u@\t \w]\$'  #显示 \[root\@14:59:35 \~/hyf]#

### 4.2.3 位置参数变量

<img src="https://github.com/Missyesterday/Picture/blob/main/161dccaf-9dcd-4148-81f9-ab4451afd4ac.png?raw=true" style="zoom:40%;" />
用来向脚本当中传入数据。
例如：
canshu1.sh 脚本内容：

```shell
echo $0
echo $1
echo $2
echo $3
```

执行的时候 ./canshu1.sh 11 22 33 用空格隔开，11 22 33 就传入脚本中了
\$\* 和  \$@的区别可见 /root/hyf/sh/canshu2.sh

### 4.2.4 预定义变量

<img src="https://github.com/Missyesterday/Picture/blob/main/8adaabda-f0a5-4868-8feb-9bd03f8cfa6f.png?raw=true" style="zoom:40%;" />
&&与|| 的执行结果就是看\$?
每个程序运行都至少有一个进程

## 4.3 接受键盘输入

-   read \[选项]\[变量名]
    选项
    \-p "提示信息"  #在等待read输入时，输出提示信息
    \-t 秒数  #read命令会一直等待用户输入，使用此选项可以指定等待时间
    \-n 字符数 #read命令只接受指定的字符数，就会执行
    \-s 隐藏输入的数据，适用于机密信息的输入

例子：

```shell
#!/bin/bash
read -t 30 -p "请输入你的名字" name #记得加空格 
echo $ name
read -s -t 30 -p "请输入你的年龄" age
echo -e "\n"
echo  $age
read -n 1 -t 30 -p "请输入你的性别[M/F]" sex
echo\$sex
```

# 5. Bash的运算符

declare \[+/-]\[选项] 变量名
选项：

-   \-  #给变量设定类型属性

-   \+  #取消变量的类型属性

-   \-i #将变量声明为整数类型

-   \-x #将变量声明为环境变量

-   \-p #显示指定变量的被声明的类型

## 5.1 数值运算与运算符

方法1:  aa=11 bb=22
declare -i cc=\$aa+\$bb

方法2 或 let数值运算工具
dd=\$ (expr  \$aa+\$bb)

`推荐：方法3(()) 或是 $[]`

## 5.2 变量测试与内容替换

通过显示x来判断y是否有值
<img src="https://github.com/Missyesterday/Picture/blob/main/27bbc7d6-2c00-4a98-b543-c6f07f39067a.png?raw=true" style="zoom:40%;" />
例如：

```shell
unset y
x=$ {y-new}
echo  $x  

y=""       #**注意y为空值**
x=$ {y-new}
echo  $x
```

# 6. 环境变量与配置文件

## 6.1 环境变量配置文件简介

-   配置文件可以永久性修改环境变量。

-   source 配置文件 #强制让当前文件直接生效，不用重启

-   或 .配置文件 #   \*\*. \*\* 就是suorce

-   环境变量配置文件中主要是定义对系统的操作环境生效的系统默认环境变量，比如PATH、HISTSIZE、PS1（提示符）、HOSTNAME（主机名）等默认环境变量。

环境变量配置文件有：
/etc/profile  /etc/profile.d/\*.sh /etc/bashrc 是对所有用户都生效的。
\~/.bashrc ～/.bash\_profile 只对当前用户生效。

## 6.2 环境变量配置文件作用

<img src="https://github.com/Missyesterday/Picture/blob/main/90374916-454e-441d-894e-dcceb8b7247e.png?raw=true" style="zoom:40%;" />
环境用户变量优先级(CentOS7)

## 6.3 其他配置文件和登陆信息

～/.bash\_history 查看历史命令

### 6.3.1远程终端登陆后欢迎信息：

/etc/issue.net
转义符在 /etc/issue.net文件中不能使用
是否显示次欢迎信息，由ssh的配置文件 /etc/ssh/sshd\_config 决定，加入“Banner /etc/issue.net”行才能显示（记得重启SSH服务 service sshd restart）

### 6.3.2 本地终端欢迎信息

/etc/issue
<img src="https://github.com/Missyesterday/Picture/blob/main/06cae8d8-fbe1-476c-a360-563a7f6f4ad7.png?raw=true" style="zoom:40%;" />
Kernel \r on an \m and the OS is \s
\l
显示为:
![](https://github.com/Missyesterday/Picture/blob/main/f0ff8d15-caaa-4cc2-8569-97caeceaaac3.png?raw=true)

### 6.3.2登陆前欢迎信息。

进入update-motd.d目录cd /etc/update-motd.d, 里面的文件都是shell脚本, 用户登录时服务器会自动加载这个目录中的文件, 所以就能看到欢迎信息了.这个可以目录中的文件名都是数字开头的, 数字越小的文件越先加载。

![](https://github.com/Missyesterday/Picture/blob/main/90a70336-bc15-4a7d-a73f-5f12fea2c852.png?raw=true)

# 7. 正则表达式

## 7.1 基础正则表达式

### 7.3.1 正则表达式与通配符

-   正则表达式是用来在**文件中匹配符合条件的字符串**，正则是\*\*包含匹配。grep、awk、sed等命令可以支持正则表达式。

-   通配符用来**匹配符合条件的文件名，通配符是**完全匹配\*\*。ls、find、cp这些命令不支持正则表达式，所以只能用Shell自己的通配符来进行匹配。

-   在其他语言中，通配符只是正则表达式的内容。

| 元字符       | 作用                                                                                         |
| --------- | ------------------------------------------------------------------------------------------ |
| \*        | 前一个字符匹配0次或任意多次。                                                                            |
| .         | 匹配除了换行符外任意一个字符。                                                                            |
| ^         | 匹配行首。例如^hello会匹配以hello开头的行。                                                                |
| \$        | 匹配行尾。例如hello \$会匹配以hello结尾的行。                                                              |
| \[]       | 匹配括号中指定的任意一个字符，只匹配一个字符。例如\[aeiou]匹配任意一个元音字母，\[0-9]匹配任意一位数字，\[a-z]\[0-9]匹配小写字母和一位数字构成的两位字符。 |
| \[^]      | 匹配除括号的字符外以外的任意一个字符。例如：\[^0-9]匹配任意一位非数字字符,\[^a-z]匹配任意一位非小写字母。                               |
| \\        | 转义符。用于取消特殊符号的含义                                                                            |
| \\{n\\}   | 表示其前面的字符恰好出现n次，例如:\[0-9]{4}匹配4位数字，\[1]\[3]\[0-9]\\{9\\}匹配手机号码                              |
| \\{n,\\}  | 表示其前面的字符出现不小于n次。例如\[0-9]\\{2,\\}匹配两位及其以上的数字，其实和上面那个差不多                                     |
| \\{n,m\\} | 表表示其前面的字符至少出现n次，最多出现m次。例如:\[a-z]\\{6,8\\}匹配6到8位的小写字母                                       |

举例：

-   grep "a\*" test\_rule.txt #匹配所有内容，包块空白行

-   grep "aa\*" test\_rule.txt #匹配至少有一个a的行

-   grep "aaaaa\*" test\_rule.txt#匹配至少有4个连续a的行

-   grep "s..d" test\_rule.txt  #匹配在s和d两个字母之间一定有两个字符的行

-   grep "s.\*d" test\_rule.txt #匹配在s和d字母之间有任意字符的行

-   grep  "^M" test\_relu.txt #匹配以大写M开头的行

-   grep -n "^\$" test\_relu.txt  #匹配空白行，可以-n显示行号

-   grep -n "s\[ao]id" test\_rule.txt#匹配s和id之间的字母是a或者o

-   grep -n "^\[0-9]" test\_rule.txt #匹配以数字开头的行

-   grep -n "^\[^0-9]" test\_rule.txt#匹配不以数字开头的行

-   grep "^\[^a-zA-Z]" test\_rule.txt #匹配不用字母开头的行

-   grep "\\.\$" test\_rule.txt #匹配以.结尾的字符串

-   grep -n "a\\{3\\}" test\_rule.txt #匹配出现三次a的行

-   grep -n "\[0-9]\\{3\\}" test\_rule.txt  #匹配连续出现三次数字的行

-   grep "sa\\{1,3\\}i" test\_rule.txt#匹配s和i之间最少一个a最多三个a

## 7.2 字符截取命令

### 7.2.1 cut字段提取命令

-   cut\[选项] 文件名  #提取列命令，主要与grep配合使用
    选项：
    \-f 列号 #提取第几列
    \-d 分割符 #按照指定分隔符分割列

    举例：
    有一个student.txt 文件（空格全是制表符，否则cut命令不生效）：

```txt
ID Name  Gender Mark
1    Liming M    86
2    sc   M    90
3    hyf   M    100
```

-   cut -f 2,3 student.txt #提取第2,3列

-   cut -d ":" -f 1,3 /etc/passwd #提取用“：”分割的第一列和第三列
    \= cat /etc/passwd | grep /bin/sh | grep -v jkl | cut -d ":" -f 1#查看除了jkl外所有/bin/sh登陆的用户,然后以	:分割，提取第一列，也就是显示用户名
    ![](https://github.com/Missyesterday/Picture/blob/main/1cb4891b-0d35-48f6-887e-f53cb7727330.png?raw=true)

cut命令的局限：不能以空格作为分割符

### 7.2.2 printf命令

-   printf ‘输出类型输出格式’ 输出内容
    输出类型：
    %ns #输出字符串。n是数字指代输出几个字符
    %ni #输出整数。n是数字指代输出几个数字
    %m.nf #输出浮点数。m和n是数字，指代输出的整数位数和小数位数。如%8.2	代表共输出8位数，其中2位是小数，6位是整数。

输出格式：
![](https://github.com/Missyesterday/Picture/blob/main/68e0776c-31ce-41ed-94fa-c7160ef122bb.png?raw=true)
print会在每个输出后自动加入一个换行符，Linux默认没有print命令

### 7.2.3 awk命令

-   可以称为awk编程。

-   awk '条件1 {动作1} 条件2 {动作2}... '文件名

    -   条件（pattern）：关系表达式

    -   动作：格式化输出  流程控制语句

-   awk '{printf \$2 "\t"  \$3"\n"}' student.txt #输出student第二列和第三列 ，awk的执行顺序是先读入第一行数据再操作
    awk中print和printf都能使用（默认换行与否）
    可以输出不是严格Tab符，默认分隔符是空格和制表符

-   BEGIN命令 #可以手动操作第一行数据

-   awk 'BEGIN{FS=":"}{print \$1 "\t"  \$3}' /etc/passwd

-   以“：”为分隔符，如果不加BEGIN，则第一行不会以：分割直接输出，而加上BEGIN所有行都能只输出第一列和第三列
    END #所有数据处理完之后，再执行END

还能加上逻辑运算符

例如:
`cat student.txt | grep -v Name | awk '$4 >=86 {printf $2 "\n"}`
\##代表输出成绩大于86分的学生名字，-v反选，不能带第一行，会报错（>=86处）

### 7.2.4 sed命令

是一个轻量级流编辑器，可以对数据进行选取、替换、删除、新增。sed与vi/vim的区别在于：sed可以从管道符来接受处理流数据，直接修改命令结果。

-   sed \[选项] '\[动作]' 文件名

-   选项：

    -   \-n #一般sed命令会把所有数据都输出到屏幕，如果加入此选项， 则只会把经过sed命令处理的行输出到屏幕。

    -   \-e #允许对输入数据应用多条sed命令，多个条件之间用";"分开

    -   \-i #由sed的修改结果直接修改读取数据的文件，而不是由屏幕输出，会修改原文件，最好不要-i，用vim。

-   动作：

    -   a\ #追加，在当前行后添加一行或多行。**添加多行时，除最后一行外，每行末尾需要用“\”代表数据未完结**

    -   c\ #行替换，用c后面的字串替换愿数据行，替换多行时如上

    -   i\ #插入，在当前行插入一行或多行。插入多行时如上

    -   d #删除指定的行

    -   p #打印，输出指定的行

    -   s #字串替换，用一个字符串替换另外一个字符串。格式为“行范围s/旧字串/新字串/g” （与vim中的替换格式类似）

-   行数据操作：

    -   sed -n '2p' student.txt  #如果不加-n会输出所有，一般会加上-n选项

    -   df -h | sed -n '2p'  #输出第2行

    -   sed '2,4d' student.txt 	#输出删除第2到4行的结果，但真实文件不会删除

    -   sed '2a hello' student.txt  #在第二行后追加hello

    -   sed '2i hello \  world ' student.txt #在第二行前插入两行数据，\*\*不要复制这一行，\*\*要手动输入""然后按回车。

    -   sed '2c No such Person' student.txt #把第二行替换成“NoSuchPerson” ，c的意思是替换整行。

    -   sed -i '3s/90/100/g' student.txt #直接把第三行的90替换成100（修改了原文件），然后不显示

    -

细说Linux

## 7.3 字符处理命令

### 7.3.1 排序命令sort

-   sort \[选项] 文件名 （也可以排序管道符传过来的信息）
    选项：

    -   \-f #忽略大小写

    -   \-n #以数值型进行排序，默认使用字符串型排序

    -   \-r #反向排序

    -   \-t #指定分割符，默认分割符是制表符

    -   \-k n\[,m] #按照指定的字段范围排序，从第n字段开始，m字段结束（默认到行尾）。

举例：
sort /etc/passwd #按第一个字符排序
sort -t ":" -k 3,3 /etc/passwd #指定分隔符是“：”，用第三个字段开头，第三个字段结尾排序，就是只用第三字段排序。
如果想用数字排序，就-n

### 7.3.2 统计命令wc

-   wc \[选项]文件名

-   选项：

    -   \-l #只统计行数

    -   \-w #只统计单词数

    -   \-m #只统计字符数

## 7.4 条件判断

### 7.4.1 按照文件类型进行判断

| 测试选项    | 作用                               |
| ------- | -------------------------------- |
| -b 文件   | 判断该文件是否存在，并且是否为块设备（是块设备文件为真）     |
| -c 文件   | 判断该文件是否存在，并且是否为字符设备文件（是字符设备文件为真） |
| \\-d 文件 | 判断该文件是否存在名，并且是否为目录文件（是目录为真）      |
| -e 文件   | 判断该文件是否存在（存在为真)                  |
| -f 文件   | 判断该文件是否存在，并且为普通文件（是普通文件为真）       |
| -L 文件   | 判断该文件是否存在，并且是否为链接文件（是符号链接文件为真）   |
| -p 文件   | 判断该文件是否存在，并且是否为管道文件（是管道文件为真）     |
| -s 文件   | 判断该文件是否存在，并且是否为非空（非空为真）          |
| -S 文件   | 判断该文件是否存在，并且是否为套接字文件（是套接字文件为真）   |

两种判断格式

1.  test -e /root/install.log\\

2.  \[ -e /root/install.log ] **一定要在\`\[\`后\`]\`前输入空格**

echo \$?(代表上一条命令是否正确，0正确）#判断/root/install.log
\[ -d /root ] && echo "yes" || echo "no"  #一条命令解决

### 7.4.2 判断文件权限

| 测试选项  | 作用                             |
| ----- | ------------------------------ |
| -r 文件 | 判断存在和读权限（只要ugo其中之一有读权限为真，以下同理） |
| -w 文件 | 写权限                            |
| -x 文件 | 执行权限                           |
| -u 文件 | SUID权限                         |
| -g 文件 | SGID权限                         |
| -k 文件 | SBit权限                         |

### 7.4.3 两个文件之间进行比较

| 测试选项        | 作用                                                                                   |
| ----------- | ------------------------------------------------------------------------------------ |
| 文件1 -nt 文件2 | 判断文件1的修改时间是否比文件2的新（如果新为真）&#x20;                                                      |
| 文件1 -ot 文件2 | 判断文件1的修改时间是否比文件2的旧（如果旧为真）                                                            |
| 文件1 -ef 文件2 | **判断文件1是否和文件2的Inode（i节点）号一致，可以理解文两个文件是否为同一个文件。这个可以用来判断硬链接。（如果这两个的节点号一样则为硬链接，只能肉眼看）** |

### 7.4.4 两个整数之间的比较

| 测试选项        | 作用                 |
| ----------- | ------------------ |
| 整数1 -eq 整数2 | 判断整数1是否与整数2相等      |
| 整数1 -ne 整数2 | 判断整数1是否与整数2不相等     |
| 整数1 -gt 整数2 | 判断整数1是否大于整数2&#x20; |
| 整数1 -lt 整数2 | 判断整数1是否小于整数2       |
| 整数1 -ge 整数2 | 大于等于               |
| 整数1 -eq 整数2 | 小于等于               |

### 7.4.5 字符串的判断

| 测试选项     | 作用  |
| -------- | --- |
| -z 字符串   | 判空  |
| -n 字符串   | 判非空 |
| 字串1==字串2 | 判等  |
| 字串1!=字串2 | 判不等 |

### 7.4.6 多重条件判断

| 测试选项       | 作用  |
| ---------- | --- |
| 判断1 -a 判断2 | 逻辑与 |
| 判断1 -o 判断2 | 逻辑或 |
| !判断        | 逻辑非 |

&#x20;

## 7.5 流程控制

### 7.5.1 if语句

```shell
if [ 条件判断式 ]
	then
		程序
elif [ 条件判断式 ]    #**注意在elif的时候退出exit**
	then
		程序
...

else
	程序
fi
```

**举例：可见 /root/hyf//Look.sh和/root/hyf/sh/if.sh**
例子：判断apache是否启动 /root/hyf/sh/isApache.sh

### 7.5.2 case语句

```shell
case \$变量名 in
	"值1")
		程序1
		;;
	"值2")
		程序2
		;;
	"值3")
		程序3
		;;
esac
```

### 7.5.3 for循环

语法1：

```shell
for 变量 in 值1 值2 值3
	do
		程序
	done
```

初看很笨，但是可以可以用变量替代in后面的，利于系统管理
**可见/root/hyf/sh/for2.sh**

语法2：

```shell
for ((初始值;循环控制条件;变量变化))
	do
		程序
	done
```

**可见/root/hyf/sh/for3.sh和useradd.sh**

### 7.5.4 while循环和until循环   

while与until相反
**可见/root/hyf/sh/while1.sh**
/etc存放配置文件  /etc/init.d存放启动脚本
