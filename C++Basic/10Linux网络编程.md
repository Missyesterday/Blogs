# Linux网络编程



## 1. 网络结构模式

### 1.1 C/S结构

**简介**

服务器 - 客户机，即 Client - Server(C/S)结构。C/S 结构通常采取两层结构。服务器负责数据的管理，客户机负责完成与用户的交互任务。客户机是因特网上访问别人信息的机器，服务器则是提供信息供人访问的计算机。

客户机通过局域网与服务器相连，接受用户的请求，并通过网络向服务器提出请求，对数据库进行操作。服务器接受客户机的请求，将数据提交给客户机，客户机将数据进行计算并将结果呈现给用户。服务器还要提供完善安全保护及对数据完整性的处理等操作，并允许多个客户机同时访问服务器，这就对服务器的硬件处理数据能力提出了很高的要求。

**在C/S结构中，应用程序分为两部分:服务器部分和客户机部分。**服务器部分是多个用户共享的信息与功能，执行后台服务，如控制共享数据库的操作等;客户机部分为用户所专有，负责执行前台功能，在出错提示、在线帮助等方面都有强大的功能，并且可以在子程序间自由切换。



**优点**

1.   充分发挥客户端PC的处理能力，很多工作可以在客户端处理后再提交给服务器，所以C/S结构客户端相应速度快。
2.   操作界面漂亮、形式多样，可以充分满足客户自身的个性化要求。
3.   C/S架构的管理信息系统具有较强的事务处理能力，能实现复杂的业务流程。
4.   安全性较高，C/S一般面向固定的用户群，程序更加注重流程，它可以对权限进行多层次校验，提供了更安全的存取模式，对信息安全的控制能力很强，一般机密的信息系统采用C/S架构比较合适。
5.   C/S架构可以自定义自己的协议。



**缺点**

1.   客户端需要安装客户端软件。软件出现问题要维护，软件升级要重新维护。
2.   不能跨平台，客户端收到操作系统的限制。针对不同平台要开发不同的客户端软件。



### 1.2 B/S结构

B/S 结构(Browser/Server，浏览器/服务器模式)，是 WEB 兴起后的一种网络结构模式，WEB浏览器是客户端最主要的应用软件。这种模式统一了客户端，将系统功能实现的核心部分集中到服务器上，简化了系统的开发、维护和使用。客户机上只要安装一个浏览器，如 Firefox 或 Internet Explorer，服务器安装 SQL Server、Oracle、MySQL 等数据库。浏览器通过 Web Server 同数据库进行数据交互。



**优点**

B/S 架构最大的优点是总体拥有成本低、维护方便、 分布性强、开发简单，可以不用安装任何专门的软件就能实现在任何地方进行操作，客户端零维护，系统的扩展非常容易，只要有一台能上网的电脑就能 使用。



**缺点**

1.   通信开销大、系统和数据安全性较难保障
2.   个性特点明显降低，无法实现具有个性化的功能要求
3.   协议是固定的：http/https
4.   客户端服务器端的交互是请求-响应模式，通常动态刷新页面，响应速度明显降低。



## 2.MAC地址

>   网卡是一块被设计用来允许计算机在计算机网络上进行通讯的计算机硬件，又称为网络适配器或者网络接口卡NIC。其拥有MAC地址，属于OSI协议的第二层，它使得用户就可以通过电缆或者无线相互连接。每一个网卡都有一个被称为MAC地址的独一无二的48位串行号，它被写在卡上的一块ROM中。网卡的主要功能：
>
>   1.   数据封装和解封装
>   2.   链路管理
>   3.   数据编码与译码
>
>   网卡分为以太网卡和无线网卡。



MAC地址（Media Access Control Address），也称为局域网地址、以太网地址、物理地址或硬件地址。它是一个用来确认网络设备位置的地址，由网络设备制造商生产时烧录在网卡中。在 OSI 模型中，第三层网络层负责 IP 地址，第二层数据链路层则负责 MAC 地址 。MAC 地址用于在网络中唯一标识一个网卡，一台设备若有一或多个网卡，则每个网卡都需要并会有一个唯一的 MAC 地址。

MAC 地址的长度为 48 位(6个字节)，通常表示为12个16进制数，如:00-16-EA-AE-3C-40 就是一个MAC 地址，其中前 3 个字节，16 进制数 00-16-EA 代表网络硬件制造商的编号，它由IEEE(电气与电子工程师协会)分配，而后3个字节，16进制数 AE-3C-40 代表该制造商所制造的 某个网络产品(如网卡)的系列号。只要不更改自己的 MAC 地址，MAC 地址在世界是唯一的。形象地说，MAC 地址就如同身份证上的身份证号码，具有唯一性。



## 3. IP地址

### 3.1 简介

IP协议是为计算机网络相互连接进行通信而设计的协议。在因特网中，它是能使连接到网上的所有计算机网络实现相互通信的一套规则，规定了计算机在因特网上进行通信时应当遵守的规则。任何厂家生产的计算机系统，只要遵守IP协议就可以与因特网互连互通。各个厂家生产的网络系统和设备，如以太网、分组交换网等，它们相互之间不能互通，不能互通的主要原因是因为它们所传 数据的基本单元(技术上称之为“帧”)的格式不同。IP协议实际上是一套由软件程序组成的协议 软件，它把各种不同“帧”统一转换成“IP 数据报”格式，这种转换是因特网的一个最重要的特点，使所有各种计算机都能在因特网上实现互通，即具有“开放性”的特点。正是因为有了IP协议，因特网才得以迅速发展成为世界上最大的、开放的计算机通信网络。因此IP协议也可以叫做“因特网 协议”。



IP地址(Internet Protocol Address)是指互联网协议地址，又译为网际协议地址。IP地址是IP协议提供的一种统一的地址格式，它为互联网上的每一个网络和每一台主机分配一个逻辑地址，以此来屏蔽物理地址的差异。

IP 地址是一个32位的二进制数，通常被分割为4个“8位二进制数”(也就是4个字节)。IP 地址通常用“点分十进制”表示成(a.b.c.d)的形式，其中，a,b,c,d都是 0~255 之间的十进制整数。 例:点分十进IP地(100.4.5.6)，实际上是 32 位二进制数 (01100100.00000100.00000101.00000110)。



### 3.2 IP地址编码方式

最初设计互联网络时，为了便于寻址以及层次化构造网络，每个 IP 地址包括两个标识码(ID)，即网络ID和主机ID。同一个物理网络上的所有主机都使用同一个网络ID，网络上的一个主机(包括网络上工作站，服务器和路由器等)有一个主机 ID 与其对应。Internet 委员会定义了5种IP地址类型以适合不同容量的网络，即A 类~ E类。

其中 A、B、C 3类(如下表格)由 InternetNIC 在全球范围内统一分配，D、E 类为特殊地址。

| 类别 | 最大网络数字 | IP地址范围                | 单个网段最大主机数 | 私有IP地址范围              |
| ---- | ------------ | ------------------------- | ------------------ | --------------------------- |
| A    | 126          | 1.0.0.1-126.255.255.254   | 16777214           | 10.0.0.0-10.255.255.255     |
| B    | 16384        | 128.0.0.0-191.255.255.254 | 65534              | 172.16.0.0-172.31.255.255   |
| C    | 2097152      | 192.0.0.1-223.255.255.254 | 254                | 192.168.0.0-192.168.255.255 |

**A类IP地址**

一个A类IP地址是指，在IP地址的四段号码中，第一段号码为网络号码，剩下的三段号码为本地计算机的号码。如果用二进制表示 IP 地址的话，A 类 IP 地址就由 1 字节的网络地址和 3 字节主机地址组成，网络地址的最高位必须是“0”。A 类IP地址中网络的标识长度为8位，主机标识的长度为24位，A类网络地址数量较少，有126个网络，每个网络可以容纳主机数达 1600 多万台。

A 类 IP 地址 地址范围 1.0.0.1 - 126.255.255.254(二进制表示为:00000001 00000000 00000000 00000001 - 01111111 11111111 11111111 11111110)。最后一个是广播地址。

A 类 IP 地址的子网掩码为 255.0.0.0，每个网络支持的最大主机数为 256 的 3 次方 - 2 = 16777214 台。



**B类IP地址**

一个B类IP地址是指，在IP地址的四段号码中，前两段号码为网络号码。如果用二进制表示 IP 地址的话，B类IP地址就由2字节的网络地址和2字节主机地址组成，网络地址的最高位必须是“10”。B类IP地址中网络的标识长度为16位，主机标识的长度为16位，B类网络地址适用于中等规模的网络，有16384个网络，每个网络所能容纳的计算机数为6万多台。

B类IP 地址地址范围 128.0.0.1 - 191.255.255.254 (二进制表示为:10000000 00000000 00000000 00000001 - 10111111 11111111 11111111 11111110)。 最后一个是广播地址。

B 类 IP 地址的子网掩码为 255.255.0.0，每个网络支持的最大主机数为 256 的 2 次方 - 2 = 65534 台。



**C类IP地址**

一个C类IP地址是指，在IP地址的四段号码中，前三段号码为网络号码，剩下的一段号码为本地计算机的号码。如果用二进制表示 IP 地址的话，C类IP地址就由3字节的网络地址和1字节主机地址组成，网络地址的最高位必须是“110”。C类 IP地址中网络的标识长度为24位，主机标识的长度为8位，C类网络地址数量较多，有209万余个网络。适用于小规模的局域网络，每个网络最多只能包含254台计算机。

C 类 IP 地址范围 192.0.0.1-223.255.255.254 (二进制表示为: 11000000 00000000 00000000 00000001 - 11011111 11111111 11111111 11111110)。

C类IP地址的子网掩码为 255.255.255.0，每个网络支持的最大主机数为 256 - 2 = 254 台。



**特殊的地址**

-   0.0.0.0对应当前主机
-   255.255.255.255是当前子网的广播地址
-   「111110」开头的E类IP地址保留实验使用
-   IP地址中不能以十进制 “127” 作为开头，该类地址中数字 127.0.0.1 到 127.255.255.255 用于回路测试，如:127.0.0.1可以代表本机IP地址



### 3.3 子网掩码

子网掩码(subnet mask)又叫网络掩码、地址掩码、子网络遮罩，它是一种用来指明一个IP地址的哪些位标识的是主机所在的子网，以及哪些位标识的是主机的位掩码。子网掩码不能单独存在，它必须结合IP地址一起使用。子网掩码只有一个作用，就是将某个IP地址划分成网络地址和主机地址两部分。

子网掩码是一个32位地址，用于屏蔽 IP 地址的一部分以区别网络标识和主机标识，并说明该IP地址是在局域网上，还是在广域网上。



子网掩码是在IPv4 地址资源紧缺的背景下为了解决IP地址分配而产生的虚拟IP技术，通过子网掩码将A、B、C 三类地址划分为若干子网，从而显著提高了IP地址的分配效率，有效解决了IP地址资源紧张的局面。另一方面，在企业内网中为了更好地管理网络，网管人员也利用子网掩码的作用，人为地将一个较大的企业内部网络划分为更多个小规模的子网，再利用三层交换机的路由功能实现子网互联，从而有效解决了网络广播风暴和网络病毒等诸多网络管理方面的问题。



根据 RFC950定义，子网掩码是一个32位的2进制数， 其对应网络地址的所有位都置为1，对应于主机地址的所有位置都为0。



## 4. 端口

### 4.1 简介

“端口” 是英文port的意译，可以认为是设备与外界通讯交流的出口。端口可分为虚拟端口和物理端口，其中虚拟端口指计算机内部或交换机路由器内的端口，不可见，是特指TCP/IP协议中的端口，是逻辑意义上的端口。例如计算机中的 80端口、21端口、23端口等。物理端口又称为接口，是可见端口，计算机背板的RJ45网口，交换机路由器集线器等RJ45 端口。电话使用RJ11插口也属于物理端口的范畴。

如果把IP地址比作一间房子，端口就是出入这间房子的门。真正的房子只有几个门，但是一个IP地址的端口可以有 65536(即:2^16)个之多!端口是通过端口号来标记的，端口号只有整数，范围是从0到65535(2^16-1)。

**端口就是一个缓冲区，有读缓冲区和写缓冲区，端口号就是用来标识这一块缓冲区的。**

>    端口会和一个进程绑定，那为什么不用进程号呢？一个进程可以绑定多个端口。
>
>   因为每次启动进程，pid都会变化。

### 4.1 端口类型

**1. 周知端口**

周知端口是众所周知的端口号，也叫知名端口、公认端口或者常用端口，范围从0到1023，它们紧密绑定于一些特定的服务。例如80端口分配给WWW服务，21端口分配给FTP服务，23端口分配给Telnet服务等等。我们在IE的地址栏里输入一个网址的时候是不必指定端口号的，因为在默认情况下WWW服务的端口是“80”。网络服务是可以使用其他端口号的，如果不是默认的端口号则应该在地址栏上指定端口号，方法是在地址后面加上冒号“:”(半角)，再加上端口号。比如使用 “8080”作为WWW服务的端口，则需要在地址栏里输入“网址:8080”。但是有些系统协议使用固定的端口号，它是不能被改 变的，比如139端口专门用于NetBIOS与TCP/IP之间的通信，不能手动改变。

**2. 注册端口**

端口号从 1024到49151，它们松散地绑定于一些服务，分配给用户进程或应用程序，这些进程主要是用户选择安装的一些应用程序，而不是已经分配好了公认端口的常用程序。这些端口在没有被服务器资源占用的时候，可以用用户端动态选用为源端口。

**3. 动态端口/私有端口**

动态端口的范围是从49152到65535。之所以称为动态端口，是因为它一般不固定分配某种服务，而是动态分配。



## 5. 网络模型

### 5.1 OSI七层参考模型

七层模型，亦称OSI(Open System Interconnection)参考模型，即开放式系统互联。参考模型是国际标准化组织(ISO)制定的一个用于计算机或通信系统间互联的标准体系，一般称为OSI参考模型或七层模型。

它是一个七层的、抽象的模型体，不仅包括一系列抽象的术语或概念，也包括具体的协议。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230207224751255.png" alt="image-20230207224751255" style="zoom:40%;" />

>   七字真言：
>
>   「物数网传会表应」

1.   物理层：主要定义物理设备标准，如网线的接口类型、光纤的接口类型、各种传输介质的传输速率等。它的主要作用是传输比特流（就是1、0转换为电流强弱来进行传输，到达目的地后再转换为1、0，也就是数模转换）。这一层的数据称为「比特」。
2.   数据链路层：建立逻辑连接、进行硬件地址寻址、差错校验等功能。定义了如何让格式化数据以「帧」为单位进行传输，以及如何让控制对物理介质的访问。将比特组合成字节进而组合成「帧」，用MAC地址访问介质。对MAC地址进行封装，主要涉及到网卡。
3.   网络层：进行「逻辑地址」寻址，在位于不同地理位置的网络的两个主机系统之间提供连接和路径选择。Internet的发展使得从世界各站点访问信息的用户数大大增加，而网络层正是管理这种连接的层。
4.   传输层：定义了一些传输数据的协议和端口号，如：TCP、UDP等。QQ聊天就是UDP传输的。主要是将从下层接收的数据进行分段和传输，到达目的地址后再进行重组。常常把这一层数据叫做段。
5.   会话层：通过传输层(端口号:传输端口与接收端口)建立数据传输的通路。主要在你的系统之间发起会话或者接受会话请求。
6.   表示层：数据的表示、安全、压缩。主要是进行对接收的数据进行解释、加密与解密、压缩与解压缩等(也就是把计算机能够识别的东西转换成人能够能识别的东西(如图片、声音等)。
7.   应用层：网络服务与最终用户的一个接口。这一层为用户的应用程序(例如电子邮件、文件传输和终端仿真)提供网络服务。



### 5.2 TCP/IP四层模型

####  简介

>   现在 Internet(因特网)使用的主流协议族是「TCP/IP协议族」，它是一个分层、多协议的通信体系。TCP/IP协议族是一个四层协议系统，自底而上分别是数据链路层、网络层、传输层和应用层。每一层完成不同的功能，且通过若干协议来实现，「上层协议使用下层协议提供的服务。」



TCP/IP协议在一定程度上参考了OSI的体系架构，但是简化为4个层次：

1.   应用层、表示层、会话层三个层次提供的服务相差不是很大，所以在 TCP/IP 协议中，它们被合并为应用层一个层次。
2.   由于传输层和网络层在网络协议中的地位十分重要，所以在 TCP/IP 协议中它们被作为独立的两个层次。
3.   因为数据链路层和物理层的内容相差不多，所以在TCP/IP协议中它们被归并在网络接口层一个层次里。只有四层体系结构的TCP/IP协议，与有七层体系结构的OSI相比要简单了不少，也正是这样，TCP/IP协议在实际的应用中效率更高，成本更低。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230207232205058.png" alt="image-20230207232205058" style="zoom:40%;" />

其中OSPF应该在网络层。

1.  应用层:应用层是 TCP/IP 协议的第一层，是直接为应用进程提供服务的。 
    1.  对不同种类的应用程序它们会根据自己的需要来使用应用层的不同协议，邮件传输应用使用了 SMTP 协议、万维网应用使用了 HTTP 协议、远程登录服务应用使用了有 TELNET 协议。 
    2.  应用层还能加密、解密、格式化数据。 
    3.  应用层可以建立或解除与其他节点的联系，这样可以充分节省网络资源。
2.  传输层:作为 TCP/IP 协议的第二层，运输层在整个 TCP/IP 协议中起到了中流砥柱的作用。且在运输层中， TCP 和 UDP 也同样起到了中流砥柱的作用。
3.  网络层:网络层在 TCP/IP 协议中的位于第三层。在 TCP/IP 协议中网络层可以进行网络连接的建立和终止以及 IP 地址的寻找等功能。
4.  网络接口层:在 TCP/IP 协议中，网络接口层位于第四层。由于网络接口层兼并了物理层和数据链路层所以，网络接口层既是传输数据的物理媒介，也可以为网络层提供一条准确无误的线路。



## 6. 协议

协议，网络协议的简称，网络协议是通信计算机双方必须共同遵从的一组约定。如怎么样建立连接、怎么样互相识别等。只有遵守这个约定，计算机之间才能相互通信交流。它的三要素是:**语法、语义、时序**。为了使数据在网络上从源到达目的，网络通信的参与方必须遵循相同的规则，这套规则称为协议 (protocol)，它最终体现为在网络上传输的数据包的格式。 协议往往分成几个层次进行定义，分层定义是为了使某一层协议的改变不影响其他层次的协议。



### 6.1 常见的协议：

-   应用层常见的协议有：FTP协议（File Transfer Protocol文件传输协议）、HTTP协议（Hyper Text Transfer Protocol超文本传输协议）、NFS（Network File System 网络文件系统）
-   传输层常见协议有：TCP协议（Transmission Control Protocol 传输控制协议）、UDP协议（User Datagram Protocal 用户数据报协议）
-   网络层常见的协议有：IP协议（Internet Protocol 因特网互联协议）、ICMP协议（Internet Control Message Protocol 因特网控制报文协议）、IGMP协议（Internet Group Management Protocol 因特网组管理协议）
-   网络接口层常见协议有：ARP协议（Address Resolution Protocol 地址解析协议）、RARP协议（Reverse Address Resolution Protocol 反向地址解析协议）



### 6.2 UDP协议



<img src="https://imgconvert.csdnimg.cn/aHR0cHM6Ly9jZG4uanNkZWxpdnIubmV0L2doL3hpYW9saW5jb2Rlci9JbWFnZUhvc3QyLyVFOCVBRSVBMSVFNyVBRSU5NyVFNiU5QyVCQSVFNyVCRCU5MSVFNyVCQiU5Qy9UQ1AtJUU0JUI4JTg5JUU2JUFDJUExJUU2JThGJUExJUU2JTg5JThCJUU1JTkyJThDJUU1JTlCJTlCJUU2JUFDJUExJUU2JThDJUE1JUU2JTg5JThCLzEyLmpwZw?x-oss-process=image/format,png" style="zoom:90%;" />

-   源端口号：发送方端口号
-   目的端口号：接收方端口号
-   长度：UDP和用户数据报的长度，最小值是8（仅有头部）
-   校验和：检测UDP用户数据再传输的过程中是否有错误，有错就丢弃。



### 6.3 TCP协议



<img src="https://imgconvert.csdnimg.cn/aHR0cHM6Ly9jZG4uanNkZWxpdnIubmV0L2doL3hpYW9saW5jb2Rlci9JbWFnZUhvc3QyLyVFOCVBRSVBMSVFNyVBRSU5NyVFNiU5QyVCQSVFNyVCRCU5MSVFNyVCQiU5Qy9UQ1AtJUU0JUI4JTg5JUU2JUFDJUExJUU2JThGJUExJUU2JTg5JThCJUU1JTkyJThDJUU1JTlCJTlCJUU2JUFDJUExJUU2JThDJUE1JUU2JTg5JThCLzYuanBn?x-oss-process=image/format,png" style="zoom:60%;" />

-   序列号：在建立连接时由计算机生成的随机数作为其初始值，通过 SYN 包传给接收端主机，每发送一次数据，就「累加」一次该「数据字节数」的大小。**用来解决网络包乱序问题。**也就是本报文段数据的第一个字节的序号。
-   确认应答号：：指下一次「期望」收到的数据的序列号，发送端收到这个确认应答以后可以认为在这个序号以前的数据都已经被正常接收。**用来解决丢包的问题。**
-   首部长度（数据偏移）：TCP报文段的数据开始处距离TCP报文段的开始处的距离。
-   紧急URG：此位置 1 ，表明紧急指针字段有效，它告诉系统此报文段中有紧急数据，应尽快传送
-   确认 ACK:仅当 ACK=1 时确认号字段才有效，TCP 规定，在连接建立后所有传达的报文段都必须把 ACK 置1
-   推送 PSH:当两个应用进程进行交互式的通信时，有时在一端的应用进程希望在键入一个命令后立即就能够收到对方的响应。在这种情况下，TCP 就可以使用推送(push)操作，这时，发送方 TCP 把 PSH 置1，并立即创建一个报文段发送出去，接收方收到 PSH = 1 的报文段，就尽快地 (即“推送”向前)交付给接收应用进程，而不再等到整个缓存都填满后再向上交付
-   复位 RST:用于复位相应的 TCP 连接
-   同步 SYN:仅在三次握手建立 TCP 连接时有效。当 SYN = 1 而 ACK = 0 时，表明这是一个连接请求报文段，对方若同意建立连接，则应在相应的报文段中使用 SYN = 1 和 ACK = 1。因此，SYN 置 1 就表示这是一个连接请求或连接接受报文
-   终止 FIN:用来释放一个连接。当 FIN = 1 时，表明此报文段的发送方的数据已经发送完毕，并要 求释放运输连接
-   窗口:指发送本报文段的一方的接收窗口(而不是自己的发送窗口)
-   校验和:校验和字段检验的范围包括首部和数据两部分，在计算校验和时需要加上 12 字节的伪头部
-   紧急指针:仅在 URG = 1 时才有意义，它指出本报文段中的紧急数据的字节数(紧急数据结束后就 是普通数据)，即指出了紧急数据的末尾在报文中的位置，注意:即使窗口为零时也可发送紧急数 据
-   选项:长度可变，最长可达 40 字节，当没有使用选项时，TCP 首部长度是 20 字节





<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/计算机网络/IP/7.jpg" style="zoom: 67%;" />

>   ttl就是最大生存时间



## 7. 网络通信过程

### 7.1 封装

上层协议是如何使用下层协议提供的服务的呢?其实这是通过封装(encapsulation)实现的。应用程序数据在发送到物理网络上之前，将沿着协议栈从上往下依次传递。**每层协议都将在上层数据的基础上加上自己的头部信息(有时还包括尾部信息)，以实现该层的功能，这个过程就称为封装。**



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230208165820711.png" alt="image-20230208165820711" style="zoom:50%;" />



下层的协议给上层的协议使用，通过封装来实现该层功能。



### 7.2 分用

当帧到达目的主机时，将沿着协议栈自底向上依次传递。各层协议依次处理帧中本层负责的头部数据，以获取所需的信息，并最终将处理后的帧交给目标应用程序。这个过程称为分用(demultiplexing)。 分用是依靠头部信息中的类型字段实现的。

Arp通过IP找到Mac地址，`arp -a`可以看到本机的IP地址对应的物理地址。



## 8. socket

### 8.1 socket介绍

所谓socket(套接字)，就是对网络中不同主机上的应用进程之间进行双向通信的端点的抽象。 一个套接字就是网络上进程通信的一端，提供了应用层进程利用网络协议交换数据的机制。从所处的地位来讲，套接字上联应用进程，下联网络协议栈，是应用程序通过网络协议进行通信的接口，是应用程序与网络协议根进行交互的接口。

socket可以看成是两个网络应用程序进行通信时，各自通信连接中的端点，这是一个逻辑上的概念。它是网络环境中进程间通信的API，也是可以被命名和寻址的通信端点，使用中的每一个套接字都有其类型和一个与之相连进程。通信时其中一个网络应用程序将要传输的一段信息写入它所在 主机的socket中，该socket通过与网络接口卡(NIC)相连的传输介质将这段信息送到另外一台主机的socket中，使对方能够接收到这段信息。socket是由IP地址和端口结合的，提供向应用层进程传送数据包的机制。

socket 本身有“插座”的意思，在Linux环境下，用于表示进程间网络通信的特殊文件类型。本质为内核借助缓冲区形成的伪文件。既然是文件，那么理所当然的，我们可以使用文件描述符引用套接字。与管道类似的，Linux系统将其封装成文件的目的是为了统一接口，使得读写套接字和读写文件的操作一致。区别是管道主要应用于本地进程间通信，而套接字多应用于网络进程间数据的传递。**那么它也对应了文件描述符。**所以可以使用文件描述符。



同时本地socket可以用于同一台主机上进程间通信的场景。



>   socket通信分为两个部分
>
>   -   服务器端：被动接受连接，一般不会主动发起连接
>   -   客户端：主动向服务器发起连接
>
>   socket是一套通信的接口，在Linux、Windows下都有，但是有一些细微的差别。

### 8.2 字节序

现代的32位CPU累加器每一次都能装载（至少）4字节，也就是一个`int`。那么这4个字节在内存中是排列的顺序将影响它倍累加器装载成的整数的值，这就是字节序问题。在各种计算机体系结构中，对于字节、字等的存储机制有所不同，因而引发了计算机通信领域中一个很重要的问 题，即通信双方交流的信息单元(比特、字节、字、双字等等)应该以什么样的顺序进行传送。如果不达成一致的规则，通信双方将无法进行正确的编码/译码从而导致通信失败。 **字节序，顾名思义字节的顺序，就是大于一个字节类型的数据在内存中的存放顺序(一个字节的数据当然就无需谈顺序的问题了)**。

字节序分为大端字节序(Big-Endian) 和小端字节序(Little-Endian)。大端字节序是指一个整 数的最高位字节(23~31 bit)存储在内存的低地址处，低位字节(0 ~ 7 bit)存储在内存的高地 址处;小端字节序则是指整数的高位字节存储在内存的高地址处，而低位字节则存储在内存的低地址处。



>   -   大端是高字节存放在内存的低地址，地址由小向大增加，而数据从高位往低位放。和我们”从左到右“阅读习惯一
>   -   小端是高字节存放在内存的高地址，<u>高地址部分权值高，低地址部分权值低，和我们的逻辑方法一致</u>



X86是小端，ARM可小端可大端，默认小端。



**判断本机是大端还是小端：**

```cpp

//检测当前主机的字节序
#include <stdio.h>

int main()
{
    union 
    {
        short value; //2个字节
        char bytes[sizeof(short)]; //数组大小也是两个字节
    } test;

    test.value = 0x0102;

    //地址位低的,如果获取到高位数据
    if((test.bytes[0]== 1)  && (test.bytes[1] == 2))
    {
            printf("这是大端字节序\n");
    }
    else
    {
        printf("这是小端字节序\n");
    }
    return 0;
}
```



### 8.3 字节序转换函数

当格式化的数据在两台使用不同字节序的主机之间直接传递时，接收端必然错误的解释之。解决问题的方法是:发送端总是把要发送的数据转换成大端字节序数据后再发送，而接收端知道对方传送过来的数据总是采用大端字节序，所以接收端可以根据自身采用的字节序决定是否对接收到的数据进行转换(小端机转换，大端机不转换)。



**网络字节顺序**是 TCP/IP 中规定好的一种数据表示格式，它与具体的 CPU 类型、操作系统等无关，从而可以保证数据在不同主机之间传输时能够被正确解释，网络字节顺序采用大端排序方式。



>   h：host主机，主机字节序
>
>   to：转换成什么
>
>   n：network 网络字节序
>
>   s：short     unsigned short
>
>   l：long     unsigned int
>
>   冷知识：long和int都是32位。



```cpp
#include <arpa/inet.h>
// 转换端口 2个字节
uint16_t htons(uint16_t hostshort);  //主机字节序- 网络字节序
uint16_t ntohs(uint16_t netshort); //网络字节序 - 主机字节序
// 转IP 4个字节
uint32_t htonl(uint32_t hostlong); 
uint32_t ntohl(uint32_t netlong);
```



在网络通信时，需要将主机字节序（不一定是小端）转为网络字节序，另外一端根据情况将网络字节序转换成主机字节序。



**bytetrans.c**

```cpp
#include <stdio.h>
#include <arpa/inet.h>

int main()
{
    unsigned short a = 0x0102;
    unsigned short b = htons(a);

    //输出201
    printf("%x\n", b);

    char buf[4] = {192, 168, 1, 100};
    int num =  *(int *) buf;
    unsigned int sum =  htonl(num);
    
    unsigned char *p = (char *)&sum;
    
    printf("%d %d %d %d\n", *p ,*(p + 1), * (p + 2), * (p + 3));

    //ntohs
    unsigned char buf1[4] = {1, 1, 168, 192};
    int num1 = *(int *) buf1;

    int sum1 =  ntohl(num1);
    unsigned char *p1 = (unsigned char *)&(sum1);
    printf("%d %d %d %d\n", *p1, *(p1 + 1), *(p1 + 2), *(p1 +3));
    
    //ntohl
    return 0;
}

```



### 8.4 socket地址

socket地址就是对就是端口和IP的封装，其实是一个结构体，后面的socket的api都要用到socket地址。



#### 8.4.1 通用socket地址

`sockaddr`结构体表示socket的地址，给IPv4用的：

```cpp
#include <bits/socket.h>
struct sockaddr {
    sa_family_t sa_family;
    char        sa_data[14];
};
typedef unsigned short int sa_family_t;
```

`sa_family_t`代表地址族类型。地址族类型通常与协议族类型对应。常见的协议族（protocol family，也叫domain）和对应的地址族表示：

| 协议族   | 地址族   | 描述             |
| -------- | -------- | ---------------- |
| PF_UNIX  | AF_UNIX  | UNIX本地域协议族 |
| PF_INET  | AF_INET  | TCP/IPv4协议族   |
| PF_INET6 | AF_INET6 | TCP/IPv6协议族   |

每一行的宏都定义在`<bits/socket.h>`头文件中，而且完全相同，所以可以混用



`sa_data`成员用于存放socket的地址值，但是不同协议族的地址值具有不同的含义和长度，如下所示：

| 协议族   | 地址值含义和长度                                             |
| -------- | ------------------------------------------------------------ |
| PF_UNIX  | 文件的路径名，长度可以达到108字节                            |
| PF_INET  | 16bit的端口号和32bit的IPv4地址，共6字节                      |
| PF_INET6 | 16bit端口号，32bit的标识流，128bit的IPv6地址，32bit范围ID，共26字节 |

由上表可知，14字节的`sa_data`根本无法容纳多数协议族的地址值。因此，Linux定义了下面这个新的通用的socket地址结构体，这个结构体不仅提供了足够大的空间用于存放地址值，而且是内存对齐的。



**sockaddr_storage:**

```cpp
#include <bits/socket.h>
struct sockaddr_storage
{
    sa_family_t sa_family;
    unsigned long int __ss_align;
    char __ss_padding[ 128 - sizeof(__ss_align) ]; //存储具体的IP数据
};
typedef unsigned short int sa_family_t;
```



#### 8.4.2 专用socket地址

很多网络编程函数诞生早于IPv4协议，那时候都使用的是struct sockaddr结构体，为了向前兼容，现在sockaddr退化成了(void *)的作用，传递一个地址给函数，至于这个函数是sockaddr_in还是sockaddr_in6，由地址族确定，然后函数内部再强制类型转化为所需的地址类型。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230209153453843.png" alt="image-20230209153453843" style="zoom:40%;" />

UNIX本地域协议族使用如下专用的socket地址结构体:

```cpp
#include <sys/un.h>
struct sockaddr_un
{
    sa_family_t sin_family;
    char sun_path[108];
};
```

TCP/IP 协议族有`sockaddr_in` 和 `sockaddr_in6` 两个专用的 socket 地址结构体，它们分别用于 IPv4 和 IPv6:



```cpp
#include <netinet/in.h>
struct sockaddr_in
{
    sa_family_t sin_family;
    in_port_t sin_port;
    struct in_addr sin_addr;
    /* Pad to size of `struct sockaddr'. */
    unsigned char sin_zero[sizeof (struct sockaddr) - __SOCKADDR_COMMON_SIZE -
};

struct in_addr
{
/* __SOCKADDR_COMMON(sin_) */
/* Port number.  */
/* Internet address.  */
sizeof (in_port_t) - sizeof (struct in_addr)];
    in_addr_t s_addr;
};
struct sockaddr_in6
{
    sa_family_t sin6_family;
    in_port_t sin6_port;    /* Transport layer port # */
    uint32_t sin6_flowinfo; /* IPv6 flow information */
    struct in6_addr sin6_addr;  /* IPv6 address */
    uint32_t sin6_scope_id; /* IPv6 scope-id */
};
typedef unsigned short  uint16_t;
typedef unsigned int    uint32_t;
typedef uint16_t in_port_t;
typedef uint32_t in_addr_t;
#define __SOCKADDR_COMMON_SIZE (sizeof (unsigned short int))
```

所有专用 socket 地址(以及 `sockaddr_storage`)类型的变量在实际使用时都需要转化为通用 socket 地 址类型 `sockaddr`(强制转化即可)，因为所有 socket 编程接口使用的地址参数类型都是` sockaddr`。



## 9. IP地址转换

将字符串的ip转换为整数，比如用点分湿紧致字符串表示IPv4地址，以及用十六进制字符串表示IPv6地址。但编程过程中，我们需要把它们转化为整数（二进制）方便使用。而记录日志时则相反，我们要把我们要把整数表示的 IP 地址转化为可读的字符串。下面3个函数可用于用点分十进制字符串表示的 IPv4 地址和用网络字节序整数表示的 IPv4 地址之间的转换:

```cpp
#include <arpa/inet.h>
in_addr_t inet_addr(const char *cp);
int inet_aton(const char *cp, struct in_addr *inp);
char *inet_ntoa(struct in_addr in); //返回字符串（点分十进制）
```

但是这三个函数比较旧了，只适用IPv4地址。



下面这对更新的函数也能完成前面3个函数同样的功能，并且它们同时适用IPv4和IPv6地址：

```cpp
#include <arpa/inet.h>
int inet_pton(int af, const char *src, void *dst);
const char *inet_ntop(int af, const void *src, char *dst, socklen_t size);
```

函数名中的`p`代表点分十进制的字符串,`n`表示网络字节序的整数，`aton`和`pton`就代表转换。



```cpp
int inet_pton(int af, const char *src, void *dst);
//将点分十进制的字符串转换为网络字节序的整数
```

-   `af`：地址族，`AF_INET`，`AF_INET6`
-   `src`：需要转换的点分十进制的IP字符串
-   `dest`：转换后的结果保存在里面



```cpp
const char *inet_ntop(int af, const void *src, char *dst, socklen_t size);
//将网络字节序的整数，转换成点分十进制的字符串
```

-   `af`：地址族，`AF_INET`，`AF_INET6`
-   `src`：要转换的ip的整数的地址
-   `dst`：转成IP地址字符串保存的地方
-   `size`：第三个参数的大小，char数组的大小
-   返回值：转换后的字符串的地址，和`dst`是一样的。



测试这两个函数：

**iptrans.c**

```cpp
#include <stdio.h>
#include <arpa/inet.h>

int main()
{
    //创建一个ip字符串,一个点分十进制的字符串
    char buf[] = "192.168.1.4"; 

    //保存转换后的值
    unsigned int num = 0;
    
    inet_pton(AF_INET, buf, &num); //num小端存储转换后的字符串，192在数据的低位，也在存储的低位

    unsigned char *p = (unsigned char *)&num;
    printf("%d %d %d %d\n", *p, *(p + 1), *(p + 2), *(p + 3));


    //将网络字节序的IP整数转换成点分十进制的IP字符串
    //定义一个16长度的字符串
    char ip[16] = "";
    const char* str =    inet_ntop(AF_INET, &num, ip,sizeof(ip));
    
    //事实上,ip和str是一样的
    printf("%s\n", str);
    return 0;
}
```



## 10. TCP通信流程

>   UDP是面向无连接的，可以单播，多播，广播，面向数据报，它是一个不可靠的协议。UDP没有拥塞控制。
>
>   TCP：传输控制协议，一种面向连接的传输协议，可靠的。基于字节流的，仅支持单播传输（点对点）。



|                | UDP                            | TCP                                |
| -------------- | ------------------------------ | ---------------------------------- |
| 是否创建连接   | 无连接的                       | 面向连接的                         |
| 是否可靠       | 不可靠                         | 可靠的                             |
| 连接对象的个数 | 一对一、一对多、多对一、多对多 | 仅支持一对一                       |
| 传输的方式     | 面向数据报                     | 面向字节流                         |
| 头部开销       | 8个字节                        | 最少20个字节                       |
| 使用场景       | 实时应用（QQ、视频会议、直播） | 可靠性高的应用（文件传输、下载等） |



![图的来源是小林coding](https://imgconvert.csdnimg.cn/aHR0cHM6Ly9jZG4uanNkZWxpdnIubmV0L2doL3hpYW9saW5jb2Rlci9JbWFnZUhvc3QyLyVFOCVBRSVBMSVFNyVBRSU5NyVFNiU5QyVCQSVFNyVCRCU5MSVFNyVCQiU5Qy9UQ1AtJUU0JUI4JTg5JUU2JUFDJUExJUU2JThGJUExJUU2JTg5JThCJUU1JTkyJThDJUU1JTlCJTlCJUU2JUFDJUExJUU2JThDJUE1JUU2JTg5JThCLzM0LmpwZw?x-oss-process=image/format,png)


>    图的来源是[小林coding](xiaolincoding.com)。



TCP通信的流程：

**服务器端：**

1.   创建一个用于监听的套接字

     -   监听：监听所有客户端的连接
     -   套接字：这个套接字其实就是一个文件描述符

1.   将这个监听文件描述符和本地IP和端口绑定（IP和端口就是服务器的地址信息）

     -   客户端连接服务器的时候，使用的就是这个IP和端口

1.   设置监听，监听的fd开始工作
1.   阻塞等待，当有客户端发起连接，解除阻塞，接受客户端的连接，会得到一个和客户端通信的「套接字」（也就是又生成了一个套接字，专门用来和客户端进行通信）。
1.   通信
     -   接收数据
     -   发送数据
1.   通信结束，断开连接。



**客户端：**

1.   创建一个用于通信的套接字（文件描述符）
2.   连接服务器，需要指定连接的服务器的IP和端口
3.   连接成功了，客户端可以直接和服务器通信
     -   接收数据
     -   发送数据
4.   通信结束，断开连接



## 11. 套接字函数

```cpp
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h> // 包含了这个头文件，上面两个就可以省略
int socket(int domain, int type, int protocol);
```

-    功能：创建一个套接字
-   参数：
    -   `domain`：也就是协议族，填入一些宏，例如`AF_UNIX`,`AF_INET`,`AF_INET6`等，分别代表本地套接字通信，IPv4和IPv6。
    -   `type`：通信过程中使用的协议类型，
        -   `SOCK_STREAM`, 流式协议
        -   `SOCK_DGRAM`, 报式协议
    -   `protocol`：具体的协议。一般传入0
        -   第二个参数传入`SOCK_STREAM`，默认使用TCP
        -   第二个参数传入`SOCK_DGRAM`，默认使用UDP
-   返回值：成功，返回一个文件描述符，操作的就是内核缓冲区。失败返回-1。



```cpp
int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
```

-   功能：绑定，将fd和本地的IP和端口绑定。也叫socket命名。
-   参数：
    -   `socket`：通过`socket()`函数返回的文件描述符
    -   `address`：需要绑定的`sockaddr`，里面封装了IP和端口号的信息
    -   `address_len`：第二个参数结构体占用的内存大小。
-   返回值：成功返回0，失败返回-1



```cpp
int listen(int sockfd, int backlog);
```

-   功能：监听某个socket上的连接。同时会有两个队列，一个是未连接的队列，一个是已连接的队列。
-   参数：
    -   `sockfd`：
    -   `backlog`：定义的是「两个队列之和」的最大值，不用太大，一般指定5就够了。可以在`/proc/sys/net/core/somaxconn`查看。
-   返回值：成功返回0，失败返回-1



```cpp
int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
```

-   功能：接收客户端连接，默认是一个阻塞的函数，阻塞等待客户端连接
-   参数：
    -   `sockfd`：用于监听的文件描述符
    -   `addr`：传出参数，记录了连接成功后，客户端的地址信息（IP和端口）
    -   `addrlen`：指定第二个参数对应的内存大小，注意是一个指针，不能直接`sizeof`
-   返回值：
    -   成功：返回用于通信的文件描述符
    -   -1：失败



```cpp
int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
```

-   功能：客户端连接服务器
-   参数：
    -   `sockfd`：用于通信的文件描述符
    -   `addr`：客户端要连接的服务器的地址信息
    -   `addrlen`：第二个参数的内存大小，不是指针，可以直接`sizeof`
-   返回值：成功0，失败-1.





## 12. TCP通信实现

**服务器端：server.c**

```cpp
//实现TCP通信的服务器端

#include <stdio.h>
#include <string.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <unistd.h>
int main()
{
    //1. 创建socket套接字,用于监听
    int lfd = socket(AF_INET, SOCK_STREAM, 0);

    //2. 绑定
    struct sockaddr_in saddr;
    saddr.sin_family = AF_INET;

    //转换为整数
    // inet_pton(AF_INET, "192.168. 193.128", saddr.sin_addr.s_addr);
    saddr.sin_addr.s_addr = INADDR_ANY; //代表服务端的来源可以是任意(如果有多张网卡)

    saddr.sin_port = htons(9999);

    int ret = bind(lfd, (struct sockaddr*) &saddr, sizeof(saddr));
    if(-1 == ret)
    {
        perror("bind");
        exit(0);
    }

    //3. 监听
    ret = listen(lfd, 8);
     if(-1 == ret)
    {
        perror("listen");
        exit(0);
    }

    //4. 接收客户端连接
    struct sockaddr_in clientaddr;
    socklen_t len = sizeof(clientaddr);
    int cfd = accept(lfd, (struct sockaddr *)&clientaddr, &len);
    if(-1 == cfd)
    {
        perror("accept");
        exit(-1);
    }

    //输出客户端的信息
    char cliIp[16];
    inet_ntop(AF_INET, &clientaddr.sin_addr.s_addr, cliIp, sizeof(cliIp));

    unsigned short clientPort = ntohs(clientaddr.sin_port);
   
    printf("client ip is %s, port is %d\n", cliIp, clientPort);

    //5. 通信
    //获取客户端的数据
    char recvBuf[1024] = {0};
    while(1)
    {
        int len1 = read(cfd, recvBuf, sizeof(recvBuf));
        if(len1 == -1)
        {
            perror("read");
            exit(-1);
        }
        else if (len1 > 0)
        {
            printf("recv client data %s\n", recvBuf);
        }
        else if (len1 == 0)
        {
            //客户端断开连接
            printf("client closed");
            break;
        }



        //给客户端发送数据
        char* data = "hello, i am server";
        write(cfd, data, strlen(data));
    }
    //关闭文件描述符
    close(cfd);
    close(lfd);

    
    return 0;
}
```



**客户端：client.c**

```cpp
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <arpa/inet.h>

int main()
{
    //创建套接字
    int fd = socket(AF_INET, SOCK_STREAM, 0);

    //连接服务器
    //
    struct sockaddr_in serveraddr;
    serveraddr.sin_family = AF_INET;
    inet_pton(AF_INET, "127.0.0.1", &serveraddr.sin_addr.s_addr);
    serveraddr.sin_port = htons(9999);
    int ret = connect(fd, (struct sockaddr*)&serveraddr, sizeof(serveraddr));
    
    
    //通信
    //写入数据
    char* data = "hello, i am client";
    while(1){
        write(fd, data, strlen(data));

        //读取数据
        char recvBuf[1024] = {0};
        int len = read(fd, recvBuf, sizeof recvBuf);
        
        if(len > 0)
        {
            printf("recv server data :%s\n", recvBuf);
        }
        sleep(1);
    }
    close(fd);
    return 0;
    
}

```



客户端每秒会向服务器端发送数据`hello i am client`。

## 13. TCP三次握手

TCP是一种面向连接的单播协议，在发送数据前，通信双方必须在彼此之间建立一条连接，所谓的「连接」，其实就是客户端和服务器内存里保存的一份关于对方的信息，如IP地址、端口号等。

TCP可以看成是一种字节流，它会处理IP层或以下的层的丢包、重复以及错误问题。在连接建立的过程中，双方需要交换一些连接的参数，这些参数可以放在TCP头部。

TCP提供了一种可靠、面向连接、字节流、传输层的服务，采用三次握手建立一个连接，采用四次挥手来关闭一个连接。三次握手的目的是保证双方互相之间建立了连接。

三次握手发生在客户端连接的时候，当调用`connect()`函数的时候，底层会通过TCP协议进行三次握手。



<img src="https://imgconvert.csdnimg.cn/aHR0cHM6Ly9jZG4uanNkZWxpdnIubmV0L2doL3hpYW9saW5jb2Rlci9JbWFnZUhvc3QyLyVFOCVBRSVBMSVFNyVBRSU5NyVFNiU5QyVCQSVFNyVCRCU5MSVFNyVCQiU5Qy9UQ1AtJUU0JUI4JTg5JUU2JUFDJUExJUU2JThGJUExJUU2JTg5JThCJUU1JTkyJThDJUU1JTlCJTlCJUU2JUFDJUExJUU2JThDJUE1JUU2JTg5JThCLzYuanBn?x-oss-process=image/format,png" style="zoom:60%;" />

-   URG标志，表示紧急指针是否有效
-   ACK标志，表示确认号是否有效。我们称携带ACK标志的TCP报文段为确认报文段。
-   RST标志
-   SYN标志
-   FIN标志

### 13.1 为什么要三次握手？

<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost4/网络/TCP三次握手.drawio.png" style="zoom:60%;" />

简单的原因：「“因为三次握手才能保证双方具有接收和发送的能力。”」

「Ack Num」和「Seq Num」分别代表确认应答号和序列号。

只有是SYN和FIN的时候，确认序号才会+1



<img src="https://imgconvert.csdnimg.cn/aHR0cHM6Ly9jZG4uanNkZWxpdnIubmV0L2doL3hpYW9saW5jb2Rlci9JbWFnZUhvc3QyLyVFOCVBRSVBMSVFNyVBRSU5NyVFNiU5QyVCQSVFNyVCRCU5MSVFNyVCQiU5Qy9UQ1AtJUU0JUI4JTg5JUU2JUFDJUExJUU2JThGJUExJUU2JTg5JThCJUU1JTkyJThDJUU1JTlCJTlCJUU2JUFDJUExJUU2JThDJUE1JUU2JTg5JThCLzE1LmpwZw?x-oss-process=image/format,png" style="zoom:67%;" />

-   客户端随机初始化序号（`client_isn`），将此序号放在TCP首部的「序列号」字段中，同时把`SYN`的标志置为1，表示`SYN`报文。接着把第一个SYN报文发送给服务端，表示向服务端发起连接，该报文不包含应用层数据，之后客户端处于`SYN-SENT`状态。

<img src="https://imgconvert.csdnimg.cn/aHR0cHM6Ly9jZG4uanNkZWxpdnIubmV0L2doL3hpYW9saW5jb2Rlci9JbWFnZUhvc3QyLyVFOCVBRSVBMSVFNyVBRSU5NyVFNiU5QyVCQSVFNyVCRCU5MSVFNyVCQiU5Qy9UQ1AtJUU0JUI4JTg5JUU2JUFDJUExJUU2JThGJUExJUU2JTg5JThCJUU1JTkyJThDJUU1JTlCJTlCJUU2JUFDJUExJUU2JThDJUE1JUU2JTg5JThCLzE2LmpwZw?x-oss-process=image/format,png" style="zoom:67%;" />

-   服务端收到客户端的`SYN`报文后，首先服务器端也会初始化自己的序列号（`server_isn`），将此序号放入TCP首部的「序列号」字段中，然后把「确认应答号」字段填入`client_isn + 1`，接着把`SYN`和`ACK`标志置为1.最后把报文发送给客户端，该报文也不用包含应用层数据，之后服务端处于`SYN-RCVD`状态。



<img src="https://imgconvert.csdnimg.cn/aHR0cHM6Ly9jZG4uanNkZWxpdnIubmV0L2doL3hpYW9saW5jb2Rlci9JbWFnZUhvc3QyLyVFOCVBRSVBMSVFNyVBRSU5NyVFNiU5QyVCQSVFNyVCRCU5MSVFNyVCQiU5Qy9UQ1AtJUU0JUI4JTg5JUU2JUFDJUExJUU2JThGJUExJUU2JTg5JThCJUU1JTkyJThDJUU1JTlCJTlCJUU2JUFDJUExJUU2JThDJUE1JUU2JTg5JThCLzE3LmpwZw?x-oss-process=image/format,png" style="zoom:67%;" />

-   客户端收到服务端报文后，还要向服务端回应最后一个应答报文，首相该应答报文TCP首部`ACK`标志位置为1，之后「确认应答号」字段填入`server_isn + 1`，最后把报文发送给服务端，这次报文可以携带客户到服务端的数据，之后客户端处于`ESTABLISHED`状态
-   服务端收到客户端的应答报文后，也进入`ESTABLISHED`状态，之后双发就可以相互发送数据了。



## 14. TCP滑动窗口

TCP为了保证可靠性，用了非常多的机制，称得上是一个「伟大」的协议。

滑动窗口是TCP中实现诸如ACK确认、流量控制、拥塞控制的承载结构。

滑动窗口会随着发送数据和接收数据而变化。

通信双方都有发送缓冲区和接收数据的缓冲区。

窗口大小就是指**无需等待确认应答，而可以继续发送数据的最大值**。

![image-20230210161624593](https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230210161624593.png)

发送方：

-   红色格子：还没有发送出去的数据
-   灰色格子：发送出去但是还没接收的数据
-   白色格子：空闲区域

接收方：

-   白色格子：空闲区域
-   红色格子：已经接收到的数据



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230210162448139.png" alt="image-20230210162448139" style="zoom:40%;" />

MSS：最大报文段大小，一条数据的最大大小

WIN：滑动窗口的（剩余）大小

1.   客户端向服务器发起连接，客户端的滑动窗口是4096，一次发送的最大数据量是1460
2.   服务器接收连接情况，告诉客户端服务器窗口大小是6144，一次发送的最大数据量是1024
3.   第三次握手
4.   4-9 客户端连续给服务器发送了6K数据，每次发送1K
5.   第10次，服务器告诉客户端：发送的6K数据已经接收到，存储在缓冲区中，缓冲区数据已经处理了2k，窗口大小是2k
6.   第11次，服务器告诉客户端：发送的6K数据已经接收到，存储在缓冲区中，缓冲区数据已经处理了4k，窗口大小是4k
7.   第12次，客户端给服务器发送了客户端给服务器发送了1k的数据
8.   下面就是四次挥手的过程
     1.   第13次，客户端主动请求和服务器断开连接，并且给服务器发送了1K的数据
     2.   第14次，服务器端回复了一个ACK，在此状态，服务器可能会传输数据（第15、16都是通知客户端滑动窗口的大小）
     3.   17，服务器发送FIN，请求断开连接
     4.   客户端统一服务器端断开请求。

## 15. TCP四次挥手

四次挥手，在程序中调用`close()`函数会进行四次挥手。

客户端和服务端都可以主动发起断开连接，谁先调用`close()`，就是谁发起。因为在TCP连接的时候，采用三次握手建立的连接是双向的，所以在断开的时候，也需要双向断开。

<img src="https://img-blog.csdnimg.cn/18635e15653a4affbdab2c9bf72d599e.png" style="zoom:67%;" />

-   断开连接发送 FIN报文，这个 FIN报文代表客户端不会再发送数据了，进入 FIN_WAIT_1状态
-   服务器
-   

有的时候，会出现三次挥手。



## 16. 多进程实现并发服务器

>   并发：两队人,一台咖啡机☕️
>
>   并行：两队人,两台咖啡机☕️



实现并发服务器，可以有多台客户机器连接服务器，要实现TCP通信服务器并发，

思路：

-   一个父进程，多个子进程
-   父进程负责等待并接受客户端的连接
-   子进程：完成通信，接受一个客户端连接，就创建一个子进程用于通信







**server_pthread.c**

```cpp
#include <stdio.h>
#include <pthread.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>


struct sockInfo
{
    int fd; //通信的文件描述符
    struct sockaddr_in addr;
    pthread_t tid; //线程号

};

//表示同时支持128个客户端连接
struct sockInfo sockinfos[128];

void* working(void* arg)
{
    //子线程和客户端通信
    //需要的参数, cfd, 客户端的信息 线程号等信息
     //子进程
    //获取客户端的信息
    struct sockInfo* pinfo = (struct sockInfo*) arg;
    char cliIp[16];
    inet_ntop(AF_INET, &pinfo->addr.sin_addr.s_addr, cliIp, sizeof(cliIp));
    unsigned short cliPort = ntohs(pinfo->addr.sin_port);
    printf("client ip is : %s, port is %d\n", cliIp, cliPort);

    //接收客户端发来的数据
    char recvBuf[1024] = {0};
    while(1)
    {
        int len = read(pinfo->fd, &recvBuf, sizeof(recvBuf));

        if(len == -1)
        {
            perror("read");
            exit(-1);
        }
        else if(len > 0)
        {
            printf("recv client : %s\n", recvBuf);
        }
        else
        {
            printf("client closed.... \n");
            break;
        }

        //把读到的发送回去
        write(pinfo->fd, recvBuf, strlen(recvBuf) + 1);
    }

    close(pinfo->fd);
    
    //退出当前子进程
    exit(0);

    return NULL;
}

int main()
{

    //1. 创建socket
    int lfd = socket(PF_INET, SOCK_STREAM, 0);
    if(-1 == lfd)
    {
        perror("socket");
        exit(-1);
    }

    //绑定
    struct sockaddr_in saddr;
    saddr.sin_family = AF_INET;
    saddr.sin_port = htons(9999);
    saddr.sin_addr.s_addr = INADDR_ANY;
    int ret = bind(lfd, (struct sockaddr*)&saddr, sizeof(saddr));
    if(-1 == ret)
    {
        perror("bind");
        exit(-1);
    }

    //监听
    ret = listen(lfd, 128);
    if(-1 == ret)
    {
        perror("listen");
        exit(-1);
    }

    //初始化数据
    int max = sizeof(sockinfos) / sizeof(sockinfos[0]);
    for (size_t i = 0; i < max; i++)
    {
        bzero(&sockinfos[i], sizeof(sockinfos[i]));
        sockinfos[i].fd = -1;
        sockinfos[i].tid = -1;
    }
    

    //循环等待客户端连接, 一旦一个客户端连接进来,就创建一个子线程进行通信
    while(1)
    {
        struct sockaddr_in  cliaddr;
        int len = sizeof(cliaddr);
        // 接受连接
        //软中断回到accept时,accept是不阻塞的, 产生一个错误EINTR
        int cfd = accept(lfd, (struct sockaddr*)&cliaddr, &len);
        struct sockInfo* pinfo;

        for(int i = 0; i < max; i++)
        {
            //从这个数组中找到一个可用的sockInfo元素
            if(sockinfos[i].fd == -1)
            {
                pinfo = &sockinfos[i];
                break;
            }
            if(i == max - 1)
            {
                sleep(1);
                i--;//持续等待
            }
        }
        pinfo->fd = cfd;
        memcpy(&(pinfo->addr), &cliaddr, len);
        //创建子线程
        pthread_create(&pinfo->tid, NULL, working, pinfo);

        pthread_detach(pinfo->tid);

    }
    close(lfd);

    return 0;
}
```



## 17. TCP的状态转换

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230211165358817.png" alt="image-20230211165358817" style="zoom:50%;" />

TIME_WAIT定时经过两倍报文寿命之后结束，2MSL（Maximum Segment Lifetime），为了一定的安全性，保证通信的另一方能接受到最后一次ACK。MSL官方建议2分钟，实际是30s。

四次挥手可以是服务器发起，也可以是客户端发起。

![image-20230211170106576](https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230211170106576.png)



1.   红色的线可以看作客户端（主动打开，建立连接）
2.   绿色的虚线可以看作服务端。
3.   



**四次挥手 FIN和ACK为什么不一同发送？**

因为另一方可能还有数据没有发送完。第二次挥手和第三次挥手之间还可能发送数据。



>   当 TCP 连接主动关闭方接收到被动关闭方发送的 FIN 和最终的 ACK 后，连接的主动关闭方必须处于TIME_WAIT 状态并持续 2MSL 时间。
>    这样就能够让 TCP 连接的主动关闭方在它发送的 ACK 丢失的情况下重新发送最终的 ACK。
>
>   主动关闭方重新发送的最终 ACK 并不是因为被动关闭方重传了 ACK(它们并不消耗序列号， 被动关闭方也不会重传)，而是因为被动关闭方重传了它的 FIN。事实上，被动关闭方总是重传 FIN 直到它收到一个最终的ACK。

**第四次挥手丢失了，会发生什么？**
服务端（被动关闭方）就会重发 FIN 报文，重发次数由tcp_orphan_retries 参数控制，重传次数超过 tcp_orphan_retries 后，就不再发送 FIN 报文，直接进入到 close 状态。



### 17.1 半关闭

当 TCP 链接中 A 向 B 发送 FIN 请求关闭，另一端 B 回应 ACK 之后(A 端进入 FIN_WAIT_2 状态)，并没有立即发送 FIN 给 A，A 方处于半连接状态(半开关 / 半关闭)，此时 A 可以接收 B 发 送的数据，但是 A 已经不能再向 B 发送数据。

从程序的角度，可以使用API来控制实现半关闭状态：

```cpp
#include <sys/socket.h>
int shutdown(int sockfd, int how);
```

-   功能：关闭一部分全双工连接
-   参数
    -   `sockfd`：需要关闭的sockfd操作符
    -   `how`：如何关闭
        -   `SHUT_RD`：关闭sockfd的读功能。该套接字不再接受数据，任何在当前套接字读缓冲区都被丢弃。
        -   `SHUT_WR`：关闭sockfd的写。
        -   `SHUT_RDWR`：关闭sockfd的读写。相当于调用`shutdown`两次。



使用`close()`终止一个连接，但是它只是减少文件描述符的引用计数，并不直接关闭连接，只有当描述符的引用计数为0时才关闭连接，而`shutdown`不会考虑文件描述符的文件描述符，直接终止某一个方向的连接。



>   1.   如果有多个进程共享一个套接字，`close` 每被调用一次，计数减 1 ，直到计数为 0 时，也就是所用 进程都调用了` close`，套接字将被释放。
>   2.    在多进程中如果一个进程调用了 `shutdown(sfd, SHUT_RDWR) `后，其它的进程将无法进行通信。 但如果一个进程` close(sfd)` 将不会影响到其它进程。



## 18. 端口复用

端口复用最常用的用途是：

-   防止服务器重启之前绑定的端口还没有释放
-   程序突然退出而系统没有释放端口



socket专用的接受函数

```cpp
#include <sys/types.h>
#include <sys/socket.h>
ssize_t recv(int sockfd, void *buf, size_t len, int flags);
```

-   参数
    -   `flags`指定读这些数据的一些行为（非阻塞等）



查看网络相关信息的命令：

```shell
netstat -apn
```

参数：

-   -a ： 显示所有的socket
-   -p：显示正在使用socket的程序的名称
-   -n：直接使用ip地址，而不通过服务器
-   -l：显示正在监听的socket



如果在一台机器上同时启动一个服务器和一个客户端，服务器绑定9999端口，使用`netstat`会有三个进程：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230216201456650.png" alt="image-20230216201456650" style="zoom:67%;" />

其中一有两个server的原因是有一个进程是专门用来监听的，还有一个用于通信。

如果我们关闭服务器（而不关闭客户端），服务器端会主动发起关闭，则客户端处于`CLOSE_WAIT`状态，服务器端处于`FIN_WAIT2`状态。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230216201744220.png" alt="image-20230216201744220" style="zoom:50%;" />

如果再重启服务器，会显示address already used!（有2MSL的时间处于TIME_WAIT状态）



如果想立即重启服务器，可以使用端口复用，使用系统API：

```cpp
int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen);
```

-   功能：设置套接字的属性（不仅仅能设置端口复用）
-   参数：
    -   `sockfd`：要操作的文件描述符
    -   `level`：如果使用端口复用功能，使用`SOL_SOCKET`
    -   `optname`：如果使用端口复用功能，使用`SO_REUSEADDR`和`SO_REUSEPORT`
    -   `optval`：端口复用的值（int），1代表可以复用，0代表不可以复用
    -   `optlen`：`optval`参数的大小

端口复用设置的时机是在服务器绑定端口之前，也就是先设置`setsockopt`，再调用`bind`。

**核心代码：**

```cpp
   int optval = 1;
   setsockopt(lfd, SOL_SOCKET, SO_REUSEPORT, &optval, sizeof(optval));

   // 绑定
   int ret = bind(lfd, (struct sockaddr *)&saddr, sizeof(saddr));
   if(ret == -1) {
   ¦   perror("bind");
   ¦   return -1;
   }

```

这样就可以立即重启服务器了，不必等待TIME_WATI。





## 19. I/O多路复用

也叫I/O多路转接。

I/O多路复用使得程序能同时监听多个文件描述符，提高程序的性能，Linux下实现I/O多路复用的系统调用主要有`select`、`poll`、`epoll`。

### 19.1 几种IO模型

**阻塞等待模型/BIO模型**

阻塞等待，如果没有数据来到，`read`就一直阻塞。

好处：不占用CPU宝贵的时间片

缺点：同一时刻智能处理一个操作，效率低



这个模型可以用多线程或者多进程来解决。

缺点：

1.   线程或者进程会消耗资源
2.   线程或者进程调度消耗CPU资源

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230216210703764.png" alt="image-20230216210703764" style="zoom:50%;" />

每一个进程/线程对应一个客户端，read/recv都是阻塞的。**根本原因是：blocking（阻塞），导致程序不能继续往下走。**



**NIO模型**

非阻塞，忙轮询

程序会一直执行accept和read，而不是阻塞在accept。

我们可以使用IO多路复用技术：select/poll/epolls

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230216211957734.png" alt="image-20230216211957734" style="zoom:50%;" />

优点：提高程序的执行效率

缺点：需要占用更多CPU和系统资源



此时可以使用IO多路复用技术来解决这个问题。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230216212554632.png" alt="image-20230216212554632" style="zoom:50%;" />

快递对应文件描述符，select/poll只会告诉你哪几个文件描述符有数据到达，打开了哪几个需要遍历。



而epoll又有不同：

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230216212821434.png" alt="image-20230216212821434" style="zoom:50%;" />



### 19.2 select

主旨思想：

1.   首先构造一个关于文件描述符的列表，将要监听的文件描述符添加到该列表中
2.   调用系统函数`select`，监听该列表中的文件描述符，直到这些文件描述符中的一个或者多个进行了IO操作时，该函数才返回
     -   `select`是阻塞的
     -   `select`对文件描述符的检测操作是由内核完成的
3.   在返回时，它会告诉进程有多少（哪些）描述符要进行IO操作。

 ```cpp
 /* According to POSIX.1-2001 */
 #include <sys/select.h>
 
 /* According to earlier standards */
 #include <sys/time.h>
 #include <sys/types.h>
 #include <unistd.h>
 int select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout);
 ```

-   参数
    -   `nfds`委托内核检测的最大文件描述符的值 + 1
    -   `readfds`：要检测的文件描述符的读的集合，委托内核检测哪些文件描述符的读的属性
        -   这个类型有128字节，共1024位，
        -   一般检测读操作
        -   对应的是对方发送过来的数据，因为读是被动的接受数据，检测的就是读缓冲区
        -   是一个传入传出参数
    -   `writefds`是`fd_set`的指针，代表要检测的文件描述符的写的结合，委托内核检车哪些文件描述符的写的属性（写缓冲区不满就可以写）。一般不检测`writefds`。
    -   `exceptfds`是检测发生异常的文件描述符的集合
    -   `timeout`：这个结构体内有两个属性「秒+微秒」，设置超时时间。
        -   NULL代表永久阻塞，直到检测到了文件描述符有变化。
        -   0代表不阻塞
        -   \>0代表阻塞对应的时间
-   返回值：
    -   -1：调用失败
    -   \>0的值：检测的集合中有n哥文件描述符发生了变化



```cpp
//将set中fd文件描述符设置为0
void FD_CLR(int fd, fd_set *set);
//判断set中fd标志位是0还是1，将这个值返回
int  FD_ISSET(int fd, fd_set *set);
//将参数文件描述符对应的标志位设置为1
void FD_SET(int fd, fd_set *set);
//将set中每一位都置0，共1024bit
void FD_ZERO(fd_set *set);
```



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230216221128728.png" alt="image-20230216221128728" style="zoom:50%;" />



#### 代码示例

内核如果没有检测到数据就置为0，返回给用户态（传入的`read`可能发生变化），经过一个`select`调用，由于会把没有数据的位置0，而有时客户端还没断开，所以需要引入一个对应的tmp，我们交给内核是tmp，而程序自己维护的rdset是自己修改的。



不使用多线程或者多进程来实现多个客户端连接：

**select.c**

```cpp
#include <stdio.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/select.h>

int main()
{
    //注意都没有判断
    //创建socket
    int lfd = socket(PF_INET, SOCK_STREAM, 0);
    struct sockaddr_in saddr;
    saddr.sin_port = htons(9999);
    saddr.sin_family = AF_INET;
    saddr.sin_addr.s_addr = INADDR_ANY;


    //绑定
    bind(lfd, (struct sockaddr*) &saddr, sizeof(saddr));

    //监听
    listen(lfd, 8);

    //采用NIO模型
    //创建一个fd_set的集合, 存放需要检测的文件描述符
    //fd_set是一个long int 的数, 能表示1024个文件描述符
    fd_set rdset, tmp;
    //首先全部置为0
    FD_ZERO(&rdset);
    //添加需要检测的文件描述符
    //首先添加监听的文件描述符
    FD_SET(lfd, &rdset);
    int maxfd = lfd;

    while(1)
    {
        tmp = rdset;
        //调用select系统函数，让内核帮助检测哪些文件描述符有数据
        //最后一个参数填NULL代表永久阻塞, 知道rdset发生变化
        int ret = select(maxfd + 1, &tmp, NULL, NULL, NULL);
        if(-1 == ret)
        {
            perror("select");
            exit(-1);
        }
        else if (0 == ret)
        {
            //超时时间到了, 同时没有检测到
            //在本例子中，显然不可能为0，因为我们设置的timeout为NULL
            printf("ret == 0");
            continue;
        }
        else if (ret > 0)
        {
            //说明检测到了有文件描述符对应的缓冲区的数据发生了改变
            //返回的是个数, 我们并不不知道是哪几个文件描述符对应的缓冲区有数据

            //首先检查lfd
            if(FD_ISSET(lfd, &tmp))
            {
                //表示有客户端连接进来
                struct sockaddr_in cliaddr;
                int len = sizeof cliaddr;
                int cfd = accept(lfd, (struct sockaddr*) &cliaddr, &len );

                //将新的文件描述符添加到集合中
                FD_SET(cfd, &rdset);

                //同时更新最大的文件描述符
                maxfd = maxfd > cfd ? maxfd : cfd;
            }

            //遍历文件描述符(注意区间)
            for(int i = lfd + 1; i <= maxfd; ++i)
            {
                if(FD_ISSET(i, &tmp))
                {
                    //说明发送来了数据
                    char buf[1024] = {0};
                    int len = read(i, buf, sizeof(buf));
                    if(len == -1)
                    {
                        //错误
                        perror("read");
                        exit(-1);
                    }
                    else if (0 == len)
                    {
                        //对方断开连接
                        printf("client closed...\n");
                        //同时关闭对应的文件描述符,并且清空
                        close(i);
                        FD_CLR(i, &rdset);
                    }
                    else if(len > 0)
                    {
                        printf("read buf = %s\n", buf);
                        write(i, buf, strlen(buf) + 1);
                    }
                }
            }

        }
    }

    close(lfd);

    return 0;

}
```



**client.c**

```cpp
#include <stdio.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

int main() {

    // 创建socket
    int fd = socket(PF_INET, SOCK_STREAM, 0);
    if(fd == -1) {
        perror("socket");
        return -1;
    }

    struct sockaddr_in seraddr;
    inet_pton(AF_INET, "127.0.0.1", &seraddr.sin_addr.s_addr);
    seraddr.sin_family = AF_INET;
    seraddr.sin_port = htons(9999);

    // 连接服务器
    int ret = connect(fd, (struct sockaddr *)&seraddr, sizeof(seraddr));

    if(ret == -1){
        perror("connect");
        return -1;
    }

    int num = 0;
    while(1) {
        char sendBuf[1024] = {0};

        //这里不需要换行, 服务器收到数据换行就行， 不然会有两个换行
        sprintf(sendBuf, "send data %d", num++);
        //发送数据
        write(fd, sendBuf, strlen(sendBuf) + 1);

        // 接收
        int len = read(fd, sendBuf, sizeof(sendBuf));
        if(len == -1) {
            perror("read");
            return -1;
        }else if(len > 0) {
            printf("read buf = %s\n", sendBuf);
        } else {
            printf("服务器已经断开连接...\n");
            break;
        }
        sleep(1);
    }

    close(fd);

    return 0;
}


```



>   简单说下我的看法吧：
>
>   本来`accept`是阻塞的，每个线程/进程只能调用一次，但是现在引入`select`，为了不让他阻塞产生BIO的情况才选择监听lfd，而`select`可以遍历文件描述符，如果有文件描述符（可能是多个）产生变化，则`select`返回，此时再遍历文件描述符的缓冲区（使用`read`，就可以读取多个文件描述符的缓冲区）
>
>   其实要清楚的是，如果只是单纯的在`while`循环中无限遍历所有的文件描述符也可以做到这一点，但是`select`是阻塞的，不会占用过多的CPU时间片，只有有数据返回时才return， 但是不用`select`则程序会在`while(1)`里面空转，占用过多CPU。

#### select()多路复用的缺点

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230218201527433.png" alt="image-20230218201527433" style="zoom:40%;" />

1.   每次调用`select`，都要把fd集合从用户态拷贝到内核台，这个开销在fd很多的时候会很大。
2.   同时每次调用`select`都需要在内核遍历传递进来所有fd
3.   `select`支持的文件描述符太小了，默认是1024
4.   fds集合不能重复使用，每次都需要重制

### 19.3 poll

`poll`是对`select`的改进，实现原理相似。

```cpp
#include <poll.h>
int poll(struct pollfd *fds, nfds_t nfds, int timeout);

//poollfd结构体，也就是需要检测的文件描述符
struct pollfd {
    int   fd;         /* file descriptor */// 委托内核检测的文件描述符
    short events;     /* requested events */ //委托内核检测文件描述符的什么事件
    short revents;    /* returned events */ //文件描述符实际发生的事件
};
```



**`events`和`revents`的取值：**

如果要检测多个事件，用`|`连接。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230218204803341.png" alt="image-20230218204803341" style="zoom:50%;" />

-   参数：
    -   `fds`：是一个`struct pollfd`的结构体数组，类似于`fd_set`，也是一个需要检测的文件描述符的集合，这个数组可以重用，内核修改的是`revents`，而我们委托的是`events`，同时没有1024个文件描述符的限制。
    -   `nfds`：是第一个参数数组中最后一个有效元素的下标 + 1
    -   `timeout`：阻塞时长
        -   0：表示不阻塞
        -   -1：阻塞，当检测到需要检测的文件描述符有变化，解除阻塞
        -   \>0的值：阻塞的时长，单位是毫秒（milliseconds）
-   返回值：
    -   -1：表示失败
    -   \>0：成功，表示检测到集合中有几个文件描述符发生变化



```cpp
#define _GNU_SOURCE         /* See feature_test_macros(7) */
#include <poll.h>
int ppoll(struct pollfd *fds, nfds_t nfds,
          const struct timespec *timeout_ts, const sigset_t *sigmask);
```



#### 代码

需要注意，此时`i`代表数组的索引，真正的文件描述符是`fds[i].fd`。

**poll.c**

```cpp
#include <stdio.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/select.h>
#include <poll.h>

int main()
{
    //注意都没有判断
    //创建socket
    int lfd = socket(PF_INET, SOCK_STREAM, 0);
    struct sockaddr_in saddr;
    saddr.sin_port = htons(9999);
    saddr.sin_family = AF_INET;
    saddr.sin_addr.s_addr = INADDR_ANY;


    //绑定
    bind(lfd, (struct sockaddr*) &saddr, sizeof(saddr));

    //监听
    listen(lfd, 8);

    //创建并初始化检测的文件描述符数组
    //数组的大小可以指定
    struct pollfd fds[1024];

    //C下的初始化
    for(int i = 0; i < 1024; ++i)
    {
        fds[i].fd = -1;
        //表示检测读事件
        fds[i].events = POLLIN;
    }

    //第一个数据对应监听的文件描述符
    fds[0].fd = lfd;
    int nfds = 0;

    while(1)
    {
        //调用poll系统函数，让内核帮助检测哪些文件描述符有数据
        int ret = poll(fds, nfds + 1, -1);
        if(-1 == ret)
        {
            perror("select");
            exit(-1);
        }
        else if (0 == ret)
        {
            //超时时间到了, 同时没有检测到
            //在本例子中，显然不可能为0，因为我们设置阻塞
            printf("ret == 0");
            continue;
        }
        else if (ret > 0)
        {
            //说明检测到了有文件描述符对应的缓冲区的数据发生了改变
            //返回的是个数, 我们并不不知道是哪几个文件描述符对应的缓冲区有数据

            //首先检查lfd
            //不能直接写==0, 因为revents可能有多个事件, 他们用 | 连接
            if(fds[0].revents & POLLIN )
            {
                //表示有客户端连接进来
                struct sockaddr_in cliaddr;
                int len = sizeof (cliaddr);
                int cfd = accept(lfd, (struct sockaddr*)&cliaddr, &len );

                //将新的文件描述符添加到集合中
                for(int i = 1; i < 1024; ++i)
                {
                    //找到一个可用的(未被占用的文件描述符)
                    if(fds[i].fd == -1)
                    {
                        fds[i].fd = cfd;
                        
                        fds[i].events = POLLIN;

                        //同时更新最大的文件描述符
                        nfds = nfds > i ? nfds : i;
                        printf("nfds = %d\n", nfds);
                        break;
                    }
                }

            }

            //遍历文件描述符(注意区间)
            for(int i = 1; i <= nfds; ++i)
            {
                if(fds[i].revents & POLLIN)
                {
                    //说明发送来了数据
                    char buf[1024] = {0};
                    int len = read(fds[i].fd, buf, sizeof(buf));
                    if(len == -1)
                    {
                        //错误
                        perror("read");
                        exit(-1);
                    }
                    else if (0 == len)
                    {
                        //对方断开连接
                        printf("client closed...\n");
                        //同时关闭对应的文件描述符,并且清空
                        close(fds[i].fd);
                        //表示不可用
                        fds[i].fd = -1;
                    }
                    else if(len > 0)
                    {
                        printf("read buf = %s\n", buf);
                        write(i, buf, strlen(buf) + 1);
                    }
                }
            }

        }
    }

    close(lfd);

    return 0;

}
```



#### poll的缺点

poll实际上是对select的改进，但是仍然有：

-   每次调用都需要把fds集合从用户态拷贝到内核台
-   每次都要遍历传递进来的所有fd

也就是改进了select的3、4缺点，但是还是保留了1、2。

### 19.4 epoll

#### 简介

用`epoll_create`创建一个epoll实例，在内核中创建一个`eventpoll`，返回一个文件描述符，通过文件描述符来操作这个内存（通过一些函数，不是直接操作）。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230218215607474.png" alt="image-20230218215607474" style="zoom:40%;" />



  

`rbr`是一个红黑树，`rdlist`代表就绪列表（代表有数据改变），可以通过`epoll_ctl()`控制,调用`epoll_wait()`函数来从`rbr`中检测，改变的文件描述符放到`rdlist`（ready—list），返回`epoll_wait()`，这里只拷贝了一部分数据，同时还告诉是哪几个发生改变，并且发生的事件是什么，用户只需要直接遍历就可以了。

#### epoll API

```cpp
#include <sys/epoll.h>

int epoll_create(int size);
```

-   作用：创建一个epoll实例，在内核中创建一个数据，这个数据中有两个重要数据：
    -   需要检测的文件描述符（红黑树） 
    -   就绪列表，存放检测到数据发生改变的文件描述符（双向链表）
-   参数：`size`目前没有意义了，随便写一个数（但是要\>0），以前是用hash来实现的
-   返回值：
    -   `>0`：文件描述符，操作`epoll`实例的
    -   `-1`：调用失败



```cpp
#include <sys/epoll.h>

int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event);
struct epoll_event {
    uint32_t     events;      /* Epoll events */
    epoll_data_t data;        /* User data variable */
};
typedef union epoll_data {
    void        *ptr;
    int          fd;
    uint32_t     u32;
    uint64_t     u64;
} epoll_data_t;
```

-   作用：对`epoll`实例进行管理，添加文件描述符信息，删除信息，修改信息
-   参数：
    -   `epfd`：epoll实例对应的文件描述符
    -   `op`：要进行的操作，传入宏
        -   `EPOLL_CTL_ADD`：添加
        -   `EPOLL_CTL_MOD`：修改
        -   `EPOLL_CTL_DEL`：删除
    -   `fd`：要检测的文件描述符
    -   `event`：检测文件描述符的具体事件，是一个`epoll_event`结构体：
        -   `events`代表检测的事件，例如`EPOLLIN`,`EPOLLOUT`,`EPOLLERR`等
        -   `data`又是一个`union epoll_data_t`，里面的四个只有一个有用，我们用`fd`就够了





```cpp
#include <sys/epoll.h>

int epoll_wait(int epfd, struct epoll_event *events,
               int maxevents, int timeout);
```

-   作用：检测函数
-   参数：
    -   `epfd`：epoll实例对应的文件描述符
    -   `events`：传出参数，保存发生变化的文件描述符的信息，通过这个参数就知道「有哪些文件描述符发生改变了」和「发生的事件」。
    -   `maxevents`：第二个参数的最大值（第二个参数的大小）
    -   `timeout`：阻塞时长，单位是ms，
        -   0代表不阻塞
        -   -1代表永久阻塞知道检测到数据发生变化
        -   \>0代表时长
-   返回值：
    -   成功：返回发生变化的文件描述符的个数\>0
    -   失败：返回-1



#### 代码

**epoll.c**

这个代码只对读逻辑进行了处理，如果`epev.enents`有多个，例如`EPOLLIN | EPOLLOUT`，则需要在`else`中进行`&`操作来判断，对每一种事件进行处理。

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/epoll.h>

int main()
{
     //注意都没有判断
    //创建socket
    int lfd = socket(PF_INET, SOCK_STREAM, 0);
    struct sockaddr_in saddr;
    saddr.sin_port = htons(9999);
    saddr.sin_family = AF_INET;
    saddr.sin_addr.s_addr = INADDR_ANY;


    //绑定
    bind(lfd, (struct sockaddr*) &saddr, sizeof(saddr));

    //监听
    listen(lfd, 8);

    //调用epoll_creat()创建epoll实例
    int epfd = epoll_create(100);
    //将监听的文件描述符添加到epoll实例中
    struct epoll_event epev = 
    {
        .data.fd = lfd,
        .events = EPOLLIN,
    };
    epoll_ctl(epfd, EPOLL_CTL_ADD, lfd, &epev);
    

    struct epoll_event epevs[1024];
    
    while(1)
    {

        //调用epoll_wait
        int ret = epoll_wait(epfd, epevs, 1024, -1);
        if(-1 == ret)
        {
            perror("epoll_wait");
            exit(-1);
        }

        // >0代表检测到有几个文件描述符发生改变了
        //输出这个数字
        printf("ret = %d\n", ret);

        for(int i = 0; i < ret; ++i)
        {
            int curfd = epevs[i].data.fd;
            if(curfd == lfd)
            {
                //监听的文件描述符有数据到达, 也就是有客户端连接
                struct sockaddr_in cliaddr;
                int len = sizeof(cliaddr);
                int cfd = accept(lfd, (struct sockaddr*)&cliaddr, &len);

                epev.events = EPOLLIN;
                epev.data.fd = cfd;

                //添加一个epev到epoll中
                epoll_ctl(epfd, EPOLL_CTL_ADD, cfd, &epev);
            }
            else
            {
                //有数据到达
                char buf[1024] = {0};
                int len = read(curfd, buf, sizeof(buf));
                if(len == -1)
                {
                    //错误
                    perror("read");
                    exit(-1);
                }
                else if (0 == len)
                {
                    //对方断开连接
                    printf("client closed...\n");
                    //同时关闭对应的文件描述符,并且清空
                    close(curfd);
                    epoll_ctl(epfd, EPOLL_CTL_DEL, curfd, NULL);
                }
                else if(len > 0)
                {
                    printf("read buf = %s\n", buf);
                    write(curfd , buf, strlen(buf) + 1);
                }
            }
        }
    }

    close(lfd);
    close(epfd);
    return 0;
}
```



### 19.5 epoll的两种工作模式

-   **LT模式（水平触发）**

    LT（level-triggered）是缺省的工作方式，并且同时支持block和non-block socket。在这种做法中，内核告诉你一个文件描述符是否就绪了，然后你可以对这个就绪的fd进行IO操作，如果你不做任何操作，内核还会继续通知你的。

-   **ET模式（边缘触发）**

    ET（edge-triggered）是高速工作方式，只支持no-block socket。在这种模式下，当描述符从未就绪变为就绪时，内核通过epoll告诉你，然后它会假设你知道文件描述符已经就绪，并且不会再为那个文件描述符发送更多的就绪通知，直到你做了某些操作导致那个文件描述符不再为就绪状态了。但是请注意，如果一直不对这个fd进行IO操作（从而导致它再次变为未就绪），内核不会发送更多的同时（only once）。

    ET模式在很大程度上减少了epoll事件被重复处罚的次数，因此效率要比LT要高，epoll工作在ET模式的时候，必须使用非阻塞套接口，以免由于一个文件句柄的「阻塞读」或「阻塞写」操作把处理多个文件描述符的任务饿死。



假设委托内核检测读事件，也就是检测fd的读缓冲区：

-   读缓冲区有数据：epoll检测到了会给用户通知：
-   对于LT模式：
    -   用户不读数据：数据一直在缓冲区，epoll会一直通知
    -   用户只读了一部分数据，epoll会通知
    -   缓冲区数据读完了，epoll不会通知
-   对于ET模式：
    -   用户不读数据，数据一直在缓冲区，epoll下次检测的时候就不会通知了
    -   用户只读了一部分数据，epoll不会通知
    -   缓冲区数据读完了，也不通知





>   当询问chatGPT：「水平触发和边缘触发的区别」
>
>   水平触发（Level Triggered）和边缘触发（Edge Triggered）是 epoll I/O 多路复用机制中的两种不同触发方式。
>
>   在水平触发模式下，当一个文件描述符上有数据到达时，epoll_wait 函数会立即返回，应用程序可以通过读取该文件描述符来处理到达的数据。如果数据没有被处理完全，epoll_wait 函数会一直返回该文件描述符上的事件，直到数据被处理完毕。
>
>   而在边缘触发模式下，当一个文件描述符上有数据到达时，epoll_wait 函数只会返回一次该文件描述符上的事件，并且仅在文件描述符上有新的事件到达时才会返回。因此，在边缘触发模式下，应用程序需要尽可能快地读取所有到达的数据，否则可能会丢失一些数据。
>
>   边缘触发模式相对于水平触发模式更加高效，因为它可以减少 epoll_wait 函数的调用次数，从而降低系统调用的开销。但是，边缘触发模式对应用程序的编写要求也更高，需要确保能够及时读取到所有到达的数据。
>
>   总的来说，水平触发模式是 epoll I/O 多路复用的默认模式，可以用于处理大部分的 I/O 事件。而边缘触发模式可以提高处理效率，但需要开发人员更加小心谨慎地编写代码，以避免出现数据丢失等问题。



#### 水平触发模式

**epoll_LT.c**

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/epoll.h>

int main()
{
     //注意都没有判断
    //创建socket
    int lfd = socket(PF_INET, SOCK_STREAM, 0);
    struct sockaddr_in saddr;
    saddr.sin_port = htons(9999);
    saddr.sin_family = AF_INET;
    saddr.sin_addr.s_addr = INADDR_ANY;


    //绑定
    bind(lfd, (struct sockaddr*) &saddr, sizeof(saddr));

    //监听
    listen(lfd, 8);

    //调用epoll_creat()创建epoll实例
    int epfd = epoll_create(100);
    //将监听的文件描述符添加到epoll实例中
    struct epoll_event epev = 
    {
        .data.fd = lfd,
        .events = EPOLLIN,
    };
    epoll_ctl(epfd, EPOLL_CTL_ADD, lfd, &epev);
    

    struct epoll_event epevs[1024];
    
    while(1)
    {

        //调用epoll_wait
        int ret = epoll_wait(epfd, epevs, 1024, -1);
        if(-1 == ret)
        {
            perror("epoll_wait");
            exit(-1);
        }

        // >0代表检测到有几个文件描述符发生改变了
        //输出这个数字
        printf("ret = %d\n", ret);

        for(int i = 0; i < ret; ++i)
        {
            int curfd = epevs[i].data.fd;
            if(curfd == lfd)
            {
                //监听的文件描述符有数据到达, 也就是有客户端连接
                struct sockaddr_in cliaddr;
                int len = sizeof(cliaddr);
                int cfd = accept(lfd, (struct sockaddr*)&cliaddr, &len);

                epev.events = EPOLLIN;
                epev.data.fd = cfd;

                //添加一个epev到epoll中
                epoll_ctl(epfd, EPOLL_CTL_ADD, cfd, &epev);
            }
            else
            {
                //有数据到达
                char buf[5] = {0};
                int len = read(curfd, buf, sizeof(buf));
                if(len == -1)
                {
                    //错误
                    perror("read");
                    exit(-1);
                }
                else if (0 == len)
                {
                    //对方断开连接
                    printf("client closed...\n");
                    //同时关闭对应的文件描述符,并且清空
                    close(curfd);
                    epoll_ctl(epfd, EPOLL_CTL_DEL, curfd, NULL);
                }
                else if(len > 0)
                {
                    printf("read buf = %s\n", buf);
                    write(curfd , buf, strlen(buf) + 1);
                }
            }
        }
    }

    close(lfd);
    close(epfd);
    return 0;
}
```



#### 边缘触发模式

首先在 `epoll_event`中添加`EPPLLET`事件，但是这样会导致数据可能没有读完，所以需要添加「一次性读完缓冲区数据」的代码。

同时还需要注意，如果在非阻塞状态下，`read`完了之后继续`read`,会出现`EAGAIN`错误，需要避免这个错误。

```cpp
#include <stdio.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/epoll.h>
#include <fcntl.h>
#include <errno.h>

int main() {

    // 创建socket
    int lfd = socket(PF_INET, SOCK_STREAM, 0);
    struct sockaddr_in saddr;
    saddr.sin_port = htons(9999);
    saddr.sin_family = AF_INET;
    saddr.sin_addr.s_addr = INADDR_ANY;

    // 绑定
    bind(lfd, (struct sockaddr *)&saddr, sizeof(saddr));

    // 监听
    listen(lfd, 8);

    // 调用epoll_create()创建一个epoll实例
    int epfd = epoll_create(100);

    // 将监听的文件描述符相关的检测信息添加到epoll实例中
    struct epoll_event epev;
    epev.events = EPOLLIN;
    epev.data.fd = lfd;
    epoll_ctl(epfd, EPOLL_CTL_ADD, lfd, &epev);

    struct epoll_event epevs[1024];

    while(1) {

        int ret = epoll_wait(epfd, epevs, 1024, -1);
        if(ret == -1) {
            perror("epoll_wait");
            exit(-1);
        }

        printf("ret = %d\n", ret);

        for(int i = 0; i < ret; i++) {

            int curfd = epevs[i].data.fd;

            if(curfd == lfd) {
                // 监听的文件描述符有数据达到，有客户端连接
                struct sockaddr_in cliaddr;
                int len = sizeof(cliaddr);
                int cfd = accept(lfd, (struct sockaddr *)&cliaddr, &len);

                // 设置cfd属性非阻塞
                int flag = fcntl(cfd, F_GETFL);
                flag |= O_NONBLOCK;
                fcntl(cfd, F_SETFL, flag);

                epev.events = EPOLLIN | EPOLLET;    // 设置边沿触发
                epev.data.fd = cfd;
                epoll_ctl(epfd, EPOLL_CTL_ADD, cfd, &epev);
            } else {
                if(epevs[i].events & EPOLLOUT) {
                    continue;
                }  

                // 循环读取出所有数据
                char buf[5];
                int len = 0;
                while( (len = read(curfd, buf, sizeof(buf))) > 0) {
                    // 打印数据
                    // printf("recv data : %s\n", buf);
                    write(STDOUT_FILENO, buf, len);
                    write(curfd, buf, len);
                }
                if(len == 0) {
                    printf("client closed....");
                }else if(len == -1) {
                    if(errno == EAGAIN) {
                        printf("data over.....");
                    }else {
                        perror("read");
                        exit(-1);
                    }
                    
                }

            }

        }
    }

    close(lfd);
    close(epfd);
    return 0;
}
```



## 20. UDP通信

### 20.1 实现

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230219195210334.png" alt="image-20230219195210334" style="zoom:40%;" />

UDP是以数据报的方式发送数据，不用建立连接。

```cpp
#include <sys/types.h>
#include <sys/socket.h>

ssize_t sendto(int sockfd, const void *buf, size_t len, int flags,
               const struct sockaddr *dest_addr, socklen_t addrlen);
```

-   作用：发送数据
-   参数：
    -   `sockfd`：通信的fd
    -   `buf`：要发送的数据
    -   `len`：发送数据的长度
    -   `flags`：0
    -   `dest_addr`：通信的另外一端的地址信息（发给谁）
    -   `addrlen`：地址的内存大小
-   返回值：
    -   成功：返回发送的字节数量
    -   失败：-1



```cpp

ssize_t recvfrom(int sockfd, void *buf, size_t len, int flags,
                 struct sockaddr *src_addr, socklen_t *addrlen);
```

-   作用：接受数据
-   参数：
    -   `sockfd`：通信的fd
    -   `buf`：接收的数据的数组
    -   `len`：数组的大小
    -   `flags`：0
    -   `src_addr`：用来保存另外一端的地址信息，不需要可以指定为`NULL`
    -   `addrlen`：`src_addr`对应的大小
-   返回值：
    -   成功：接收到的字节数量
    -   失败：-1



#### 代码

**udp_server.c**

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <arpa/inet.h>

int main() {

    // 1.创建一个通信的socket
    int fd = socket(PF_INET, SOCK_DGRAM, 0);
    
    if(fd == -1) {
        perror("socket");
        exit(-1);
    }   

    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(9999);
    addr.sin_addr.s_addr = INADDR_ANY;

    // 2.绑定
    int ret = bind(fd, (struct sockaddr *)&addr, sizeof(addr));
    if(ret == -1) {
        perror("bind");
        exit(-1);
    }

    // 3.通信
    while(1) {
        char recvbuf[128];
        char ipbuf[16];

        struct sockaddr_in cliaddr;
        int len = sizeof(cliaddr);

        // 接收数据
        int num = recvfrom(fd, recvbuf, sizeof(recvbuf), 0, (struct sockaddr *)&cliaddr, &len);

        printf("client IP : %s, Port : %d\n", 
            inet_ntop(AF_INET, &cliaddr.sin_addr.s_addr, ipbuf, sizeof(ipbuf)),
            ntohs(cliaddr.sin_port));

        printf("client say : %s\n", recvbuf);

        // 发送数据
        sendto(fd, recvbuf, strlen(recvbuf) + 1, 0, (struct sockaddr *)&cliaddr, sizeof(cliaddr));

    }

    close(fd);
    return 0;
}
```



**udp_client.c**

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <arpa/inet.h>

int main() {

    // 1.创建一个通信的socket
    int fd = socket(PF_INET, SOCK_DGRAM, 0);
    
    if(fd == -1) {
        perror("socket");
        exit(-1);
    }   

    // 服务器的地址信息
    struct sockaddr_in saddr;
    saddr.sin_family = AF_INET;
    saddr.sin_port = htons(9999);
    inet_pton(AF_INET, "127.0.0.1", &saddr.sin_addr.s_addr);

    int num = 0;
    // 3.通信
    while(1) {

        // 发送数据
        char sendBuf[128];
        sprintf(sendBuf, "hello , i am client %d \n", num++);
        sendto(fd, sendBuf, strlen(sendBuf) + 1, 0, (struct sockaddr *)&saddr, sizeof(saddr));

        // 接收数据
        int num = recvfrom(fd, sendBuf, sizeof(sendBuf), 0, NULL, NULL);
        printf("server say : %s\n", sendBuf);

        sleep(1);
    }

    close(fd);
    return 0;
}
```





### 20.2 广播

广播是向子网中多台计算机发送消息，并且子网中所有的计算机都可以接收到发送方发送的消息，每个广播消息都包含一个特殊的IP地址，这个IP中子网内「主机标识部分的二进制全部为1」。

1.   只能在局域网中使用
2.   客户端需要绑定服务器广播使用的端口，还可以接收到广播消息。



我们需要在服务端设置广播属性，客户端绑定服务端设置的广播属性的端口。

```cpp
int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen);
```

-   `sockfd`：文件描述符
-   `level`：SOL_SOCKET
-   `optname`：SO_BROADCAST
-   `optval`：int类型的值，1表示允许广播
-   `optlen`：`optval`的大小





**bro_server.c**

需要注意广播地址需要用`ifconfig`查看，而不是单纯的把IP地址的最后1个字节设置为255.

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <arpa/inet.h>

int main()
{

    // 1.创建一个通信的socket
    int fd = socket(PF_INET, SOCK_DGRAM, 0);
    
    if(fd == -1) {
        perror("socket");
        exit(-1);
    }   

    //2. 设置广播属性
    int op = 1;
    setsockopt(fd, SOL_SOCKET, SO_BROADCAST, &op, sizeof(op));

    //创建一个广播的地址
    struct sockaddr_in cliaddr = 
    {
        .sin_family = AF_INET,
        .sin_port = htons(9999),
    };
    inet_pton(AF_INET, "172.25.239.255", &cliaddr.sin_addr.s_addr);


    // 3.通信
    int num = 0;
    while(1) 
    {
        char sendBuf[128];
        sprintf(sendBuf, "hello, client : %d\n", num++);
        //发送数据
        sendto(fd, sendBuf, strlen(sendBuf) + 1, 0, (struct sockaddr *)&cliaddr, sizeof(cliaddr));
        printf("广播的数据: %s\n", sendBuf);
        sleep(1);
    }

    close(fd);
    return 0;
}
```



**bro_client.c**

按照接收方需要绑定端口来理解；这个时候服务器是发起方，客户端才是接收方，需要绑定接收端口。

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <arpa/inet.h>

int main() {

    // 1.创建一个通信的socket
    int fd = socket(PF_INET, SOCK_DGRAM, 0);
    if(fd == -1) {
        perror("socket");
        exit(-1);
    }   

    struct in_addr in;

    // 2.客户端绑定本地的IP和端口
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(9999);
    addr.sin_addr.s_addr = INADDR_ANY;

    int ret = bind(fd, (struct sockaddr *)&addr, sizeof(addr));
    if(ret == -1) {
        perror("bind");
        exit(-1);
    }

    // 3.通信
    while(1) {
        
        char buf[128];
        // 接收数据
        int num = recvfrom(fd, buf, sizeof(buf), 0, NULL, NULL);
        printf("server say : %s\n", buf);

    }

    close(fd);
    return 0;
}
```



### 20.3 组播（多播）

单播地址标识单个IP接口，广播地址标识某个子网的所有IP结构，多播地址标识一组IP接口。单播和广播是寻址方案的两个极端（要么一个要么全部），多播则在两者之间提供一种之间提供一种折中的方案。多播数据报只应该由对它感兴趣的接口接收，也就是说由运行「相应的多播会话应用系统」的主机上的接口接收。另外，广播一般局限于局域网的使用，多播则既可以用于局域网，也可以跨广域网使用。



-   组播既可以用于局域网，也可以用于广域网
-   客户端需要加入多播组，才能接收到多播的数据

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230220142128680.png" alt="image-20230220142128680" style="zoom:50%;" />

#### 组播地址：

>   IP多播通信必须依赖于IP多播地址，在IPv4中，它的范围从`224.0.0.0`到`239.255.255.255`，并被划分为局部链接多播地址，预留多播地址和管理权限多播地址三类:

| IP地址                    | 说明                                                         |
| ------------------------- | ------------------------------------------------------------ |
| 224.0.0.0-224.0.0.255     | 局部链接多播地址：是为路由器协议和其他用途保留的地址，路由器并不转发属于此范围的IP包 |
| 224.0.1.0-224.0.1.255     | 预留多播地址：公用组播地址，可用于Internet，使用需要提前申请 |
| 224.0.2.0-238.255.255.255 | 预留多播地址：用户可用组播地址（临时组地址），全网范围有效   |
| 239.0.0.0-239.255.255.255 | 本地管理组播地址，可供组织内部使用，类似于私有IP地址，不能用于Internet，可限制多播范围 |



#### 组播API

```cpp
int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen);
```

-   服务器设置多播的信息，外出接口：
	-   `level`：`IPPROTO_IP`	
	-   `optname`：`IP_MULTICAST_IF`
	-   `optval`：`struct in_addr`
-   客户端加入到多播组：
	-   `level`：`IPPROTO_IP`
	-   `optname`：`IP_ADD_MEMBERSHIP`
	-   `optval`：`struct ip_mreq`
	

```cpp
struct ip_mreqn
{
    struct in_addr imr_multiaddr;	/* IP multicast address of group 组播的IP地址 */
    struct in_addr imr_address;		/* local IP address of interface *///本地某一网络接口设备的IP地址， INADDR_ANY
    int	imr_ifindex;			/* Interface index *///网卡编号
};
struct ip_mreq
{
    /* IP multicast address of group.  */
    struct in_addr imr_multiaddr;

    /* Local IP address of interface.  */
    struct in_addr imr_interface;
};
typedef uint32_t in_addr_t;
struct in_addr
{
    in_addr_t s_addr;
};
```



#### 代码

服务端，修改多播的属性即可，

**multi_server.c**

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <arpa/inet.h>

int main()
{

    // 1.创建一个通信的socket
    int fd = socket(PF_INET, SOCK_DGRAM, 0);
    
    if(fd == -1) {
        perror("socket");
        exit(-1);
    }   

    //2. 设置多播的属性, 服务端设置外出接口
    struct in_addr imr_multiaddr;
    inet_pton(AF_INET, "239.0.0.10", &imr_multiaddr);
    setsockopt(fd, IPPROTO_IP, IP_MULTICAST_IF, &imr_multiaddr, sizeof(imr_multiaddr));

    //3. 初始化客户端的地址信息
    struct sockaddr_in cliaddr = 
    {
        .sin_family = AF_INET,
        .sin_port = htons(9999),
    };
    inet_pton(AF_INET, "239.0.0.10", &cliaddr.sin_addr.s_addr);


    // 3.通信
    int num = 0;
    while(1) 
    {
        char sendBuf[128];
        sprintf(sendBuf, "hello, client : %d\n", num++);
        //发送数据
        sendto(fd, sendBuf, strlen(sendBuf) + 1, 0, (struct sockaddr *)&cliaddr, sizeof(cliaddr));
        printf("组播的数据: %s\n", sendBuf);
        sleep(1);
    }

    close(fd);
    return 0;
}
```



客户端，加入到多播组

**multi_client.c**

```cpp
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <arpa/inet.h>

int main() {

    // 1.创建一个通信的socket
    int fd = socket(PF_INET, SOCK_DGRAM, 0);
    if(fd == -1) {
        perror("socket");
        exit(-1);
    }   

    struct in_addr in;

    // 2.客户端绑定本地的IP和端口
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(9999);
    addr.sin_addr.s_addr = INADDR_ANY;

    int ret = bind(fd, (struct sockaddr *)&addr, sizeof(addr));
    if(ret == -1) {
        perror("bind");
        exit(-1);
    }

    struct ip_mreq op;
    inet_pton(AF_INET, "239.0.0.10", &op.imr_multiaddr.s_addr);
    op.imr_interface.s_addr = INADDR_ANY;
    //加入到多播组
    setsockopt(fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, &op, sizeof(op));

    // 3.通信
    while(1) {
        
        char buf[128];
        // 接收数据
        int num = recvfrom(fd, buf, sizeof(buf), 0, NULL, NULL);
        printf("server say : %s\n", buf);

    }

    close(fd);
    return 0;
}
```



## 21. 本地套接字

本地套接字可以用来：本地的「进程间通信」。

可以实现：

-   有关系的进程间的通信（父子进程）
-   没有关系的进程间通信



### 21.1 本地套接字通信的流程

本地套接字实现和网络套接字类似，一般采用TCP的通信流程。

**服务器端：**

1.   创建监听的套接字

     ```cpp
     int lfd = socket(AF_UNIX/AF_LOCAL, SOCK_STREAM, 0);
     ```

2.   监听的套接字绑定本地的套接字文件

     ```cpp
     // 头文件: sys/un.h #define UNIX_PATH_MAX 108 
     struct sockaddr_un {
     	sa_family_t sun_family; // 地址族协议 af_local
     	char sun_path[UNIX_PATH_MAX]; // 套接字文件的路径, 这是一个伪文件, 大小永远=0 
     };
     struct sockaddr_un addr;
     //绑定成功后，指定的sun_path中的套接字文件会自动生成
     bind(lfd, addr, len);
     ```

3.   监听

     ```cpp'
     listen(lfd, 100);
     ```

4.   等待并接收连接请求

     ```cpp
     struct sockaddr_un cliaddr;
     int cfd = accpet(lfd, &cliaddr, len);
     ```

5.   通信（接收和发送数据）

     ```cpp
     read/recv
     write/send
     ```

6.   关闭连接

     ```cpp
     close();
     ```





**客户端的流程：**

1.   创建通信的套接字

     ```cpp
     int fd = socket(AF_UNIX/AF_LOCAL, SOCK_STREAM, 0);
     ```

2.   监听的套接字绑定本地的IP端口

     ```cpp
     struct sockaddr_un addr;
     //绑定成功后，指定的sun_path中的套接字文件会自动生成
     bind(fd, addr, len);
     ```

3.   连接服务器

     ```cpp
     struct sockadd_un serveraddr;
     connect(fd, &serveraddr, sizeof(serveraddr));
     ```

4.   通信（发送和接收数据）

     read/recv

     write/send

5.   关闭连接

     ```cpp
     close();
     ```



### 21.2 代码

**ipc_server.c**

```cpp
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <sys/un.h>

int main()
{
    //删除存在的server.sock(不管是否存在)
    unlink("server.sock");
    //1. 创建监听的套接字
    int lfd = socket(AF_LOCAL, SOCK_STREAM, 0);
    if(0 == lfd)
    {
        perror("socket");
        exit(-1);
    }

    //2. 绑定本地套接字文件
    struct sockaddr_un addr = 
    {
        .sun_family = AF_LOCAL,
    };
    
    strcpy(addr.sun_path, "server.sock");
    int ret = bind(lfd, (struct sockaddr*)&addr, sizeof(addr));
    if (-1 == ret)
    {
        perror("bind");
        exit(-1);
    }

    //3.监听
    ret = listen(lfd, 100);
    if(-1 == ret)
    {
        perror("listen");
        exit(-1);
    }

    //4. 等待客户端连接
    struct sockaddr_un cliaddr;
    int len = sizeof(cliaddr);
    int cfd = accept(lfd, (struct sockaddr*)&cliaddr, &len);
    if(-1 == cfd)
    {
        perror("accept");
        exit(-1);
    }

    printf("client socket filename : %s\n", cliaddr.sun_path);

    //5. 通信
    while(1)
    {
        char buf[128];
        int len = recv(cfd, buf, sizeof(buf), 0);
        if(-1 == len)
        {
            perror("recv");
            exit(-1);
        }
        else if(len == 0)
        {
            printf("client closed...\n");
            break;
        }
        else if(len > 0)
        {
            printf("client say : %s\n", buf);
            send(cfd, buf, len, 0);
        }

    }
    close(cfd);
    close(lfd);
    return 0;
}

```



**ipc_client.c**

```cpp
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <sys/un.h>

int main()
{
    //删除文件
    unlink("client.sock");
    //1. 创建监听的套接字
    int cfd = socket(AF_LOCAL, SOCK_STREAM, 0);
    if(0 == cfd)
    {
        perror("socket");
        exit(-1);
    }

    //2. 绑定本地套接字文件
    struct sockaddr_un addr = 
    {
        .sun_family = AF_LOCAL,
    };
    
    strcpy(addr.sun_path, "client.sock");
    int ret = bind(cfd, (struct sockaddr*)&addr, sizeof(addr));
    if (-1 == ret)
    {
        perror("bind");
        exit(-1);
    }

    //3. 连接服务器
    struct sockaddr_un seraddr;
    seraddr.sun_family = AF_LOCAL;
    strcpy(seraddr.sun_path, "server.sock");
    ret = connect(cfd, (struct sockaddr*)&seraddr, sizeof(seraddr));
    if(-1 == ret)
    {
        perror("connect");
        exit(-1);
    }

    //4. 通信
    int num = 0;
    while(1)
    {

        //发送数据
        char buf[128];
        sprintf(buf, "hello, i am client %d\n", num++);
        send(cfd, buf, strlen(buf) + 1, 0);
        printf("client say : %s\n", buf);


        //接收数据
        int len = recv(cfd, buf, sizeof(buf), 0);
        if(-1 == len)
        {
            perror("recv");
            exit(-1);
        }
        else if(len == 0)
        {
            printf("client closed...\n");
            break;
        }
        else if(len > 0)
        {
            printf("server say : %s\n", buf);
        }
        sleep(1);

    }
    close(cfd);

    return 0;
}

```



>   `server.sock`和`client.sock`不会占用磁盘空间。同时使用本地套接字时，如果重启服务器，需要删除这两个文件，可以使用`unlink()`删除一个文件。