# SpringMVC

ssm\:mybatis + Spring + SpringMVC **MVC三层架构**

JavaSE：

JavaWeb：

框架：研究官方文档，锻炼笔记能力和项目能力

Spring：IOC和AOP

SpringMCVC：SpingMVC的执行流程！SSM框架整合！

## 1. 回顾MVC

MVC：模型（dao、service）    视图（jsp）     控制器（servlet）

JSP本质就是一个Servlet

假设：你的项目的架构，是设计好的，还是演进的？

-   Alibaba  PHP

-   随着用户量大，Java

-   王坚 去IOE **MySQL**

-   MySQL：MySQL-->AliSQL、AliRedis

-   All in one --->微服务&#x20;

MVC：

MVVM：M V ViewModel：双向绑定

## 2. 什么是SpringMVC

### 2.1 概述

SpringMVC是Spring Framework的一部分，是基于Java实现MVC的轻量级Web框架。

[官方链接]()

***

优点：

-   轻量级，简单易学

-   高效，基于请求响应的MVC框架

-   与Spring兼容性好、无缝结合

-   约定优于配置

-   功能强大：RESTful、数据验证、格式化、本地化、主题等

-   简介灵活

-   使用的人多

## 2.2 中心控制器

Spring的web框架围绕**DispatcherServlet** \[ 调度Servlet ] 设计。DispatcherServlet的作用是将请求分发到不同的处理器。从Spring 2.5开始，使用Java 5或者以上版本的用户可以采用基于注解形式进行开发。

Spring MVC框架像许多其他MVC框架一样, **以请求为驱动** , **围绕一个中心Servlet分派请求及提供其他功能**，**DispatcherServlet是一个实际的Servlet (它继承自HttpServlet 基类)**。

## 2.3 SpringMVC执行原理

![](https://kuangstudy.oss-cn-beijing.aliyuncs.com/bbs/2021/04/13/kuangstudy0214fd0a-0df0-4910-a467-5b7d61712868.png)

实线表示SpringMVC框架提供的技术，虚线表示需要开发者实现。

**简要分析执行流程**

1.  DispatcherServlet表示前置控制器，是整个SpringMVC的控制中心。用户发出请求，DispatcherServlet接收请求并拦截请求。

我们假设请求的url为 : <http://localhost:8080/SpringMVC/hello>

**如上url拆分成三部分：**

<http://localhost:8080服务器域名>

SpringMVC部署在服务器上的web站点

hello表示控制器

通过分析，如上url表示为：请求位于服务器localhost:8080上的SpringMVC站点的hello控制器。

1.  HandlerMapping为处理器映射。DispatcherServlet调用HandlerMapping,HandlerMapping根据请求url查找Handler。

2.  HandlerExecution表示具体的Handler,其主要作用是根据url查找控制器，如上url被查找控制器为：hello。

3.  HandlerExecution将解析后的信息传递给DispatcherServlet,如解析控制器映射等。

4.  HandlerAdapter表示处理器适配器，其按照特定的规则去执行Handler。

5.  Handler让具体的Controller执行。

6.  Controller将具体的执行信息返回给HandlerAdapter,如ModelAndView。

7.  HandlerAdapter将视图逻辑名或模型传递给DispatcherServlet。

8.  DispatcherServlet调用视图解析器(ViewResolver)来解析HandlerAdapter传递的逻辑视图名。

9.  视图解析器将解析的逻辑视图名传给DispatcherServlet。

10. DispatcherServlet根据视图解析器解析的视图结果，调用具体的视图。

11. 最终视图呈现给用户。

## 3.  HelloSpringMVC

### 3.1 配置版

-   前置

    -   新建一个Moudle，spring-02-hello，添加web的支持

    -   确定导入了SpringMVC的依赖

-   配置web.xml,注册DispatcherServlet

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
             version="4.0">
    	<!--配置DispatchServlet：这个是SpringMVC的核心；请求分发器，前端控制器-->
    	<servlet>
    		<servlet-name>springmvc</servlet-name>
    		<servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
    		<!--DispatchServlet要绑定Spring的配置文件-->
    		<init-param>
    			<param-name>contextConfigLocation</param-name>
    			<param-value>classpath:springmvc-servlet.xml</param-value>
    		</init-param>
    		<!--启动级别:1-->
    		<load-on-startup>1  </load-on-startup>

    	</servlet>

    	<!--
    	在SpringMVC中， /   /*
    	/：只匹配所有的请求，不会匹配jsp页面
    	/*：匹配所有的业务，包括jsp页面
    	-->
    	<servlet-mapping>
    		<servlet-name>springmvc</servlet-name>
    		<url-pattern>/</url-pattern>
    	</servlet-mapping>
    </web-app>
    ```

-   编写SpringMVC的配置文件！官方命名 \[servletname]-servlet.xml，我们的名称为springmvc-servlet.xml,依次添加处理映射器，处理适配器，视图解析器

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <beans xmlns="http://www.springframework.org/schema/beans"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xsi:schemaLocation="http://www.springframework.org/schema/beans
            http://www.springframework.org/schema/beans/spring-beans.xsd">
    	<!--处理器映射器-->
    	<bean class="org.springframework.web.servlet.handler.BeanNameUrlHandlerMapping"/>


    	<!--处理器适配器-->
    	<bean class="org.springframework.web.servlet.mvc.SimpleControllerHandlerAdapter"/>


    	<!--视图解析器:模版引擎Thymeleaf  Freemarker-->
    	<bean class="org.springframework.web.servlet.view.InternalResourceViewResolver" id="internalResourceViewResolver">
    		<!--前缀-->
    		<property name="prefix" value="/WEB-INF/jsp/"/>
    		<!--后缀 -->
    		<property name="suffix" value=".jsp"/>
    	</bean>

    	<!--BeanNameUrlHandlerMapping:bean-->
    	<bean id="/hello" class="com.hyf.controller.HelloController"/>
    </beans>
    ```

-   编写我们要操作业务Controller ，要么实现Controller接口，要么增加注解；需要返回一个ModelAndView，装数据，封视图；

    ```java
    package com.hyf.controller;

    import org.springframework.web.servlet.ModelAndView;
    import org.springframework.web.servlet.mvc.Controller;

    import javax.servlet.http.HttpServletRequest;
    import javax.servlet.http.HttpServletResponse;

    public class HelloController implements Controller {
        @Override
        public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {
            ModelAndView mv = new ModelAndView();

            //业务代码
            String result = "HelloSpringMVC";

            mv.addObject("msg",result);

            //视图跳转
            mv.setViewName("test");

            return mv;
        }
    }
    ```

-   在springmvc-servlet.xml中注册bean

    ```xml
    <!--Handler-->
    <bean id="/hello" class="com.kuang.controller.HelloController"/>
    ```

-   在WEB-INF/jsp/目录下添加test.jsp页面,显示ModelandView存放的数据，以及我们的正常页面；

    ```jsp
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>
    <head>
        <title>Kuangshen</title>
    </head>
    <body>
        ${msg}
    </body>
    </html>
    ```

-   **可能遇到的问题：访问出现404，排查步骤：**

    1.  查看控制台输出，看一下是不是缺少了什么jar包。

    2.  如果jar包存在，显示无法输出，就在IDEA的项目发布中，添加lib依赖！

    3.  重启Tomcat 即可解决！

### 3.2 注解版

**新建一个Moudle，springmvc-03-hello-anno 。添加web支持！**

建立包结构 com.kuang.controller

1.  由于Maven可能存在资源过滤的问题，我们在pom.xml将配置完善

    ```xml
    <build>
        <resources>
            <resource>
                <directory>src/main/java</directory>
                <includes>
                    <include>**/*.properties</include>
                    <include>**/*.xml</include>
                </includes>
                <filtering>false</filtering>
            </resource>
            <resource>
                <directory>src/main/resources</directory>
                <includes>
                    <include>**/*.properties</include>
                    <include>**/*.xml</include>
                </includes>
                <filtering>false</filtering>
            </resource>
        </resources>
    </build>
    ```

    在pom.xml文件引入相关的依赖：主要有Spring框架核心库、Spring MVC、servlet , JSTL等。我们在父依赖中已经引入了！

2.  **配置web.xml**

    注意点：

    -   注意web.xml版本问题，要最新版！

    -   注册DispatcherServlet

    -   关联SpringMVC的配置文件

    -   启动级别为1

    -   映射路径为 / 【不要用/\*，会404】

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
             version="4.0">
        <!--1.注册servlet-->
        <servlet>
            <servlet-name>SpringMVC</servlet-name>
            <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
            <!--通过初始化参数指定SpringMVC配置文件的位置，进行关联-->
            <init-param>
                <param-name>contextConfigLocation</param-name>
                <param-value>classpath:springmvc-servlet.xml</param-value>
            </init-param>
            <!-- 启动顺序，数字越小，启动越早 -->
            <load-on-startup>1</load-on-startup>
        </servlet>
        <!--所有请求都会被springmvc拦截 -->
        <servlet-mapping>
    <!--/ 和 /* 的区别：
    < url-pattern > / </ url-pattern > 不会匹配到.jsp， 只针对我们编写的请求；
    即：.jsp 不会进入spring的 DispatcherServlet类 。
    < url-pattern > / </ url-pattern > 会匹配 .jsp，
    会出现返回 jsp视图 时再次进入spring的DispatcherServlet 类，导致找不到对应的controller所以报404错。-->
            <servlet-name>SpringMVC</servlet-name>
            <url-pattern>/</url-pattern>
        </servlet-mapping>
    </web-app>
    ```

3.  **添加Spring MVC配置文件\:resources下**pringmvc-servlet.xml

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <beans xmlns="http://www.springframework.org/schema/beans"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xmlns:context="http://www.springframework.org/schema/context"
           xmlns:mvc="http://www.springframework.org/schema/mvc"
           xsi:schemaLocation="http://www.springframework.org/schema/beans
            http://www.springframework.org/schema/beans/spring-beans.xsd
            http://www.springframework.org/schema/context
            https://www.springframework.org/schema/context/spring-context.xsd
            http://www.springframework.org/schema/mvc
            https://www.springframework.org/schema/mvc/spring-mvc.xsd">
        <!-- 自动扫描包，让指定包下的注解生效,由IOC容器统一管理 -->
        <context:component-scan base-package="com.hyf.controller"/>
        <!-- 让Spring MVC不处理静态资源 -->
        <mvc:default-servlet-handler />
        <!--
        支持mvc注解驱动
            在spring中一般采用@RequestMapping注解来完成映射关系
            要想使@RequestMapping注解生效
            必须向上下文中注册DefaultAnnotationHandlerMapping
            和一个AnnotationMethodHandlerAdapter实例
            这两个实例分别在类级别和方法级别处理。
            而annotation-driven配置帮助我们自动完成上述两个实例的注入。
         -->
        <mvc:annotation-driven />
        <!-- 视图解析器 -->
        <bean class="org.springframework.web.servlet.view.InternalResourceViewResolver"
              id="internalResourceViewResolver">
            <!-- 前缀 -->
            <property name="prefix" value="/WEB-INF/jsp/" />
            <!-- 后缀 -->
            <property name="suffix" value=".jsp" />
        </bean>
    </beans>
    ```

4.  **创建Controller**

    编写一个Java控制类： com.hyf.controller.HelloController , 注意编码规范

    ```java
    package com.hyf.controller;
    import org.springframework.stereotype.Controller;
    import org.springframework.ui.Model;
    import org.springframework.web.bind.annotation.RequestMapping;

    @Controller
    public class HelloController {
        //真实访问地址 : 项目名/HelloController/hello
        @RequestMapping("/hello")
        public String sayHello(Model model){
            //向模型中添加属性msg与值，可以在JSP页面中取出并渲染
            model.addAttribute("msg","hello,SpringMVC");
            //web-inf/jsp/hello.jsp
            return "hello";
        }
    }

    ```

5.  创建视图层

    在WEB-INF/jsp/目录创建hello.jsp，视图可以直接取出并展示从Controller带回的信息

    ```jsp
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>
    <head>
        <title>SpringMVC</title>
    </head>
    <body>
        ${msg}
    </body>
    </html>
    ```

6.  配置tomcat运行

    访问对应的请求路径

    ![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-01-28_17-01-06.jpg?raw=true)

**一些注意事项：**

1.  在IDEA的项目发布中，添加lib依赖，注意lib的路径和classes同级\
    ![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-01-28_17-04-03.jpg?raw=true)

2.  在tomcat配置时application Context选择“/”

3.  修改了Java代码Redeploy，修改了配置文件restart，修改了前端页面刷新一下就好

## 4. Controller及RestFul

### 4.1 控制器Controller

-   控制器复杂提供访问应用程序的行为，通常通过接口定义或注解定义两种方法实现。 

-   控制器负责解析用户的请求并将其转换为一个模型。

-   在Spring MVC中一个控制器类可以包含多个方法

-   在Spring MVC中，对于Controller的配置方式有很多种

### 4.2 实现Controller接口

Controller是一个接口，在org.springframework.web.servlet.mvc包下，接口中只有一个方法；

操作步骤：

-   新建一个Moudle，springmvc-04-controller 。 将刚才的03 拷贝一份, 删除HelloController，mvc配置文件只留下视图解析器，编写一个ControllerTest1

    ```java
    package com.hyf.controller;


    import org.springframework.web.servlet.ModelAndView;
    import org.springframework.web.servlet.mvc.Controller;

    import javax.servlet.http.HttpServletRequest;
    import javax.servlet.http.HttpServletResponse;

    //只要实现了Controller接口的类，就说明这是一个控制器

    public class ControllerTest1 implements Controller {
        @Override
        public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {
            ModelAndView mv = new ModelAndView();
            //添加数据
            mv.addObject("msg","ControllerTest1");
            //设置视图（跳转到哪）
            mv.setViewName("test");
            return mv;
        }
    }
    ```

-   编写完毕后，去Spring配置文件springmvc-servlet.xml中注册请求的bean；name对应请求路径，class对应处理请求的类

    ```xml
    <bean name="/t1" class="com.hyf.controller.ControllerTest1"/>
    ```

-   编写前端test.jsp，注意在WEB-INF/jsp目录下编写，对应我们的视图解析器

    ```jsp
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>
    <head>
        <title>test</title>
    </head>
    <body>
        ${msg}
    </body>
    </html>

    ```

-   配置Tomcat运行测试，项目发布名配置为 / \
    ![](https://github.com/Missyesterday/Picture/blob/main/下载.png?raw=true)

缺点：一个控制器只有一个方法

### 4.3 使用注解@Controller和@**RequestMapping**

-   [@Controller](https://github.com/Controller)注解类型用于声明Spring类的实例是一个控制器，[@RequestMapping](https://github.com/RequestMapping)注解用于映射url到控制器类或一个特定的处理程序方法。可用于类或方法上。用于类上，表示类中的所有响应请求的方法都是以该地址作为父路径。

-   Spring可以使用扫描机制来找到应用程序中所有基于注解的控制器类，为了保证Spring能找到你的控制器，需要在配置文件springmvc-servlet.xml中声明组件扫描。

    ```xml
    <!-- 自动扫描指定的包，下面所有注解类交给IOC容器管理 -->
    <context:component-scan base-package="com.hyf.controller"/>

    ```

-   增加一个ControllerTest2类，使用注解实现；

    ```java
    package com.hyf.controller;

    import org.springframework.stereotype.Controller;
    import org.springframework.ui.Model;
    import org.springframework.web.bind.annotation.RequestMapping;

    @Controller //代表这个类会被Spring接管，这个注解的类中的所有方法，如果返回值是String，并且有具体页面可以跳转，那么就会被视图解析器解析，这样视图解析器的页面可以复用
    public class ControllerTest2 {
        @RequestMapping("/t1")
        public String test1(Model model){ //Model 和 ModelAndView都可以传，Model是简化版本的

            model.addAttribute("msg","ControllerTest2");

            return "test";  //      /WEB-INF/jsp/test.jsp
        }

        @RequestMapping("/t3")
        public String test3(Model model){ //Model 和 ModelAndView都可以传，Model是简化版本的

            model.addAttribute("msg","ControllerTest3");

            return "test";  //      /WEB-INF/jsp/test.jsp
        }
    }

    ```

-   运行tomcat测试

    ![](https://github.com/Missyesterday/Picture/blob/main/下载%20\(1\).png?raw=true)\
    ![](https://github.com/Missyesterday/Picture/blob/main/download.png?raw=true)

-   如果@**RequestMapping**写在类上，则访问路径：<http://localhost:8080> / 项目名/ admin /h1 , 需要先指定类的路径再指定方法的路径；一般在方法上写上完整路径而不在类上写，因为调试不方便

### 4.5 **RestFul风格**

#### 4.5.1 概念

Restful就是一个资源定位及资源操作的风格。不是标准也不是协议，只是一种风格。基于这个风格设计的软件可以更简洁，更有层次，更易于实现缓存等机制。

#### 4.5.2 **功能**

资源：互联网所有的事物都可以被抽象为资源\
资源操作：使用POST、DELETE、PUT、GET，使用不同方法对资源进行操作。\
分别对应 添加、 删除、修改、查询。

**传统方式操作资源** ：通过不同的参数来实现不同的效果！方法单一，post 和 get

​  <http://127.0.0.1/item/queryItem.action?id=1> 查询,GET\
​  <http://127.0.0.1/item/saveItem.action> 新增,POST\
​  <http://127.0.0.1/item/updateItem.action> 更新,POST\
​  <http://127.0.0.1/item/deleteItem.action?id=1> 删除,GET或POST

**使用RESTful操作资源** ： 可以通过不同的请求方式来实现不同的效果！如下：请求地址一样，但是功能可以不同！

​  <http://127.0.0.1/item/1> 查询,GET\
​  <http://127.0.0.1/item> 新增,POST\
​  <http://127.0.0.1/item> 更新,PUT\
​  <http://127.0.0.1/item/1> 删除,DELETE

更加安全，隐藏了参数名，并且一个url可能有不同效果

#### 4.5.3 实验

-   新建一个类 RestFulController

    ```java
    package com.hyf.controller;

    import org.springframework.stereotype.Controller;
    import org.springframework.ui.Model;
    import org.springframework.web.bind.annotation.*;

    @Controller
    public class RestFulController {

        //安全：
        // 原来的：  http://localhost:8080/add?a=1&b=2
        //RestFul ： http://localhost:8080/add/a/b
        @RequestMapping(value = "/add/{a}/{b}",method = RequestMethod.GET)
        public String test1(@PathVariable int a,@PathVariable String b, Model model){
            String res = a + b;
            model.addAttribute("msg","结果1为" + res );
            return "test";
        }
        @PostMapping( "/add/{a}/{b}")
        public String test2(@PathVariable int a,@PathVariable String b, Model model){
            String res = a + b;
            model.addAttribute("msg","结果2为" + res );
            return "test";
        }
    }
    ```

-   在web目录下写一个a.jsp

    ```jsp
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>
    <head>
        <title>Title</title>
    </head>
    <body>
    <form  action="/add/1/2" method="post">
        <input type="submit">
    </form>
    </body>
    </html>
    ```

-   测试

    -   直接在搜索框输入<http://localhost:8080/add/1/sf>

        ![](https://github.com/Missyesterday/Picture/blob/main/下载%20\(2\).png?raw=true)返回结果1，走的get方法

    -   在<http://localhost:8080/a.jsp>点击提交按钮

        ![](https://github.com/Missyesterday/Picture/blob/main/下载%20\(3\).png?raw=true)![](https://github.com/Missyesterday/Picture/blob/main/下载%20\(4\).png?raw=true)返回结果2，走post方法

## 5. 结果跳转方式

### 5.1 ModelAndView

设置ModelAndView对象和视图解析器

页面 : {视图解析器前缀} + viewName +{视图解析器后缀}

视图解析器：

```xml
<!-- 视图解析器 -->
<bean class="org.springframework.web.servlet.view.InternalResourceViewResolver"
      id="internalResourceViewResolver">
    <!-- 前缀 -->
    <property name="prefix" value="/WEB-INF/jsp/" />
    <!-- 后缀 -->
    <property name="suffix" value=".jsp" />
</bean>

```

对应Controller类

```java
public class ControllerTest1 implements Controller {
    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {
        //返回一个模型视图对象
        ModelAndView mv = new ModelAndView();
        mv.addObject("msg","ControllerTest1");
        mv.setViewName("test");
        return mv;
    }
}
```

### 5.2 ServletAPI

通过设置ServletAPI , 不需要视图解析器 .

1.  通过HttpServletResponse进行输出

2.  通过HttpServletResponse实现重定向

3.  通过HttpServletResponse实现转发

```java
@Controller
public class ResultGo {
    @RequestMapping("/result/t1")
    public void test1(HttpServletRequest req, HttpServletResponse rsp) throws IOException {
        rsp.getWriter().println("Hello,Spring BY servlet API");
    }
    @RequestMapping("/result/t2")
    public void test2(HttpServletRequest req, HttpServletResponse rsp) throws IOException {
        rsp.sendRedirect("/index.jsp");
    }
    @RequestMapping("/result/t3")
    public void test3(HttpServletRequest req, HttpServletResponse rsp) throws Exception {
        //转发
        req.setAttribute("msg","/result/t3");
        req.getRequestDispatcher("/WEB-INF/jsp/test.jsp").forward(req,rsp);
    }
}
```

### 5.3 SpringMVC

**通过SpringMVC来实现转发和重定向 - 可以不需要视图解析器，有两种方法**

1.  两种转发。没有配置视图解析器的情况下写全路径名，如果有配置解析器还是会拼接。

    ```java
    @Controller
    public class ModelTest1 {

        @RequestMapping("/m1/t1")
        public String test(Model model) {

            //转发
            model.addAttribute("msg","ModelTest1");

            //没有配置视图解析器的情况下写全路径名
            //return "forward:WEB-INF/jsp/test.jsp:" 方法1
            return "WEB-INF/jsp/test.jsp";//方法2

        }

    }
    ```

2.  重定向，如果有视图解析器。**redirect可以避开这个视图解析器，不会拼接！！！**

    ```java
    @Controller
    public class ModelTest1 {

        @RequestMapping("/m1/t1")
        public String test(Model model) {

            //转发
            model.addAttribute("msg","ModelTest1");

            //没有配置视图解析器的情况下写全路径名
            //而redirect可以避开这个视图解析器
            return "redirect:/index.jsp";//

        }

    }
    ```

## 6. 数据处理

### 6.1 处理提交数据

1.  提交的域名称和处理方法的参数名一致

    域名称： [http://localhost:8080/hello?name=hyf](http://localhost:8080/hello?name=kuangshen)

    处理方法：

    ```java
    @RequestMapping("/hello")
    public String hello(String name){
        System.out.println(name);
        return "hello";
    }
    ```

    参数名称一致，没什么好说的，正常运行

2.  但是一般会在参数前加一个@RequestParam注解

    ```java
       @GetMapping("/t1")
        public String test1(@RequestParam("username") String name, Model model){

            //1. 接收前端参数
            System.out.println("接收到前端参数" + name);
            //2。将返回的结果传递给前端, Model
            model.addAttribute("msg",name);
            //视图跳转
            return "test";
        }
    ```

    这样我们提交的域名就是[localhost:8080/user/t1?username=xx](http://localhost:8080/user/t1?name=xx)

3.  提交的是一个对象

    前面提交的都是基础类型，这里我们提交一个User实体类：假设有User类

    ```java
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public class User {
        private int id;
        private String name;
        private int age;
    }
    ```

    我们可以在域名中提交id name age三个参数:[http://localhost:8080/mvc04/user?name=hyf\&id=1\&age=15](http://localhost:8080/mvc04/user?name=kuangshen\&id=1\&age=15)

    处理方法，参数用User类来接收：

    ```java
        @GetMapping("/t2")
        public String test2(User user, Model model){
            System.out.println(user);
            return "test";
        }
    ```

    **注意前端传递的参数名和对象的参数必须一致！**

    &#x20;\* 1.接收前端用户传递的参数，判断参数的名字，假设名字直接在方法上，可以直接使用 \* 2.假设传递的是一个对象user，匹配User对象中的字段名，如果名字一致可以使用，不一致则匹配不到，顺序无所谓\* \*

### 6.2 数据显示到前端

1.  **ModelAndView**

2.  **ModelMap**

3.  **Model**

他们都可以用addAttribute()方法来传递数据到前端

Model 只有寥寥几个方法只适合用于储存数据，简化了新手对于Model对象的操作和理解；

ModelMap 继承了 LinkedMap ，除了实现了自身的一些方法，同样的继承 LinkedMap 的方法和特性；

ModelAndView 可以在储存数据的同时，可以进行设置返回的逻辑视图，进行控制展示层的跳转。

### 6.3 乱码问题

当我们在表单中提交中文的时候，经常会出现乱码，我们有以下解决方法

1.  方法1:使用SpringMVC提供的过滤器

    在web.xml中配置

    ```xml
    <filter>
        <filter-name>encoding</filter-name>
        <filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
        <init-param>
            <param-name>encoding</param-name>
            <param-value>utf-8</param-value>
        </init-param>
    </filter>
    <filter-mapping>
        <filter-name>encoding</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>

    ```

2.  修改tomcat配置文件/Tomcat路径/conf/server.xml ： 设置编码！

    ```xml
    <Connector URIEncoding="utf-8" port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
    ```

3.  自定义过滤器（极端情况）

    ```java
    package com.hyf.filter;
    import javax.servlet.*;
    import javax.servlet.http.HttpServletRequest;
    import javax.servlet.http.HttpServletRequestWrapper;
    import javax.servlet.http.HttpServletResponse;
    import java.io.IOException;
    import java.io.UnsupportedEncodingException;
    import java.util.Map;
    /**
     * 解决get和post请求 全部乱码的过滤器
     */
    public class GenericEncodingFilter implements Filter {
        @Override
        public void destroy() {
        }
        @Override
        public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
            //处理response的字符编码
            HttpServletResponse myResponse=(HttpServletResponse) response;
            myResponse.setContentType("text/html;charset=UTF-8");
            // 转型为与协议相关对象
            HttpServletRequest httpServletRequest = (HttpServletRequest) request;
            // 对request包装增强
            HttpServletRequest myrequest = new MyRequest(httpServletRequest);
            chain.doFilter(myrequest, response);
        }
        @Override
        public void init(FilterConfig filterConfig) throws ServletException {
        }
    }
    //自定义request对象，HttpServletRequest的包装类
    class MyRequest extends HttpServletRequestWrapper {
        private HttpServletRequest request;
        //是否编码的标记
        private boolean hasEncode;
        //定义一个可以传入HttpServletRequest对象的构造函数，以便对其进行装饰
        public MyRequest(HttpServletRequest request) {
            super(request);// super必须写
            this.request = request;
        }
        // 对需要增强方法 进行覆盖
        @Override
        public Map getParameterMap() {
            // 先获得请求方式
            String method = request.getMethod();
            if (method.equalsIgnoreCase("post")) {
                // post请求
                try {
                    // 处理post乱码
                    request.setCharacterEncoding("utf-8");
                    return request.getParameterMap();
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }
            } else if (method.equalsIgnoreCase("get")) {
                // get请求
                Map<String, String[]> parameterMap = request.getParameterMap();
                if (!hasEncode) { // 确保get手动编码逻辑只运行一次
                    for (String parameterName : parameterMap.keySet()) {
                        String[] values = parameterMap.get(parameterName);
                        if (values != null) {
                            for (int i = 0; i < values.length; i++) {
                                try {
                                    // 处理get乱码
                                    values[i] = new String(values[i]
                                            .getBytes("ISO-8859-1"), "utf-8");
                                } catch (UnsupportedEncodingException e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                    }
                    hasEncode = true;
                }
                return parameterMap;
            }
            return super.getParameterMap();
        }
        //取一个值
        @Override
        public String getParameter(String name) {
            Map<String, String[]> parameterMap = getParameterMap();
            String[] values = parameterMap.get(name);
            if (values == null) {
                return null;
            }
            return values[0]; // 取回参数的第一个值
        }
        //取所有值
        @Override
        public String[] getParameterValues(String name) {
            Map<String, String[]> parameterMap = getParameterMap();
            String[] values = parameterMap.get(name);
            return values;
        }
    }
    ```

    在web.xml中配置

    ```xml
    	<!--配置SpringMVC的乱码过滤-->
    	<filter>
    		<filter-name>encoding</filter-name>
    		<filter-class>com.hyf.filter.GenericEncodingFilter</filter-class>
    	</filter>
    	<filter-mapping>
    		<filter-name>encoding</filter-name>
    		<!--/只能过滤请求，/*可以过滤请求和页面-->
    		<url-pattern>/*</url-pattern>
    	</filter-mapping>
    ```

## 7. JSON

### 7.1 简介

JSON(JavaScript Object Notation,JS对象标记)是一种轻量级的数据交换格式，目前使用特别广泛，它是用文本格式来存储和表示数据，完全独立于编程语言。

格式：

-   对象表示为键值对，数据由“,”逗号分隔

-   键(name)置于双引号中，值(value)有字符串、数组、布尔值、null、对象和数组

-   ”{}“花括号保存对象

-   "\[]"方括号保存数组

例如：

```json
{
    "name":"何宇凡",
    "age":"19",
    "sex":"男",
    "fruits":["apple","pear","grape"]
}
```

JSON与Javascript对象的区别:

-   JSON 是 JavaScript 对象的字符串表示法,JSON本质是字符串，需要通过特定的函数将其转化为JS对象。

-   `var obj = {a: 'Hello', b: 'World'}; //这是一个对象，注意键名也是可以使用引号包裹的`

    `var json = '{"a": "Hello", "b": "World"}'; //这是一个 JSON 字符串，本质是一个字符串`

### 7.2 JSON和JavaScript对象的相互转换

-   JSON字符串转换为JavaScript对象,用JSON.parse()方法

    ```javascript
    var obj = JSON.parse('{"a": "Hello", "b": "World"}'); 
    //结果是 {a: 'Hello', b: 'World'}
    ```

-   要实现从JavaScript 对象转换为JSON字符串，使用 JSON.stringify() 方法：

    ```javascript
    var json = JSON.stringify({a: 'Hello', b: 'World'});
    //结果是 '{"a": "Hello", "b": "World"}'
    ```

### 7.3 Controller返回JSON数据

新建一个module,springmvc-05-json,添加web支持

-   在SpringMVC中处理JSON可以用Jackson或者fastjson

    在pom.xml中导入jar包

    ```xml
    <!-- https://mvnrepository.com/artifact/com.fasterxml.jackson.core/jackson-core -->
    <dependency>
        <groupId>com.fasterxml.jackson.core</groupId>
        <artifactId>jackson-databind</artifactId>
        <version>2.9.8</version>
    </dependency>
    ```

-   配置SpringMVC

    web.xml

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
             version="4.0">
       <!--1.注册servlet-->
       <servlet>
          <servlet-name>SpringMVC</servlet-name>
          <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
          <!--通过初始化参数指定SpringMVC配置文件的位置，进行关联-->
          <init-param>
             <param-name>contextConfigLocation</param-name>
             <param-value>classpath:springmvc-servlet.xml</param-value>
          </init-param>
          <!-- 启动顺序，数字越小，启动越早 -->
          <load-on-startup>1</load-on-startup>
       </servlet>
       <!--所有请求都会被springmvc拦截 -->
       <servlet-mapping>
          <servlet-name>SpringMVC</servlet-name>
          <url-pattern>/</url-pattern>
       </servlet-mapping>
       <filter>
          <filter-name>encoding</filter-name>
          <filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
          <init-param>
             <param-name>encoding</param-name>
             <param-value>utf-8</param-value>
          </init-param>
       </filter>
       <filter-mapping>
          <filter-name>encoding</filter-name>
          <url-pattern>/</url-pattern>
       </filter-mapping>
    </web-app>
    ```

    springmvc-servlet.xml,配置自动扫描的包, JSON乱码问题和视图解析器

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <beans xmlns="http://www.springframework.org/schema/beans"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xmlns:context="http://www.springframework.org/schema/context"
           xmlns:mvc="http://www.springframework.org/schema/mvc"
           xsi:schemaLocation="http://www.springframework.org/schema/beans
            http://www.springframework.org/schema/beans/spring-beans.xsd
            http://www.springframework.org/schema/context
            https://www.springframework.org/schema/context/spring-context.xsd
            http://www.springframework.org/schema/mvc
            https://www.springframework.org/schema/mvc/spring-mvc.xsd">
    	<!-- 自动扫描指定的包，下面所有注解类交给IOC容器管理 -->
    	<context:component-scan base-package="com.hyf.controller"/>

    	<!--JSON乱码问题-->
    	<mvc:annotation-driven>
    		<mvc:message-converters register-defaults="true">
    			<bean class="org.springframework.http.converter.StringHttpMessageConverter">
    				<constructor-arg value="UTF-8"/>
    			</bean>
    			<bean class="org.springframework.http.converter.json.MappingJackson2HttpMessageConverter">
    				<property name="objectMapper">
    					<bean class="org.springframework.http.converter.json.Jackson2ObjectMapperFactoryBean">
    						<property name="failOnEmptyBeans" value="false"/>
    					</bean>
    				</property>
    			</bean>
    		</mvc:message-converters>
    	</mvc:annotation-driven>

    	<!-- 视图解析器 -->
    	<bean class="org.springframework.web.servlet.view.InternalResourceViewResolver"
    	      id="internalResourceViewResolver">
    		<!-- 前缀 -->
    		<property name="prefix" value="/WEB-INF/jsp/" />
    		<!-- 后缀 -->
    		<property name="suffix" value=".jsp" />
    	</bean>
    </beans>
    ```

-   编写一个User的实体类,com.hyf.pojo.User

    ```java
    package com.hyf.pojo;
    import lombok.AllArgsConstructor;
    import lombok.Data;
    import lombok.NoArgsConstructor;
    //需要导入lombok
    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public class User {
        private String name;
        private int age;
        private String sex;
    }
    ```

-   在UserController类上在类上直接使用 [**@RestController**](https://github.com/RestController) 注解,里面所有的方法都只会返回 json 字符串了，不用再每一个都添加[@ResponseBody](https://github.com/ResponseBody) .添加一个Controller

    @ResponseBody注解,可以将str转为json格式返回

    ```java
    //produces:指定响应体返回类型和编码
    @RequestMapping(value = "/j1")
    @ResponseBody    //加上这个注解就不会找视图解析器，会直接返回一个字符串
    public String json1() throws JsonProcessingException {
        //jackson ObjectMapper
        ObjectMapper mapper = new ObjectMapper();
        
        //创建一个对象
        User user = new User("何宇凡",3,"男");
        String str = mapper.writeValueAsString(user);

        return str;
    }
    ```

-   测试

    ![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-02-05_17-24-46.jpg?raw=true)

### 7.4 **测试集合输出**

在UserController增加一个新的方法

```java
 @RequestMapping(value = "/j2")
    public String json2() throws JsonProcessingException {


        List<User> userList = new ArrayList<User>();

        User user1 = new User("何宇凡",3,"男");
        User user2 = new User("何宇凡",3,"男");
        User user3 = new User("何宇凡",3,"男");
        User user4 = new User("何宇凡",3,"男");
        User user5 = new User("何宇凡",3,"男");
        userList.add(user1);
        userList.add(user2);
        userList.add(user3);
        userList.add(user4);
        userList.add(user5);

        return JsonUtils.getJson(userList);
    }
```

测试

\
![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-02-05_17-31-06.jpg?raw=true)

### 7.5 输出时间对象

将Date对象解析成JSON格式是时间戳timestamps,是1970年1月1日到当前时间的毫秒数,Jackson 默认是会把时间转成timestamps形式.

我们自定义时间格式,并将其封装为工具类\:JsonUtils

```java
package com.hyf.utils;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;

import java.text.SimpleDateFormat;

public class JsonUtils {
    public static String getJson(Object obj) throws JsonProcessingException {
         return getJson(obj,"yyyy-MM-dd HH:mm:ss");
    }

    public static String getJson(Object obj,String dataFormat) throws JsonProcessingException {
        ObjectMapper mapper = new ObjectMapper();
        mapper.configure(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS,false);
        SimpleDateFormat sdf = new SimpleDateFormat(dataFormat);
        mapper.setDateFormat(sdf);
        try {
            return mapper.writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
        return null;
    }
}
```

然后在UserController使用工具类:

```java
@RequestMapping(value = "/j3")
//@ResponseBody    //加上这个注解就不会找视图解析器，会直接返回一个字符串
public String json3() throws JsonProcessingException {
    Date date = new Date();
    // sdf.format(date)
    // 时间解析后的默认格式为Timestamp 时间戳：1970年1月1日到现在的毫秒数
    return JsonUtils.getJson(date);

}
```

测试:

\
![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-02-05_17-36-53.jpg?raw=true)完美显示时间!

### 7.6 FastJson

fastjson.jar是阿里开发的一款专门用于Java开发的包,与Jaskson的作用差不多.

## 8. 整合SSM

**命名尽量统一规范**

### 8.1 数据库环境

在database \`ssmbuild\`中有一张books表

![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-02-05_17-40-43.jpg?raw=true)

### 8.2 基本环境搭建

1.  在pom.xml中导包,设置资源过滤

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <project xmlns="http://maven.apache.org/POM/4.0.0"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    	<modelVersion>4.0.0</modelVersion>

    	<groupId>org.example</groupId>
    	<artifactId>ssmbuild</artifactId>
    	<version>1.0-SNAPSHOT</version>

    	<properties>
    		<maven.compiler.source>8</maven.compiler.source>
    		<maven.compiler.target>8</maven.compiler.target>
    	</properties>

    	<!--依赖  junit 数据库驱动 连接池 servlet jsp mybatis  mybatis-spring Spring -->
    	<dependencies>
    		<!--Junit-->
    		<dependency>
    			<groupId>junit</groupId>
    			<artifactId>junit</artifactId>
    			<version>4.12</version>
    		</dependency>
    		<!--数据库驱动-->
    		<dependency>
    			<groupId>mysql</groupId>
    			<artifactId>mysql-connector-java</artifactId>
    			<version>5.1.47</version>
    		</dependency>
    		<!-- 数据库连接池 -->
    		<dependency>
    			<groupId>com.mchange</groupId>
    			<artifactId>c3p0</artifactId>
    			<version>0.9.5.2</version>
    		</dependency>
    		<!--Servlet - JSP -->
    		<dependency>
    			<groupId>javax.servlet</groupId>
    			<artifactId>servlet-api</artifactId>
    			<version>2.5</version>
    		</dependency>
    		<dependency>
    			<groupId>javax.servlet.jsp</groupId>
    			<artifactId>jsp-api</artifactId>
    			<version>2.2</version>
    		</dependency>
    		<dependency>
    			<groupId>javax.servlet</groupId>
    			<artifactId>jstl</artifactId>
    			<version>1.2</version>
    		</dependency>
    		<!--Mybatis-->
    		<dependency>
    			<groupId>org.mybatis</groupId>
    			<artifactId>mybatis</artifactId>
    			<version>3.5.2</version>
    		</dependency>
    		<dependency>
    			<groupId>org.mybatis</groupId>
    			<artifactId>mybatis-spring</artifactId>
    			<version>2.0.2</version>
    		</dependency>
    		<!--Spring-->
    		<dependency>
    			<groupId>org.springframework</groupId>
    			<artifactId>spring-webmvc</artifactId>
    			<version>5.1.9.RELEASE</version>
    		</dependency>
    		<dependency>
    			<groupId>org.springframework</groupId>
    			<artifactId>spring-jdbc</artifactId>
    			<version>5.1.9.RELEASE</version>
    		</dependency>
    		<dependency>
    			<groupId>org.projectlombok</groupId>
    			<artifactId>lombok</artifactId>
    			<version>1.18.22</version>
    		</dependency>
    		<dependency>
    			<groupId>org.projectlombok</groupId>
    			<artifactId>lombok</artifactId>
    			<version>RELEASE</version>
    			<scope>compile</scope>
    		</dependency>
    	</dependencies>

    	<!--静态资源导出-->
    	<build>
    		<resources>
    			<resource>
    				<directory>src/main/java</directory>
    				<includes>
    					<include>**/*.properties</include>
    					<include>**/*.xml</include>
    				</includes>
    				<filtering>false</filtering>
    			</resource>
    			<resource>
    				<directory>src/main/resources</directory>
    				<includes>
    					<include>**/*.properties</include>
    					<include>**/*.xml</include>
    				</includes>
    				<filtering>false</filtering>
    			</resource>
    		</resources>
    	</build>

    </project>
    ```

2.  建立基本结构和配置框架！

    1.  目录\
        ![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-02-05_17-47-13.jpg?raw=true)

    2.  Mybatis核心配置文件\:mybatis-config.xml

        ```xml
        <?xml version="1.0" encoding="UTF-8" ?>
        <!DOCTYPE configuration
                PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
                "http://mybatis.org/dtd/mybatis-3-config.dtd">
        <configuration>
        </configuration>

        ```

    3.  Spring核心配置文件\:applicationContext.xml

        ```xml
        <?xml version="1.0" encoding="UTF-8"?>
        <beans xmlns="http://www.springframework.org/schema/beans"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xsi:schemaLocation="http://www.springframework.org/schema/beans
                http://www.springframework.org/schema/beans/spring-beans.xsd">
        </beans>

        ```

### 8.3 Mybatis层编写

1.  数据库配置文件\:database.properties

    ```
    jdbc.driver=com.mysql.jdbc.Driver
    jdbc.url=jdbc:mysql://localhost:3306/ssmbuild?useSSL=true&useUnicode=true&characterEncoding=utf8
    jdbc.username=root
    jdbc.password=XXX
    ```

2.  编写MyBatis的核心配置文件 mybatis-config.xml

    ```xml
    <?xml version="1.0" encoding="UTF-8" ?>
    <!DOCTYPE configuration
    		PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
    		"http://mybatis.org/dtd/mybatis-3-config.dtd">
    <configuration>
    	<!--配置数据源，交给Spring去做-->

    	<settings>
    		<setting name="logImpl" value="STDOUT_LOGGING"/>

    	</settings>
    	<typeAliases>
    		<package name="com.hyf.pojo"/>
    	</typeAliases>
    	<mappers>
    		<mapper class="com.hyf.dao.BookMapper"/>
    	</mappers>

    </configuration>
    ```

3.  编写实体类Books

    ```java
    package com.hyf.pojo;

    import jdk.jfr.DataAmount;
    import lombok.AllArgsConstructor;
    import lombok.Data;
    import lombok.NoArgsConstructor;

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public class Books {
        private int bookID;
        private String bookName;
        private int bookCounts;
        private String detail;


    }
    ```

4.  编写Dao层的Mapper接口BookMapper

    ```java
    package com.hyf.dao;

    import com.hyf.pojo.Books;
    import org.apache.ibatis.annotations.Param;

    import java.util.List;

    public interface BookMapper {
        //增加一本书
        int addBook(Books book);

        //删除一本书
        int deleteBookById(@Param("bookID") int id);

        //更新一本书
        int updateBook(Books book);

        //查询一本书
        Books queryBookById(@Param("bookID") int id);

        //查询全部的书
        List<Books> queryAllBooks();

        //
        Books  queryBookByName(@Param("bookName") String bookName);
    }

    ```

5.  编写接口对应的 Mapper.xml 文件。需要导入MyBatis的包；

    ```xml
    <?xml version="1.0" encoding="UTF-8" ?>
    <!DOCTYPE mapper
    		PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
    		"http://mybatis.org/dtd/mybatis-3-mapper.dtd">

    <mapper namespace="com.hyf.dao.BookMapper">
    	<insert id="addBook" parameterType="Books">
    		insert into ssmbuild.books (bookName, bookCounts, detail)
    		values (#{bookName},#{bookCounts},#{detail});
    	</insert>

    	<delete id="deleteBookById" parameterType="_int">
    		delete from ssmbuild.books where bookID = #{bookID}
    	</delete>

    	<update id="updateBook" parameterType="books">
    		update ssmbuild.books
    			set bookName=#{bookName},bookCounts=#{bookCounts},detail=#{detail}
    		where bookID=#{bookID};
    	</update>

    	<select id="queryBookById" resultType="Books" parameterType="_int">
    		select * from ssmbuild.books
    		where bookID = #{bookID}
    	</select>

    	<select id="queryAllBooks" resultType="Books">
    		select * from ssmbuild.books
    	</select>

    	<select id="queryBookByName" resultType="Books">
    		select * from ssmbuild.books where bookName = #{bookName}
    	</select>

    </mapper>
    ```

6.  编写Service层的接口和实现类

    1.  接口\:BookService

        ```java
        package com.hyf.service;

        import com.hyf.pojo.Books;
        import org.apache.ibatis.annotations.Param;

        import java.util.List;

        public interface BookService {
            //增加一本书
            int addBook(Books book);

            //删除一本书
            int deleteBookById(int id);

            //更新一本书
            int updateBook(Books book);

            //查询一本书
            Books queryBookById(int id);

            //查询全部的书
            List<Books> queryAllBooks();

            Books  queryBookByName(String bookName);

        }
        ```

    2.  实现类\:BookServiceImpl

        ```java
        package com.hyf.service;

        import com.hyf.dao.BookMapper;
        import com.hyf.pojo.Books;
        import org.springframework.beans.factory.annotation.Autowired;
        import org.springframework.stereotype.Service;

        import java.util.List;


        public class BookServiceImpl implements BookService{

            //service调dao层
            private BookMapper mapper;


            public void setMapper(BookMapper mapper) {
                this.mapper = mapper;
            }

            @Override

            public int addBook(Books book) {
                return mapper.addBook(book);
            }

            @Override
            public int deleteBookById(int id) {
                return mapper.deleteBookById(id);
            }

            @Override
            public int updateBook(Books book) {
                System.out.println("BookServiceImpl:update==>"+book);
                return mapper.updateBook(book);
            }

            @Override
            public Books queryBookById(int id) {
                return mapper.queryBookById(id);
            }

            @Override
            public List<Books> queryAllBooks() {
                return mapper.queryAllBooks();
            }

            @Override
            public Books queryBookByName(String bookName) {
                return mapper.queryBookByName(bookName);
            }
        }
        ```

### 8.4 Spring层

配置Spring整合MyBatis,编写Spring整合Mybatis的相关的配置文件； spring-dao.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xmlns:mvc="http://www.springframework.org/schema/mvc"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
            http://www.springframework.org/schema/beans/spring-beans.xsd
            http://www.springframework.org/schema/context
            https://www.springframework.org/schema/context/spring-context.xsd
            http://www.springframework.org/schema/mvc
            https://www.springframework.org/schema/mvc/spring-mvc.xsd">
	<!--1. 关联数据库文件-->
	<context:property-placeholder location="classpath:database.properties"/>

	<!--2. 连接池
		dbcp:半自动化操作，不能自动链接
		c3p0：自动化操作，自动化地加载配置文件，并且可以自动设置到对象中
		druid
		hikari
	-->
	<bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">
		<property name="driverClass" value="${jdbc.driver}"/>
		<property name="jdbcUrl"    value="${jdbc.url}"/>
		<property name="user"   value="${jdbc.username}"/>
		<property name="password" value="${jdbc.password}"/>
		<!-- c3p0连接池的私有属性 -->
		<property name="maxPoolSize" value="30"/>
		<property name="minPoolSize" value="10"/>
		<!-- 关闭连接后不自动commit -->
		<property name="autoCommitOnClose" value="false"/>
		<!-- 获取连接超时时间 -->
		<property name="checkoutTimeout" value="10000"/>
		<!-- 当获取连接失败重试次数 -->
		<property name="acquireRetryAttempts" value="2"/>
	</bean>

	<!--3. sqlSessionFactory-->
	<bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
		<property name="dataSource" ref="dataSource"/>
		<!--绑定Mybatis配置文件-->
		<property name="configLocation" value="classpath:mybatis-config.xml"/>
	</bean>

	<!--配置dao接口扫描包，动态实现Dao接口注入到Sprin容器中-->
	<bean class="org.mybatis.spring.mapper.MapperScannerConfigurer">
		<!--注入SqlSessionFactory-->
		<property name="sqlSessionFactoryBeanName" value="sqlSessionFactory"/>
		<!--扫描的dao包-->
		<property name="basePackage" value="com.hyf.dao"/>
	</bean>

</beans>
```

Spring整合Service层的配置文件

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context https://www.springframework.org/schema/context/spring-context.xsd">
	
	<!--1.扫描service下的包-->
	<context:component-scan base-package="com.hyf.service"/>

	<!--2.将我们的所有业务类注入到Spring，可以通过配置或者注解实现-->
	<bean id="BookServiceImpl" class="com.hyf.service.BookServiceImpl">
		<property name="mapper" ref="bookMapper"/>
	</bean>

	<!--3。声明式事务配置-->
	<bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
		<!--注入数据源-->
		<property name="dataSource" ref="dataSource"/>
	</bean>

	<!--4。AOP事务支持-->
</beans>
```

### 7.5 SpringMVC层之配置文件

1.  web.xml声明使用SpringMVC并配置乱码过滤

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
             version="4.0">
    	<!--DispatchServlet-->
    	<servlet>
    		<servlet-name>springmvc</servlet-name>
    		<servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
    		<init-param>
    			<param-name>contextConfigLocation</param-name>
    			<param-value>classpath:applicaitonContext.xml</param-value>
    		</init-param>
    		<load-on-startup>1</load-on-startup>
    	</servlet>

    	<servlet-mapping>
    		<servlet-name>springmvc</servlet-name>
    		<url-pattern>/</url-pattern>
    	</servlet-mapping>

    	<!--乱码过滤-->
    	<filter>
    		<filter-name>encodingFilter</filter-name>
    		<filter-class>org.springframework.web.filter.CharacterEncodingFilter</filter-class>
    		<init-param>
    			<param-name>encoding</param-name>
    			<param-value>utf-8</param-value>
    		</init-param>
    	</filter>
    	<filter-mapping>
    		<filter-name>encodingFilter</filter-name>
    		<url-pattern>/*</url-pattern>
    	</filter-mapping>

    	<!--Session-->
    	<session-config>
    		<session-timeout>15</session-timeout>
    	</session-config>

    </web-app>
    ```

2.  spring-mvc.xml

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <beans xmlns="http://www.springframework.org/schema/beans"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xmlns:context="http://www.springframework.org/schema/context"
           xmlns:mvc="http://www.springframework.org/schema/mvc"
           xsi:schemaLocation="http://www.springframework.org/schema/beans
            http://www.springframework.org/schema/beans/spring-beans.xsd http://www.springframework.org/schema/context https://www.springframework.org/schema/context/spring-context.xsd http://www.springframework.org/schema/mvc https://www.springframework.org/schema/mvc/spring-mvc.xsd">


    	<!--1，注解驱动-->
    	<mvc:annotation-driven/>

    	<!--2。静态资源过滤-->
    	<mvc:default-servlet-handler/>

    	<!--3。扫描包 controller-->
    	<context:component-scan base-package="com.hyf.controller"/>
    	<!--4。视图解析器-->
    	<bean class="org.springframework.web.servlet.view.InternalResourceViewResolver">
    		<property name="prefix"  value="/WEB-INF/jsp/"/>
    		<property name="suffix" value=".jsp"/>
    	</bean>



    </beans>
    ```

3.  Spring配置整合文件\:applicationContext.xml

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <beans xmlns="http://www.springframework.org/schema/beans"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xsi:schemaLocation="http://www.springframework.org/schema/beans
            http://www.springframework.org/schema/beans/spring-beans.xsd">

    	<import resource="classpath:spring-dao.xml"/>
    	<import resource="classpath:spring-service.xml"/>
    	<import resource="classpath:spring-mvc.xml"/>

    </beans>
    ```

    配置文件就结束了,准备编写Controller和视图层

    ### 7.6 SpringMVC层之视图层页面

    有4个页面,除了首页都写在/WEB-INF/jsp/目录下

<!---->

1.  &#x20;首页index.jsp    \
    ![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-02-05_18-13-01.jpg?raw=true)

    ```jsp
    <%--
      Created by IntelliJ IDEA.
      User: heyufan1
      Date: 2022/1/29
      Time: 18:24
      To change this template use File | Settings | File Templates.
    --%>
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>
      <head>
        <title>首页</title>
        <style>
          a{
            text-decoration: none;
            color:black;
            font-size: 18px;
          }
          h3{
            width: 180px;
            height: 38px;
            margin: 100px auto;
            line-height: 38px;
            background: deepskyblue;
            border-radius: 5px;
          }
        </style>
      </head>
      <body>
      <h3>
        <a href="${pageContext.request.contextPath}/book/allBook">进入书籍页面</a>
      </h3>
      </body>
    </html>

    ```

2.  显示所有书籍的页面\:allBook.jsp\
    ![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-02-05_18-13-17.jpg?raw=true)

    ```jsp
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>
    <head>
        <title>书籍列表</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- 引入 Bootstrap -->
        <link href="https://cdn.bootcss.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
    <div class="container">
        <div class="row clearfix">
            <div class="col-md-12 column">
                <div class="page-header">
                    <h1>
                        <small>书籍列表 —— 显示所有书籍</small>
                    </h1>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-4 column">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/book/toAddBook">新增</a>
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/book/allBook">显示所有书籍</a>
            </div>
            <div class="col-md-4 column">
                <%--查询书籍--%>
                <form action="${pageContext.request.contextPath}/book/queryBook" method="post" style="float: right">
                    <span style="color:red;font-weight: bold">${error}</span>

                    <input type="text" name="queryBookName" class="form-control" placeholder="请输入要查询的书籍名称">
                    <input type="submit" value="查询" class="btn btn-primary">
                </form>
            </div>
        </div>
        <div class="row clearfix">
            <div class="col-md-12 column">
                <table class="table table-hover table-striped">
                    <thead>
                    <tr>
                        <th>书籍编号</th>
                        <th>书籍名字</th>
                        <th>书籍数量</th>
                        <th>书籍详情</th>
                        <th>操作</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="book" items="${requestScope.get('list')}">
                        <tr>
                            <td>${book.bookID}</td>
                            <td>${book.bookName}</td>
                            <td>${book.bookCounts}</td>
                            <td>${book.detail}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/book/toUpdateBook?id=${book.getBookID()}">更改</a> |
                                <a href="${pageContext.request.contextPath}/book/del/${book.getBookID()}">删除</a>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    ```

3.  新增书籍页面\:addBook.jsp\
    ![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-02-05_18-13-26.jpg?raw=true)

    ```jsp
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>
    <head>
        <title>新增书籍</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <!-- 引入 Bootstrap -->
        <link href="https://cdn.bootcss.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body>
    <div class="container">
        <div class="row clearfix">
            <div class="col-md-12 column">
                <div class="page-header">
                    <h1>
                        <small>新增书籍</small>
                    </h1>
                </div>
            </div>
        </div>
        <form action="${pageContext.request.contextPath}/book/addBook" method="post">
            书籍名称：<input type="text" name="bookName" required><br><br><br>
            书籍数量：<input type="text" name="bookCounts" required><br><br><br>
            书籍详情：<input type="text" name="detail" required><br><br><br>
            <input type="submit" value="添加">
        </form>
    </div>

    ```

4.  修改书籍页面\:updateBook.jsp\
    ![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-02-05_18-17-05.jpg?raw=true)

    ```jsp
    <%--
      Created by IntelliJ IDEA.
      User: heyufan1
      Date: 2022/1/31
      Time: 14:15
      To change this template use File | Settings | File Templates.
    --%>
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>
    <head>
        <title>修改书籍</title>
    </head>
    <body>
    <div class="container">
        <div class="row clearfix">
            <div class="col-md-12 column">
                <div class="page-header">
                    <h1>
                        <small>修改书籍</small>
                    </h1>
                </div>
            </div>
        </div>
        <form action="${pageContext.request.contextPath}/book/updateBook" method="post">

            <input type="hidden" name="bookID" value="${QBook.bookID}"/>
            书籍名称：<input type="text" name="bookName" value="${QBook.bookName}" required><br><br><br>
            书籍数量：<input type="text" name="bookCounts" value="${QBook.bookCounts}"  required><br><br><br>
            书籍详情：<input type="text" name="detail" value="${QBook.detail}"  required><br><br><br>
            <input type="submit" value="修改">
        </form>
    </div>
    ```

### 7.7 SpringMVC层之Controller

```java
package com.hyf.controller;

import com.hyf.pojo.Books;
import com.hyf.service.BookService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.ArrayList;
import java.util.List;

@Controller
@RequestMapping("/book")
public class BookController {
    //Controller调Service层
    @Autowired
    @Qualifier("BookServiceImpl")
    private BookService bookService;

    //查询全部书籍，并且返回到一个书籍展示页面
    @RequestMapping("/allBook")
    public String list(Model model){
        List<Books> books = bookService.queryAllBooks();

        model.addAttribute("list",books);

        return "allBook";
    }

    //跳转到增加书籍页面
    @RequestMapping("/toAddBook")
    public String toAddPaper(){
        return "addBook";
    }

    @RequestMapping("/addBook")
    public String addBook(Books books){
        System.out.println("addBook=>"+books);

        bookService.addBook(books);
        return "redirect:/book/allBook";//重定向到@RequestMapping("/addBook")请求

    }

    //跳转到修改页面
    @RequestMapping("/toUpdateBook")
    public String toUpdatePaper(int id,Model model){
        Books book = bookService.queryBookById(id);
        model.addAttribute("QBook",book);
        return "updateBook";
    }

    //修改书籍
    @RequestMapping("/updateBook")
    public String updateBook(Books books){
        System.out.println("updateBook==>" + books);
        bookService.updateBook(books);
        return "redirect:/book/allBook";//重定向到@RequestMapping("/addBook")请求

    }

    //删除书籍,我们这里使用RestFul风格
    @RequestMapping("/del/{bookID}")
    public String deleteBook(@PathVariable("bookID") int id) {
        bookService.deleteBookById(id);
        return "redirect:/book/allBook";
    }

    //查询书籍
    @RequestMapping("/queryBook")
    public String queryBook(String queryBookName,Model model){
        Books books = bookService.queryBookByName(queryBookName);
        List<Books> list = new ArrayList<Books>();
        list.add(books);

        if(books == null){
            list = bookService.queryAllBooks();
            model.addAttribute("error","未查到书籍");

        }

        model.addAttribute("list",list);
        return "allBook";
    }

}
```

## 9. AJAX

### 9.1  简介

AJAX全称async javascript and XML(异步JavaScript和XML)

-   AJAX `不是新的编程语言`，而是一种使用现有标准的新方法。不需要插件的支持,原生js就能使用

-   传统的网页(即不用ajax技术的网页)，想要更新内容或者提交一个表单，都需要重新加载整个网页。AJAX 是与服务器交换数据并更新部分网页的艺术，`在不重新加载整个页面的情况下。`

-   是⼀个 `默认异步`执⾏机制的功能,AJAX分为同步（async = false）和异步（async = true）

-   ⽤户体验好（`不需要刷新⻚⾯就可以更新数据`）,减轻服务端和带宽的负担

-   例如百度的搜索框

### 9.2 JQuery的AJAX

我们使用JQuery提供的AJAX,jQuery 提供多个与 AJAX 有关的方法。jQuery Ajax本质就是 XMLHttpRequest，对他进行了封装，方便调用.

```javascript
jQuery.ajax(...)
       部分参数：
              url：请求地址
             type：请求方式，GET、POST（1.9.0之后用method）
          headers：请求头
             data：要发送的数据
      contentType：即将发送信息至服务器的内容编码类型(默认: "application/x-www-form-urlencoded; charset=UTF-8")
            async：是否异步
          timeout：设置请求超时时间（毫秒）
       beforeSend：发送请求前执行的函数(全局)
         complete：完成之后执行的回调函数(全局)
          success：成功之后执行的回调函数(全局)
            error：失败之后执行的回调函数(全局)
          accepts：通过请求头发送给服务器，告诉服务器当前客户端课接受的数据类型
         dataType：将服务器端返回的数据转换成指定类型
            "xml": 将服务器端返回的内容转换成xml格式
           "text": 将服务器端返回的内容转换成普通文本格式
           "html": 将服务器端返回的内容转换成普通文本格式，在插入DOM中时，如果包含JavaScript标签，则会尝试去执行。
         "script": 尝试将返回值当作JavaScript去执行，然后再将服务器端返回的内容转换成普通文本格式
           "json": 将服务器端返回的内容转换成相应的JavaScript对象
          "jsonp": JSONP 格式使用 JSONP 形式调用函数时，如 "myurl?callback=?" jQuery 将自动替换 ? 为正确的函数名，以执行回调函数

```

熟悉url, data, sucess即可

### 9.3 注册提示效果

1.  新建一个module ： sspringmvc-06-ajax ， 导入web支持！配置web.xml和springmvc的配置文件

2.  编写AjaxController

    ```java

    @Controller
    public class AjaxController {

        @RequestMapping("/a3")
        public String a3(String name, String pwd){
            String msg = "";
            if(name != null){
                //这里写死为admin，实际应该在数据库中查
                if("admin".equals(name)){
                    msg = "ok";
                }else {
                    msg = "用户名有误";
                }
            }
            if(pwd != null){
                //这里写死为admin，实际应该在数据库中查
                if("123456".equals(pwd)){
                    msg = "ok";
                }else {
                    msg = "密码有误";
                }
            }
            return msg;

        }
    }

    ```

3.  编写login.jsp测试

    ```jsp
    <%--
      Created by IntelliJ IDEA.
      User: heyufan1
      Date: 2022/2/3
      Time: 23:15
      To change this template use File | Settings | File Templates.
    --%>
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>
    <head>
        <script src="${pageContext.request.contextPath}/static/js/jquery-3.6.0.js"></script>

        <title>Title</title>
        <script>
            function a1(){
                $.post({
                    url:"${pageContext.request.contextPath}/a3",
                    data:{"name":$("#name").val()},
                    success:function (data){
                        if(data.toString()==="ok"){
                            $("#userInfo").css("color","green");
                        }else {
                            $("#userInfo").css("color","red");

                        }

                        $("#userInfo").html(data);
                    }
                })
            }
            function a2(){
                $.post({
                    url:"${pageContext.request.contextPath}/a3",
                    data:{"pwd":$("#pwd").val()},
                    success:function (data){
                        if(data.toString()==="ok"){
                            $("#pwdInfo").css("color","green");
                        }else {
                            $("#pwdInfo").css("color","red");

                        }

                        $("#pwdInfo").html(data);
                    }
                })
            }
        </script>
    </head>
    <body>
    <p>
        用户名：<input type="text" id="name" onblur="a1()">
        <span id="userInfo" ></span>
    </p>

    <p>
        密码：<input type="text" id="pwd" onblur="a2()">
        <span id="pwdInfo" ></span>
    </p>
    </body>
    </html>

    ```

效果如下:\
![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-02-05_20-01-17.jpg?raw=true) ![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-02-05_20-01-17.jpg?raw=true)

## 10. 拦截器

### 10.1 简介

SpringMVC的拦截器类似于Servlet中的过滤器,

拦截器与过滤器的区别:拦截器是AOP思想的具体应用,. 拦截器可以访问action[上下文](https://www.baidu.com/s?wd=%E4%B8%8A%E4%B8%8B%E6%96%87\&tn=SE_PcZhidaonwhc_ngpagmjz\&rsv_dl=gh_pc_zhidao)、值栈里的对象，而过滤器不能访问。

过滤器:

-   servlet规范中的一部分，任何java web工程都可以使用

-   在url-pattern中配置了/\*之后，可以对所有要访问的资源进行拦截

-   过滤器是基于[函数](https://www.baidu.com/s?wd=%E5%87%BD%E6%95%B0\&tn=SE_PcZhidaonwhc_ngpagmjz\&rsv_dl=gh_pc_zhidao)[回调](https://www.baidu.com/s?wd=%E5%9B%9E%E8%B0%83\&tn=SE_PcZhidaonwhc_ngpagmjz\&rsv_dl=gh_pc_zhidao)。

-   过滤器只能在容器[初始化](https://www.baidu.com/s?wd=%E5%88%9D%E5%A7%8B%E5%8C%96\&tn=SE_PcZhidaonwhc_ngpagmjz\&rsv_dl=gh_pc_zhidao)时被调用一次

拦截器:

-   拦截器是SpringMVC框架自己的,只有使用了SpringMVC框架的工程才能使用,之前的Struct2等框架也有

-   拦截器只会拦截访问的控制器方法,只能对action请求起作用

-   拦截器是基于java的[反射机制](https://www.baidu.com/s?wd=%E5%8F%8D%E5%B0%84%E6%9C%BA%E5%88%B6\&tn=SE_PcZhidaonwhc_ngpagmjz\&rsv_dl=gh_pc_zhidao)的

-   在action的生命周期中，拦截器可以多次被调用

### 10.2 自定义拦截器

想要自定义拦截器，必须实现 HandlerInterceptor 接口。

1.  新建一个Moudule ， springmvc-07-Interceptor ， 添加web支持

2.  配置web.xml 和 springmvc-servlet.xml 文件

3.  编写一个拦截器MyInterceptor

    ```java
    package com.hyf.config;

    import org.springframework.web.servlet.HandlerInterceptor;
    import org.springframework.web.servlet.ModelAndView;

    import javax.servlet.http.HttpServletRequest;
    import javax.servlet.http.HttpServletResponse;

    public class MyInterceptor implements HandlerInterceptor {
        @Override
        //        return false;不执行下一个拦截器
        //          return ture;放行，执行下一个拦截器
        public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
            System.out.println("===========处理前");
            return true;
        }


        //拦截日志，可以不用
        @Override
        public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
            System.out.println("===========处理后");
        }


        //拦截日志，可以不用
        @Override
        public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
            System.out.println("===========清理");

        }

    }
    ```

4.  在springmvc的配置文件中配置拦截器

    ```xml
    <!--拦截器配置-->
    <mvc:interceptors>
    	<mvc:interceptor>
    		<!--包括这个请求下面的所有请求-->
    		<mvc:mapping path="/**"/>
    		<bean class="com.hyf.config.MyInterceptor"/>
    	</mvc:interceptor>
    	<mvc:interceptor>
    		<!--包括这个/user/下面的所有请求-->
    		<mvc:mapping path="/user/**"/>
    		<bean class="com.hyf.config.LoginInterceptor"/>
    	</mvc:interceptor>
    </mvc:interceptors>
    ```

5.  编写一个Controller，接收请求

    ```java
    package com.hyf.controller;

    import org.springframework.web.bind.annotation.GetMapping;
    import org.springframework.web.bind.annotation.RestController;

    @RestController
    public class TestController {

        @GetMapping("/t1")
        public String test(){
            System.out.println("TestController的test方法执行了");
            return "OK";
        }
    }
    ```

6.  前端index.jsp

    \<a href="\${pageContext.request.contextPath}/interceptor">拦截器测试\</a>

7.  测试

    ![](https://raw.githubusercontent.com/Missyesterday/Picture/2e5d3ae3cc54e5729edde19583cfbc1e020530ef/Xnip2022-02-05_21-13-17.jpg)



### 10.3 验证用户是否登陆

有一个登陆页面，需要写一个controller访问页面。 登陆页面有一提交表单的动作。需要在controller中处理。判断用户名密码是否正确。如果正确，向session中写入用户信息。返回登陆成功。 拦截用户请求，判断用户是否登陆。如果用户已经登陆。放行， 如果用户未登陆，跳转到登陆页面

1.  编写登陆页面login.jsp

    ```jsp
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>
    <head>
        <title>Title</title>
    </head>
    <body>

    <%--在/WEB-INF/下所有资源，只能通过controller，或者servlet进行访问--%>
    <h1>登陆页面</h1>


    <form action="${pageContext.request.contextPath}/user/login" method="post">
        用户名: <input type="text" name="username">
        密码: <input type="text" name="password">
        <input type="submit" value="提交">
    </form>
    </body>
    </html>
    ```



2.  编写一个Controller处理请求

    ```java
    package com.hyf.controller;

    import org.springframework.stereotype.Controller;
    import org.springframework.ui.Model;
    import org.springframework.web.bind.annotation.RequestMapping;

    import javax.servlet.http.HttpSession;

    @Controller
    @RequestMapping("user")
    public class LoginController {
        @RequestMapping("/main")
        public String main(){
            return "main";
        }

        @RequestMapping("/goLogin")
        public String goLogin(){
            return "login";
        }

        @RequestMapping("/login")
        public String login(HttpSession session, String username, String password, Model model){
            //把用户的信息，存在session中
            session.setAttribute("userLoginInfo",username);
            model.addAttribute("username",username);
            return "main";
        }

        @RequestMapping("/goOut")
        public String goOut(HttpSession session){
            session.removeAttribute("userLoginInfo");
            return "main";

        }
    }

    ```

3.  编写一个登陆成功的页面 main.jsp

    ```jsp

    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>
    <head>
        <title>Title</title>
    </head>
    <body>
    <h1>首页</h1>
    <span>${username}</span>

    <p>
        <a href="${pageContext.request.contextPath}/user/goOut">注销</a>
    </p>
    </body>
    </html>
    ```



4.  在 index 页面上测试跳转！启动Tomcat 测试，未登录也可以进入主页！

    ```jsp
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>
      <head>
        <title>$Title$</title>
      </head>
      <body>
      <h1>
        <a href="${pageContext.request.contextPath}/user/goLogin">登陆</a>
        <a href="${pageContext.request.contextPath}/user/main">首页</a>
      </h1>
      </body>
    </html>
    ```



5.  编写用户登录拦截器

    ```java
    package com.hyf.config;

    import org.springframework.web.servlet.HandlerInterceptor;

    import javax.servlet.http.HttpServletRequest;
    import javax.servlet.http.HttpServletResponse;
    import javax.servlet.http.HttpSession;

    public class LoginInterceptor implements HandlerInterceptor {
        @Override
        public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
            HttpSession session = request.getSession();
            //放行：判断什么情况下登陆
            //1.本身就在登陆页面，准备去登陆
            if (request.getRequestURI().contains("goLogin")){

                return HandlerInterceptor.super.preHandle(request, response, handler);

            }

            //2。说明在第一次登陆
            if (request.getRequestURI().contains("login")){

                return HandlerInterceptor.super.preHandle(request, response, handler);

            }
            //3。已经登陆
            if (session.getAttribute("userLoginInfo") != null){
                return HandlerInterceptor.super.preHandle(request, response, handler);

            }

            //判断什么情况下没有登陆
            request.getRequestDispatcher("/WEB-INF/jsp/login.jsp").forward(request,response);

            return false;
        }
    }

    ```

6.  在SpringMVC中配置拦截器

    ```java
    	<!--拦截器配置-->
    	<mvc:interceptors>
    		<mvc:interceptor>
    			<!--包括这个请求下面的所有请求-->
    			<mvc:mapping path="/**"/>
    			<bean class="com.hyf.config.MyInterceptor"/>
    		</mvc:interceptor>
    		<mvc:interceptor>
    			<!--包括这个/user/下面的所有请求-->
    			<mvc:mapping path="/user/**"/>
    			<bean class="com.hyf.config.LoginInterceptor"/>
    		</mvc:interceptor>
    	</mvc:interceptors>
    ```

7.  测试拦截器

## 11. 文件的上传和下载

文件的上传就是一个模版

### 11.1文件上传

1.  index.jsp

    ```jsp
    <%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <html>
      <head>
        <title>$Title$</title>
      </head>
      <body>
      <form action="/upload" enctype="multipart/form-data" method="post">
        <input type="file" name="file"/>
        <input type="submit" value="upload">
      </form>

      </body>
    </html>
    ```

2.  导包

    ```xml
    <!--文件上传-->
    <dependency>
        <groupId>commons-fileupload</groupId>
        <artifactId>commons-fileupload</artifactId>
        <version>1.3.3</version>
    </dependency>
    <!--servlet-api导入高版本的-->
    <dependency>
        <groupId>javax.servlet</groupId>
        <artifactId>javax.servlet-api</artifactId>
        <version>4.0.1</version>
    </dependency>
    ```

3.  Controller

    ```java
    package com.hyf.controller;
    import org.springframework.stereotype.Controller;
    import org.springframework.web.bind.annotation.RequestMapping;
    import org.springframework.web.bind.annotation.RequestParam;
    import org.springframework.web.bind.annotation.RestController;
    import org.springframework.web.multipart.commons.CommonsMultipartFile;
    import javax.servlet.http.HttpServletRequest;
    import javax.servlet.http.HttpServletResponse;
    import java.io.*;
    import java.net.URLEncoder;

    @RestController
    public class FileController {
        //@RequestParam("file") 将name=file控件得到的文件封装成CommonsMultipartFile 对象
        //批量上传CommonsMultipartFile则为数组即可
        @RequestMapping("/upload")
        public String fileUpload(@RequestParam("file") CommonsMultipartFile file , HttpServletRequest request) throws IOException {
            //获取文件名 : file.getOriginalFilename();
            String uploadFileName = file.getOriginalFilename();
            //如果文件名为空，直接回到首页！
            if ("".equals(uploadFileName)){
                return "redirect:/index.jsp";
            }
            System.out.println("上传文件名 : "+uploadFileName);
            //上传路径保存设置
            String path = request.getServletContext().getRealPath("/upload");
            //如果路径不存在，创建一个
            File realPath = new File(path);
            if (!realPath.exists()){
                realPath.mkdir();
            }
            System.out.println("上传文件保存地址："+realPath);
            InputStream is = file.getInputStream(); //文件输入流
            OutputStream os = new FileOutputStream(new File(realPath,uploadFileName)); //文件输出流
            //读取写出
            int len=0;
            byte[] buffer = new byte[1024];
            while ((len=is.read(buffer))!=-1){
                os.write(buffer,0,len);
                os.flush();
            }
            os.close();
            is.close();
            return "redirect:/index.jsp";
        }


        /*
         * 采用file.Transto 来保存上传的文件
         */
        @RequestMapping("/upload2")
        public String  fileUpload2(@RequestParam("file") CommonsMultipartFile file, HttpServletRequest request) throws IOException {
            //上传路径保存设置
            String path = request.getServletContext().getRealPath("/upload");
            File realPath = new File(path);
            if (!realPath.exists()){
                realPath.mkdir();
            }
            //上传文件地址
            System.out.println("上传文件保存地址："+realPath);
            //通过CommonsMultipartFile的方法直接写文件（注意这个时候）
            file.transferTo(new File(realPath +"/"+ file.getOriginalFilename()));
            return "redirect:/index.jsp";
        }

        @RequestMapping(value="/download")
        public String downloads(HttpServletResponse response , HttpServletRequest request) throws Exception{
            //要下载的图片地址
            String  path = request.getServletContext().getRealPath("/upload");
            String  fileName = "跟踪方向投稿目标期刊20211105.txt";
            //1、设置response 响应头
            response.reset(); //设置页面不缓存,清空buffer
            response.setCharacterEncoding("UTF-8"); //字符编码
            response.setContentType("multipart/form-data"); //二进制传输数据
            //设置响应头
            response.setHeader("Content-Disposition",
                    "attachment;fileName="+ URLEncoder.encode(fileName, "UTF-8"));
            File file = new File(path,fileName);
            //2、 读取文件--输入流
            InputStream input=new FileInputStream(file);
            //3、 写出文件--输出流
            OutputStream out = response.getOutputStream();
            byte[] buff =new byte[1024];
            int index=0;
            //4、执行 写出操作
            while((index= input.read(buff))!= -1){
                out.write(buff, 0, index);
                out.flush();
            }
            out.close();
            input.close();
            return null;
        }

    }
    ```

4.  测试

### 11.2 文件下载

```java
@RequestMapping(value="/download")
public String downloads(HttpServletResponse response ,HttpServletRequest request) throws Exception{
    //要下载的图片地址
    String  path = request.getServletContext().getRealPath("/upload");
    String  fileName = "基础语法.jpg";//下什么写什么
    //1、设置response 响应头
    response.reset(); //设置页面不缓存,清空buffer
    response.setCharacterEncoding("UTF-8"); //字符编码
    response.setContentType("multipart/form-data"); //二进制传输数据
    //设置响应头
    response.setHeader("Content-Disposition",
            "attachment;fileName="+URLEncoder.encode(fileName, "UTF-8"));
    File file = new File(path,fileName);
    //2、 读取文件--输入流
    InputStream input=new FileInputStream(file);
    //3、 写出文件--输出流
    OutputStream out = response.getOutputStream();
    byte[] buff =new byte[1024];
    int index=0;
    //4、执行 写出操作
    while((index= input.read(buff))!= -1){
        out.write(buff, 0, index);
        out.flush();
    }
    out.close();
    input.close();
    return null;
}
```



前端

```html
<a href="/download">点击下载</a>
```
