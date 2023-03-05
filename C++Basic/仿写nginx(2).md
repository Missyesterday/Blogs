# 仿写nginx（2）

## 5. 网络通讯实战

### 5.1 客户端和服务器

客户端和服务器都是程序。

连接一般是是客户端发起的，但是连接建立后，数据流动是双向的（双工）。

端口是0～65535之间的一个数，计算机不允许两个程序监听一个端口。浏览器也有一个端口，但是浏览器的端口是随机的，不是固定的。

### 5.2 网络模型

#### 5.2.1 OSI七层网络模型

物链网传会表应，想象成一个人穿了七件衣服。

#### 5.2.2 TPC/IP 协议四层模型

事实上的协议。 传输控制协议/网际协议。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230305141323403.png" alt="image-20230305141323403" style="zoom:40%;" />

TCP/IP四层模型更为简单，它是一组协议。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230305141506424.png" alt="image-20230305141506424" style="zoom:40%;" />

#### 5.2.3 TCP/IP协议解释和比喻

就相当于人上街要穿衣服。



#### 5.2.4 TCP和UDP的区别

使用`socket()`时候指定不同的参数，就能使用不同的协议，后面的参数也需要进行相应修改。

-   可靠VS不可靠

-   连接VS无连接

TCP：

-   耗费更多的系统资源确保数据的可靠，传输的数据一定正确，不丢失，不重复，按顺序叨叨

UDP：

-   发送速度特别快，效率高，不保证数据的可靠性，QQ聊天信息用UDP（内部有一些弥补的机制），DNS解析
-   随着硬件的发展，UDP越来越可靠，随着网络的发展，可能UDP的适用性更广



### 5.3 最简单的C/S通信程序

可以参考《Unix网络编程》第一卷，里面有很多小demo。

演示一下（玩具程序）：

#### 5.3.1 套接字Socket的概念

-   套接字socket就是一个数字，通过调用`socket()`函数来生成，这个数字具有唯一性：可以一直使用，直到调用`close()`函数
-   socket这个数字被视为一个文件描述符，可以利用socket来收发数据（`send()`和`recv()`函数）

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230305145312713.png" alt="image-20230305145312713" style="zoom:50%;" />

#### 5.3.2 一个简单的服务器通信程序

<mark>需要关注调用了哪些函数和调用顺序</mark>

**5_1_1server.c**

属于是八股文，需要注意服务器端有两个socket，一个用于监听，一个用于通信（可能有多个）

```cpp

#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <string.h>

#define SERV_PORT 9000  //本服务器要监听的端口号，一般1024以下的端口很多都是属于周知端口，所以我们一般采用1024之后的数字做端口号

int main(int argc, char *const *argv)
{    
    //这些演示代码的写法都是固定套路，一般都这么写

    //服务器的socket套接字【文件描述符】
    int listenfd = socket(AF_INET, SOCK_STREAM, 0);    //创建服务器的socket，大家可以暂时不用管这里的参数是什么，知道这个函数大概做什么就行

    struct sockaddr_in serv_addr;                  //服务器的地址结构体
    memset(&serv_addr,0,sizeof(serv_addr));
    
    //设置本服务器要监听的地址和端口，这样客户端才能连接到该地址和端口并发送数据
    serv_addr.sin_family = AF_INET;                //选择协议族为IPV4
    serv_addr.sin_port = htons(SERV_PORT);         //绑定我们自定义的端口号，客户端程序和我们服务器程序通讯时，就要往这个端口连接和传送数据
    serv_addr.sin_addr.s_addr = htonl(INADDR_ANY); //监听本地所有的IP地址；INADDR_ANY表示的是一个服务器上所有的网卡（服务器可能不止一个网卡）多个本地ip地址都进行绑定端口号，进行监听。

    bind(listenfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr));//绑定服务器地址结构体
    listen(listenfd, 32);     //参数2表示服务器可以积压的未处理完的连入请求总个数，客户端来一个未连入的请求，请求数+1，连入请求完成，c/s之间进入正常通讯后，请求数-1

    int connfd;
    const char *pcontent = "I sent sth to client!"; //指向常量字符串区的指针
    while(1)
    {
        //卡在这里，等客户单连接，客户端连入后，该函数走下去【注意这里返回的是一个新的socket——connfd，后续本服务器就用connfd和客户端之间收发数据，而原有的lisenfd依旧用于继续监听其他连接】        
        connfd = accept(listenfd, (struct sockaddr*)NULL, NULL);

        //发送数据包给客户端
        write(connfd, pcontent, strlen(pcontent)); //注意第一个参数是accept返回的connfd套接字
        
        //只给客户端发送一个信息，然后直接关闭套接字连接；
        close(connfd); 
    } //end for
    close(listenfd);     //实际本简单范例走不到这里，这句暂时看起来没啥用
    return 0;
}
```



#### 5.3.3 IP地址简介

绝大部分地址是IPv4地址，也渐渐有了IPv6，写服务器不需要考虑IPv4和IPv6问题，遵照IPv4就行，IPv6的问题交给硬件厂商。

写客户端程序，需要改动，但改动不是很大。



#### 5.3.4 IPv4客户端通信程序

```cpp

#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <string.h>


#define SERV_PORT 9000    //要连接到的服务器端口，服务器必须在这个端口上listen着

int main(int argc, char *const *argv)
{    
    //这些演示代码的写法都是固定套路，一般都这么写
    int sockfd = socket(AF_INET, SOCK_STREAM, 0); //创建客户端的socket

    struct sockaddr_in serv_addr; 
    memset(&serv_addr,0,sizeof(serv_addr));

    //设置要连接到的服务器的信息
    serv_addr.sin_family = AF_INET;                //选择协议族为IPV4
    serv_addr.sin_port = htons(SERV_PORT);         //连接到的服务器端口，服务器监听这个地址
    //这里为了方便演示，要连接的服务器地址固定写
    if(inet_pton(AF_INET,"192.168.1.126",&serv_addr.sin_addr) <= 0)  //IP地址转换函数,把第二个参数对应的ip地址转换第三个参数里边去，固定写法
    {
        printf("调用inet_pton()失败，退出！\n");
        exit(1);
    }

    //连接到服务器
    if(connect(sockfd,(struct sockaddr*)&serv_addr,sizeof(serv_addr)) < 0)
    {
        printf("调用connect()失败，退出！\n");
        exit(1);
    }

    int n;
    char recvline[1000 + 1]; 
    while(( n = read(sockfd,recvline,1000)) > 0) //仅供演示，非商用，所以不检查收到的宽度，实际商业代码，不可以这么写
    {
        recvline[n] = 0; //实际商业代码要判断是否收取完毕等等，所以这个代码只有学习价值，并无商业价值
        printf("收到的内容为：%s\n",recvline);
    }
    close(sockfd); //关闭套接字
    printf("程序执行完毕，退出!\n");
    return 0;
}
```

 

### 5.4 TCP/IP

#### 5.4.1 最大传输单元MTU

MTU：maximum Transfer Unit 最大传输单元，每个数据包最多可以有多少个字节（1.5k左右）

如果超过这个数量，操作系统会分片。一端拆包，一端组包。

#### 5.4.2 TCP包包头结构



#### 5.4.3 TCP数据首发之前的准备工作

三次握手是针对TCP而言的：

-   客户端给服务器发送 SYN置位的无内容（包体）的 数据包
-   服务器收到后 发送一个 SYN和ACK置位的 无内容的 数据包
-   客户端再次发送 ACK置位的数据包

后续就可以进行通信了。



>   为什么三次握手而不是两次握手？
>
>   原因有很多，都是为了确保数据稳定可靠的收发。
>
>   三次握手很大程度上是为了防止恶意破坏TCP连接的验证机制，而不仅仅只是浅显的「确认双方都有收发能力」。
>
>   尽量减少伪造数据包对服务器的攻击，例如伪造一个IP地址和端口发送一个请求，服务端向这个IP地址和端口发送数据（并有随机数），如果不能收到「这个IP地址和端口」的应答（随机数+1），则服务器能发现伪造的IP地址和端口。



#### 5.4.4 telnet工具

这是一个命令行方式运行的客户端TCP通讯工具，可以连接到服务器端，往服务器端发送数据，也可以接受从服务器发送过来的数据。

该工具能非常方便的测试服务器某个「TCP端口」是否能正常收发数据，所以非常实用。



```bash
telnet ip地址 端口
```

中间用空格隔开。

Windows下的telnet敲入一个字符发送一个字符，而Linux按回车才会发送。



#### 5.4.5 wireshark

希望抓去本机和服务器9000端口的包。

在过滤器中输入`host 192.168.31.242 and port 9000`

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230305170146369.png" alt="image-20230305170146369" style="zoom:50%;" />

使用telnet，出现的前三行就是「三次握手」

「四次挥手」：服务器和客户端都有可能是发起断开请求的一方。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230305171330664.png" alt="image-20230305171330664" style="zoom:50%;" />

这是客户端发送了两次ACK，把这两次视为1次就是四次挥手。

#### 5.4.5 TCP状态转换

