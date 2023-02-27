# MAC的环境变量

Mac系统Bash的环境变量，加载顺序为：

1. /etc/profile

2. /etc/paths

3. \~/.bash_profile

4. \~/.bash_login

5. \~/.profile 

6. \~/.bashrc

"/"代表系统根目录，"\~/"代表用户目录。其中1和2是系统级别的，系统启动就会加载，其余是用户接别的。3,4,5按照从前往后的顺序读取，如果3文件存在，则后面的几个文件就会被忽略不读了，以此类推。\~/.bashrc没有上述规则，它是bash shell打开的时候载入的。这里建议在3中添加环境变量。

> 在zsh中，可以修改\~/.zshrc文件来添加环境变量。默认zsh用不了\~/.bash_profile里的环境变量，可以source \~/.bash_profile。当然复制一份也可以。

我们可以echo $PATH来看当前的环境变量。macOS、Linux以“:”分割，Win以“;"分割。

本机的环境变量：

/Users/heyufan1/opt/anaconda3/bin:

/Users/heyufan1/opt/anaconda3/condabin:

/usr/local/bin:

/usr/bin:/bin:

/usr/sbin:

/sbin: 

/Applications/VMware Fusion.app/Contents/Public:

/usr/local/share/dotnet:/opt/X11/bin:

\~/.dotnet/tools:/Library/Apple/usr/bin:

/Library/Frameworks/Mono.framework/Versions/Current/Commands:

/Users/heyufan1/apache-maven-3.6.1/bin:

/Library/Java/JavaVirtualMachines/jdk1.8.0_181.jdk/Contents/Home/bin:

/usr/local/bin:/usr/local/mysql/bin:

/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home/bin:

/Users/heyufan1/apache-maven-3.6.1/bin