# RabbitMQ

## 1. 消息队列

### 1.1 MQ的相关概念

#### 1.1.1 什么是MQ

MQ(message queue)，从字面意思上看，本质是一个队列，FIFO 先入先出，只不过队列中存放的内容是 message 而已，还是一种跨进程的通信机制，用于上下游传递消息。在互联网架构中，MQ 是一种非常常 见的上下游“逻辑解耦+物理解耦”的消息通信服务。使用了 MQ 之后，消息发送上游只需要依赖 MQ，不 用依赖其他服务。

#### 1.1.2 为什么要用MQ

**1. 流量消峰**

通过MQ内部对访问进行排队来达到消峰目的。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220911115308582.png" alt="image-20220911115308582" style="zoom:40%;" />

举个例子，如果订单系统最多能处理一万次订单，这个处理能力应付正常时段的下单时绰绰有余，正 常时段我们下单一秒后就能返回结果。但是在高峰期，如果有两万次下单操作系统是处理不了的，只能限 制订单超过一万后不允许用户下单。使用消息队列做缓冲，我们可以取消这个限制，把一秒内下的订单分 散成一段时间来处理，这时有些用户可能在下单十几秒后才能收到下单成功的操作，但是比不能下单的体 验要好。

**2. 应用解耦**

以电商应用为例，应用中有订单系统、库存系统、物流系统、支付系统。用户创建订单后，如果耦合 调用库存系统、物流系统、支付系统，任何一个子系统出了故障，都会造成下单操作异常。当转变成基于 消息队列的方式后，系统间调用的问题会减少很多，比如物流系统因为发生故障，需要几分钟来修复。在 这几分钟的时间里，物流系统要处理的内存被缓存在消息队列中，用户的下单操作可以正常完成。当物流 系统恢复后，继续处理订单信息即可，其中用户感受不到物流系统的故障，提升系统的可用性。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220911115632773.png" alt="image-20220911115632773" style="zoom:40%;" />



**3. 异步处理**

有些服务间调用是异步的，例如 A 调用 B，B 需要花费很长时间执行，但是 A 需要知道 B 什么时候可 以执行完，以前一般有两种方式，A 过一段时间去调用 B 的查询 api 查询。或者 A 提供一个 callback api， B 执行完之后调用 api 通知 A 服务。这两种方式都不是很优雅，使用消息总线，可以很方便解决这个问题， A 调用 B 服务后，只需要监听 B 处理完成的消息，当 B 处理完成后，会发送一条消息给 MQ，MQ 会将此 消息转发给 A 服务。这样 A 服务既不用循环调用 B 的查询 api，也不用提供 callback api。同样 B 服务也不 用做这些操作。A 服务还能及时的得到异步处理成功的消息。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220911115809289.png" alt="image-20220911115809289" style="zoom:40%;" />

#### 1.1.3 MQ的分类

1.   **ActiveMQ**
     -   优点：单机吞吐量万级，实效性ms级，可用性高，基于主从架构实现高可用性，消息可靠性较低的概率丢失数据
     -   缺点：官方社区现在对ActiveMQ 5.x**维护越来越少，高吞吐量场景较少使用**
2.   **Kafka**
     -   大数据的杀手锏，谈到大数据领域内的消息传输，则绕不开 Kafka，这款为**大数据而生**的消息中间件， 以其**百万级** **TPS** 的吞吐量名声大噪，迅速成为大数据领域的宠儿，在数据采集、传输、存储的过程中发挥 着举足轻重的作用。目前已经被 LinkedIn，Uber, Twitter, Netflix 等大公司所采纳。
     -   优点: 性能卓越，单机写入 TPS 约在百万条/秒，最大的优点，就是吞**吐量高**。时效性 ms 级可用性非 常高，kafka 是分布式的，一个数据多个副本，少数机器宕机，不会丢失数据，不会导致不可用,消费者采 用 Pull 方式获取消息, 消息有序, 通过控制能够保证所有消息被消费且仅被消费一次;有优秀的第三方 Kafka Web 管理界面 Kafka-Manager;在日志领域比较成熟，被多家公司和多个开源项目使用;功能支持: 功能较为简单，主要支持简单的 MQ 功能，在大数据领域的实时计算以及**日志采集**被大规模使用
     -   缺点:Kafka 单机超过 64 个队列/分区，Load 会发生明显的飙高现象（CPU飙高），队列越多，load 越高，发送消 息响应时间变长，使用短轮询方式，实时性取决于轮询间隔时间，消费失败不支持重试;支持消息顺序， 但是一台代理宕机后，就会产生消息乱序，**社区更新较慢**
3.   **RocketMQ**
     -   RocketMQ 出自阿里巴巴的开源产品，用 Java 语言实现，在设计时参考了 Kafka，并做出了自己的一 些改进。被阿里巴巴广泛应用在订单，交易，充值，流计算，消息推送，日志流式处理，binglog 分发等场 景。
     -   优点:**单机吞吐量十万级**,可用性非常高，分布式架构,**消息可以做到0丢失**,MQ 功能较为完善，还是分 布式的，扩展性好,支持 **10亿级别的消息堆积**，不会因为堆积导致性能下降,源码是 java 我们可以自己阅 读源码，定制自己公司的 MQ
     -   缺点:**支持的客户端语言不多**，目前是 java 及 c++，其中 c++不成熟;社区活跃度一般,没有在 MQ 核心中去实现 JMS 等接口,有些系统要迁移需要修改大量代码

4.   **RabbitMQ**

     -   2007 年发布，是一个在 AMQP(高级消息队列协议)基础上完成的，可复用的企业消息系统，**是当前最主流的消息中间件之一**。

     -   优点:由于 erlang 语言的**高并发特性**，性能较好;**吞吐量到万级**，MQ 功能比较完备,健壮、稳定、易 用、跨平台、**支持多种语言** 如:Python、Ruby、.NET、Java、JMS、C、PHP、ActionScript、XMPP、STOMP 等，支持 AJAX 文档齐全;开源提供的管理界面非常棒，用起来很好用,**社区活跃度高**;更新频率相当高

     -   缺点:商业版需要收费,学习成本较高
     
     -   [Rabbit官网](https://www.rabbitmq.com/news.html)

#### 1.1.4 MQ的选择

1.   Kafka

     Kafka 主要特点是基于 Pull 的模式来处理消息消费，追求高吞吐量，一开始的目的就是用于日志收集 和传输，适合产生**大量数据**的互联网服务的数据收集业务。**大型公司**建议可以选用，如果有**日志采集**功能， 肯定是首选 kafka 了。

2.   RocketMQ

     天生为**金融互联网**领域而生，对于可靠性要求很高的场景，尤其是电商里面的订单扣款，以及业务削 峰，在大量交易涌入时，后端可能无法及时处理的情况。RoketMQ 在稳定性上可能更值得信赖，这些业务 场景在阿里双 11 已经经历了多次考验，如果你的业务有上述并发场景，建议可以选择 RocketMQ。

3.   RabbitMQ

     结合 erlang 语言本身的并发优势，性能好**时效性微秒级**，**社区活跃度也比较高**，管理界面用起来十分

     方便，如果你的**数据量没有那么大**，中小型公司优先选择功能比较完备的 RabbitMQ。

### 1.2 RabbitMQ

#### 1.2.1 RabbitMQ的概念

RabbitMQ 是一个消息中间件:它接受并转发消息。你可以把它当做一个快递站点，当你要发送一个包 裹时，你把你的包裹放到快递站，快递员最终会把你的快递送到收件人那里，按照这种逻辑 RabbitMQ 是 一个快递站，一个快递员帮你传递快件。RabbitMQ 与快递站的主要区别在于，它不处理快件而是接收， 存储和转发消息数据。

具体结构如下：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220911135807072.png" alt="image-20220911135807072" style="zoom:40%;" />



#### 1.2.2 四大核心概念

1.   **生产者**

     产生数据发送消息的程序是生产者

2.   **交换机**

     交换机是 RabbitMQ 非常重要的一个部件，一方面它接收来自生产者的消息，另一方面它将消息 推送到队列中。交换机必须确切知道如何处理它接收到的消息，是将这些消息推送到特定队列还是推 送到多个队列，亦或者是把消息丢弃，这个得有交换机类型决定

3.   **队列**

     队列是 RabbitMQ 内部使用的一种数据结构，尽管消息流经 RabbitMQ 和应用程序，但它们只能存 储在队列中。队列仅受主机的内存和磁盘限制的约束，本质上是一个大的消息缓冲区。许多生产者可 以将消息发送到一个队列，许多消费者可以尝试从一个队列接收数据。这就是我们使用队列的方式

4.   **消费者**

     消费与接收具有相似的含义。消费者大多时候是一个等待接收消息的程序。请注意生产者，消费 者和消息中间件很多时候并不在同一机器上。同一个应用程序既可以是生产者又是可以是消费者。

#### 1.2.3 RabbitMQ核心部分

RabbitMQ有六大核心部分，也叫六大工作模式。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220911140019539.png" alt="image-20220911140019539" style="zoom:40%;" />

#### 1.2.4 各个名词介绍

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220911140051555.png" alt="image-20220911140051555" style="zoom:40%;" />

-   **Broker：**接收和分发消息的应用，RabbitMQ Server就是Message Broker

-   **Virtual host**：出于多租户和安全因素设计的，把 AMQP 的基本组件划分到一个虚拟的分组中，类似 于网络中的 namespace 概念。当多个不同的用户使用同一个 RabbitMQ server 提供的服务时，可以划分出 多个 vhost，每个用户在自己的 vhost 创建 exchange/queue 等

-   **Connection：**publisher/consumer 和 broker 之间的 TCP 连接

-   **Channel：**如果每一次访问RabbitMQ都建立一个Connection，在消息量大的时候建立 TCP Connection 的开销将是巨大的，效率也较低。Channel 是在 connection 内部建立的逻辑连接，如果应用程 序支持多线程，通常每个 thread 创建单独的 channel 进行通讯，AMQP method 包含了 channel id 帮助客 户端和 message broker 识别 channel，所以 channel 之间是完全隔离的。Channel 作为轻量级的 **Connection极大减少了操作系统建立TCP connection的开销**

-   **Exchange：**message 到达 broker 的第一站，根据分发规则，匹配查询表中的 routing key，分发 消息到 queue 中去。常用的类型有:direct (point-to-point), topic (publish-subscribe) and fanout (multicast)

-   **Queue：**消息最终被送到这里等待 consumer 取走

-   **Binding：**exchange 和 queue 之间的虚拟连接，binding 中可以包含 routing key，Binding 信息被保 存到 exchange 中的查询表中，用于 message 的分发依据

#### 1.2.5 安装

1.   官网下载：

     [RabbitMQ下载的官网](https://www.rabbitmq.com/download.html)

     <img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220911140653079.png" alt="image-20220911140653079" style="zoom:40%;" />

     需要先安装Erlang语言

2.   文件上传：

     上传到/usr/local/software 目录下(如果没有 software 需要自己创建)

3.   安装文件(分别按照以下顺序安装)

     ```shell
     rpm -ivh erlang-21.3-1.el7.x86_64.rpm
     yum install socat -y
     rpm -ivh rabbitmq-server-3.8.8-1.el7.noarch.rpm
     ```

4.   常用命令(按照以下顺序执行)

     -   添加开机启动RabbitMQ服务：`chkconfig rabbitmq-server on`
     -   启动服务：`/sbin/service rabbitmq-server start`
     -   查看服务状态：`/sbin/service rabbitmq-server status`
     -   停止服务：`/sbin/service rabbitmq-server stop`
     -   开启web管理插件`rabbit-plugins enable rabbitmq_management`，阿里云和防火墙打开15672和5672端口。（分别是Web页面的端口号和RabbitMQ的端口号）
     -   用默认账号密码(guest)访问地址`60.205.xx:15672`出现权限问题

5.   添加新用户

     -   创建账号：`rabbitmqctl add_user <user> <password>`

     -   设置用户角色：`rabbitmqctl set_user_tags <user> administrator`

     -   设置用户权限：`set_permissions [-p <vhostpath>] <user> <conf> <write> <read>`、`rabbitmqctl set_permissions -p "/" <user> ".*" ".*" ".*"`

         用户 user_admin 具有/ 这个 virtual host 中所有资源的配置、写、读权限

     -   当前用户和角色：`rabbitmqctl list_users`

6.   再次登陆

7.   重置命令

     -   关闭应用的命令为：`rabbitmqctl stop_app`
     -   清除的命令：`rabbitmqctl reset`
     -   重启：`rabbitmqctl start_app`

## 2. Hello World

搭建好RabbitMQ服务器后，还需要用代码构建生产者和消费者，并通过MQ实现通信。

### 2.1 依赖

pom.xml文件：

```xml
<!--指定JDK编译版本-->
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <configuration>
                <source>8</source>
                <target>8</target>
            </configuration>
        </plugin>
    </plugins>
</build>

<dependencies>
    <!--rabbitmq依赖客户端-->
    <dependency>
        <groupId>com.rabbitmq</groupId>
        <artifactId>amqp-client</artifactId>
        <version>5.8.0</version>
    </dependency>
    <!--操作文件流的一个依赖-->
    <dependency>
        <groupId>commons-io</groupId>
        <artifactId>commons-io</artifactId>
        <version>2.6</version>
    </dependency>
</dependencies>
```

### 2.22 消息生产者

需要打开5672端口号

```java
package com.hyf.rabbitmq.one;

import com.rabbitmq.client.Channel;
import com.rabbitmq.client.Connection;
import com.rabbitmq.client.ConnectionFactory;

/**
 * @author 旋风冲锋龙卷风
 * @description: 生产者发消息
 * @date 2022/09/11 14:59
 * @Copyright: 个人博客 : http://letsgofun.cn/
 **/
public class Producer {
	//队列名称
	public static final String QUEUE_NAME = "hello";

	//发消息
	public static void main(String[] args) throws Exception {
		//创建一个连接工厂
		ConnectionFactory factory = new ConnectionFactory();
		//工厂IP 连接RabbitMQ的队列
		factory.setHost("60.205.XX");
		//设置超时时间
		//用户名和密码 
		factory.setUsername("");
		factory.setPassword("");//使用自己的账号密码



		try(//创建连接
			Connection connection = factory.newConnection();

			//获取信道
			Channel channel = connection.createChannel()){
			/*
			 * 生成一个队列
			 * 1. 队列名称
			 * 2. 队列里面的消息是否持久化(磁盘) 默认情况消息存储在内存中,不进行持久化
			 * 3. 该队列是否只供一个消费者进行消费 是否进行消息共享 true:允许多个消费者消费 false:只能一个消费者消费
			 * 4. 是否自动删除 最后一个消费者端开连接以后 该队列是否自动删除 true:自动删除
			 * 5. 其他参数
			 * */
			channel.queueDeclare(QUEUE_NAME,false,  false, false, null);
			//发消息
			String message = "hello world";
			/*
			 * 发送一个消息，参数：
			 * 1. 发送到哪个交换机
			 * 2. 路由的Key值是哪个 本次是队列名称
			 * 3. 其他参数信息
			 * 4. 发送消息的消息体
			 * */
			//需要二进制
			channel.basicPublish("", QUEUE_NAME, null, message.getBytes());
			System.out.println("消息发送完毕");

		}


	}
}

```

### 2.3 消息消费者

```java
package com.hyf.rabbitmq.one;

import com.rabbitmq.client.*;

import java.io.IOException;
import java.util.concurrent.TimeoutException;

/**
 * @author 旋风冲锋龙卷风
 * @description: 消费者:接收消息
 * @date 2022/09/11 15:49
 * @Copyright: 个人博客 : http://letsgofun.cn/
 **/
public class Consumer {
	//队列名称
	public static final String QUEUE_NAME = "hello";
	//接收消息
	public static void main(String[] args) throws IOException, TimeoutException {
		//创建一个连接工厂
		ConnectionFactory factory = new ConnectionFactory();
		//工厂IP 连接RabbitMQ的队列
		factory.setHost("60.205.226.189");
		//用户名和密码
		factory.setUsername("hyfZ");
		factory.setPassword("Love3tory.");
		Connection connection = factory.newConnection();

		Channel channel = connection.createChannel();

		//声明
		DeliverCallback deliverCallback = (consumerTag, message) -> {
			System.out.println(new String( message.getBody()));
		};

		//取消消息回调时的回调
		CancelCallback cancelCallback = consumerTag -> {
			System.out.println("消息消费被中断才执行");
		};
		/*
		* 消费者接收消息,参数:
		* 1. 消费哪个队列
		* 2. 消费成功之后是否要自动应答 true:是 false:手动应答
		* 3. 消费者未成功消费的回调
		* 4. 消费者取消消费的回调
		* */
		channel.basicConsume(QUEUE_NAME, true, deliverCallback, cancelCallback);
	}
}
```

## 3. Work Queues

工作队列(又称任务队列)的主要思想是避免立即执行资源密集型任务，而不得不等待它完成。 相反我们安排任务在之后执行。我们把任务封装为消息并将其发送到队列。在后台运行的工作进 程将弹出任务并最终执行作业。当有多个工作线程时，这些工作线程（消费者）将一起处理这些任务。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220911193919343.png" alt="image-20220911193919343" style="zoom:40%;" />

### 3.1 轮训分发消息

在这个案例中我们会启动两个工作线程，一个消息发送线程，我们来看看他们两个工作线程是如何工作的。

#### 3.1.1 抽取工具类

```java
public class RabbitMqUtils {
	public static Channel getChennel() throws IOException, TimeoutException {
		//创建一个连接工厂
		ConnectionFactory factory = new ConnectionFactory();
		//工厂IP 连接RabbitMQ的队列
		factory.setHost("60.xx");
		//设置超时时间
		//用户名和密码
		factory.setUsername("z");
		factory.setPassword("z");
		Connection connection = factory.newConnection();
		Channel channel = connection.createChannel();
		return channel;
	}
}
```

#### 3.1.2 启动两个工作线程

```java
public class Worker01 {
	//队列名称
	public static final String QUEUE_NAME = "hello";
	//接收消息
	public static void main(String[] args) throws IOException, TimeoutException {
		Channel chennel = RabbitMqUtils.getChennel();
		//声明借口
		DeliverCallback deliverCallback = (consumerTag, message) -> {
			System.out.println("接收到的消息: " + new String( message.getBody()));
		};

		//取消消息回调时的回调
		CancelCallback cancelCallback = consumerTag -> {
			System.out.println(consumerTag + "消息消费被中断才执行");
		};
		//消息接收
		System.out.println("工作线程C2等待接收消息......");
		chennel.basicConsume(QUEUE_NAME, true, deliverCallback, cancelCallback);
	}
}
```

![image-20220911200433870](https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220911200433870.png)



#### 3.1.3 启动一个发送线程

```java
public class Task01 {
	//队列名称
	public static final String QUEUE_NAME = "hello";

	//发送大量消息
	public static void main(String[] args) throws IOException, TimeoutException {
		Channel channel = RabbitMqUtils.getChannel();

		//声明队列
		channel.queueDeclare(QUEUE_NAME,false,  false, false, null);
		//从控制台中接收信息
		Scanner scanner = new Scanner(System.in);
		while(scanner.hasNext()){
			String message = scanner.next();
			channel.basicPublish("", QUEUE_NAME, null, message.getBytes());
			System.out.println("发送消息完成");
		}
	}
}
```

#### 3.1.4 结果

通过程序执行发现生产者总共发送 4 个消息，消费者 1 和消费者 2 分别分得两个消息，并且 是按照有序的一个接收一次消息

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220911201443372.png" alt="image-20220911201443372" style="zoom:40%;" />

### 3.2 消息应答

消费者完成一个任务可能需要一段时间，如果其中一个消费者处理一个长的任务并仅只完成 了部分突然它挂掉了，会发生什么情况。RabbitMQ 一旦向消费者传递了一条消息，便立即将该消 息标记为删除。在这种情况下，突然有个消费者挂掉了，我们将丢失正在处理的消息。以及后续 发送给该消费这的消息，因为它无法接收到。

为了保证消息在发送过程中不丢失，rabbitmq 引入消息应答机制，消息应答就是:**消费者在接 收到消息并且处理该消息之后，告诉 rabbitmq 它已经处理了，rabbitmq 可以把该消息删除了。**

#### 3.2.2 自动应答

消息发送后立即被认为已经传送成功，这种模式需要在**高吞吐量和数据传输安全性方面做权衡**,因为这种模式如果消息在接收到之前，消费者那边出现连接或者 channel 关闭，那么消息就丢 失了,当然另一方面这种模式消费者那边可以传递过载的消息，**没有对传递的消息数量进行限制**， 当然这样有可能使得消费者这边由于接收太多还来不及处理的消息，导致这些消息的积压，最终 使得内存耗尽，最终这些消费者线程被操作系统杀死，**所以这种模式仅适用在消费者可以高效并 以某种速率能够处理这些消息的情况下使用。**

>   它不能出现极端情况。

#### 3.2.3 消息应答的方法

1.   Channel.basicAck(用于肯定确认)

     RabbitMQ已经知道消息并且成功处理消息，可以将其丢弃了

2.   .Channel.basicNack(用于否定确认)

3.   Channel.basicReject(用于否定确认)

     与Channel.basicNack相比少一个参数（是否批量处理），不处理该消息了直接拒绝，可以将其丢弃了

#### 3.2.1 Multiple的解释

手动应答的好处是可以批量应答并且减少网络阻塞。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220911202504373.png" alt="image-20220911202504373" style="zoom:40%;" />

 

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220912142430921.png" alt="image-20220912142430921" style="zoom:40%;" />

建议使用false，只应答当前已经处理完的数据。

#### 3.2.5 消息自动重新入队

如果消费者由于某些原因失去连接(其通道已关闭，连接已关闭或 TCP 连接丢失)，导致消息 未发送 ACK 确认，RabbitMQ 将了解到消息未完全处理，并将对其重新排队。如果此时其他消费者 可以处理，它将很快将其重新分发给另一个消费者。这样，即使某个消费者偶尔死亡，也可以确 保不会丢失任何消息

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220912142629539.png" alt="image-20220912142629539" style="zoom:40%;" />



#### 3.2.6 消息手动应答代码

默认消息采用的是自动应答，所以我们要想实现消息消费过程中不丢失，需要把自动应答改 为手动应答，消费者在上面代码的基础上增加`channel.basicAck(message.getEnvelope().getDeliveryTag(),false);`。 

**生产者**

```java
/**
 * @author 旋风冲锋龙卷风
 * @description: 消息在手动应答时不丢失,放回队列中重新消费
 * @date 2022/09/12 14:41
 * @Copyright: 个人博客 : http://letsgofun.cn/
 **/
public class Task2 {
	//队列名称
	public static final String TASK_QUEUE_NAME = "ack_queue";

	public static void main(String[] args) throws IOException, TimeoutException {
		Channel channel = RabbitMqUtils.getChannel();

		//声明一个队列
		channel.queueDeclare(TASK_QUEUE_NAME, false, false, false, null);
		//从控制台中输入信息
		Scanner scanner = new Scanner(System.in);
		while(scanner.hasNext()){
			String message = scanner.next();
			channel.basicPublish("", TASK_QUEUE_NAME, null, message.getBytes(StandardCharsets.UTF_8));
			System.out.println("生产者发出消息: " + message);

		}
	}
}
```



**消费者01**

```java
public class Work03 {
	//队列名称
	public static final String TASK_QUEUE_NAME = "ack_queue";

	public static void main(String[] args) throws IOException, TimeoutException {
		Channel channel = RabbitMqUtils.getChannel();
		System.out.println("C1等待接收消息处理时间较短");
		DeliverCallback deliverCallback = (consumerTag, message) ->{
			//沉睡1s
			SleepUtils.sleep(1);
			System.out.println("接收到的消息" + new String(message.getBody(), "UTF-8"));
			//手动应答
			/*
			 *1. 消息的标记tag
			 * 2. 是否批量应答 false:应该处理一个应答一个
			 * */
			channel.basicAck(message.getEnvelope().getDeliveryTag(),false);
		};
		//采用手动应答
		boolean autoAck = false;
		channel.basicConsume(TASK_QUEUE_NAME, autoAck, deliverCallback,(consumerTag -> {
			System.out.println("消费者取消消费时借口回调逻辑");
		}));
	}
}
```



**消费者02**

```java
public class Work04 {
	//队列名称
	public static final String TASK_QUEUE_NAME = "ack_queue";

	public static void main(String[] args) throws IOException, TimeoutException {
		Channel channel = RabbitMqUtils.getChannel();
		System.out.println("C2等待接收消息处理时间较长");
		DeliverCallback deliverCallback = (consumerTag, message) ->{
			//沉睡1s
			SleepUtils.sleep(30);
			System.out.println("接收到的消息" + new String(message.getBody(), "UTF-8"));
			//手动应答
			/*
			*1. 消息的标记tag
			* 2. 是否批量应答 false:应该处理一个应答一个
			* */
			channel.basicAck(message.getEnvelope().getDeliveryTag(),false);
		};
		//采用手动应答
		boolean autoAck = false;
		channel.basicConsume(TASK_QUEUE_NAME, autoAck, deliverCallback,(consumerTag -> {
			System.out.println("消费者取消消费时借口回调逻辑");
		}));
	}
}
```

两个消费者的应答时间不同。如果消费者2在等待30s的过程中挂掉，那么消费者1会收到消息，该消息不回丢失。

### 3.3 RabbitMQ持久化

#### 3.3.1 概念

如何保障当 RabbitMQ 服务停掉以后消 息生产者发送过来的消息不丢失。默认情况下 RabbitMQ 退出或由于某种原因崩溃时，它忽视队列 和消息，除非告知它不要这样做。**确保消息不会丢失需要做两件事:我们需要将队列和消息都标记为持久化。**

#### 3.3.2 队列如何实现持久化

在上述代码中，如果RabbitMQ重启，队列会被删除，如果要队列实现持久化，需要在生产者声明队列的时候把`durable`参数设置为持久化。

```java
//让消息队列持久化
boolean durable = true;
channel.queueDeclare(TASK_QUEUE_NAME, durable, false, false, null);
```

>   注意：
>
>   但是需要注意的就是如果之前声明的队列不是持久化的，需要把原先队列先删除，或者重新 创建一个持久化的队列，不然就会出现错误

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220912152550461.png" alt="image-20220912152550461" style="zoom:40%;" />

#### 3.3.3 消息持久化

消息和队列的区别

-   队列是MQ中的一个组件，例如上图的hello队列
-   消息是生产者发送过来的消息
-   队列持久化不等于消息也持久化，它不能保证队列里面的消息不丢失

发消息的时候生产者通知队列需要持久化消息，修改`channel.basicPublish()`第三个参数，添加`MessageProperties.PERSISTENT_TEXT_PLAIN`这个属性。

```java
//设置生产者发送消息为持久化消息,要求保存到磁盘上
channel.basicPublish("", TASK_QUEUE_NAME, MessageProperties.PERSISTENT_TEXT_PLAIN, message.getBytes(StandardCharsets.UTF_8));

```



将消息标记为持久化并不能完全保证不会丢失消息。尽管它告诉 RabbitMQ 将消息保存到磁盘，但是 这里依然存在当消息刚准备存储在磁盘的时候 但是还没有存储完，消息还在缓存的一个间隔点。此时并没 有真正写入磁盘。持久性保证并不强，但是对于我们的简单任务队列而言，这已经绰绰有余了。如果需要 更强有力的持久化策略，参考后边课件**发布确认章节。**

#### 3.3.4 不公平分发

默认情况下RabbitMQ分发消息采用轮训分发，但是在某些场景下这种策略并不是最好。例如有两个消费者在处理任务，其中有个消费者 1 处理任务的速度非常快，而另外一个消费者 2 处理速度却很慢，这个时候我们还是采用轮训分发的化就会到这处理速度快的这个消费者很大一部分时间 处于空闲状态，而处理慢的那个消费者一直在干活，这种分配方式在这种情况下其实就不太好，但是 RabbitMQ 并不知道这种情况它依然很公平的进行分发。

为了避免这种情况，我们可以**在消费者方设置参数**`channel.basicQos(1)`，位置在接收消息之前。

```java
int prefetchCount = 1;
channel.basicQos(prefetchCount);
```



意思就是如果这个任务我还没有处理完或者我还没有应答你，你先别分配给我，我目前只能处理一个 任务，然后 rabbitmq 就会把该任务分配给没有那么忙的那个空闲消费者，当然如果所有的消费者都没有完 成手上任务，队列还在不停的添加新任务，队列有可能就会遇到队列被撑满的情况，这个时候就只能添加 新的 worker 或者改变其他存储任务的策略。

在两个work上都添加不公平分发。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220912153948022.png" alt="image-20220912153948022" style="zoom:40%;" />

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220912153923028.png" alt="image-20220912153923028" style="zoom:40%;" />

#### 3.3.5 预取值(prefetch)

本身消息的发送就是异步发送的，所以在任何时候，channel 上肯定不止只有一个消息另外来自消费 者的手动确认本质上也是异步的。因此这里就存在一个未确认的消息缓冲区，因此希望开发人员能**限制此 缓冲区的大小，以避免缓冲区里面无限制的未确认消息问题**。这个时候就可以通过使用 basic.qos 方法设 置“预取计数”值来完成的。**该值定义通道上允许的未确认消息的最大数量**。一旦数量达到配置的数量， RabbitMQ 将停止在通道上传递更多消息，除非至少有一个未处理的消息被确认，例如，假设在通道上有 未确认的消息 5、6、7，8，并且通道的预取计数设置为 4，此时 RabbitMQ 将不会在该通道上再传递任何 消息，除非至少有一个未应答的消息被 ack。比方说 tag=6 这个消息刚刚被确认 ACK，RabbitMQ 将会感知 这个情况到并再发送一条消息。消息应答和 QoS 预取值对用户吞吐量有重大影响。通常，增加预取将提高 向消费者传递消息的速度。

**虽然自动应答传输消息速率是最佳的，但是，在这种情况下已传递但尚未处理的消息的数量也会增加，从而增加了消费者的 RAM 消耗**(随机存取存储器)应该小心使用具有无限预处理 的自动确认模式或手动确认模式，消费者消费了大量的消息如果没有确认的话，会导致消费者连接节点的 内存消耗变大，所以找到合适的预取值是一个反复试验的过程，不同的负载该值取值也不同 100 到 300 范 围内的值通常可提供最佳的吞吐量，并且不会给消费者带来太大的风险。预取值为 1 是最保守的。当然这 将使吞吐量变得很低，特别是消费者连接延迟很严重的情况下，特别是在消费者连接等待时间较长的环境 中。对于大多数应用来说，稍微高一点的值将是最佳的。

预取值的代码在消费者的不公平分发中`prefetchCount`中，如果设置为1，就是不公平分发，如果设置2，就是预取值。效果需要几条消息堆积才能有效。

>   其实不公平分发就是预取值的一个特殊情况。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220912170524682.png" alt="image-20220912170524682" style="zoom:40%;" />

C2会积压5条数据。

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220912170823451.png" alt="image-20220912170823451" style="zoom:40%;" />

## 4. 发布确认

### 4.1 发布确认原理

1.   生产者要求队列持久化
2.   设置要求队列中的消息也要持久化
3.   但是在传送过程中，消息只有存在磁盘上才能达到持久化目标，但是消息可能在生产者发送消息到队列的过程中丢失
4.   这时候就需要发布确认。

>   生产者将信道设置成 confirm 模式，一旦信道进入 confirm 模式，所有在该信道上面发布的 消息都将会被指派一个唯一的 ID(从 1 开始)，一旦消息被投递到所有匹配的队列之后，broker 就会发送一个确认给生产者(包含消息的唯一 ID)，这就使得生产者知道消息已经正确到达目的队 列了，如果消息和队列是可持久化的，那么确认消息会在将消息写入磁盘之后发出，broker 回传 给生产者的确认消息中 delivery-tag 域包含了确认消息的序列号，此外 broker 也可以设置 basic.ack 的 multiple 域，表示到这个序列号之前的所有消息都已经得到了处理。
>
>   confirm 模式最大的好处在于他是异步的，一旦发布一条消息，生产者应用程序就可以在等信 道返回确认的同时继续发送下一条消息，当消息最终得到确认之后，生产者应用便可以通过回调 方法来处理该确认消息，如果 RabbitMQ 因为自身内部错误导致消息丢失，就会发送一条 nack 消 息，生产者应用程序同样可以在回调方法中处理该 nack 消息。

### 4.2 发布确认的策略

#### 4.2.1 开启发布确认的方法

发布确认默认是没有开启的，发布确认默认是没有开启的，如果要开启需要调用方法 `confirmSelect`，每当你要想使用发布 确认，都需要在 `channel` 上调用该方法

```java
Channel channel = RabbitMqUtils.getChannel();

//开启发布确认
channel.confirmSelect();
```

#### 4.2.2 单个确认发布

发一条，确认一条。

这是一种简单的确认方式，它是一种**同步确认发布**的方式，也就是发布一个消息之后只有它 被确认发布，后续的消息才能继续发布,`waitForConfirmsOrDie(long)`这个方法只有在消息被确认 的时候才返回，如果在指定时间范围内这个消息没有被确认那么它将抛出异常。

这种确认方式有一个最大的缺点就是:**发布速度特别的慢**，因为如果没有确认发布的消息就会 阻塞所有后续消息的发布，这种方式最多提供每秒不超过数百条发布消息的吞吐量。当然对于某 些应用程序来说这可能已经足够了。

打印一下发布消息的耗时：

```java
//1. 单个确认
public static void publishMessageIndividually() throws Exception {
    Channel channel = RabbitMqUtils.getChannel();

    String queueName = UUID.randomUUID().toString();
    channel.queueDeclare(queueName, true, false, false, null);
    //开启发布确认
    channel.confirmSelect();
    //开始时间
    long begin = System.currentTimeMillis();

    //大量发消息
    for (int i = 0; i < MESSAGE_COUNT; i++) {
        //转成字符串
        String message = i + "";
        channel.basicPublish("",queueName, null, message.getBytes());

        //单个消息马上进行发布确认
        boolean flag = channel.waitForConfirms();
        if(flag){
            System.out.println("消息发送成功");
        }
    }
    //结束时间
    long end = System.currentTimeMillis();
    System.out.println("发布" + MESSAGE_COUNT + "个单独确认消息,耗时: " + (end - begin) + "ms");
}
```

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/20220913230632.png" style="zoom:40%;" />

#### 4.2.3 批量确认发布

上面那种方式非常慢，与单个等待确认消息相比，先发布一批消息然后一起确认可以极大地 提高吞吐量，当然这种方式的缺点就是:**当发生故障导致发布出现问题时，不知道是哪个消息出现问题了，我们必须将整个批处理保存在内存中，以记录重要的信息而后重新发布消息**。当然这种方案仍然是同步的，也一样阻塞消息的发布。 

```java
//2. 批量确认
public static void publishMessageBatch() throws Exception {
    Channel channel = RabbitMqUtils.getChannel();

    String queueName = UUID.randomUUID().toString();
    channel.queueDeclare(queueName, true, false, false, null);
    //开启发布确认
    channel.confirmSelect();
    //开始时间
    long begin = System.currentTimeMillis();

    //批量确认消息大小,100条确认一次
    int batchSize = 100;

    //批量发送,批量确认
    for (int i = 0; i < MESSAGE_COUNT; i++) {
        //转成字符串
        String message = i + "";
        channel.basicPublish("",queueName, null, message.getBytes());
        //判断达到100条消息的时候批量确认一次
        if(i % batchSize == 0){
            //发布确认
            channel.waitForConfirms();
        }
    }
    //发布确认
    channel.waitForConfirms();
    //结束时间
    long end = System.currentTimeMillis();
    System.out.println("发布" + MESSAGE_COUNT + "个单独确认消息,耗时: " + (end - begin) + "ms");
}
```

最终耗时：521ms

#### 4.2.4 异步确认发布

异步确认虽然编程逻辑比上两个要复杂，但是性价比最高，无论是可靠性还是效率都没得说， 他是利用回调函数来达到消息可靠性传递的，这个中间件也是通过函数回调来保证是否投递成功。

```java
public static void publishMessageAsync() throws Exception {
    Channel channel = RabbitMqUtils.getChannel();

    String queueName = UUID.randomUUID().toString();
    channel.queueDeclare(queueName, true, false, false, null);
    //开启发布确认
    channel.confirmSelect();
    //开始时间
    long begin = System.currentTimeMillis();

    //消息确认成功回调函数, 记录下来,方便后期业务处理
    /*
    * 1. deliveryTag: 消息的标记
    * 2. multiple:是否批量确认
    * */

    ConfirmCallback ConfirmCallback = (deliveryTag, multiple) -> {
        System.out.println("确认的消息: " + deliveryTag);

    };

    //消息确认失败回调函数
    ConfirmCallback nackCallback =  (deliveryTag, multiple) -> {
        System.out.println("未确认的消息: " + deliveryTag);
    };
    //准备消息监听器 监听哪些消息成功发送失败了,这个监听是异步的

    channel.addConfirmListener(ConfirmCallback, nackCallback);
    //批量发送消息
    for (int i = 0; i < MESSAGE_COUNT; i++) {
        String message = "消息" + i;
        channel.basicPublish("",queueName, null,message.getBytes());

    }

    //结束时间
    long end = System.currentTimeMillis();
    System.out.println("发布" + MESSAGE_COUNT + "个异步批量确认消息,耗时: " + (end - begin) + "ms");

}

```

最终耗时24ms

#### 4.2.5 如何处理异步未确认消息

最好的解决的解决方案就是把未确认的消息放到一个**基于内存的能被发布线程访问的队列**， 比如说用 `ConcurrentLinkedQueue` 这个队列在 `confirm callbacks` 与发布线程之间进行消息的传递。

```java
public static void publishMessageAsync() throws Exception {
    Channel channel = RabbitMqUtils.getChannel();

    String queueName = UUID.randomUUID().toString();
    channel.queueDeclare(queueName, true, false, false, null);
    //开启发布确认
    channel.confirmSelect();

    /*
    * 线程安全的一个哈希表,适用于高并发的情况下
    * 1. 轻松的将序号与消息进行关联
    * 2. 轻松批量删除条目
    * 3. 支持高并发(多线程)
    * */
    ConcurrentSkipListMap<Long, String> outstandingConfirms =
            new ConcurrentSkipListMap<>();
    //消息确认成功回调函数, 记录下来,方便后期业务处理
    /*
    * 1. deliveryTag: 消息的标记
    * 2. multiple:是否批量确认
    * */
    ConfirmCallback ConfirmCallback = (deliveryTag, multiple) -> {
        //2. 删除掉已经确认的消息,剩下的就是未确认的消息
        if(multiple){
            // headMap(key) 返回map中在key对应kv对前的所有kv对组成的子视图返回(不包含key本身)
            ConcurrentNavigableMap<Long, String> confirmed = outstandingConfirms.headMap(deliveryTag);
            confirmed.clear();
        }else{
            outstandingConfirms.remove(deliveryTag);
        }
        System.out.println("确认的消息: " + deliveryTag);

    };

    //消息确认失败回调函数
    ConfirmCallback nackCallback =  (deliveryTag, multiple) -> {
        //3. 打印未确认的消息
        String message = outstandingConfirms.get(deliveryTag);
        System.out.println("未确认的消息: " + message + ", 它的标记是 : " + deliveryTag);
    };
    //准备消息监听器 监听哪些消息成功发送失败了,这个监听是异步的

    channel.addConfirmListener(ConfirmCallback, nackCallback);

    //开始时间
    long begin = System.currentTimeMillis();
    //批量发送消息
    for (int i = 0; i < MESSAGE_COUNT; i++) {
        String message = "消息" + i;
        channel.basicPublish("",queueName, null,message.getBytes());
        //1. 此处记录下所有要发送的消息
        outstandingConfirms.put(channel.getNextPublishSeqNo(), message);
    }

    //结束时间
    long end = System.currentTimeMillis();
    System.out.println("发布" + MESSAGE_COUNT + "个异步批量确认消息,耗时: " + (end - begin) + "ms");

}

```

>   综上，异步批量处理的速度最快

#### 4.2.6 三种发布确认的速度。

-   单个确认发布
    -   同步等待确认，简单，但吞吐量非常有限。
-   批量发布消息
    -   批量同步等待确认，简单，合理的吞吐量，一旦出现问题但很难推断出是哪条消息出了问题
-   异步处理
    -   最佳性能和资源使用，在出现错误的情况下可以很好地控制，但是实现起来稍微难些



## 5. 交换机

