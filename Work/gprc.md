# gRPC

## 写在前面

首先感谢翻译人员。

[https://doc.oschina.net/grpc?t=56831](https://doc.oschina.net/grpc?t=56831)



结构数据序列化机制：protocol buffer、JSON

protocol buffer有几个版本，建议使用 proto3 的新风格。



## hello world

## gRPC概念

### 概览

#### 服务定义

和其他 RPC 系统一样，gRPC也是「**定义一个服务，指定其可以被远程调用的方法以及参数和返回类型**」。gRPC默认使用`protocol buffer`作为「接口定义语言」：

```protobuf
service HelloService{
	rpc SayHello (HelloRequest) returns (HelloResponse);
}
message HelloRequest{
	required string greeting = 1;
}
message HelloResponse{
	required string reply = 1;
}
```

gRPC允许定义四类服务方法：

-   单项RPC，也就是客户端发送一个请求给服务端，从服务端获取一个应答，就像一个普通的函数调用：

    ```protobuf
    rpc SayHello(HelloRequest) returns (HelloResponse)
    {}
    ```

-   服务端流式 RPC，即客户端发送一个请求给服务端，可获取一个数据流用来读取**一系列消息**。客户端从返回的数据流中读取直到没有更多消息为止：

    ```protobuf
    rpc LotsOfReplies(HelloRequest) returns(HelloResponse)
    {}
    ```

-   客户端流式 RPC，即客户端用提供的一个数据流写入并发送一系列消息给服务端，一旦客户端完成消息写入，就等待服务端读取这些消息并应答

    ```protobuf
    rpc LotsOfGreetings(stream HelloRequest) returns (HelloResponse)
    {}
    ```

-   双向流式 RPC，即两边都可以分别通过一个读写数据流来发送一系列消息。这两个数据流操作是相互独立的，所以客户端和服务端能按照其希望的任意顺序读写。服务端可以再写应答前等待所有的客户端消息，也可以先读一个消息再写一个消息，也可以读写结合。每个数据流中的消息的顺序会被保持：

    ```protobuf
    rpc BidiHello(stream HelloRequest) returns (stream HelloResponse)
    {}
    ```

#### 使用 API 接口

gRPC提供 protocol buffer 编译插件，能够从一个服务定义的`.proto`文件生成客户端和服务端代码，通常gRPC 的使用者可以再服务端实现这些 API，并从客户端调用他们。

-   在服务侧，服务端实现服务接口，运行一个 gPRC 服务器来处理客户端调用。gPRC底层架构会解码传入的请求，执行服务方法，编码服务应答
-   在客户侧，客户端有一个「存根」实现了服务端同样的方法。客户端可以在本地「存根」调用这些方法，用合适的`protocol buffer`消息类型封装这些参数。gPRC 来负责发送请求给服务端并返回服务端的`protocol buffer`响应。



#### 同步 VS 异步

同步 RPC 调用会一直阻塞直到从服务端获得一个应答，这与 RPC 希望的抽象最为接近。另一方面，网络内部是异步的，并且在许多场景下能够在不阻塞当前线程的情况下，启动 RPC 是非常有用的。

在多数语言里，gRPC 编程接口同时支持同步和异步。



### RPC 生命周期

## 安全认证

gRPC 支持多种授权机制：

SSL/TLS

OAuth 2.0



## 通讯协议

gRPC 是基于 HTTP2 协议的。



## 教程



