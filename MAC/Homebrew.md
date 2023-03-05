# Homebrew

`Homebrew`是macOS常用的包管理工具，类似于linux中的`apt`或者`yum`。

M1版本的`Homebrew`默认安装在`/opt/homebrew`，而非`/usr/loacl`。通过:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

将`Homebrew`切换为M1版本。

如果想用X86的`Homebrew`，可以勾选：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20221014170847742.png" alt="image-20221014170847742" style="zoom:40%;" />

