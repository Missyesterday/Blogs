# 1. 服务的分类

- Linux服务分为包安装的服务和源码包服务，一般service命令找到的就是包安装的服务。包安装服务分为独立服务和基于xinetd的的服务
- 对于基于包安装的服务，Ubuntu将其配置文件存放在/etc/下，而独立服务启动文件存放在/etc/init.d下，service命令就是在/etc/init.d目录下寻找服务。
- 而源码包的服务存放在/usr/local下

# 2. 服务管理

常驻内存
![](https://github.com/Missyesterday/Picture/blob/main/85c326fd-cfc4-4865-8bca-5ad1c3b597fc.png?raw=true)
cat /var/www/html/index.html #apache的index页面

## 独立服务的启动：

- /etc/init.d/独立服务名  start|stop|status|restart
- service 独立服务名 start|stop|status|restart **（redhat系列专属命令）**

## 独立服务的自启动：

修改配置文件
- /lib/systemd/system/rc.local.service
- systemctl 命令
  
自启动不会影响当前的状态，只会影响下次启动。

## 基于xinetd的服务管理

用的不多
1. 修改 /etc/xinetd.d/服务名
2. 然后service xinetd restart


xinetd会影响当前状态，如果修改了自启动，当前服务也会被修改。

## 源码包服务的管理

使用绝对路径，调用启动脚本来启动。不同源码包的启动脚本路径不同。可以查看源码包的安装说明。

# 总结
Linux服务的不同来源于安装的不同


![](https://github.com/Missyesterday/Picture/blob/main/570d55e8-69ac-461f-a4ee-7be90936f6f7.png?raw=true)

# 常见服务的应用

用什么开什么。
