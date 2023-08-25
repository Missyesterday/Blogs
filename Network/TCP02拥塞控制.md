# TCP重传、滑动窗口、流量控制、拥塞控制

TCP通过序列号、确认应答、重发控制、连接管理、以及窗口控制等机制实现可靠传输的。



## 重传机制

TCP 实现可靠传输的方式之一：通过序列号和确认应答号。

如果收到了一个「序列号」为 A 的包，那么发送出去的包的确认应答号是`A+1`。

在正常情况下，当发送端的数据到达接收主机时，接收端主机会返回一个确认应答的消息，表示已经收到消息。

但是网络的情况是错综复杂的，并不一定能顺利进行数据传输，TCP针对数据包丢失的情况，会使用重传机制来解决。

常见的重传机制有：

-   超时重传
-   快速重传
-   SACK
-   D-SACK

### 超时重传

超时重传，就是在发送数据时，设定一个定时器，当超过指定的时间后，没有收到对方的`ACK`确认报文，就会重新发送该数据。

TCP会在以下两种情况发生超时重传：

-   数据包丢失
-   确认应答ACK丢失，这个不是说ACK报文会重传，而是ACK报文丢失，会发送数据包。

<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/5.jpg?image_process=watermark,text_5YWs5LyX5Y-377ya5bCP5p6XY29kaW5n,type_ZnpsdHpoaw,x_10,y_10,g_se,size_20,color_0000CD,t_70,fill_0" style="zoom:50%;" />

**超时时间的设置**

RTT（Round-Trip Time 往返时间），如下图：

<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/6.jpg?" style="zoom:50%;" />





也就是说，RTT指的是数据从发送出去到接收到ACK时刻的差值，也就是包的往返时间。

超时重传则是RTO（Retransmission Timeout）表示，超时时长RTO太长或者太短都不好：

<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/7.jpg?image_process=watermark,text_5YWs5LyX5Y-377ya5bCP5p6XY29kaW5n,type_ZnpsdHpoaw,x_10,y_10,g_se,size_20,color_0000CD,t_70,fill_0" style="zoom:50%;" />

-   超时时间RTO太长，则代表丢了太久才重发，没有效率
-   超时时间RTO太短，可能会出现「包没有丢就重发」，导致网络负荷增大

所以精准的RTO是很有必要的，这可以让我们的重传机制更加高效。所以：**RTO的值应该略大于RTT的值**。

<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/8.jpg?image_process=watermark,text_5YWs5LyX5Y-377ya5bCP5p6XY29kaW5n,type_ZnpsdHpoaw,x_10,y_10,g_se,size_20,color_0000CD,t_70,fill_0" style="zoom:50%;" />

但是RTT的值是不断变化的，所以超时重传时间RTO也是一个动态变化的值。Linux 中，每遇到一次超时重传，都会将下一次超时时间间隔 RTO 设置为之前的两倍。



Linux计算RTO的方法：

1.   采样两个数据：
     1.   采样RTT的时间，然后进行加权平均，计算出一个平滑RTT，这个值需要不断变化
     2.   采样RTT的波动范围
2.   通过公式计算RTO
3.   如果超时重发的数据，再次超时的时候，又需要重传的时候，TCP 的策略是**超时间隔加倍。**



超时重传的问题是，超时周期可能相对较长，所以可以利用快速重传来解决重发时间等待。



### 快速重传

TCP的「快速重传」（Fast Retransmit）机制，不以时间为驱动，而是以数据为驱动重传。

如下图：

<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/10.jpg?image_process=watermark,text_5YWs5LyX5Y-377ya5bCP5p6XY29kaW5n,type_ZnpsdHpoaw,x_10,y_10,g_se,size_20,color_0000CD,t_70,fill_0" style="zoom: 67%;" />



就是如果收到连续三次**同样的ACK确认**，那么就会在定时器过期之前，重传丢失的报文段。但是这样又有问题，那就是重传一个，还是重传所有的问题。这两种方法也都有问题。

也就ACK的确认应答号相同。

>   从上图可以看出，还有一个细节，就是发送方的Seq1和Seq3到了，Seq2没到，接收方会发送ACK2和ACK2，而不是ACK2和ACK4。而发送方收到连续三个 ACK2，而自己又没有多次发送 Seq1，就知道 Seq2 丢了。

但是这种方法的的不足之处就在于，到底重发哪一个包呢，首先 Seq2 肯定是丢了，但是 Seq3、Seq4、Seq5发送方是不知道丢了没：

-   **如果只选择重传 Seq2，后面的包正常发送**，万一 Seq2 和 Seq3 都丢了，则接收方回复的是 ACK3，对于后续收到的包也是回复 ACK3，连续发送三个 ACK3 发送方才知道 Seq3 也丢了，重发 Seq3，此时连接才正常。这样效率很低。
-   **如果选择重传 Seq2 之后的所有包。**那么 Seq4 和 Seq5 就又重传了一次，相当于白发。

所以有了「SACK」方法。



### SACK方法

SACK（Selective Acknowledgment），选择性确认。

这种方法需要在TCP头部「选项」字段中添加一个「SACK」，它可以将已收到的数据的信息发送给「发送方」，这样发送方就知道哪些数据收到了，哪些数据没收到，有这些信息，就可以**只重传丢失的数据**。

如下图，发送方收到了三次同样的ACK确认报文，于是就会触发快速重传机制，并通过「SACK」信息发现只有「200～299」这段数据丢失，则重发时，就只选择了这个TCP段进行重发。

<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/11.jpg?image_process=watermark,text_5YWs5LyX5Y-377ya5bCP5p6XY29kaW5n,type_ZnpsdHpoaw,x_10,y_10,g_se,size_20,color_0000CD,t_70,fill_0" style="zoom:50%;" />



-   可以看到TCP的ACK是一种**累积ACK**，只有当前n个数据块全部收到后，ACK 才等于n+1
-   而SACK则是收到哪个数据包就返回这个数据包+1，**当 SACK 不断变大，而 ACK 不变的时候，证明可能丢报了；当 SACK 突然又变小，而 ACK 变为之前 SACK 最大的时候，发送方就知道不是丢包，而是网络延迟。**
-   双方都要支持SACK，同时Linux2.4后默认打开。



### Duplicate SACK

又称D-SACK，其主要**使用SACK来告诉「发送方」有哪些数据被重复接收了**。

**例1: ACK丢包**

让发送方知道，发送的数据没有丢失，而是接收方的ACK丢失了，如下图：

<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/12.jpg?image_process=watermark,text_5YWs5LyX5Y-377ya5bCP5p6XY29kaW5n,type_ZnpsdHpoaw,x_10,y_10,g_se,size_20,color_0000CD,t_70,fill_0" style="zoom:50%;" />

-   接收方ACK大于SACK，说明ACK之前的都已经接收到了，这样发送方就知道，数据没有丢。
-   注意到发送方重新发送`3000-3499`数据包的时候，接收方发送的包中：`ACK=4000, SACK = 3000-3500`



**例2: 网络延时**



<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/13.jpg?image_process=watermark,text_5YWs5LyX5Y-377ya5bCP5p6XY29kaW5n,type_ZnpsdHpoaw,x_10,y_10,g_se,size_20,color_0000CD,t_70,fill_0" style="zoom:50%;" />

-   同样也是SACK小于ACK，说明3000之前的都已经收到了，而SACK的1000～1500属于重复收到的包

所以，D-SACK的好处：

-   可以让发送方知道，是自己发出去的包丢了，还是接收方回应的ACK丢了
-   可以知道是不是发送方的数据包被网络延时了
-   可以知道网络中是不是把「发送方」的数据包给复制了;

Linux2.4后默认打开



## 滑动窗口

在概念上，TCP每发送一个数据，都要进行一次确认应答，类似于你说一句我回一句，但是这样效率很低。

所以，TCP引入了「窗口」这个概念**，即使在往返时间较长的情况下，它也不会降低网络通信的效率**，同时窗口还可以允许某些 ACK 丢失。

窗口有个大小的概念，窗口大小就是指「无需等待确认应答，而可以继续发送数据的最大值」。

**窗口实际上就是OS开辟的一个缓冲空间**：

-   「发送方主机」在等到确认应答返回之前，必须在缓冲区中保留已发送的数据，如果按期收到确认应答，此时数据就可以从缓存区清除。
-   「接收方」主机的滑动窗口指的是「未收到数据，但是可以接收的数据」

窗口的最小单位应该是字节。

假设窗口为3个TCP段，那么发送方就可以连续发送3个TCP段，并且如果中途有ACK丢失，可以通过下一个确认应答进行确认，如图：

<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/15.jpg?image_process=watermark,text_5YWs5LyX5Y-377ya5bCP5p6XY29kaW5n,type_ZnpsdHpoaw,x_10,y_10,g_se,size_20,color_0000CD,t_70,fill_0" style="zoom: 67%;" />

只是要发送方收到了ACK700，那么就意味着700之前的所有数据「接收方」都接收到了，这个模式就叫**「累计确认」**或者**「累计应答」。**

TCP头中有一个字段叫`Window`，也就是「窗口大小」，**这个字段是接收端告诉发送端自己还有多少缓冲区可以接收数据。于是发送端就可以根据接收方的处理能力来发送数据，而不会导致接收端处理不过来**

所以，窗口的大小是由接收端的窗口大小来决定的。

发送方发送的数据大小不能超过接收方的窗口大小，否则接收方就无法接受到数据。

### **发送方的滑动窗口：**



<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/16.jpg?" style="zoom:50%;" />

真正属于「发送方滑动窗口」（发送方缓冲区）的部分：

-   \#2：已发送但未收到 ACK 确认的数据
-   \#3：未发送但总大小在「接收方处理范围」内的数据

如果发送方把缓冲区的数据（滑动窗口中的数据）全部发送完，那么「发送窗口」的 \#2 部分将占据整个「发送窗口」，此时不能发送数据。

当收到一部分应答后，例如收到 32-36 字节的 ACK 确认应答后，如果「发送窗口」的总大小没有变化，则「发送窗口」会向后移动 5 个字节。此时\#3部分有 5 个字节。

### 程序如何表示发送方的四个部分？

<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/19.jpg?image_process=watermark,text_5YWs5LyX5Y-377ya5bCP5p6XY29kaW5n,type_ZnpsdHpoaw,x_10,y_10,g_se,size_20,color_0000CD,t_70,fill_0" style="zoom:50%;" />

TCP的滑动窗口方案使用三个指针来跟踪在「四个传送类别」中每一个类别中的字节。其中两个指针是绝对指针（指特定的序列号），一个是相对指针（需要做偏移）。

-   `SND.WND`：表示发送窗口的大小（大小是由接受方指定的）
-   `SND.UNA`：（Send Unacknoleged），一个绝对指针，它指向的是已发送但未收到确认的第一个字节的序号，也就是上图#2的第一个字节
-   `SND.NXT`：也是一个绝对指针，指向「未发送但是可以发送范围」的第一个字节的序号，也就是#3的第一个字节
-   指向#4的第一个字节是一个相对指针，大小为：`SND.UNA+SND.WND`，它指向第四个区域的第一个字节

>    可用窗口大小=`SND.WND - (SND.NXT - SND.UNA)` ，也就是说，所谓「可用窗口大小」就是「未发送但是在接收方处理范围内」的窗口。



### 接收方的滑动窗口：

接收方的滑动窗口相对简单一些：

<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/20.jpg" style="zoom:50%;" />

根据处理情况分为 3 个部分：

-   #1 + #2表示已经成功接收并确认的数据
-   #3 是未收到数据但是可以接收的数据
-   #4 区域表示未收到数据并不可以接受的数据

其中真正属于「接收窗口」的只有：**「未收到数据但可以接收的数据」**。

其中三个接收部分，使用两个指针进行划分：

-   `RCV.WND`：表示接收窗口的大小，它会通告给发送方
-   `RCV.NXT`：它直接「期望从发送方发送来的下一个数据字节的序列号」，也就是#3的第一个字节
-   指向#4的第一个字节是相对指针，也就是`RCV.NXT+RCV.WND`。



>   需要注意的是，接收窗口和发送窗口并不完全相等，接收窗口是约等于发送方窗口大小的。
>
>   一般来说，服务端和客户端都要收发数据，所以他们都既有「发送窗口」，也有「接收窗口」。

因为滑动窗口不是一成不变的。例如接收方的应用进程读取数据的速度非常快的话，这样的话接收窗口就会很快空缺出来，但是新的接收窗口的大小，**是通过TCP报文中的Windows字段来告诉发送方，这个过程可能存在延时**，所以接收窗口和发送窗口是约等于的关系。

 

## 流量控制

发送方不能无脑地发送数据给接收方，需要考虑对方的处理能力。

如果一直发送数据给对方，但是对方处理不过来，那么就会导致触发重发极值，从而导致网络流量的浪费。

为了防止这种现象，TCP提供一种机制，可以让「发送方」根据「接收方」的实际接收能力控制发送的数据量，这就是所谓流量控制。

<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/21.png?image_process=watermark,text_5YWs5LyX5Y-377ya5bCP5p6XY29kaW5n,type_ZnpsdHpoaw,x_10,y_10,g_se,size_20,color_0000CD,t_70,fill_0" style="zoom: 40%;" />

假设服务端是发送方，客户端是接收方，接收窗口和发送窗口相同，都为200，同时这个大小不改变。注意服务端的接收窗口和客户端的发送窗口。



### 操作系统缓冲区和滑动窗口的关系

很多时候为了方便，我们会假设发送窗口和接收窗口是不变的。但实际上，「发送窗口」和「接收窗口」所存放的字节数，都是存放在操作系统的「内核缓冲区」中，操作系统的缓冲区，会被操作系统调整。也就是说，操作系统的缓冲区，会影响发送窗口和接收窗口。

考虑如下场景：

-   客户端作为发送方，服务端作为接收方，发送窗口和接收窗口的初始大小为：360
-   服务端非常繁忙，收到客户端的数据时，应用层不能及时读取数据

<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/22.jpg?image_process=watermark,text_5YWs5LyX5Y-377ya5bCP5p6XY29kaW5n,type_ZnpsdHpoaw,x_10,y_10,g_se,size_20,color_0000CD,t_70,fill_0" style="zoom:40%;" />

-   客户端发送 140 个字节，服务端收到后，应用进程只读取了 40 个字节，还有 100 字节占用着缓冲区，导致接收窗口只有 260（360 - 100）。
-   客户端收到「确认+窗口通告」报文后，发送窗口也变为 260
-   如此每次发送接收数据，接受方（服务端）都由于进程处理不过来，导致接收窗口变小，最后发送窗口和接收窗口都变为 0，也就是发生了「窗口关闭」

更严重的情况是，接收方的窗口通告报文没有及时发送给发送方，导致发送窗口和接收窗口大小不一致，发送方发送大量数据给接收方，如果接收方的接收窗口小于数据，就会把数据包丢弃。

所以 TCP 规定先收缩窗口，再减少缓存，这样就有更多的空间来给进程处理为处理的数据。



### 窗口关闭

TCP 的窗口大小是由接收方决定的，如果窗口大小为 0，就会阻止发送方发送数据，直到接收方处理完数据，此时接收方处理完数据，窗口增大了，于是发送一个「ACK+窗口通告」的数据包给接收方，这个包如果丢失了，那么就会很麻烦，因为这个 ACK 包不带数据，「单独的 ACK包」不会重发。此时双方都在等待对方的非 0 窗口通知，造成「死锁」。

所以 TCP 又设计了一个定时器，只要 TCP 连接的一方受到对方的「零窗口通知」报文，就启动持续计时器，这个计时器一超时，就会发送**「窗口探测（Window probe）报文」**，对方在确认这个探测报文时，给出自己的现在的接收窗口的大小。

-   如果接收窗口仍然是 0，则重启计时器
-   如果不是 0，则可以打破死锁

当发送者收到了一个窗口为0的应答，发送者便停止发送，等待接收者的下一个应答。但是如果这个窗口不为0的应答在传输过程丢失，发送者一直等待下去，而接收者以为发送者已经收到该应答，等待接收新数据，这样双方就相互等待，从而产生死锁。
为了避免流量控制引发的死锁，TCP使用了持续计时器。每当发送者收到一个零窗口的应答后就启动该计时器。时间一到便主动发送报文询问接收者的窗口大小。若接收者仍然返回零窗口，则重置该计时器继续等待；若窗口不为0，则表示应答报文丢失了，此时重置发送窗口后开始发送，这样就避免了死锁的产生。

## 拥塞控制

### 流量控制和拥塞控制的区别

流量控制是避免「发送方」的数据填满「接收方」的缓存，但是并不知道网络中发生了什么。

当网络出现拥堵时，如果继续发送大量数据包，可能会导致数据包延迟、丢失等，此时TCP就会重传数据，但是此时网络又很差，所以这个事就会进入恶性循环。

当网络发送拥塞时，TCP会自我牺牲，降低发送的数据量，所谓「拥塞控制」就是避免「发送方」的数据填满整个网络。

所以有了一个「拥塞窗口」的概念。

**总结：**

-   流量控制：服务于「接收方」，避免发送方的数据填满接收方的缓存，导致数据丢失。
-   拥塞控制：作用于「网络」，防止过多的数据进入到网络中，避免出现网络负载过大。避免「发送方」的数据填满整个网络。

所以拥塞窗口也是在发送端。

### 拥塞窗口和发送窗口

-   「拥塞窗口cwnd」（congestion window）是发送方维护的一个状态变量，它会根据网络的拥塞程度动态变化。
-   swnd(send window), rwnd(recive window)

发送窗口swnd和接收窗口rwnd是约等于的关系，加入拥塞窗口的概念后，发送窗口的值`swnd=min(cwnd, rwnd)`，也就是拥塞窗口和接收窗口的最小值。

拥塞窗口cwnd变化的规则：

-   只要网络中没有出现拥塞，cwnd就会变大
-   但是网络中出现拥塞，cwnd就会减少



### **如何确定网络是否出现拥塞？**

只要「发送方」没有在规定时间收到ACK应答报文，也就是发生了「超时重传」，就认为网络中出现了拥塞。



**拥塞控制的算法：**

-   慢启动
-   拥塞避免
-   拥塞发生
-   快速恢复

### 慢启动

TCP在刚简历连接完成后，首先是一个慢启动的过程，一点一点提高发送数据包的数量：

-   **每当发送方收到一个ACK，拥塞窗口cwnd就会增加1**

假设拥塞窗口和发送窗口swnd相等：

-   连接建立完成后，一开始初始化cwnd=1，表示可以传一个MSS大小的数据
-   当收到一个ACK确认应答后，cwnd增加1，于是一次可以发送2个
-   当收到两个ACK确认应答，cwnd增加2
-   每一轮，慢启动呈指数增加

所以每个往返时间，慢启动呈指数增加。

当cwnd大于等于「慢启动阈值」（slow start threshold）时，就会使用「拥塞避免算法」。



### 拥塞避免算法

一般来说ssthresh的大小是65535字节，当拥塞窗口达到ssthresh时，就会进入拥塞避免算法：

-   **每当收到一个 ACK 时，cwnd 增加 1/cwnd。**

所以如果ssthresh是16，当cwnd到达16后，收到16个ACK才会增加1，也就说每个往返时间最多增加1，每轮呈线性增长。

<img src="https://s2.51cto.com/images/blog/202104/15/3c38f763ef2d971b1b4e110d59a7f788.jpeg?x-oss-process=image/watermark,size_16,text_QDUxQ1RP5Y2a5a6i,color_FFFFFF,t_30,g_se,x_10,y_10,shadow_20,type_ZmFuZ3poZW5naGVpdGk=/resize,m_fixed,w_1184" style="zoom: 67%;" />

就这样一直增长，网络就可能进入拥塞的状况了，如果丢包，就要触发重传机制，也就进入了「拥塞发生算法」。



### 拥塞发生算法

当网络出现拥塞，也就是会发生数据包重传，有两种重传机制：

-   超时重传（RTO）
-   快速重传

这种重传方法会导致拥塞发生算法不同。

**发生超时重传的拥塞发生算法：**

当发生的是「超时重传」，拥塞发生算法如下：

<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost2/计算机网络/TCP-可靠特性/29.jpg?image_process=watermark,text_5YWs5LyX5Y-377ya5bCP5p6XY29kaW5n,type_ZnpsdHpoaw,x_10,y_10,g_se,size_20,color_0000CD,t_70,fill_0" style="zoom:50%;" />

-   慢启动阈值ssthresh变为cwnd/2
-   cwnd重制为cwnd的初始值（可能是1），可以使用`ss -nli`每一个TCP连接的cwnd初始值。
-   接着就重新开始慢启动

可以看到这种方法的一个缺点就是：太激进了，直接从头再来



**发生快速重传的拥塞发生算法：**

当接收方发现丢了一个中间包的时候，发送三次前一个包的 ACK，于是发送端就会快速地重传，不必等待超时再重传。

TCP认为这种情况不严重，因为只丢了一小部分，做法是：

-   cwnd = cwnd/2，也就是设置为原来的一半
-   ssthresh = cwnd
-   进入快速恢复算法



### 快速恢复算法

也就是发生快速重传的拥塞发生算法。

快速重传一般配合快速恢复算法一同使用。

<img src="https://cdn.xiaolincoding.com/gh/xiaolincoder/ImageHost4@main/网络/拥塞发生-快速重传.drawio.png?image_process=watermark,text_5YWs5LyX5Y-377ya5bCP5p6XY29kaW5n,type_ZnpsdHpoaw,x_10,y_10,g_se,size_20,color_0000CD,t_70,fill_0" style="zoom:50%;" />

我们从绿色的点开始看：

-   cwnd = ssthresh + 3，3是因为连续收到三个ACK才会快速重传，ssthresh为6
-   重传丢失的数据包
-   收到重复的ACK，cwnd增加1
-   如果收到新数据的ACK（也就是不是重复的ACK）之后，cwnd = ssthresh，这里是6，表示ACK收到新的数据，恢复过程已经正常结束，并在此进入拥塞避免状态

