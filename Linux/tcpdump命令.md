# tcpdump

tcpdump是 Linux 的抓包工具。

安装：

```bash
yum install tcpdump
```

使用 tcpdump 必须要有 sudo 权限。

## 常用选项

-   -i 指定要捕获的目标网卡名，网卡名可以通过 ifconfig 得到，如果要抓所有网卡上的包，可以使用`any`关键字。
-   -X 以 ASCII 和十六进制的形式输出捕获的数据包内容，减去链路层的包头信息；**-XX** 以 ASCII 和十六进制的形式输出捕获的数据包内容，包括链路层的包头信息。
-   -n 将 ip 地址显示成数字，-nn：将ip 地址和端口都不要以别名出现
-   -S 以绝对值显示 ISN 号（包序列号），默认情况是以上一个包的偏移量显示
-   -vv 显示详细的抓包数据，-vvv 显示更加详细的抓包数据
-   -w filename，将包的原始信息（不解析）写入文件中



## 过滤形式

```bash
## 仅显示通过端口 8888 的数据包，包括 tcp 和 udp
tcpdump -i any 'port 8888'

## 仅显示端口 8888 的 tcp 包
tcpdump -i any 'tcp port 8888'

## 仅显示源端口是 tcp8888 的数据包
tcpdump -i any 'tcp src port 8888'

## 需要注意的是，如果用 and，则需要指定源和目的
tcpdump -i any 'src host 127.0.0.1 and tcp src port 9999' -XX -nn -vv

```



## 实战

```bash
tcpdump -i any 'port 80 or port 443' -XX -nn -vv -S
```

Flag 代表：

```
Flags are some combination of S (SYN), F (FIN), P (PUSH), R (RST), W (ECN CWR) or E (ECN-Echo),
or a single '.' (no flags)
```

>   一般 eth0 就是真正的网卡。