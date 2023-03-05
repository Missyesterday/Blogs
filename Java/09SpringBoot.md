# SpringBoot

war包和jar包

jar包内嵌tomcat，微服务架构，服务更多的时候用SpringCloud

## 1. 快速入门

### 1.1 什么是SpringBoot

Spring是为了解决企业级应用开发的复杂性而创建的。

SpringMVC的xml配bean太复杂。

SpringBoot整合了所有框架。SpringBoot

高内聚、低耦合。

### 1.2 什么是微服务

## 2. 第一个SpringBoot程序

- jdk 1.8

- maven  3.6.1

- SpringBoot：2.6.4

- IDEA

官方提供了一个网站可以在线生成

### 2.1 使用IDEA创建

IDEA也可以调用这个网站，所以我们一般在IDEA中生成。:

1. 创建一个新项目

2. 选择spring initalizr

3. 填写项目信息

4. 选择初始化组件（这里我们勾选Web即可）

5. 填写项目路径

### 2.2 项目结构分析

1. 程序的主启动类Springboot01HelloworldApplication

2. 一个application.properties配置文件

3. 一个测试类

4. 一个pom.xml

### 2.3 编写一个Http接口

1. 在主程序的同级目录下，新建一个Controller包

2. 在包中新建一个HelloController类

   ```java
   @RestController
   public class HelloController {
   
       @RequestMapping("/hello")
       public String hello() {
           return "Hello World";
       }
       
   }
   ```

3. 从主程序启动项目,测试

> 个人感觉SpringBoot项目的启动时间明显要比MVC快很多，而且省略了tomcat的配置，它嵌入了tomcat。

### 2.4 将项目打包成jar包

![](https://raw.github.com/Missyesterday/picgo/main/picgo/1647178564000.png)

打包后在target目录下

![](https://raw.github.com/Missyesterday/picgo/main/picgo/20220313213656.png)

打包之后就可以在任何地方运行了

```shell
java -jar jar包路径
```

### 2.5修改Banner

SpringBoot启动的时候的banner图案，可以在resources下添加一个banner.txt修改启动时的banner文件。

被识别成Springboot项目中的文件右下角会有这样的标志。

banner可以在网上搜。

![](https://raw.github.com/Missyesterday/picgo/main/picgo/20220313213956.png)

### 2.6修改端口

在application.properties文件中添加server.port=xxxx，可以修改项目的指定端口号。

![](https://raw.github.com/Missyesterday/picgo/main/picgo/20220313214238.png)

## 3. 原理初探

自动配置：

### **3.1 pom.xml：**

- spring-boot-dependencies：核心依赖在父工程中

- 我们在写或者引入一些springboot依赖的时候，不需要指定版本，因为有这些版本仓库

### **3.2 启动器：**

```xml
<!--启动器-->
<dependency>
   <groupId>org.springframework.boot</groupId>
   <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

- 是SpringBoot的启动场景

- 比如spring-boot-starter-web，会自动帮我们自动导入web环境所有的依赖

- springboot会将所有的功能场景，

- springboot

### **3.3 主程序：**

```java
package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

//@SpringBootApplication ：标注这个类是一个springboot的应用
@SpringBootApplication
public class Springboot01HelloworldApplication {
    //将springboot启动
    public static void main(String[] args) {
        SpringApplication.run(Springboot01HelloworldApplication.class, args);
    }

}
```

- 注解

  * @SpringBootConfiguration：springboot的配置

    * @Configuration：spring配置类

    * @Component ：说明这也是一个spring的组件

  * @EnableAutoConfiguration：自动配置

    * @AutoConfigurationPackage：自动配置包

      * @Import({Registrar.class})：自动配置包注册

    * @Import({AutoConfigurationImportSelector.class})：自动导入选择

  * 

### **3.5** SpringApplication.run

- 推断应用是普通的项目还是Web项目

- 查找并加载所有可用初始化器，设置到initializers属性中

- 找出所有的应用程序监听器，设置到listeners属性中

- 推断并设置main方法的定义类，找到运行的主类

## 4. yml配置注入

yaml就是yml

## 5. JSR303数据校验以及多环境切换

## 6. 自动配置原理

xxxProperties

xxxAutoConfiguration

## 7. Springboot Web开发

要解决的问题：

1. 导入静态资源

2. 首页

3. jsp，模版引擎Thymeleaf

4. 转配扩展SpringMVC

5. CRUD

6. 拦截器

7. 国际化！

### 静态资源

```java
public void addResourceHandlers(ResourceHandlerRegistry registry) {
            if (!this.resourceProperties.isAddMappings()) {
                logger.debug("Default resource handling disabled");
            } else {
                if (!registry.hasMappingForPattern("/webjars/**")) {
                    ResourceHandlerRegistration registration = registry.addResourceHandler(new String[]{"/webjars/**"}).addResourceLocations(new String[]{"classpath:/META-INF/resources/webjars/"});
                    this.configureResourceCaching(registration);
                    this.customizeResourceHandlerRegistration(registration);
                }

                String staticPathPattern = this.webFluxProperties.getStaticPathPattern();
                if (!registry.hasMappingForPattern(staticPathPattern)) {
                    ResourceHandlerRegistration registration = registry.addResourceHandler(new String[]{staticPathPattern}).addResourceLocations(this.resourceProperties.getStaticLocations());
                    this.configureResourceCaching(registration);
                    this.customizeResourceHandlerRegistration(registration);
                }

            }
        }
```

什么是webjars

获得静态资源的路径

总结：

1. 在SpringBoot中，我们可以使用以下方式处理静态资源

   1. webjars   localhost:8080/webjars/

   2. public，static，/\*\*，resources   localhost:8080

2. 优先级：resources > static > public

### 首页定制

favicon.ico放在与index.html同级目录下

### thymeleaf模版引擎

依赖：

```xml
<!--thmeleaf模版-->
		<dependency>
			<groupId>org.thymeleaf.extras</groupId>
			<artifactId>thymeleaf-extras-java8time</artifactId>
		</dependency>
		<dependency>
			<groupId>org.thymeleaf</groupId>
			<artifactId>thymeleaf-spring5</artifactId>
		</dependency>
```

命名空间

```html
<html lang="en" xmlns:th="http://www.thymeleaf.org">
```

只要需要使用thymeleaf，只需要导入对应的依赖就可以了！我们将html页面放在templates目录下。

```java
    private String prefix = "classpath:/templates/";
    private String suffix = ".html";
```

可以在html文件中取值

### MVC 自动配置原理

## 项目

1. 首页配置：注意点，需要所有的静态资源都被thymeleaf接管;@{}

2. 登录+拦截器

3. 员工列表展示

   1. 

   2. 提取公共页面并传递参数

      ```html
      th:replace="~{commons/commons::sidebar(active='main.html')}
      th:fragment="sidebar"
      ```

## 如何写网站

1. 前端：页面和数据

2. 设计数据库（难点）

3. 前端能自动运行

4. 数据接口如何对接，对象all in one

5. 前后端联调测试！

## Druid

druid是数据源

## 整合Mybatis

整合包

mybatis-spring-boot-starter

url请求都是get

记得绑定namespace

1. 导包

2. 配置文件

   ```
   spring:
     datasource:
       username: root
       password: 5xxx
   #    假如时区报错了,需要增加一个时区的配置
       url: jdbc:mysql://localhost:3306/mybatis?useUnicode=true&characterEncoding=utf-8&serverTimezone=UTC
       driver-class-name: com.mysql.jdbc.Driver
       #切换数据源
       type: com.alibaba.druid.pool.DruidDataSource
         #Spring Boot 默认是不注入这些属性值的，需要自己绑定
         #druid 数据源专有配置
   
       initialSize: 5
       minIdle: 5
       maxActive: 20
       maxWait: 60000
       timeBetweenEvictionRunsMillis: 60000
       minEvictableIdleTimeMillis: 300000
       validationQuery: SELECT 1 FROM DUAL
       testWhileIdle: true
       testOnBorrow: false
       testOnReturn: false
       poolPreparedStatements: true
   
       #配置监控统计拦截的filters，stat:监控统计、log4j：日志记录、wall：防御sql注入
       #如果允许时报错  java.lang.ClassNotFoundException: org.apache.log4j.Priority
       #则导入 log4j 依赖即可，Maven 地址：https://mvnrepository.com/artifact/log4j/log4j
       #可以把log4j改为log4j2
       filters: stat,wall,log4j2
       maxPoolPreparedStatementPerConnectionSize: 20
       useGlobalDataSourceStat: true
       connectionProperties: druid.stat.mergeSql=true;druid.stat.slowSqlMillis=500
   ```

3. mybatis配置

4. 编写sql

5. service调用dao层

6. controller调用service

## SpringSecurity（安全）

在web开发中，安全是第一位！过滤器，拦截器

安全属于非功能性需求

shiro、SpringSecurity很相似，除了类和名字不一样

认证，授权（vip1、vip2.。。）

- 功能权限

- 访问权限

- 菜单权限

- 拦截器过滤器：大量原生代码

SpringSecurity的思想就是AOP

对于安全控制，只需要引入spring-boot-security模块，进行少量的配置

几个类：

- W

- A

- @E

SpringSecurity的两个主要目标是“认证(Authentication)”和“授权(Authorization)”（访问控制）

这个概念是通用的

1. 引入<dependency>
   <groupId>org.thymeleaf</groupId>
   <artifactId>thymeleaf-spring5</artifactId>
   </dependency>

## Shiro

1. 导入依赖

2. 配置文件

3. helloworld

```java
Subject currentUser = SecurityUtils.getSubject();
```

```
Session session = currentUser.getSession();
currentUser.isAuthenticated()
currentUser.getPrincipal()
```

### 在Springboot中集成

1. Subject 用户

2. s

导入jar包

```xml
<!--shiro整合-->
		<dependency>
			<groupId>org.apache.shiro</groupId>
			<artifactId>shiro-spring</artifactId>
			<version>1.4.1</version>
		</dependency>
```

编写配置类ShiroConfig

编写页面