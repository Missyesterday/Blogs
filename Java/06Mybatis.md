# Mybatis

环境：

-   JDK1.8

-   MySQL 5.7

-   maven 3.6.1

-   IDEA

回顾：

-   JDBC

-   MySQL

-   Java基础

-   Maven

-   Junit

框架：配置文件的。最好的方式：看官网文档：[Mybatis官方文档](https://mybatis.org/mybatis-3/zh/getting-started.html)

## 1. 简介

### 1.1 什么是Mybatis

![Mybatis图标](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-01-15_13-55-09.jpg?raw=true)

maven仓库

```xml
<!-- https://mvnrepository.com/artifact/org.mybatis/mybatis -->
<dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis</artifactId>
    <version>3.5.2</version>
</dependency>1.2 持久化
```

### 1.2 数据持久化

-   持久化就是将程序的数据在持久状态和瞬时状态转化的过程

-   内存：**断电即失**

-   数据库（jdbc），io文件持久化

-   生活：冷藏，罐头

为什么需要持久化？因为有一些对象不能丢掉，内存太贵了

### 1.3 持久层

Dao层，Service层，Controller层

-   完成持久化工作的代码块

-   层界限十分明显

### 1.4 为什么需要Mybatis？

-   方便

-   传统的JDBC代码太复杂了。简化、框架

-   帮助程序员将数据存入到数据库中

-   不用Mybatis也可以。更容易上手

-   优点

    -   简单易学

    -   灵活

    -   提供映射标签，支持对象和数据库的orm字段关系映射

    -   提供对象关系映射标签，支持对象关系组建维护

    -   提供xml标签，支持编写动态SQL。

-   用的人多

## 2. 第一个Mybatis程序

思路：搭建环境->导入Mybatis->编写代码->测试

### 2.1 搭建环境

搭建数据库

```SQL
create database `mybatis`;

use `mybatis`;

create table `user`(
	`id` int(20) not null primary key,
	`name` varchar(30) default null,
    `pwd` varchar(30) default null
)engine=InnoDB default charset=utf8;

use `mybatis`;
insert into	`user`(`id`,`name`,`pwd`) values
(1,'张三','123'),
(2,'张三','124'),
(3,'张三','125'
```

新建项目

1.  新建一个普通maven项目，选择自己的maven

2.  删除src文件夹

3.  导入maven依赖

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <project xmlns="http://maven.apache.org/POM/4.0.0"
             xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
        <modelVersion>4.0.0</modelVersion>

          <!--      父工程-->
        <groupId>com.hyf</groupId>
        <artifactId>Mybatis-Study</artifactId>
        <version>1.0-SNAPSHOT</version>

          <!--    导入依赖-->
        <dependencies>
          <!--mySQL驱动-->
          <dependency>
            <groupId>mySQL</groupId>
            <artifactId>mySQL-connector-java</artifactId>
            <version>5.1.47</version>
          </dependency>
          <!--mybatis-->
          <dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis</artifactId>
            <version>3.5.2</version>
          </dependency>

          <!--junit-->

          <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>

          </dependency>


        </dependencies>
        <properties>
            <maven.compiler.source>8</maven.compiler.source>
            <maven.compiler.target>8</maven.compiler.target>
        </properties>

    </project>
    ```

### 2.2 创建模块

-   编写mybatis核心配置文件

    ```xml
      <?xml version="1.0" encoding="UTF-8" ?>
    <!DOCTYPE configuration
      PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
      "http://mybatis.org/dtd/mybatis-3-config.dtd">

    <!--核心配置文件-->
    <configuration>
      <environments default="development">
        <environment id="development">
          <transactionManager type="JDBC"/>
          <dataSource type="POOLED">
            <property name="driver" value="com.mySQL.jdbc.Driver"/>
            <property name="url" value="jdbc:mySQL://localhost:3306/mybatis?useSSL=true&amp;useUnicode=true&amp;characterEncoding=UTF-8"/>
            <property name="username" value="root"/>
            <property name="password" value="请输入你的密码"/>
          </dataSource>
        </environment>
      </environments>
    <!--每一个Mapper.XML都需要在Mybatis核心配置文件中注册-->
      <mappers>
        <mapper resource="com/hyf/dao/UserMapper.xml"></mapper>
      </mappers>
    </configuration>


    ```

-   编写mybatis工具类

    ```java
    package com.hyf.utils;

    import com.mySQL.jdbc.interceptors.SessionAssociationInterceptor;
    import org.apache.ibatis.io.Resources;
    import org.apache.ibatis.session.SQLSession;
    import org.apache.ibatis.session.SQLSessionFactory;
    import org.apache.ibatis.session.SQLSessionFactoryBuilder;

    import java.io.InputStream;

    public class MybatisUtils {
      private static  SQLSessionFactory SQLSessionFactory;
      static  {

        InputStream inputStream = null;
        try {
          //使用mybatis第一步：获取SQLSessionFactory对象
          String resource = "org/mybatis/example/mybatis-config.xml";
          inputStream = Resources.getResourceAsStream(resource);
          SQLSessionFactory = new SQLSessionFactoryBuilder().build(inputStream);
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
      //既然有了 SQLSessionFactory，顾名思义，
      // 我们可以从中获得 SQLSession 的实例。
      // SQLSession 提供了在数据库执行 SQL 命令所需的所有方法。
      // 你可以通过 SQLSession 实例来直接执行已映射的 SQL 语句。
      // 例如：
      public static SQLSession getSQLSession(){
        return SQLSessionFactory.openSession();
      }
      
    }
    ```

### 2.3 编写代码

-   实体类

    ```java
    package com.hyf.pojo;

    public class User {
      private int id;
      private String name;
      private String pwd;

      public User() {
      }

      public User(int id, String name, String pwd) {
        this.id = id;
        this.name = name;
        this.pwd = pwd;
      }

      public int getId() {
        return id;
      }

      public void setId(int id) {
        this.id = id;
      }

      public String getName() {
        return name;
      }

      public void setName(String name) {
        this.name = name;
      }

      public String getPwd() {
        return pwd;
      }

      public void setPwd(String pwd) {
        this.pwd = pwd;
      }

      @Override
      public String toString() {
        return "User{" +
          "id=" + id +
          ", name='" + name + '\'' +
          ", pwd='" + pwd + '\'' +
          '}';
      }
    }
    ```

-   Dao接口

    ```java
    public interface UserDao {
      List<User> getUserList();
    }

    ```

-   接口实现类由原来的UserDaoImpl转换为一个Mapper配置文件

    ```xml
    <?xml version="1.0" encoding="UTF-8" ?>
    <!DOCTYPE mapper
      PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
      "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <!--namespace=绑定一个对应的Dao/Mapper接口-->
    <mapper namespace="com.hyf.dao.UserDao">
      <!--查询语句-->
      <select id="getUserList" resultMap="com.hyf.pojo.User">

        select * from mybatis.user
      </select>
    </mapper>
    ```

### 2.4 测试

注意点：`org.apache.ibatis.binding.BindingException: Type interface com.hyf.dao.UserDao is not known to the MapperRegistry.`

**MapperRegistry**

核心配置文件中注册Mappers:复制到pom.xml

```xml
  <!--在maven中配置resource，来防止资源导出失败问题-->
  <build>
    <resources>
      <resource>
        <directory>src/main/resources</directory>
        <includes>
          <include>**/*.properties</include>
          <include>**/*.xml</include>
        </includes>
        <filtering>true</filtering>
      </resource>
      <resource>
        <directory>src/main/java</directory>
        <includes>
          <include>**/*.properties</include>
          <include>**/*.xml</include>
        </includes>
        <filtering>true</filtering>
      </resource>

    </resources>
  </build>
```

`### Cause: org.apache.ibatis.builder.BuilderException: Error parsing SQL Mapper Configuration. Cause: java.io.IOException: Could not find resource com/hyf/dao/UserMapper.xml`

可以clean Maven，然后把mybatis-config.xml中的resource路径从“com.hyf.dao/UserMapper改为com/hyf/dao/UserMapper.xml”

junit测试：

```java
package com.hyf.dao;

import com.hyf.pojo.User;
import com.hyf.utils.MybatisUtils;
import org.apache.ibatis.session.SQLSession;
import org.junit.Test;

import java.util.List;

public class UserDaoTest {
  @Test
  public void test(){
    //1。获得SQLSession对象
    SQLSession SQLSession   = MybatisUtils.getSQLSession();

    //2.执行SQL
    //方法1：getMapper
    UserDao mapper = SQLSession.getMapper(UserDao.class);
    List<User> userList = mapper.getUserList();

    for (User user : userList) {
      System.out.println(user);
    }

    //关闭SQLSession
    SQLSession.close();
  }
}
```

***

**可能会遇到的问题**

1.  配置文件没有注册

2.  绑定接口错误

3.  方法名不对

4.  返回类型不对

5.  Maven导出资源问题

## 3. CRUD Boy's work

### 3.1 namespace

`namaspace中的包名要和Mapper接口中的包名一致！namespace用包名.而不是/`

### 3.2 select

选择，查询语句

-   id:就是对应的namespace中的方法名

-   resultType：SQL语句执行的返回值！

-   parameterType

1.  编写接口

    ```java
    User getUserById(int id);
    ```

2.  编写对应中mapper的语句

    ```xml
    <select id="getUserById" parameterType="int" resultType="com.hyf.pojo.User">
      select * from mybatis.user where id = #{id};
    </select>
    ```

3.  测试

    ```java

        public void test2(){
          SQLSession SQLSession = MybatisUtils.getSQLSession();
          User user = mapper.getUserById(2);
          System.out.println(user);
        }

    ```

### 3.3 insert

### 3.4 update

### 3.5 delete

**注意增删改需要提交事务**

### 3.6 分析错误

1.  标签不要匹配错

2.  resource绑定mapper，需要使用路径

3.  程序配置文件必须符合规范

4.  NullPointerException没有注册到资源

5.  输出的xml文件中存在乱码问题

6.  maven资源没有导出问题

### 3.7 万能Map

假如我们的实体类，或者数据库中的表，字段或者参数过多，我们可以使用Map或者注解

### 3.8 模糊查询

1.  Java代码执行的时候，传递通配符 % %

2.  在SQL拼接使用通配符

    ```SQL
      select * from mybatis.user where name like "%"#{value}"%"
    ```

## 4. 配置解析

### 4.1 核心配置文件

-   mybatis-config.xml

-   Mybatis的配置文件包含了会深深影响Mybatis行为的设置和属性信息。
    ![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-01-17_19-23-29.jpg?raw=true)

### 4.2 环境配置（environments）

MyBatis 可以配置成适应多种环境，**不过要记住：尽管可以配置多个环境，但每个 SQLSessionFactory 实例只能选择一种环境**。学会使用配置多套运行环境

Mybatis默认事务管理器是JDBC，连接池：POOLED

### 4.3 属性（properties）

我们可以通过properties属性实现引用配置文件

这些属性都是可外部配置且可动态替换的，既可以在典型的 Java 属性文件中配置这些属性，也可以在 properties 元素的子元素中设置。\[db.properties]

![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-01-17_19-59-31.jpg?raw=true)
编写一个配置文件：

db.properties

```properties
driver=com.mySQL.jdbc.Driver
url=jdbc:mySQL://localhost:3306/mybatis?useSSL=true&useUnicode=true&characterEncoding=UTF-8
username=root
password=输入你的密码
```

```xml
<properties resource="db.properties">
  <property name="username" value="dev_user"/>
  <property name="password" value="F2Fa3!33TYyg"/>
 </properties>
```

-   可以直接引入外部文件

-   可以在其中增加一些属性

-   如果两个方法冲突，优先使用外部配置文件的！

### 4.4 类型别名（typeAliases）

-   类的别名是为Java类设置一个短的名字

-   存在的意义仅用来减少类完全限定名的冗余

-   可以给实体类取别名

-   可以给实体类的包取别名

```xml
  <!--可以给实体类取别名 -->
  <!--可以给实体类的包取别名-->
  <typeAliases>
    <typeAlias type="com.hyf.pojo.User" alias="User" />
    <package name="com.hyf.pojo"/>
  </typeAliases>
```

在实体类比较少的时候使用第一种方法，实体类比较多建议用第二种。但是第一种方法可以自定义，第二种不行（如果非要改，需要在实体类上增加注解`@Alias"别名"`

### 4.5 设置

这是 MyBatis 中极为重要的调整设置，它们会改变 MyBatis 的运行时行为。 下表描述了设置中一些设置的含义、默认值等。
![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-01-17_20-47-56.jpg?raw=true)

### 4.6 其他配置

-   typeHandlers（类型处理器）

-   objectFactory（对象工厂）

-   plugins（插件）

    -   mabatis-generator-core

    -   mybatis-plus

    -   通用mapper

### 4.7映射器（mappers）

MappersRegistry:注册绑定我们的Mapper文件

-   方法1：

    ```xml
      <mappers>
        <mapper class="com.hyf.dao.UserMapper"></mapper>
      </mappers>
    ```

-   方法2:使用class文件注册绑定

    ```xml
        <mappers>
        <mapper class="com.hyf.dao.UserMapper"></mapper>
      </mappers>
    ```

    注意点：

    -   接口和他的Mapper配置文件必须同名

    -   接口和他的Mapper配置文件必须在同一个包下

\-方法3:使用扫描包进行注入绑定

```
`<package name="com.hyf.dao"/>`

 
```

注意点：

-   接口和他的Mapper配置文件必须同名

-   接口和他的Mapper配置文件必须在同一个包下

### 4.8 生命周期和作用域

不同作用域和生命周期类别是至关重要的，因为错误的使用会导致非常严重的**并发问题**。

**SQLSessionFactoryBuilder**

-   一旦创建了 SQLSessionFactory，就不再需要它了

-   局部变量

**SQLSessionFactory**

-   说白了可以想象为数据库连接池

-   SQLSessionFactory一旦被创建就应该在应用的运行期间一直存在，**没有任何理由丢弃它或者重新创建另一个实例**

-   SQLSessionFactory 的最佳作用域是应用作用域。 有很多方法可以做到。

-   最简单的就是使用单例模式或者静态单例模式。

**SQLSession**

-   连接到连接池的一个请求！

-   。SQLSession 的实例不是线程安全的，因此是不能被共享的，所以它的最佳的作用域是请求或方法作用域。

-   用完关闭，否则资源被占用

![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-01-17_22-04-56.jpg?raw=true)
这里面每一个Mapper，就代表一个具体的业务。

## 5. 解决属性名和字段名不一致的问题

### 5.1 问题

新建一个项目，拷贝之前的，测试实体类字段不一致的问题。

把User类中的`pwd`改成`password`,

测试出现问题
![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-01-17_22-45-11.jpg?raw=true)

**解决方法**

-   起别名

    ```SQL
      select id, name, pwd as password from mybatis.user where id = #{id};
    ```

### 5.2 resultMap

结果集映射

```
id name pwd
id name password
```

-   `resultMap` 元素是 MyBatis 中最重要最强大的元素。

-   ResultMap 的设计思想是，对简单的语句做到零配置，对于复杂一点的语句，只需要描述语句之间的关系就行了

-   ResultMap 的优秀之处——你完全可以不用显式地配置它们。

-   如果这个世界总是这么简单就好了。

## 6. 日志

### 6.1 日志工厂

如果一个数据库操作出现了异常，我们需要排错，日志就是最好的助手

曾经：sout、debug

现在：日志工厂

![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-01-17_20-47-56.jpg?raw=true)

-   SLF4J

-   LOG4J(deprecated since 3.5.9) 【掌握】

-   LOG4J2

-   JDK\_LOGGING

-   COMMONS\_LOGGING

-   STDOUT\_LOGGING  【掌握】

-   NO\_LOGGING

在Mybatis中具体使用哪一个日志实现，在设置中设定。

**STDOUT\_LOGGING 标准日志输出**

在mybatis核心配置文件中，配置我们的日志

```xml
  <settings>
    <setting name="logImpl" value="STDOUT_LOGGING"/>

  </settings>
```

![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-01-18_00-33-32.jpg?raw=true "log4j在控制台的输出")

### 6.2 LOG4J

What is Log4j

-   Apache Log4j是一个基于Java的日志记录工具。

-   可以控制每一条日志的输出格式

-   通过定义每一条日志信息的级别，我们能够更加细致地控制日志的生成过程

-   配置文件来灵活地进行配置，而不需要修改应用的代码。

1.  先导入log4j的包

    ```xml
    <!-- https://mvnrepository.com/artifact/log4j/log4j -->
    <dependency>
        <groupId>log4j</groupId>
        <artifactId>log4j</artifactId>
        <version>1.2.17</version>
    </dependency>
    ```

2.  log4j.properties

    ```xml
    #将等级为DEBUG的日志信息输出到console和file这两个目的地，console和file的定义在下面的代码
    log4j.rootLogger=DEBUG,console,file

    #控制台输出的相关设置
    log4j.appender.console = org.apache.log4j.ConsoleAppender
    log4j.appender.console.Target = System.out
    log4j.appender.console.Threshold=DEBUG
    log4j.appender.console.layout = org.apache.log4j.PatternLayout
    log4j.appender.console.layout.ConversionPattern=[%c]-%m%n

    #文件输出的相关设置
    log4j.appender.file = org.apache.log4j.RollingFileAppender
    log4j.appender.file.File=./log/kuang.log
    log4j.appender.file.MaxFileSize=10mb
    log4j.appender.file.Threshold=DEBUG
    log4j.appender.file.layout=org.apache.log4j.PatternLayout
    log4j.appender.file.layout.ConversionPattern=[%p][%d{yy-MM-dd}][%c]%m%n

    #日志输出级别
    log4j.logger.org.mybatis=DEBUG
    log4j.logger.java.SQL=DEBUG
    log4j.logger.java.SQL.Statement=DEBUG
    log4j.logger.java.SQL.ResultSet=DEBUG
    log4j.logger.java.SQL.PreparedStatement=DEBUG
    ```

3.  配置log4j为日志的实现

    ```xml
     <settings>
        <setting name="logImpl" value="LOG4J"/>

      </settings>
    ```

4.  Log4j的使用

<!---->

1.  在要使用的Log4J的类中导入包 org.apache.log4j.Logger;

2.  日志对象加载参数为当前类的class`static Logger logger = Logger.getLogger(UserDaoTest.class);   `

3.  日志级别

    ```arduino
    [INFO][22-01-18][com.hyf.dao.UserDaoTest]info：进入了testLog4J
    [DEBUG][22-01-18][com.hyf.dao.UserDaoTest]debug:进入了testLog4J
    [ERROR][22-01-18][com.hyf.dao.UserDaoTest]error:进入了testLog4J
    ```

## 7. 分页

-   分页可以减少数据的处理量

### \*\* 7.1 使用limit分页\*\*

```SQL
select * from limit startIndex,pageSize;
```

**使用Mybatis实现分页，核心SQL**

1.  接口

    ```java
    List<User> getUserByLimit(Map<String, Integer> map);
    ```

2.  Mapper.xml

    ```xml
    <!--分页-->
    <select id="getUserByLimit" parameterType="map" resultMap="UserMap">
      select * from mybatis.user limit #{startIndex},#{pageSize}
    </select>
    ```

3.  测试

    ```java
    public void test03(){
      SQLSession SQLSession = MybatisUtils.getSQLSession();
      UserMapper mapper = SQLSession.getMapper(UserMapper.class);

      HashMap<String, Integer> map = new HashMap<>();
      map.put("startIndex",0);
      map.put("pageSize",2);
      List<User> users = mapper.getUserByLimit(map);
      for (User user : users) {
        System.out.println(user);
      }


      SQLSession.close();


    }
    ```

### 7.2 RowBounds分页

不再使用SQL实现分页

1.  接口

    ```java
    List<User> getUserByRowBounds();
    ```

2.  mapper.xml

    ```xml
    <!--分页2-->
    <select id="getUserByRowBounds"  resultMap="UserMap">
      select * from mybatis.user
    </select>
    ```

3.  测试

    ```java
    @Test
    public void test04(){
      SQLSession SQLSession = MybatisUtils.getSQLSession();

      //RowBounds实现
      RowBounds rowBounds = new RowBounds(1, 2);

      //通过Java代码层面实现分页
      List<User> users = SQLSession.selectList("com.hyf.dao.UserMapper.getUserByRowBounds",null,rowBounds );

      for (User user : users) {
        System.out.println(user);
      }

      SQLSession.close();
    }
    ```

### 7.3 Mybatis分页插件：PageHelper

[PageHelper网站]()

了解即可

## 8. 使用注解开发

### 8.1 面向接口编程

根本原因 ：**解耦**

**关于接口更深层次的理解**

-   定义（规范、约束）与实现的分离

-   接口的本身反映了系统设计人员对系统的抽象理解

-   接口有两类

    -   第一类是对一个个体的抽象，它可对应为一个抽象体（abstract class）

    -   第二类是对一个个体某一方面的抽象，形成一个抽象面（interface）

-   一个个体可能有多个抽象面，抽象体和抽象面是有区别的

### 8.2 使用注解开发

1.  注解就在接口上实现

    ```java
    @Select("select * from mybatis.user")
    List<User> getUsers();
    ```

2.  需要在核心配置文件中绑定接口

    ```xml
    <!--绑定接口 -->
    <mappers>
      <mapper class="com.hyf.dao.UserMapper"/>
    </mappers>

    ```

3.  测试

本质：反射机制实现

底层：动态代理

**Mybatis详细执行流程**

![](https://github.com/Missyesterday/Picture/blob/main/IMG_8426.jpg?raw=true)

### 8.3 注解CRUD

我们可以在工具类创建的时候自动提交事务&#x20;

```java

public static SQLSession getSQLSession(){
  return SQLSessionFactory.openSession(true);

}

```

编写接口，增加注解

```java
@Select("select * from mybatis.user")
List<User> getUsers();


//方法存在多个参数，所有的基本类型参数参数前面必须加上@Param注解
@Select("select * from user where id = #{id}")
User getUserById(@Param("id") int id);

@Insert("insert into user(id,name,pwd) values (#{id},#{name},#{password})")
int addUser(User user);

@Update("update user set name=#{name},pwd=#{password} where id = #{id}")
int updateUser(User user);

@Delete("delete from user where id = #{id}")
int deleteUser(@Param("id") int id);
```

测试类

注意：必须要将接口注册到核心配置文件中

### 8.4 关于@Param()注解

-   基本类型的参数或者String类型，需要加上

-   引用类型不用加

-   如果只有一个基本类型，可以忽略，但是建议加上

-   在SQL中引用的就是的@Param()中设定的属性名

**#{}和\${}区别**

能用#尽量用#，用\$不安全

## 9.  Lombok

Project Lombok是一个java库，它会自动插入编辑器并构建工具，为您的java增添趣味。

再也不用编写另一个getter或equals方法，使用一个注解，您的类有一个功能齐全的构建器，自动生成日志变量等。

使用步骤：

1.  在IDEA中安装lombok插件

2.  在项目中导入Lombok的jar包

    `<!-- https://mvnrepository.com/artifact/org.projectlombok/lombok -->`

    `<dependency>`

    `    <groupId>org.projectlombok</groupId>`

    `    <artifactId>lombok</artifactId>`

    `    <version>1.18.10</version>`

    `    <scope>provided</scope>`

    `</dependency>`

3.  注解含义

    ```
    @Data：无参构造、get、set、toString、hascode、equals
    @AllArgsConstructor
    @NoArgsConstructor
    ```

## 10.  多对一处理

多对一：

-   多个学生，对应一个老师

-   对于学生这边而言，关联 ：多个学生关联一个老师（多对一）

-   对于老师而言，集合：一个老师，有多个学生

SQL：

```SQL
CREATE TABLE `teacher` (
  `id` INT(10) NOT NULL,
  `name` VARCHAR(30) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8

INSERT INTO teacher(`id`, `name`) VALUES (1, 秦老师); 

CREATE TABLE `student` (
  `id` INT(10) NOT NULL,
  `name` VARCHAR(30) DEFAULT NULL,
  `tid` INT(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fktid` (`tid`),
  CONSTRAINT `fktid` FOREIGN KEY (`tid`) REFERENCES `teacher` (`id`)
) ENGINE=INNODB DEFAULT CHARSET=utf8INSERT INTO `student` (`id`, `name`, `tid`) VALUES (1, 小明, 1); 
INSERT INTO `student` (`id`, `name`, `tid`) VALUES (2, 小红, 1); 
INSERT INTO `student` (`id`, `name`, `tid`) VALUES (3, 小张, 1); 
INSERT INTO `student` (`id`, `name`, `tid`) VALUES (4, 小李, 1); 
INSERT INTO `student` (`id`, `name`, `tid`) VALUES (5, 小王, 1);
```

**测试环境搭建**

1.  导入Lombok

2.  新建实体类Teacher，Student

3.  建立Mapper接口

4.  建立Mapper.xml文件

5.  在核心配置文件中绑定注册我们的Mapper接口或者文件【方式很多】

6.  测试查询是否能成功

### **10.1 按照查询嵌套处理**

```xml
  <!--思路
      1。查询所有的学生信息
      2。根据查询出来的学生的tid寻找对应的老师

  -->

  <select id="getStudents" resultMap="StudentTeacher">
    select * from mybatis.student
  </select>

  <resultMap id="StudentTeacher" type="Student">
    <result property="id" column="id"/>
    <result property="name" column="name"/>
    <!--复杂的属性，需要单独处理  对象：association  集合：collection

  -->
    <association property="teacher" column="tid" javaType="Teacher" select="getTeacher"/>
  </resultMap>


  <select id="getTeacher" resultType="Teacher">
    select * from mybatis.teacher where id = #{id}
  </select>
```

### **10.2 按照结果嵌套处理**

```xml
<select id="getStudents2" resultMap="StudentTeacher2">
  select s.id sid,s.name sname,t.name tname
  from mybatis.student s, mybatis.teacher t
  where s.tid = t.id
</select>

<resultMap id="StudentTeacher2" type="Student">
  <result property="id" column="sid"/>
  <result property="name" column="sname"/>
  <association property="teacher" javaType="Teacher">
    <result property="name" column="tname"></result>
  </association>

</resultMap>
```

## 11. 一对多处理

比如：一个老师拥有多个学生！

对于老师而言，就是一对多的关系

首先搭建环境

```java

@Data
public class Student {
  private int id;
  private String name;

  private int tid;
}
@Data
public class Teacher {
  private int id;
  private String name;

  //一个老师拥有多个学生
  private List<Student> students;
}
```

### 11.1 按照结果嵌套处理

```xml
<!--按结果嵌套查询-->
<select id="getTeacher" resultMap="TeacherStudent">
  select s.id sid,s.name sname,t.name tname, t.id tid
  from mybatis.student s,mybatis.teacher t
  where s.tid = t.id and t.id = #{tid}

</select>
<resultMap id="TeacherStudent" type="Teacher">
  <result property="id" column="tid"></result>
  <result property="name" column="tname"></result>
  <!--集合用collection
  javaType=""指定的属性类型
  集合中的泛型信息，我没用ofType获取
  -->
  <collection property="students" ofType="Student">
    <result property="id" column="sid"></result>
    <result property="name" column="sname"></result>
    <result property="tid" column="tid"></result>
  </collection>
</resultMap>
```

### 11.2 按照查询嵌套处理

```xml
<select id="getTeacher2" resultMap="TeacherStudent2">
  select * from  mybatis.teacher where id = #{tid}
</select>
<!--长得一样的可以省略-->
<resultMap id="TeacherStudent2" type="Teacher">
  <collection property="students" column="id" javaType="ArrayList" ofType="Student" select="getStudentByTeacherId" ></collection>

</resultMap>
<select id="getStudentByTeacherId" resultType="Student">
  select * from mybatis.student where tid=#{tid}
</select>
```

### 11. 3 小结

1.  关联-association  \[多对一]

2.  集合-collection   \[一对多

3.  javaType & ofType

    1.  javaType用来指定实体类中属性的类型

    2.  ofType用来指定映射到List或者集合中的pojo类型，泛型中的约束类型

4.  注意点

    1.  保证SQL可读性，通俗易懂

    2.  注意一对多和多对一中，属性名和字段的问题

    3.  如果问题不好排查错误，可以使用日志，建议使用Log4J

\*\*慢SQL   1s vs 1000s \*\*

**高频问题**

-   MySQL引擎

-   InnoDB底层原理

-   索引

-   索引优化

## 12.  动态SQL

**动态SQL：根据不同的条件生成不同的SQL语句**

-   if

-   choose (when, otherwise)

-   trim (where, set)

-   foreach

### 12.1 搭建环境

```sql
CREATE TABLE `blog`(
                     `id` VARCHAR(50) NOT NULL COMMENT '博客id',
                     `title` varchar(100) NOT NULL COMMENT '博客标题',
                     `author` varchar(30) NOT NULL COMMENT '博客作者',
                     `create_time` datetime NOT NULL COMMENT '创建时间',
                     `views` int(30) NOT NULL COMMENT '浏览量'
)ENGINE=INNODB DEFAULT CHARSET=utf8
```

1.  导包

2.  编写配置文件

3.  编写Blog实体类

4.  编写实体类对应的Mapper接口和Mapper对应的xml文件

### 12.2  if标签

```xml
<select id="queryBlogIF" parameterType="map" resultType="Blog">
  select * from mybatis.blog where 1=1
  <if test="title != null">
    and title = #{title}
  </if>
  <if test="author != null">
    and author = #{author}
  </if>
</select>
```

### 12.3 choose、when、otherwise)标签

```xml
<select id="queryBlogChoose" parameterType="map" resultType="blog">
  select * from mybatis.blog
  <where>
    <choose>
      <when test="title != null">
        title = #{title}
      </when>
      <when test="author != null">
        and author = #{author}
      </when>
      <otherwise>
        and views = #{views}
      </otherwise>
    </choose>
  </where>
</select>
```

### 12.4 trim(where,set)

```xml
<select id="queryBlogIF" parameterType="map" resultType="Blog">
  select * from mybatis.blog
  <where>
    <if test="title != null">
      title = #{title}
    </if>
    <if test="author != null">
      and author = #{author}
    </if>
  </where>
</select>
```

```xml
<update id="updateBlog" parameterType="map" >
  update mybatis.blog
  <set>
      <if test="title != null">
          title = #{title},
      </if>
      <if test="author != null">
       author = #{author}
      </if>
  </set>
where id = #{id}
</update>
```

**所谓的动态SQL，本质还是SQL语句，只是我们在SQL层面，去执行一个逻辑代码。**

### 12.4 SQL片段

有的时候，我们可能会将一些公共的部分抽取出来

1.  使用SQL标签抽取公共部分

    ```xml
    <sql id="if-title-author">
       <if test="title != null">
          title = #{title}
       </if>
       <if test="author != null">
          and author = #{author}
       </if>
    </sql>
    ```

2.  在需要使用的地方使用include标签引用即可

    ```xml
    <select id="queryBlogIF" parameterType="map" resultType="blog">
        select * from mybatis.blog
    <where>
        <include refid="if-title-author"></include>
    </where>
    </select>
    ```

注意事项：

-   最好基于单表来定义SQL片段

-   不要存在where标签

### 12.5 foreach

```xml
select * from user where 1=1 and 
 <foreach item="id"  collection="ids"
        open="(" separator="," close=")" >
          #{id}
    </foreach>

(id=1 or id=2 or id=3)
```

\
![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-01-20_15-57-46.jpg?raw=true)

```xml
<!--传递一个万能map，这个map中可以存在一个集合-->
<select id="queryByForeach" parameterType="map" resultType="blog">
   select * from mybatis.blog
   <where>
      <foreach collection="ids" item="id" open="and (" separator="or" close=")">
         id =#{id}
      </foreach>
   </where>
</select>
```

**动态SQL就是在拼接SQL语句，我们只要保证SQL的正确性，按照SQL的格式，去排列组合就可以了。**

建议：

-   先在MySQL中写出完整的SQL后，再拼接

## 13. 缓存

### 13.1 简介

查询需要链接数据库，比较消耗资源。我们可以把一次查询的结果，暂存在内存中（缓存）

我们再次查询相同数据的时候，直接走缓存，就不用走数据库了

1.  什么是缓存

    -   在内存中的临时数据

    -   将用户经常查询的数据放在缓存中，用户去查询数据就不用从磁盘上（关系型数据库数据文件）查询，从缓存中查询，从而提高查询效率，解决了高并发系统的性能问题。

2.  为什么使用缓存

    -   减少和数据库的交互次数，减少系统开销，提高系统效率

3.  什么样的数据能使用缓存

    -   经常查询并且不经常改变的数据

### 13.2 Mybatis缓存

-   Mybatis包含了一个非常强大的查询缓存特性，它可以非常方便地定制和配置缓存。缓存可以极大的提升查询效率

-   Mybatis系统中默认定义了两级缓存：**一级缓存**和**二级缓存**

    -   默认情况下，只有一级缓存开启（SqlSession级别的缓存，也称为本地缓存）

    -   二级缓存需要手动开启和配置，他是基于namespace（一个Mapper或接口）级别的缓存

    -   为了提高扩展性，Mybatis定义了缓存接口Cache。我们可以通过实现Cache接口来自定义二级缓存

-   LRU和FIFO策略，默认使用LRU（Least Recently Used）策略来刷新

### 13.3 一级缓存

-   一级缓存也叫本地缓存

    -   与数据库同一次会话期间查询到的数据会放在本地缓存中。

    -   以后如果需要获取相同的数据，直接从缓存中拿，没必要再去查询数据库

测试步骤：

1.  开启日志

2.  测试在一个Session中查询两次相同的记录

3.  查看日志输出

\
![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-01-20_17-37-54.jpg?raw=true)缓存失效的情况：

1.  增删改操作可能会改变原来的数据，所有必定会刷新缓存

2.  查询不同的东西，缓存失效

3.  查询不同的Mapper.xml

4.  手动清理缓存（此时两个user==为false)

    ```java
    SqlSession sqlSession = MybatisUtils.getSqlSession();
    UserMapper mapper = sqlSession.getMapper(UserMapper.class);
    User user = mapper.queryUserById(1);
    System.out.println(user);

    System.out.println("===================================");
    sqlSession.clearCache();//手动清理缓存
    System.out.println("===================================");
    User user3 = mapper.queryUserById(1);
    System.out.println(user==user3);//地址是否相同

    sqlSession.close();
    ```

小结：一级缓存是默认开启的，只在一次SqlSession中有效，也就是拿到连接到关闭连接这个区间段。

一级缓存就是一个Map

### 13.4 二级缓存

-   二级缓存也叫全局缓存，一级缓存作用域太低了，所以诞生了二级缓存

-   基于namespace级别的缓存，一个名称空间，对应一个二级缓存

-   工作机制

    -   一个会话查询一条数据，这个数据就会被放在当前会话的一级缓存中

    -   如果当前会话关闭了，这个会话对应的一级缓存就失效了；但是我们想要的是，会话关闭了，一级缓存中的数据被保存到二级缓存中

    -   新的会话查询信息，就可以从二级缓存中获取内容

    -   不同的mapper查处的数据会放在自己对应的缓存(map)中

步骤：

1.  开启全局缓存

    ```xml
      <!-- 显示的开启全局缓存-->
    <setting name="cacheEnabled" value="true"/>
    ```

2.  在要使用二级缓存的Mapper中开启，可以自定义一些参数

    ```xml
    <!--在当前Mapper.xml中使用二级缓存-->
    <cache eviction="FIFO"
    flushInterval="60000"
    size="512"
    readOnly="true"/>
    ```

3.  测试

    1.  问题：我们需要将实体类序列化，否则就会报错

        `.  Cause: java.io.NotSerializableException: com.hyf.pojo.User  `

小结：

-   只要开启了二级缓存，在同一个Mapper下就有效

-   所有的数据会先放在一级缓存中

-   只有当会话提交，或者关闭的时候，才会提交到二级缓存中

### 13.5 缓存原理

![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-01-20_18-28-46.jpg?raw=true)

\
\\

### 13.6 自定义缓存-ehcache

Ehcache是一种广泛使用的开源Java分布式缓存。主要面向通用缓存

先导包

```xml
<dependency>
   <groupId>org.mybatis.caches</groupId>
   <artifactId>mybatis-ehcache</artifactId>
   <version>1.1.0</version>
</dependency>
```
