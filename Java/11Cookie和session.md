# Cookie

首先需要明白会话和请求的关系

## Cookie基本使用

- Cookie：客户端会话技术，将数据保存到客户端，以后每次请求都携带Cookie数据进行访问。

- Cookie基本使用

  * 发送Cookie

    1. 创建Cookie对象，设置数据

       ```java
       Cookie cookie = new Cookie("key","value");
       ```

    2. 发送Cookie到客户端，使用response对象(Model不知道可以与否，因为model没有addCookie方法）

       ```java
       response.addCookie(coookie);
       ```

  * 获取Cookie

    1. 获取客户端携带的所有Cookie，使用request对象

       ```java
       Cookie[] cookies = request.getCookies();
       ```

    2. 遍历数组，获取每一个Cookie对象：for

    3. 使用Cookie对象方法获取数据

       ```java
       cookie.getName();
       cookie.getValue();
       ```

## Cookie原理

- Cookie的实现是基于HTTP协议的

  * 响应头：set-cookie

  * 请求头：cookie

  * 浏览器每次都会将域名下的所有的cookie发送到服务器

## Cookie使用细节

- Cookie存活时间

  * 默认情况下，Cookie存储在浏览器内存中，当浏览器关闭，内存释放，则Cookie被销毁 

  * setMaxAge(int seconds)：设置Cookie存活时间

    1. 正数,将Cookie写入硬盘，持久化存储，时间到了自动销毁

    2. 负数，也是默认值，Cookie在当前浏览器内存中，当浏览器关闭，Cookie被销毁

    3. 0，删除对应Cookie

- Cookie存储中文

  * Cookie默认是不能存储中文的，如果想存储中文，需要先编码

- Cookie存储中文

# Session

## Session的基本使用

- 服务端会话跟踪技术：将数据保存到服务端

- JavaEE提供HttpSession接口，来实现一次会话的多次请求间数据共享功能

- 使用

  1. 获取Session对象

     ```java
     HttpSession session = request.getSession();
     //在springMVC中可以直接将HttpSession session写在Controller函数的参数中
     ```

  2. Session对象功能：

     - setAttribute()存储数据到session域中

     - getAttribute()：根据key，获取值

     - removeAttribute()：根据key，删除该键值对

## Session原理

- Session是基于Cookie实现的

  * Cookie中会存放一个JSESSIONID

## Session使用细节

- Session钝化、活化

  * 服务器重启后，Session中的数据依然存在

  * 钝化：在服务器正常关闭后，Tomcat会自动将Session数据写入硬盘文件中

  * 活化：再次启动服务器后，从文件中加载数据到Session中

- Session销毁

  * 默认情况下，无操作，30分钟自动销毁

  * 调用Session的invalidate()方法。

mvn tomcat:run