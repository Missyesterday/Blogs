# Vim的使用

## 序

之前在Linux中简单学习了一下vim，能记住到现在的也就`i`插入，`:wq`保存等基本的用法了。偶然看到别人的vim使用特别流畅，同时本人及其厌恶使用鼠标，遂产生深入学习vim的想法。参考了书《像IDE一样使用vim》。

本人使用的是

## 0. Vim配置

几个配置vim的要点

### 0.1 `.vimrc`文件

`.vimrc`位于`~/.vimrc`，是vim的配置文件。

>   “不论 vim 窗口外观、显示字体，还是操作方式、快捷键、插件属性均可通过编辑该配置文件将 vim 调教成最适合你的编辑器。”

#### 前缀键

：vim中有很多快捷键，大量快捷键出现在单层空间中难免引起冲突，所以引入了前缀键`\`，这样一个简单的`r`就可以配置出很多快捷键：`r`、`\r`、`\\r`等。我们可以设置任意一个键为前缀键，提高编辑效率，普遍做法是将前缀键设置为`;`。

```
" 定义快捷键的前缀，即<Leader>
let mapleader=";"
```

 快捷键设定原则：**不同快捷键尽量不要有同序的相同字符**。其实在计算机语言中，这句话也可以翻译成：一个快捷键不能是另一个快捷键的前缀表达式。

#### 文件类型帧测

允许基于不同语言加载不同插件（例如C++的语法高亮与python不同）：

```
" 开启文件类型侦测
filetype on
" 根据侦测到的不同类型加载对应的插件
filetype plugin on
```

#### 一些常用非插件操作设置为快捷键

```
" 定义快捷键到行首和行尾
nmap LB 0
nmap LE $
" 设置快捷键将选中文本块复制至系统剪贴板
vnoremap <Leader>y "+y
" 设置快捷键将系统剪贴板内容粘贴至 vim
nmap <Leader>p "+p
" 定义快捷键关闭当前分割窗口
nmap <Leader>q :q<CR>
" 定义快捷键保存当前窗口内容
nmap <Leader>w :w<CR>
" 定义快捷键保存所有窗口内容并退出 vim
nmap <Leader>WQ :wa<CR>:q<CR>
" 不做任何保存，直接退出 vim
nmap <Leader>Q :qa!<CR>
" 依次遍历子窗口
nnoremap nw <C-W><C-W>
" 跳转至右方的窗口
nnoremap <Leader>lw <C-W>l
" 跳转至左方的窗口
nnoremap <Leader>hw <C-W>h
" 跳转至上方的子窗口
nnoremap <Leader>kw <C-W>k
" 跳转至下方的子窗口
nnoremap <Leader>jw <C-W>j
" 定义快捷键在结对符之间跳转
nmap <Leader>M %
```



立即生效。全文频繁变更 .vimrc，要让变更内容生效，一般的做法是先保存 .vimrc 再重启 vim，太繁琐了，增加如下设置，可以实现保存 .vimrc 时自动重启加载它：
```
" 让配置变更立即生效
autocmd BufWritePost $MYVIMRC source $MYVIMRC
```

一些其他设置：

```
" 开启实时搜索功能
set incsearch
" 搜索时大小写不敏感
set ignorecase
" 关闭兼容模式
set nocompatible
" vim 自身命令行模式智能补全
set wildmenu
```

### 0.2 `.vim/`目录

`.vim/`目录是存放所有插件的地方。vim有一套自己的脚本语言`vimscript`，通过这种脚本语言可以实现与vim交互，达到功能拓展的目的。一组`vimscript`就是一个vim插件，vim的很多功能都由各式插件实现。此外，vim还支持`perl`、`python`、`lua`、`ruby`等主流脚本语言编写的插件，前提是vim源码编译时增加` ---enable-perlinterp、--enable-pythoninterp、--enable-luainterp、--enable-rubyinterp`等选项。[vim.org](vim.org)和GitHub有很多插件，包括了所有你能想到的。

vim插件分为：`*.vim`和`*.vba`两类：

1.   `*.vim`是传统格式的插件，实际上就是一个文本文件，通常`someplugin.vim`（插件脚本）和`someplugin.txt`（插件帮助文档）并存在一个打包文件中，解包后将`someplugin.vim`拷贝到`~/.vim/plugin/`目录，`someplugin.txt`拷贝到`~/.vim/doc/`目录即可完成安装，重启vim后安装的插件就已经生效了，可通过`:h someplugin`查看插件帮助信息。传统格式插件需要解包和两次拷贝才能安装。

2.   `*.vba`格式插件只需要在shell中执行:

     ```shell
     vim someplugin.vba
     :so %
     :q
     ```

3.   除此之外，还有管理插件的插件`vundle`，方便插件卸载和升级

## 1. 源码安装编辑器vim

./configure --with-features=huge --enable-pythoninterp --enable-rubyinterp --enable-luainterp --enable-perlinterp --with-python-config-dir=/usr/lib/python2.7/config/ --enable-gui=gtk2 --enable-cscope --prefix=/usr

关配置信息：

```
" vundle 环境设置
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
" vundle 管理的插件列表必须位于 vundle#begin() 和 vundle#end() 之间
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'tomasr/molokai'
Plugin 'vim-scripts/phd'
Plugin 'Lokaltog/vim-powerline'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'derekwyatt/vim-fswitch'
Plugin 'kshenoy/vim-signature'
Plugin 'vim-scripts/BOOKMARKS—Mark-and-Highlight-Full-Lines'
Plugin 'majutsushi/tagbar'
Plugin 'vim-scripts/indexer.tar.gz'
Plugin 'vim-scripts/DfrankUtil'
Plugin 'vim-scripts/vimprj'
Plugin 'dyng/ctrlsf.vim'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'scrooloose/nerdcommenter'
Plugin 'vim-scripts/DrawIt'
Plugin 'SirVer/ultisnips'
Plugin 'Valloric/YouCompleteMe'
Plugin 'derekwyatt/vim-protodef'
Plugin 'scrooloose/nerdtree'
Plugin 'fholgado/minibufexpl.vim'
Plugin 'gcmt/wildfire.vim'
Plugin 'sjl/gundo.vim'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'suan/vim-instant-markdown'
Plugin 'lilydjwg/fcitx.vim'
" 插件列表结束
call vundle#end()
filetype plugin indent on
```

