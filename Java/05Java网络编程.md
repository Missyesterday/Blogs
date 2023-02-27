# 网络编程

## 1.1概述

**计算机网络：**

1.  地理位置不同

2.  通过通信线路连接起来

3.  网络通信协议

4.  实现资源共享

**网络编程的目的：**

传播交流信息，数据交换。通信。

**想要达到这个效果的需要：**

1.  如何准确定位网络上的主机 192.168.7.211:端口，定位到这个计算机上的某个资源

2.  找到这个主机，如何传输数据？

    javaweb：网页编程

    网络编程：TCP/IP

## 1.2 网络通信的要素

**通信双方地址：**

-   ip

-   端口号

-   192.168.7.211:5900

**规则：网络通信的协议**

![OSI网络模型](https://github.com/Missyesterday/Picture/blob/main/WeChat9519644001d99d8f18dc5ed8a43f18ca.png?raw=true)

重点是传输层

## 1.3 IP

ip地址

-   唯一定位一台网络上计算机

-   127.0.0.1:本机localhost

-   ip地址的分类

    -   ipv4/ipv6

        -   127.0.0.1，四个字节，0～255，42亿；30亿在北美，亚洲4亿，2011年就用完了

        -   ipv6 ：128位，8个无符号整数！

    <!---->

    -   公网（互联网）-私网（局域网）

        -   ABCD类地址

        -   192.168.xx.xx,专门给组织内部使用的

-   域名：记忆IP问题

    -   [www.vip.com](http://www.vip.com)

InetAddress类：

```java
package com.he.ip;

import java.net.InetAddress;
import java.net.UnknownHostException;

//测试IP
public class TestInetAddress {
    public static void main(String[] args) {
        try {
            //查询本地机器
            InetAddress inetAddress1 = InetAddress.getByName("127.0.0.1");
            System.out.println(inetAddress1);
            InetAddress inetAddress3 = InetAddress.getByName("localhost");
            System.out.println(inetAddress3);

            //查询网站ip地址
            InetAddress inetAddress2 = InetAddress.getByName("www.baidu.com");
            System.out.println(inetAddress2);

            //常用方法
            //System.out.println(inetAddress2.getAddress());
            System.out.println(inetAddress2.getCanonicalHostName()); //规范名字
            System.out.println(inetAddress2.getHostAddress());//ip
            System.out.println(inetAddress2.getHostName());//域名或者自己电脑的名字

        } catch (UnknownHostException e) {
            e.printStackTrace();
        }
    }
}
```

## 1.4 端口

端口表示计算机上一个程序的进程；

-   不同的进程有不同的端口号

-   被规定0-65535

-   TCP，UDP：65536 \* 2，单个协议下，端口号不能冲突

-   端口分类

    -   公有端口 0 ～ 1023

    -   HTTP：80

    -   HTTPS：443

    -   FTP：21

    -   Telent：23

-   程序注册端口：1024～49151，分配用户或程序

    -   Tomcat：8080

    -   MySQL：3306

    -   Oracle：1521

-   动态、私有端口：49152～65535 `netstat -ano  #查看所有端口，也可以grep`

```java
package com.he.ip;

import java.net.InetSocketAddress;

//
public class TestInetSocketAddress {
    public static void main(String[] args) {
        InetSocketAddress inetSocketAddress = new InetSocketAddress("127.0.0.1", 8080);
        InetSocketAddress inetSocketAddress2 = new InetSocketAddress("localhost", 8080);
        System.out.println(inetSocketAddress);
        System.out.println(inetSocketAddress2);

        System.out.println(inetSocketAddress.getAddress());
        System.out.println(inetSocketAddress.getHostName());//hosts地址
        System.out.println(inetSocketAddress.getPort());//端口

    }
}
```

## 1.5 通信协议

***

协议：约定
**网络通信协议**：速率，传输码率，代码结构，传输控制...

**问题**：非常复杂，分层！

**TCP/IP协议：实际上是一组协议**

重要：

-   TCP：用户传输协议

-   UDP：用户数据报协议

出名的协议：

-   TCP

-   IP：网络互联协议

**TCP对比UDP**
TCP：打电话

-   连接，稳定

-   `三次握手，四次挥手`

    ```
    最少需要三次，保证稳定链接
     
    ```

-   客户端、服务端

-   传输完成，释放连接，效率低

UDP：发短信

-   不连接，不稳定

-   客户端、服务端：没有明确界限

-   不管有没有准备好，都可以发给你

-   导弹

-   DDOS：洪水攻击（饱和攻击)

## 1.6 TCP

客户端

1.  连接服务器Socket

2.  发送消息

```java
package com.he.TCPDemo;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;
import java.nio.charset.StandardCharsets;

//客户端
public class TcpClientDemo01 {
    public static void main(String[] args) {

        Socket socket = null;
        OutputStream os = null;
        try {
            //1.要知道服务器的地址和端口号
            InetAddress serverIP = InetAddress.getByName("127.0.0.1");

            int port = 9999;

            //2。创建一个socket连接
            socket  = new Socket(serverIP,port);

            //3.发送消息 IO流
            os = socket.getOutputStream();
            os.write("你好，我是客户端".getBytes(StandardCharsets.UTF_8));


        } catch (Exception e) {
            e.printStackTrace();
        }finally {
            if(os != null){
                try {
                    os.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (socket != null) {
                try {
                    socket.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        //
    }
}

```

服务器

1.  建立服务的端口

2.  等待用户的连接accept

3.  接受用户的消息

```java
package com.he.TCPDemo;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.ServerSocket;
import java.net.Socket;

//服务端
public class TCPServerDemo01 {
    public static void main(String[] args) throws IOException {
        ServerSocket serverSocket = null;
        Socket socket = null;
        InputStream is = null;
        ByteArrayOutputStream baos = null;
        try {
            //1。拥有一个地址
            serverSocket = new ServerSocket(9999);
            //2.等待客户端连接
            socket  = serverSocket.accept();

            //3. 读取客户端消息
             is = socket.getInputStream();

            // 管道流
             baos = new ByteArrayOutputStream();
            byte[] buffer = new byte[1024];
            int len;
            while((len = is.read(buffer)) != -1){
                baos.write(buffer,0,len);

            }
            System.out.println(baos.toString());

        } catch (IOException e) {
            e.printStackTrace();
        }finally {
            //关闭资源
            if(baos != null){
                try {
                    baos.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }

            if (is != null){
                try {
                    is.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }

            if (socket != null) {
                try {
                    socket.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (serverSocket != null) {
                try {
                    serverSocket.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}


```

**文件上传**

服务器端：

```java
package com.he.TCPDemo;


import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.charset.StandardCharsets;

public class TCPServerDemo02 {
   public static void main(String[] args) throws IOException {
       //1.创建服务
       ServerSocket serverSocket = new ServerSocket(9000);
       //2.监听客户端的连接
       Socket socket = serverSocket.accept();//阻塞式监听，会一直等待客户端连接
       //3. 获取输入流
       InputStream is = socket.getInputStream();
       //4.文件输出
       FileOutputStream fos = new FileOutputStream(new File("receive.jpg"));

       byte[] buffer = new byte[1024];
       int len;
       while((len = is.read(buffer)) != -1){
           fos.write(buffer,0,len);
       }


       //通知客户端接受完毕
       OutputStream os = socket.getOutputStream();
       os.write("我接受完毕，你可以断开".getBytes(StandardCharsets.UTF_8));

       //关闭资源
       fos.close();
       is.close();
       socket.close();
       serverSocket.close();

   }

}
```

客户端：

```java
package com.he.TCPDemo;

import java.io.*;
import java.net.InetAddress;
import java.net.Socket;
import java.nio.charset.StandardCharsets;

public class TCPClientDemo02 {
    public static void main(String[] args) throws IOException {
        //1.创建一个Socket连接
        Socket socket = new Socket(InetAddress.getByName("127.0.0.1"), 9000);
        //2。 创建一个输出流
        OutputStream fos = socket.getOutputStream();

        // 3. 文件流
        FileInputStream fis = new FileInputStream(new File("/Users/heyufan1/Desktop/Picture/Xnip2022-01-08_20-56-06.jpg"));
        //4.写出文件
        byte[] buffer = new byte[1024];
        int len;
        while ((len = fis.read(buffer))!=-1){
            fos.write(buffer,0,len);
        }
        //通知服务器结束
        socket.shutdownOutput();
        //确定服务器接受完毕才能断开连接

        InputStream inputStream = socket.getInputStream();
        //String byte[]
        ByteArrayOutputStream boas = new ByteArrayOutputStream();

        byte[] buffer2 = new byte[1024];
        int len2;
        while((len2=fis.read(buffer2)) != -1 ){
            boas.write(buffer2,0,len2);
        }
        System.out.println(boas.toString());

        //5。关闭资源
        fis.close();
        boas.close();
        socket.close();
    }

}
```

### Tomcat

服务端

-   自定义S

-   Tomcat服务器S

客户端

-   自定义C

-   浏览器B

## 1.7 UDP

发送端：

```java
package com.he.UDP;

import java.net.*;
import java.nio.charset.StandardCharsets;

//不需要连接服务器
public class UdpClientDemo01 {
    public static void main(String[] args) throws Exception {
        //1,建立一个socket
        DatagramSocket socket = new DatagramSocket();

        //2.建一个包
        String msg = "你好，服务器";

        //发送给谁

        InetAddress localhost = InetAddress.getByName("localhost");
        int port = 9090;
        DatagramPacket packet = new DatagramPacket(msg.getBytes(StandardCharsets.UTF_8), 0, msg.getBytes(StandardCharsets.UTF_8).length, localhost, port);

        //3.发送包
        socket.send(packet);

        //关闭
        socket.close();
    }
}
```

接收端

```java
package com.he.UDP;

import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.SocketException;

//还是要等待客户端的连接
public class UdpServerDemo01 {
    public static void main(String[] args) throws Exception {
        //开放端口
        DatagramSocket socket = new DatagramSocket(9090);
        //接收数据包
        byte[] buffer = new byte[1024];
        DatagramPacket packet = new DatagramPacket(buffer, 0, buffer.length);//接收
        socket.receive(packet);//阻塞接收

        System.out.println(new String(packet.getData(),0,packet.getLength()));
        //关闭连接
        socket.close();

    }
}
```

***

**循环发送消息**

```java
package com.he.chat;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetSocketAddress;
import java.net.SocketException;
import java.nio.charset.StandardCharsets;

public class UdpSenderDemo01 {
    public static void main(String[] args) throws Exception {
        DatagramSocket socket = new DatagramSocket(8888);

        //准备数据：控制台读取
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

        while (true) {
            String data = reader.readLine();

            byte[] datas = data.getBytes();
            DatagramPacket packet = new DatagramPacket(datas,0,datas.length,new InetSocketAddress("localhost",6666));

            socket.send(packet);
            if(data.equals("bye")){
                break;
            }
        }
        socket.close();

    }
}
```

**循环接收消息**

```java
package com.he.chat;

import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.SocketException;

public class UdpReceiverDemo01 {

    public static void main(String[] args) throws Exception {
        DatagramSocket socket = new DatagramSocket(6666);

        while (true) {
            //准备接收包
            byte[] container = new byte[1024];
            DatagramPacket packet = new DatagramPacket(container,0,container.length);
            socket.receive(packet);//阻塞式接收包裹
            //断开连接 bye
            byte[] data = packet.getData();
            String receiveData = new String(data, 0, packet.getLength());
            System.out.println(receiveData);
            if(receiveData.equals("bye")){
                break;
            }



        }

        socket.close();
    }
}
```

**相互发送**

两个线程：

```java
package com.he.chat;

public class TalkStudent {
    public static void main(String[] args) {
        //开启两个线程

        new Thread(new TalkSend(7777,"localhost",9999)).start();
        new Thread(new TalkReceive(8888,"老师")).start();
    }


}
```

```java

package com.he.chat;

public class TalkTeacher {
    public static void main(String[] args) {
        new Thread(new TalkSend(5555,"localhost",8888)).start();
        new Thread(new TalkReceive(9999,"学生")).start();
    }

}
```

## 1.8 URL

统一资源定位符：定位互联网上的某一个资源
DNS域名解析：把域名变成IP

```
协议://ip地址:端口/项目名/资源
```

URL类：

```java
package com.he.URL;

import javax.net.ssl.HttpsURLConnection;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLConnection;

public class URLDown {
    public static void main(String[] args) throws Exception {
        //1。下载地址
        //https://github.com/Missyesterday/Picture/blob/main/WeChat9519644001d99d8f18dc5ed8a43f18ca.png?raw=true
        URL url = new URL("https://m10.music.126.net/20220112032921/2b3f455074e3e07e8b0fa0856c4c3ea7/yyaac/515e/005d/5653/f4f0e3561d77555c0450a9e2a95031c6.m4a");//网易云音乐的一首歌


        //2。连接到这个资源
        HttpsURLConnection urlConnection = (HttpsURLConnection) url.openConnection();

        InputStream inputStream = urlConnection.getInputStream();

        FileOutputStream fos = new FileOutputStream("f.png");

        byte[] buffer = new byte[1024];
        int len;
        while((len=inputStream.read(buffer))!=-1){
            fos.write(buffer,0,len);
        }
        fos.close();
        inputStream.close();
        urlConnection.disconnect();
    }
}
```
