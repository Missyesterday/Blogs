homebrew是一个包管理工具。

M1芯片的homebrew需要自行安装，路径为`/opt/homebrew/bin/brew`。而原本的x86的homebrew在`/usr/local/Homebrew/bin/brew `。

默认使用M1的brew的情况下，有时候需要下载的软件只有x86架构，会显示错误信息，需要切换回x86的homebrew。先把终端切换为rosetta打开，再使用下面命令安装：

```shell
/usr/local/Homebrew/bin/brew install xx
```

当然也可以为其在`~/.zshrc`中设置一个别名。

![image-20221104221116386](https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221104221116386.png)