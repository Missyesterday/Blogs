# 项目实战

## 1. 阻塞/非阻塞、同步/异步

只考虑网络IO

典型的一次IO操作有两个阶段：

-   数据就绪
-   数据读写



对于`read`函数，非阻塞时，根据返回值来判断：

-   -1：不一定出错
    -   如果errno是`EINTR`,`EAGAIN`或者`EWOULDBLOCK`则可能是非阻塞造成的。
-   \>0：接收到的字节数量
-   0：读取到数据的末尾（对方连接关闭）



数据读写：

-   同步
-   异步

同步和异步并不等于阻塞和非阻塞。之前我们所写的代码都是同步的代码。需要注意，数据是用户自己去读，而不是操作系统“给”用户的。

同步就相当于「自己去机场取机票，花费的是自己的时间」，而异步相当于「机场工作人员送给你」，显然异步的效率更高。但是同步的程序编写起来简单，异步的编程是非常复杂的。

异步的IO接口，需要把「sockfd、buf和**通知方式**」给操作系统，接下来应用程序就可以执行接下来的代码了。

通知方式可以是`SIGIO`信号，程序收到这个信号，代表buf的数据就已经准备好了。



>   陈硕：在处理IO的时候，阻塞和非阻塞都是同步IO，只有使用了特殊的API才是异步IO。



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230220211900276.png" alt="image-20230220211900276" style="zoom:50%;" />

`aio_read()`,`aio_write()`都是Linux的异步IO接口，异步IO一般是非阻塞的。



**总结**

一个典型的网络IO接口调用，分为两个阶段，分别是“数据就绪” 和 “数据读写”，数据就绪阶段分为阻塞和非阻塞，表现得结果就是，「阻塞当前线程」或是「直接返回」。

同步表示A向B请求调用一个网络IO接口时(或者调用某个业务逻辑API接口时)，数据的读写都是由请求方A自己来完成的(不管是阻塞还是非阻塞);异步表示A向B请求调用一个网络IO接口时 (或者调用某个业务逻辑API接口时)，向B传入请求的事件以及事件发生时通知的方式，A就可以处理其它逻辑了，当B监听到事件处理完成后，会用事先约定好的通知方式，通知A处理结果。



>   IO多路复用（select、poll、epoll）是同步还是异步的？
>
>   在同步IO中，当用户程序发起一个IO请求时，程序会阻塞等待直到IO操作完成并返回结果。而在IO多路复用中，程序通过一个函数（如select、poll、epoll）将多个IO操作一起发起并等待，一旦其中任何一个IO操作完成，函数就会返回并通知程序哪个IO操作已经完成。
>
>   虽然IO多路复用的工作方式看起来类似于异步IO模型，但实际上它是同步IO模型的一种扩展，因为**程序仍然需要在IO操作完成后再继续进行后续处理**。与异步IO模型不同，异步IO模型中IO操作完成后会**通过回调函数通知程序结果**，程序无需等待IO操作完成。



## 2. Unix/Linux上的五种IO模型

### 2.1 阻塞blocking

用户调用了某个函数，等待这个函数返回，期间什么都不做，不停地去检查这个函数有没有返回，必须等这个函数返回才能进行下一步动作。



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230220213530000.png" alt="image-20230220213530000" style="zoom:50%;" />

**`read()`,`recv()`默认都是阻塞的，这个阻塞并不是函数的行为，而是和「文件描述符」有关。**

可以看到上图IO操作的两个阶段：等待数据和读写数据。



### 2.2 非阻塞 non-blocking（NIO）

例如Java提供了NIO的接口。

非阻塞等待，每隔一段时间就去检测IO事件是否就绪。没有就绪就可以做其他事。非阻塞I/O执行系统调用总是立即返回，不管事件是否已经发生，若事件没有发生，则返回-1，此时可以根据errno区分这两种情况，对于`accept`,`recv`和`send`，事件未发生的时候，errno通常被设置成`EAGAIN`或`EWOULDBLOCK`。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230220214047561.png" alt="image-20230220214047561" style="zoom:50%;" />

上图就展示了非阻塞条件下，系统的errno设置为`EAGAIN`，反复地调用`read()` ，每次都是立即返回。非阻塞相对于阻塞的好处是在数据未准备好的时候做其他事情。

### 2.3 IO复用（IO multiplexing）

Linux用`select/poll/epoll`函数实现IO复用模型，这些函数也会使进程阻塞，但是和阻塞IO不同的是这些函数可以同时阻塞多个IO操作，而且可以同时对多个读操作、写操作的IO函数进行检测。直到有数据可读或可写时，才真正调用IO操作函数。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230220214722455.png" alt="image-20230220214722455" style="zoom:50%;" />

通过设置`select/poll/epoll`的`timeout`参数可以设置它们是否阻塞。  



IO复用在单进程/单线程的模式下检测多个客户的连接，但是它并不是用来处理高并发的，处理高并发还是要用多线程/多进程。

### 2.4 信号驱动

Linux用套接口进行信号驱动IO，注册一个信号处理函数，进程继续运行并不阻塞，当IO事件就绪，进程收到`SIGIO`信号，然后处理`IO`事件。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230220215159396.png" alt="image-20230220215159396" style="zoom:50%;" />

内核在第一个阶段是异步，在第二个阶段是同步；与非阻塞IO的区别在于它提供了消息通知机制，不需要用户进程不断的轮询检查，减少了系统API的调用次数，提高了效率。信号在多线程当中不好处理，实际使用较少。

### 2.5 异步（asynchronous）IO模型

Linux中，可以调用`aio_read()`函数告诉内核「文件描述符指针和缓冲区」的大小、文件偏移以及通知方式，然后立即返回，当内核将数据拷贝到缓冲区后，再通知应用程序。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230220215359010.png" alt="image-20230220215359010" style="zoom:50%;" />

在异步IO模型中，等待数据和拷贝数据都是异步的。



AIO的函数中都需要`aiocb`这个结构体。cb代表control block控制块。

```cpp
struct aiocb
{
    int aio_fildes;
    int aio_lio_opcode;
    int aio_reqprio;
    volatile void *aio_buf;   /* Location of buffer.  */
    size_t aio_nbytes;        /* Length of transfer.  */
    struct sigevent aio_sigevent; /* Signal number and value.  */
    /* Internal members.  */
    struct aiocb *__next_prio;
    int __abs_prio;
    int __policy;
    int __error_code;
    __ssize_t __return_value;
    #ifndef __USE_FILE_OFFSET64
    __off_t aio_offset;
    /* File offset.  */
    /* File desriptor.  */
    /* Operation to be performed.  */
    /* Request priority offset.  */
    char __pad[sizeof (__off64_t) - sizeof (__off_t)];
    #else
    __off64_t aio_offset;     /* File offset.  */
    #endif
    char __glibc_reserved[32];
};
```



## 3. WebServer（网页服务器）

一个webserver就是一个「服务器软件（程序）」或者是「运行这个服务器软件的硬件（计算机）」，这是两个不同的角度来看「服务器」。其主要功能是通过HTTP协议与客户端（通常是浏览器（Browser））进行通信，来接收、存储，处理来自客户端的HTTP请求，并对其请求做出HTTP相应，返回给客户端其请求的内容（文件、网页等）或返回一个error信息。



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230221160703274.png" alt="image-20230221160703274" style="zoom:50%;" />

通常用户使用Web浏览器与相应服务器进行通信。在浏览器中输入「域名」或者「IP地址:端口号」，浏览器则先将你的域名解析成相应的IP地址（DNS服务器）或者直接根据你的IP地址向对应的Web服务器发送一个HTTP请求。这一过程首先要通过TCP协议的三次握手建立与目标Web服务器的连接，然后HTTP协议生成针对对目标Web服务器的HTTP请求报文，通过TCP、IP等协议发送到目标Web服务器上。



## 4. HTTP协议（应用层的协议）

### 4.1 简介

超文本传输协议(Hypertext Transfer Protocol，HTTP)是一个简单的「请求-响应」协议，它通常运行在TCP之上。它指定了客户端可能发送给服务器什么样的消息以及得到什么样的响应。请求和响应消息的头以ASCII形式给出;而消息内容则具有一个类似MIME的格式。HTTP是万维网的数据通信的基础。

HTTP的发展是由蒂姆·伯纳斯-李于1989年在欧洲核子研究组织(CERN)所发起。HTTP的标准制定由万维网协会(World Wide Web Consortium，W3C)和互联网工程任务组(Internet Engineering Task Force，IETF)进行协调，最终发布了一系列的RFC，其中最著名的是1999年6月公布的RFC2616，定义了HTTP协议中现今广泛使用的一个版本——HTTP1.1。



### 4.2 概述

HTTP是一个客户端终端（用户）和服务端（网站）请求和应答标准（TCP）。通过使用网页浏览器、网络爬虫或者其他的工具，客户端发起一个HTTP请求到服务器上指定端口（默认端口为80）。我们称这个客户端为用户代理程序（user agent）。应答的服务器上存储着一些资源，比如HTML文件和图像，我们称这个应答服务器为源服务器（origin server）。在用户代理和源服务器中间可能存在多个「中间层」，比如代理服务器、网关或者隧道（tunnel）。

尽管TCP/IP协议是互联网上最流行的应用，HTTP协议中，并没有规定必须使用它或它支持的层。事实上，HTTP可以在任何互联网协议上，或其他网络上实现。HTTP假定其下层协议提供可靠的传输。因此，任何能够提供这种保证的协议都可以被其使用。因此也就是其在TCP/IP协议族使用TCP作为其传输层。

通常，由HTTP客户端发起一个请求，创建一个到服务器指定端口(默认是80端口)的TCP连接。HTTP服务器则在那个端口监听客户端的请求。一旦收到请求，服务器会向客户端返回一个状态，比如"HTTP/1.1 200 OK"，以及返回的内容，如请求的文件、错误消息、或者其它信息。

### 4.3 工作原理

HTTP协议定义Web客户端如何从Web服务器请求Web页面，以及服务器如何把Web页面传送给客户端。HTTP协议采用了请求/响应模型。客户端向服务器发送一个请求报文，请求报文包含请求的方法、URL、协议版本、请求头部和请求数据。服务器以一个状态行作为响应，响应的内容包括协议的版本、成功或者错误代码、服务器信息、响应头部和响应数据。



**一个HTTP请求/响应的步骤：**

1.   客户端连接到Web服务器

     一个HTTP客户端，通常是浏览器，与Web服务器的HTTP端口（默认是80）建立一个TCP套接字连接。URL

2.   发送HTTP请求

     通过TCP套接字，客户端向Web服务器发送一个文本的请求报文，一个请求报文由请求行、请求头部、空行和请求数据。

3.   服务器接收请求并返回HTTP相应

     Web服务器解析请求，定位请求资源。服务器将资源副本写到TCP套接字，由客户端读取。一个响应由状态行、响应头部、空行和响应数据4部分组成。

4.   释放TCP连接

     若connection模式为close，则服务器主动关闭TCP连接，客户端被动关闭连接，释放TCP连接；若connection为keepalive，则该连接会保持一段时间，在该时间内可以继续接收请求。

5.   客户端浏览器解析HTML内容

     客户端浏览器首先解析「状态行」，查看表示请求是否成功的状态代码，然后解析每一个响应头，响应头告知以下为若干字节的HTML文档和文档的字符集。客户端浏览器读取响应数据HTML，根据HTML的语法对其进行格式化，并在浏览器中显示。

HTTP协议是基于TCP/IP协议之上的应用层协议，基于请求-响应的模式。HTTP协议规定，请求从客户端发出，最后服务器端响应该请求并返回。换句话说，肯定是先从客户端开始建立通信的，服务器端在没有接收到请求之前不会发送响应。

### 4.4 HTTP请求报文格式

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230221213439523.png" alt="image-20230221213439523" style="zoom:50%;" />

**一个请求报文**

请求头是键值对，用`:`分割字段名和值

```
GET / HTTP/1.1
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9
Accept-Encoding: gzip, deflate, br
Accept-Language: zh-CN,zh;q=0.9,en;q=0.8,en-US;q=0.7,zh-TW;q=0.6
Cache-Control: max-age=0
Connection: keep-alive
Cookie: BIDUPSID=B45163B949EFF8778C6F06649CD76F47; PSTM=1642841536; __yjs_duid=1_908460ec7d58b41d1836ea63852ea1de1642846782255; BAIDU_WISE_UID=wapp_1642846799358_523; BAIDUID_BFESS=B45163B949EFF87766EB1B4F6FD98828:FG=1; channel=pos.baidu.com; baikeVisitId=ae198b70-8701-44de-b32c-9a655146baa0; ZFY=S5ZW:A:BmvJuno:BAX:AQzI:B5lFLcZE0ubCzL6kNoQXE7JM:C; BD_HOME=1; H_PS_PSSID=36554_38105_38093_38126_37911_38148_38177_38174_38254_37931_38086_26350_38138_22159_38008_37881; BD_UPN=123253; BA_HECTOR=2l8k85800kah240la48h2ls01hv9hl11k; RT="z=1&dm=baidu.com&si=3eae826e-7606-4e71-8fb6-a4a7781bb78c&ss=leea6trx&sl=3&tt=242&bcn=https%3A%2F%2Ffclog.baidu.com%2Flog%2Fweirwood%3Ftype%3Dperf&ld=9c7&ul=4zdz&hd=4zea"
Host: www.baidu.com
Sec-Fetch-Dest: document
Sec-Fetch-Mode: navigate
Sec-Fetch-Site: none
Sec-Fetch-User: ?1
Upgrade-Insecure-Requests: 1
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36
sec-ch-ua: "Not_A Brand";v="99", "Google Chrome";v="109", "Chromium";v="109"
sec-ch-ua-mobile: ?0
sec-ch-ua-platform: "macOS"
```

与上图是一一对应的。

### 4.5 HTTP响应报文格式



<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230221213447491.png" alt="image-20230221213447491" style="zoom:50%;" />

**一个响应报文：**

```
HTTP/1.1 200 OK
Bdpagetype: 1
Bdqid: 0xb7438bbb0003f9ec
Connection: keep-alive
Content-Encoding: gzip
Content-Type: text/html; charset=utf-8
Date: Tue, 21 Feb 2023 13:31:48 GMT
Server: BWS/1.1
Set-Cookie: BDSVRTM=0; path=/
Set-Cookie: BD_HOME=1; path=/
Set-Cookie: H_PS_PSSID=36554_38105_38093_38126_37911_38148_38177_38174_38254_37931_38086_26350_38138_22159_38008_37881; path=/; domain=.baidu.com
Strict-Transport-Security: max-age=172800
Traceid: 1676986308061338241013205552167655832044
X-Frame-Options: sameorigin
X-Ua-Compatible: IE=Edge,chrome=1
Transfer-Encoding: chunked
```



### 4.6 HTTP状态码

<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost/计算机网络/HTTP/6-五大类HTTP状态码.png" style="zoom:60%;" />

### 4.7 HTTP请求方法

就是请求行里的第一个字符串：`GET`,`POST`，基本上只实现了`GET`和`POST`，`GET`一般用来向指定的资源发出“显示”请求，`POST`一般提交表单或者上传文件的时候使用。



## 5. 服务器编程基本框架

虽然服务器程序种类繁多，但其基本框架都一样，不同之处在于逻辑处理。

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230221230913534.png" alt="image-20230221230913534" style="zoom:50%;" />

| 模块         | 功能                       |
| ------------ | -------------------------- |
| I/O处理单元  | 处理客户连接，读写网络程序 |
| 逻辑单元     | 业务进程或线程             |
| 网络存储单元 | 数据库、文件或缓存         |
| 请求队列     | 各单元之间的通信方式       |



I/O处理单元是服务器管理客户连接的模块。它通常要完成以下工作:等待并接受新的客户连接，接收客户数据，将服务器响应数据返回给客户端。但是数据的收发不一定在 I/O 处理单元中执行，也可能在逻辑单元中执行，具体在何处执行取决于事件处理模式。 

一个逻辑单元通常是一个进程或线程。它分析并处理客户数据，然后将结果传递给I/O处理单元或者直接发送给客户端(具体使用哪种方式取决于事件处理模式)。服务器通常拥有多个逻辑单元，以实现对多个客户任务的并发处理。 

网络存储单元可以是数据库、缓存和文件，但不是必须的。 

请求队列是各单元之间的通信方式的抽象。I/O处理单元接收到客户请求时，需要以某种方式通知一个逻辑单元来处理该请求。同样，多个逻辑单元同时访问一个存储单元时，也需要采用某种机制来协调处理竞态条件。请求队列通常被实现为池的一部分。



## 6. 两种高效的事件处理模式

服务器程序通常需要处理三类事件：I/O事件、信号及定时事件。有两种高效的事件处理模式：Reactor和Proactor，同步I/O模型通常用于实现Rector模式，异步I/O通常用于实现Proactor模式。



### 6.1 Reactor模式

要求主线程（I/O处理单元）只负责监听文件描述符上是否有事件发生，有的话就立即将该时间通知工作线程（逻辑单元），将socket可读可写事件放入请求队列，交给工作线程处理。除此之外，主线程不做任何其他实质性的工作。读写数据，接受新的连接，以及处理客户请求均在工作线程中完成。

使用同步I/O（以`epoll_wait()`为例）实现的Reactor模式的工作流程是：

1.   主线程往epoll内核事件表中注册socket上的读就绪事件；
2.   主线程调用`epoll_wait()`等待socket上有数据可读；
3.   当socket上有数据可读时，`epoll_wait()`通知主线程。主线程则将socket可读事件放入请求队列。
4.   睡眠在请求队列上的某个工作线程被唤醒，它从socket读取数据，并处理客户请求，然后往epoll内核事件表中注册该socket上的写就绪事件；
5.   当主线程调用`epoll_wait()`等待socket可写；
6.   当socket可写时，`epoll_wait()`通知主线程。主线程将socket可写事件放入请求队列；
7.   睡眠在请求队列上的某个工作线程被唤醒，它往socket上写入服务器处理客户请求的结果。



**Reactor模式的工作流程：**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230221234309190.png" alt="image-20230221234309190" style="zoom:50%;" />



### 6.2 Proactor模式

Proactor模式将所有I/O操作都交给主线程和内核来处理（进行读、写），工作线程仅仅负责业务逻辑。使用异步IO模型（以`aio_read`和`aio_write`为例）实现的Proactor模式的工作流程是：

1.   主线程调用`aio_read()`函数向内核注册socket上的读完成事件，并告诉内核用户读缓冲区的位置，以及读操作完成时如何通知应用程序（这里以信号为例）。
2.   主线程继续处理其他逻辑。
3.   当socket上的数据被读入用户缓冲区后，内核将向应用程序发送一个信号，以通知应用程序数据已经可用。
4.   应用程序预先定义好的信号处理函数选择一个工作线程来处理客户请求。工作线程处理完客户请求后，调用`aio_write()`函数向内核注册socket上的写完成事件，并告诉内核用户写缓冲区的位置，以及写操作完成时如何通知应用程序。
5.   主线程继续处理其他逻辑。
6.   当用户缓冲区的数据被写入socket后，内核将向应用程序发送一个信号，以通知应用程序数据已经发送完毕。
7.   应用程序预先定义好的信号处理函数选择一个工作线程来做善后处理，比如决定是否关闭socket。

**Proactor模式的工作流程：**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230221234901833.png" alt="image-20230221234901833" style="zoom:50%;" />

>   这两个模式的工作线程，区别就在与工作线程所做的事情。

### 6.3 模拟Proactor模式

使用同步I/O方式模拟Proactor模式。原理是：主线程执行数据读写操作，读写完成之后，主线程向工作线程通知这一「完成事件」。那么从工作线程的角度来看，它们就直接获得了数据读写的结果，接下来只需要对读写的结果进行逻辑处理。

使用同步I/O模型（以`epoll_wait()`为例）模拟出的Proactor模式的工作流程如下：

1.   主线程往`epoll`内核和事件表中注册socket上的读就绪事件。
2.   主线程调用`epoll_wait()`等待socket上有数据可读。
3.   当socket上有数据可读时，`epoll_wait`通知主线程，主线程从socket循环读取数据，直到没有更多数据可读，然后将读取到的数据封装称一个请求对象并插入请求队列。
4.   睡眠在请求队列上的某个工作线程被唤醒，它获得请求对象并处理客户请求，然后往`epoll`内核事件表中注册socket上的写就绪事件。
5.   主线程调用`epoll_wait()`等待socket可写。
6.   当socket可写时，`epoll_wait()`通知主线程。主线程往socket上写入服务器处理客户请求的结果。



**同步I/O模拟Proactor模式的工作流程：**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230222000512108.png" alt="image-20230222000512108" style="zoom:50%;" />



## 7. 线程池

线程池是由服务器预先创建的一组子线程，线程池中的线程数量应该和CPU数量差不多。线程池中所有子线程都运行着相同的代码。当有新的任务到来时，主线程将通过某种方式选择线程池中的某一个子线程来为之服务。相比与动态地创建子线程，选择一个已经存在的子线程的代价要小得多（如果1000个客户端连接岂不是要立即创建1000个线程，同时还要销毁？）。至于主线程选择哪个子线程来为新任务服务，则有多种方式：

-   主线程使用某种算法来主动选择子线程。最简单最常用的方法是「随机算法」和「Round Robin」（轮流选取）算法，但更优秀、更智能的算法将使任务在各个工作线程中更加均匀地分配，从而减轻服务器的整体压力。
-   主线程和所有子线程通过一个共享的工作队列来同步，子线程都睡眠在该工作队列上。当有新的任务到来时，主线程将任务添加到工作队列中。这将唤醒正在等待任务的子线程，不过只有一个子线程将获得新任务的「接管权」，它可以从工作队列中取出任务并执行之，而其他子线程将继续睡在工作队列上。



**线程池的一般模型为：**

<img src="https://raw.githubusercontent.com/Missyesterday/picgo/main/picgo/image-20230222130931766.png" alt="image-20230222130931766" style="zoom:50%;" />

>   线程池中的线程数量最直接的限制因素是中央处理器（CPU）的处理器数量（processors/cores）。
>
>   如果CPU是4-cores的，对于CPU密集型任务来说，那么线程池中的线程数量也最好设置为4（或者+1防止其他因素导致的线程阻塞）；对于IO密集型任务，一般要多与CPU的核心数，因为线程间竞争的不只是CPU的计算资源而是IO，IO的处理一般较慢，多于cores的线程将为CPU争取更多的任务，不至于在线程处理IO的过程造成CPU空闲导致资源浪费。



-   空间换取事件，浪费服务器的硬件资源，换取运行效率。
-   池是一组资源的集合，这组资源在服务器启动之初就被完全创建号并初始化，被称为「静态资源」。
-   当服务器进入正式运行阶段，开始处理客户请求的时候，如果它需要相关的资源，可以直接从池中获取，无需动态分配。
-   当服务器处理完一个客户连接后，可以把相关的资源放回池中，无需执行系统调用释放资源。



>   `find / -name socket.h -print`查找某个文件并打印路径



## 8. 有限状态机

逻辑单元内部一种高效编程的方法：「有限状态机」（finite state machine）。

有的应用层协议头部包含数据包类型字段，每种类型可以映射为逻辑单元的一种执行状态，服务器可以根据它来编写相应的处理逻辑。如下是一种状态独立的有限状态机：

```cpp
STATE_MACHINE( Package _pack )
{
    PackageType _type = _pack.GetType();
    switch( _type )
    {
        case type_A:
            process_package_A( _pack );
            break;
        case type_B:
            process_package_B( _pack );
            break;
    } 
}
```

这是一个简单的有限状态机，这不过该状态机都是相互独立的，即状态之间没有相互状一，状态的转移需要状态机内部驱动，如下代码：

```cpp
STATE_MACHINE()
{
    State cur_State = type_A;

    while( cur_State != type_C )
    {
        Package _pack = getNewPackage();
        switch( cur_State )
        {
            case type_A:
                process_package_state_A( _pack );
                cur_State = type_B;
                break;
            case type_B:
                process_package_state_B( _pack );
                cur_State = type_C;
                break;
        }
    }
}

```

该状态机包含三种状态:`type_A`、`type_B`和`type_C`，其中`type_A`是状态机的开始状态`type_C`是状态机的结束状态。状态机的当前状态记录在`cur_State`变量中。在一趟循环过程中，状态机先通过`getNewPackage`方法获得一个新的数据包，然后根据`cur_State`变量的值判断如何处理该数据包。数据包处理完之后，状态机通过给`cur_State`变量传递目标状态值来实现状态转移。那么当状态机进入下一趟循环时，它将执行新的状态对应的逻辑。

## 9.EPOLLONESHOT事件

即使可以使用 ET 模式，一个`socket`上的某个事件还是可能被触发多次。这在并发程序中就会引起一个问题。比如一个线程在读取完某个`socket`上的数据后开始处理这些数据，而在数据的处理过程中该 socket 上又有新数据可读(EPOLLIN 再次被触发)，此时另外一个线程被唤醒来读取这些新的数据。于 是就出现了两个线程同时操作一个 socket 的局面。一个socket连接在任一时刻都只被一个线程处理，可 以使用 epoll 的 EPOLLONESHOT 事件实现。
对于注册了 EPOLLONESHOT 事件的文件描述符，操作系统最多触发其上注册的一个可读、可写或者异 常事件，且只触发一次，除非我们使用 epoll_ctl 函数重置该文件描述符上注册的 EPOLLONESHOT 事 件。这样，当一个线程在处理某个 socket 时，其他线程是不可能有机会操作该 socket 的。但反过来思 考，注册了 EPOLLONESHOT 事件的 socket 一旦被某个线程处理完毕， 该线程就应该立即重置这个 socket 上的 EPOLLONESHOT 事件，以确保这个 socket 下一次可读时，其 EPOLLIN 事件能被触发，进 而让其他工作线程有机会继续处理这个 socket。

## 10.服务器压力测试

Webbench 是 Linux 上一款知名的、优秀的 web 性能压力测试工具。它是由Lionbridge公司开发。
    测试处在相同硬件上，不同服务的性能以及不同硬件上同一个服务的运行状况。
    展示服务器的两项内容:每秒钟响应请求数和每秒钟传输数据量。
基本原理:Webbench 首先 fork 出多个子进程，每个子进程都循环做 web 访问测试。子进程把访问的 结果通过pipe 告诉父进程，父进程做最终的统计结果。
   测试示例

```
webbench -c 1000 -t 30 http://60.xx.xx.xx:10000/html
```

-   -c代表客户端数
-   -t代表时间（30代表30秒）



```
1000 clients, running 5 sec.

Speed=20676 pages/min, 54791 bytes/sec.
Requests: 1723 susceed, 0 failed.
```



