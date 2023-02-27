# 文本编辑器Vim

<img src="https://github.com/Missyesterday/Picture/blob/main/0e3fda97-44df-4c15-897f-7e4d24960764.png?raw=true" style="zoom: 33%;" />

## 1. Vim常用操作

<img src="https://github.com/Missyesterday/Picture/blob/main/2b0775bf-4908-43c5-8919-e8cfd7bf1911.png?raw=true" style="zoom: 33%;" />

没啥用，记得一个i就行

### **1.1光标移动命令**

| 输入   | 含义    |
| ---- | ----- |
| nu   | 设置行号s |
| \set | 取消行号  |
| gg   | 到第一行  |
| G    | 到最后一行 |
| nG   | 到第n行  |
|      | 到第n行  |
| \$   | 移动到行尾 |
| 0    | 移动到行首 |

### **1.2 删除命令**

| 输入   | 含义               |
| ---- | ---------------- |
| x    | 删除光标所在处字符        |
| nx   | 删除光标所在处后n个字符     |
| dd   | 删除光标所在行          |
| ndd  | 删除光标所在后n行        |
| dG   | 删除光标所在行到文件末尾的内容  |
| D    | 删除光标所在处到行尾的内容    |
| ,n2d | 删除\[n1, n2]范围内的行 |

### **1.3复制和剪切命令**

| 输入  | 含义             |
| --- | -------------- |
| yy  | 复制当前行          |
| nyy | 复制当前行以下n行      |
| dd  | 剪切当前行          |
| ndd | 剪切当前行以下n行      |
| p、P | 粘贴在当前光标所在行下或行上 |

### **1.4 替换和取消命令**

| 输入 | 含义                   |
| -- | -------------------- |
| r  | 替换光标处的一个字符           |
| R  | 从光标处所在处开始替换字符，按Esc结束 |
| u  | 撤销上一步                |

### **1.5 搜索和搜索替换命令**

| 输入               | 含义                           |
| ------------------ | ------------------------------ |
| /string            | 搜索指定字符串                 |
| ic                 | 忽略大小写                     |
| n                  | 搜索指定字符串的下一个出现位置 |
| :%s/old/new/g or c | 全文替换指定字符串             |
| g&#x20;            | 不询问                         |
| c&#x20;            | 询问                           |
| :范围s/old/new/g   | 在范围内替换，范围用,隔开      |

### **1.6 保存修改退出命令**

| 输入           | 含义                                       |
| -------------- | ------------------------------------------ |
| :wq            | 保存修改                                   |
| new\_filename  | 另存为指定文件(可以加路径）                |
| 或者(ZZ)快捷键 | 保存修改并退出                             |
| !              | 不保存退出                                 |
| !              | 强制保存修改退出（root或文件所有者能使用） |

## 2. Vim使用技巧

### **2.1 导入命令的执行结果 ! 命令**

如 \:r! date 导入日期到光标

### **2.2 自定义快捷键  快捷键 触发命令**

- 举例： map ^P I# `注意 ^P是按“ctrl + v + p” 代表ctrl P`
代表 ctrl + p 加注释
- map ^H <ihyf1204@icloud.com><  ESC>  可以插入我的邮箱
- map  ^B 0x 代表删除第一个元素

### **2.3 连续行注释**

- \:n1,n2s/^/#/g  `^代表行首`
- \:n1,n2s/^#//g  `取消注释` \
- :n1,n2s/^/\\/\\//g `反斜杠\代表转译  这个是用来在行首 // 注释`
>转译符\\
ls 指令会有颜色，这是因为ls有别名 开启了 color = auto
如果\ls 没有颜色

### **2.4替换**

&#x20;\[替换]\[原]
如\:  \:ab mymail  hyf1204@icloud.com 输入mymail就会替换成hyf1204@icloud.com

### **2.5 永久保存配置文件**

在用户目录下创建或修改 .vimrc文件
比如 vi /root/vimrc  vi /home/username/.vimrc 添加命令就可以了 **注意不要\":"**



## 3.  Vim基础

aio 和AIO

a：append

i：insert

o：open a new line

### 3.1 为什么vim有这么多模式

vim有许多模式：

-   进入vim默认时normal（普通）模式
    -   使用`Esc`回到普通模式
    -   普通模式下可以命令和移动
    -   由于大部分情况下浏览比编辑要多，所以默认是normal模式
-   使用`a,i,o`进入编辑模式/插入（insert）模式
    -   使用`Esc`
    -   `A,I,O`与`a,i,o`不同
-   `:cmd`命令模式
    -   例如`:wq`
    -   `:vs`(vertical split)竖分屏,`:sp`(split)横分屏
    -   `%s/old/new/g`进行替换
-   `v`可视化（visual）模式一般用来块装选择文本
    -   normal模式下使用`v`进入visual选择
    -   使用`V`选择行
    -   使用`ctrl+v`进行方块选择

### 3.2 插入模式技巧

**如何快速纠错：**

-   `ctrl+h`删除上一个字符，`ctrl+w`删除上一个单词，`ctrl+u`删除当前行
    -   另外，在终端中，还有：快捷键`ctrl+a`可以快速返回开头，`ctrl+e`可以快速返回结尾，`ctrl+b`向前移，`ctrl+f`向后移动

**快速切换insert和normal模式**

-   键盘Esc很远
-   使用`ctrl+c`代替`Esc`（但是可能会中断某些插件），或者`ctrl+[`(更为推荐)
-   在normal模式下使用`gi`快速跳转到最后一次编辑的地方并进入插入模式
-   还可以通过映射修改`Esc`

**键盘的选择**

-   HHKB或者Poker2
-   软件修改键位，把`CapsLock`修改成频繁使用的`Ctrl`
-   更重要的还是肌肉记忆，尝试抛弃退格键，使用`ctrl`快捷键来完成编辑删除工作
-   尝试修改而不是强迫自己适应难用的键位设置



### 3.2 vim快速移动

**反人类的`hjkl`:**

-   vim诞生的时候还没有上下左右键
-   <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221125001320711.png" alt="image-20221125001320711" style="zoom:40%;" />

**在单词之间移动**

-   `w/W`移动到下一个`word/WORD`开头。`e/E`下一个`word/WORD`尾
-   `b/B`回到上一个`word/WORD`开头，可以理解为backward
-   `word`指的是以非空白符分割的单词，WORD是以空白符分割的单词（其实也就相当于下一个空白的地方）
-   `w/b`用的较多

**行间搜索搜索移动**

-   使用`f{char}`可以移动到char字符上，`t{char}`移动到char的前一个字符
-   如果第一次没有搜索到，可以用`;/,`（分号/逗号）继续搜索该行的下一个/上一个
-   大写的F`F{char}`表示从后往前搜索字符

**vim水平移动**

-   `0`移动到行首的第一个字符，`^`移动到第一个非空白符
-   `$`移动到行尾，`g_`移动到行尾非空白字符
-   记住`0`和`$`就行，例如`0w`也可以回到第一个空白字符上

**vim垂直移动**

-   使用`()`在句子间移动，可以用`:help(`来查看帮助
-   使用`{}`在段落之间移动
-   可以用`easy-motion`插件移动，不用记忆这些命令

**vim页面移动**

-   `gg/G`移动到文件开头/结尾，使用`ctrl+o`快速返回
-   `H/M/L`跳转到屏幕的开头(Head)/中间(Middle)/结尾(Lower)
-   `ctrl+u` `ctrl+f` 代表上下翻页（upword/forward）。`zz`把屏幕置为中间

>   需要练习到形成条件反射，这些命令都是在normal模式下



### 3.3 快速增删查改

**vim增加字符**

-   `a/i/o/A/I/O`就是进入插入模式

**vim快速删除一个字符**

-   normal模式下使用`x`快速删除一个字符
-   使用`d`配合文本对象快速删除
    -   `dw`：删除一个词(从光标开始)
    -   `daw`：删除一个词，包括光标前后
    -   `diw`：`i`代表in XX
    -   `dd`：删除当前行
    -   `dt{char}`删除char字符前的所有字符
    -   `d$`删除到行尾
    -   `d0`删除到行首
    -   `2dd`删除两行
    -   `v`选择+`d`删除
-   `d`和`x`可以搭配数字多次执行

**vim快速修改**

-   常用的有三个`r/c/s`(replace/ change/ substitute)
-   normal模式下使用`r`可以替换一个字符。`s`替换并进入插入模式(删除当前字符，进入插入模式)
-   `c`配合文本对象，快速修改，与`d`类似，但是会进入插入模式



**vim查询**

-   使用`/`或者`?`进行前向或者反向搜索
-   使用`n/N`跳转到下一个或者上一个匹配
-   使用`*`或者`#`进行当前单词的前向或者后向匹配（也就是找到文本中同样的单词）



### 3.4 vim搜索替换

**substitute命令可以查找并替换文本，支持正则式**

-   `[range]s[ubstitute]/{pattern}/{string}/[flags]`
    -   range：表示范围，例如`10, 20`表示10-20行，`%`表示全部
    -   pattern：表示要替换的模式
    -   string：表示替换后的文本
    -   flag：替换标志位
        -   `g`表示全局(global)范围内执行
        -   `c`表示确认(confirm)，可以确认或者拒绝修改
        -   `n`报告匹配到的次数(number)而不执行替换，可以用来查询匹配的次数
        -   **如果想精确匹配某一个单词，建议用正则，例如：`:% s/\<duck\>/cat/g`只会改变`duck`这个单词，而例如`do_duck`这样的不会被修改**

>   如果想替换多个文件中的匹配，建议使用插件



### 3.5 vim多文件操作

**一些多文件操作相关的概念**：

**Buffer是指打开的一个文件的内存缓冲区**

-   vim打开一个文件后会加载文件内容到缓冲区

-   之后的修改都是针对内存中的缓冲区，并不会直接保存到文件

-   直到执行`:w`的时候才会把修改内容写入到文件里

-   使用`ls`会列举当前缓冲区，使用`:b n`跳转到第n个缓冲区
    -   `:bpre`, `:bnext`, `:bfirst`, `:blast`分别跳转到上一个/下一个/第一个/最后一个Buffer
    -   也可以使用`:b buffer_name`加上tab来补全跳转




**Window是Buffer可视化的分割区域**

-   一个缓冲区可以分割成多个窗口，每个窗口也可以打开不同的缓冲区

-   `<ctrl + w>s`水平分割，`<ctrl + w>v`垂直分割。或者`:sp`和`:vs`

-   每个窗口都可以继续被无限分割

-   关于切换窗口

    <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221125171548128.png" alt="image-20221125171548128" style="zoom:40%;" />

-   窗口的重新排列

    <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221125223914082.png" alt="image-20221125223914082" style="zoom:40%;" />



**Tab(标签页)可以组织窗口为一个工作区**

-   Vim的Tab和其他编辑器不太一样，可以想象成Linux的虚拟桌面

-   比如一个Tab全用来编辑Python文件，一个Tab全是HTML文件

-   相比窗口，Tab一般用的比较少

    <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221125225602789.png" alt="image-20221125225602789" style="zoom:40%;" />

-   使用ctrlp插件可以操作多个文件



### 3.6 Vim的 text object（文本对象）

主流的编程语言，都有面向对象编程：

-   Vim里文本也有对象的概念，比如一个单词，一段句子，一个段落
-   很多其他编辑器经常只能操作单个字符来修改文本，比较低效
-   通过操作文本对象来修改要比只操作单个字符高效

**文本对象的操作方式：**

-   `[number]<cmd>[textobject]`
-   number表示次数，cmd表示命令（d(elete), c(hange), y(ank)）
-   text object表示操作的文本对象，比如单词`w`，句子`s`，段落`p`

**举几个例子：**

-   「`vi` + `符号`」表示选中符号中的内容，例如`vi"`, `vi<`代表选中`""`/`<>`中的内容，把`v`替换成`c`则代表删除并插入，例如`ci{`表示删除`{}`内的元素并进入insert模式
-   `p`代表粘贴

>   总结：需要摆脱低效的字符操作，使用文本对象提升效率

### 3.7 Vim复制粘贴和寄存器的使用

vim的normal模式和insert模式下复制粘贴的操作是不同的

**normal模式下复制粘贴**

-   y(ank)和p(ut)，d代表剪切
-   我们可以使用`v`命令选中所要复制的地方，然后使用`p`粘贴
-   配合文本对象：比如`yiw`复制一个单词，`yy`复制一行
-   vim中剪切(cut)复制(copy)粘贴(paste)分别是delete/yank/put
-   yy,dd分别代表复制/粘贴一行

**Insert模式下的复制粘贴**

-    在有鼠标的情况下，一般复制粘贴都是用鼠标进行选中，然后使用`ctrl + v`或者`cmd + v`粘贴
-   但在vim的插入模式下，粘贴代码有个坑：
    -   如果在vimrc中设置了autoindent，粘贴代码缩进错乱
    -   这个时候需要使用`:set paste`和`:set nopaste`解决
    -   需要来回设置，比较麻烦

**Vim的寄存器**

-   Vim里操作的是寄存器而不是系统剪切板，这和其他编辑器不同
-   默认使用`d`删除或者`y`复制的内容都放到了「无名寄存器」。
-   用`x`删除一个字符放到无名寄存器，然后`p`粘贴，就可以调换这两个字符。

**深入寄存器(register)**

-   通过`"{register}`前缀可以指定寄存器，不指定默认用无名寄存器
-   使用`:reg {register}`可以查看寄存器的内容
-   比如使用`"ayiw`复制一个单词到寄存器a中，`"bdd`删除当前行到寄存器b中
-   除了寄存器a-z，Vim中还有一些其他常见寄存器
    -   复制专用寄存器 `"0`， 使用`y`复制文本的同时会被拷贝到复制寄存器0
    -   系统剪贴板，`"+`可以在复制前加上 `"+`复制到系统剪贴板
    -   其他一些寄存器入`"%`当前文件名， `".`上次插入的文本
    -   可以使用`:set clipboard=unnamed`可以让复制的内容直接复制到系统剪贴板里



### 3.8 Vim的宏(macro)

**从需求说起：**

-   给多行url链接加上双引号，该如何操作？

**宏(macro):**

-   宏可以看成一系列命令的集合
-   我们可以使用宏「录制」一系列操作，然后用于「回放」
-   宏可以非常方便地把一系列命令用于多行文本上

**如何使用宏：**

-   Vim使用q开录制，同时也是用q结束录制
-   使用`q{register}`选择要保存的寄存器，把录制的命令保存其中
    -   `qa`就相当于把一系列命令存在寄存器a中
-   使用`@{register}`回放寄存器中保存的一系列命令

**解决上述问题：**

-   先给一行加上双引号，然后再回放到其他所有行
-   我们先使用`q`开始录制，给一行加上双引号，之后使用`q`推出
-   在剩下的所有行中回放录制的宏
-   使用`v`选中再在命令行中执行命令



### 3.9 Vim中的代码补全

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221126150825199.png" alt="image-20221126150825199" style="zoom:40%;" />

一般留给插件完成



### 3.10 更换Vim主题

**Vim也可以更换主题：**

-   使用`:colorscheme`显式当前的主题配色，默认是default
-   使用`:colorscheme <ctrl + d>`可以显式所有的配色
-   使用`:colorscheme 配色名`可以更换配色

**从网络上下载配色：**

-   [https://github.com/flazz/vim-colorschemes](https://github.com/flazz/vim-colorschemes)



>   裸Vim也很好用了

## 4. Vim配置

用别人的配置除了问题都不知道怎么修，所以最好用自己一步步摸索的配置。



### 4.1如何修改

在`~/.vimrc`下修改：

-   常用设置，`:set nu`设置行号，`colorscheme hybrid`设置主题
-   自定义映射，通过`noremap <leader> w:w<cr>`保存文件
-   自定义`vimscript`和插件配置





### 4.2 常用配置

```cpp
  1 "设置行号
  2 set nu
  3 "语法高亮
  4 syntax on
  5 
  6 "F2进入粘贴模式，
  7 set pastetoggle=<F2>
  8 
  9 "高亮搜索
 10 set hlsearch
 11 
 12 "设置折叠方式
 13 set foldmethod=indent
```



### 4.3 Vim映射

vim的映射比较复杂，源于vim有多种模式

-   设置leader键：`let mapleader = ","`，常用的是逗号或空格
-   例如`inoremap <leader>w <Esc>:w<cr>`：在插入模式保存

还有很多，例如可以格式化代码

**什么是Vim映射**
- 不满意现在的按键设置
- 不满意现在的操作

**基本映射**

基本映射就是normal模式下的映射，当然还有其他模式的映射：

- 使用`map`就可以实现映射。比如：`map - x`然后按`-`就会删除字符
- `:map <space> viw`告诉vim按下空格的时候选中整个单词
- `map <c-d> dd>`可以使用ctrl + d执行dd删除一行



Vim常用模式 normal/visual/insert都可以定义映射：

-   用`nmap/vmap/imap`定义映射只在`normal/visual/insert`模式下有效
-   `:vmap \U`把在visual模式下选中的文本转换成大写(u/U转换大小写)



现有的映射存在一些问题：

```
:nmap -dd
:nmap \ -
```

当我们按下`\`的时候，Vim会递归解释为`dd`。

`*map`系列命令有递归的风险，例如插件定义了一些命令可能会有冲突。Vim提供了非递归映射，这些命令不会递归解释：

-   使用`*map`对应的`nnoremap/vnoremap/inoremap`
-   任何时候都应该使用非递归映射

### 4.4 Vim插件

现代化的Vim可以通过插件管理器安装插件

- Vim插件就是用vimscript或者其他语言编写的vim功能扩展
- 通过插件可以无限扩充Vim的功能
- 想要使用插件还需要具备一定的Vim配置知识



**如何安装插件？**

最原始的方式就是clone插件代码，如今vim有很多插件模拟器。

-   目前有很多插件管理器
-   常见的有：vim-plug，Vundle，Pathogen等
-   综合下来建议使用vim-plug

**使用vim-plug**

第一次使用，需要安装vim-plug：

-   首先在`autoload`目录下安装`plug.vim`

安装插件：

-   然后在`~/.vimrc`下添加：

    ```vim
     34 "vim-plug,需要把plug.vim添加到autoload文件夹下
     35 call plug#begin()
     36
     37 "这里填写安装的插件
     38
     39 " vim-startify,一个vim开屏软件
     40 Plug 'mhinz/vim-startify'
     41
     42 call plug#end()
    ```

    在中间添加 `Plug '插件名'`，然后保存，`:source ~/.vimrc`，再输入`:PlugInstall`就可以了。



>   github常年失败。

### 4.5 快速找到自己需要的插件

>    先有需求，后有插件。



大部分插件托管在GitHub上：

-   nerdtree管理多文件
-   python相关的插件：python-mode

可以用vimawesome查看插件：

-   fugtive集成了git
-   有语言、代码补全、继承、状态栏展示等相关的插件



### 4.6 Vim脚本

Vim有自己的脚本语言Vimscript

- Vim脚本可以实现强大的Vim插件
- 可以使用vimscript开发自己的插件

> 不得不说，Vim的使用不是一朝一夕的事情。可以参考别人的



## 5. Vim插件

### 5.1 Vim美化插件

-   修改启动页面：vim-startify
-   状态栏没话：vim-airline
-   增加代码缩进线条：indentline：
    -   `IndentLinesEnable`和`IndentLinesDisable`代表打开和关闭


>   注意mac的原生vim是不支持indentline的，需要`brew install macvim`。折腾了好久，结果发现这个插件是对python用的，但是本人不写python。。。。



### 5.2 Vim文件管理

**nerdtree：**

默认的文件管理目录比较丑陋，nerdtree弥补了这个问题



**ctrpl插件：**

快速查找并发开一个文件：

-   `<C-p>`：查找



### 5.3 Vim快速移动

**easymotion：**

-   官方文档很长，一个映射足以

在normal模式下按`ss`可以跳转到任意一个字符（太狠了）。



### 5.4 Vim成对操作

**vim-surround**

成对操作：例如想删除一对双引号，或者修改一对单引号为双引号

-   `ds`：delete a surrounding
    -   `ds [`删除一个`[`
-   `cs`：change a surrounding
    -   `cs " '`：将双引号替换为单引号
-   `ys`：you add a surrounding
    -   `ys iw "`代表给一个单词添加一对`"`

>   这个太有用了



### 5.5 Vim模糊搜索和批量替换



**fzf和fzf.vim：**

fzf是一个强大的命令行模糊搜索工具，fzf.vim集成到了vim里。

可以在命令行中安装fzf。

-   使用`Ag [PATTERN]`模糊搜索字符串
-   使用`Files [PATH]`模糊搜索目录
-   使用`Ctrl +jk`跳转



### 5.6 搜索替换插件far.vim

在很多文件里批量修改

`:Far 旧字符串 新字符串 要修改的文件`，文件可以用匹配。

先预览`Fardo`就是替换



### 5.7 Vim tagbar，浏览代码

代码大纲。

需要安装universal-ctags。

配置了一下，按F8快速打开。



### 5.8 代码补全

**deoplete.nvim**

