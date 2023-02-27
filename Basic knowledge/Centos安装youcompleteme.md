# CentOS7 安装youcompleteme插件

1.   把本地的vim配置传到服务器：`~/.vim/`和`~/.vimrc`。一些小插件能直接使用，但是YCM这种大插件无法直接使用。

2.   下载llvm-clang和「大于7.0」版本的gcc g++和「大于3.2.17」版本的cmake

3.   进入build，执行`cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm`

     