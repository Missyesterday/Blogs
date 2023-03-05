# &#x20;Spring5

# 1. Spring

## 1.1 简介

-   Spring:给软件行业带来的春天

-   2002年,首次推出了Spring框架的雏形\:interface21框架

-   Spring框架以interface21框架为基础,重新设计,丰富内涵,与2004年3月24日发布了1.0正式版.

-   Rod Johnson\:Spring创始人,音乐学博士

-   Spring的设计理念:使现有基础更加容易使用,本身是一个大杂烩,整合了现有的技术框架

-   SSH\:Struct2+Spring+Hibernate

-   SSM\:SpringMVC+Spring+Mybatis

官网:<https://spring.io/projects/spring-framework>

官方下载地址: <http://repo.spring.io/release/org/springframework/spring> 

GitHub地址:<https://github.com/spring-projects/spring-framework>

maven

```xml
<!-- https://mvnrepository.com/artifact/org.springframework/spring-webmvc -->
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-webmvc</artifactId>
    <version>5.2.5.RELEASE</version>
</dependency>
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-jdbc</artifactId>
    <version>5.2.5.RELEASE</version>
</dependency>
```

## 1.2 优点

-   Spring是一个开源的免费的容器(框架)

-   Spring是一个轻量级的, 非入侵式的框架

-   控制反转(IOC)和面向切面编程(AOP)

-   支持事务的处理, 对框架整合的支持

总结\:Spring就是一个轻量级的控制反转(IOC)和面向切面编程(AOP)的框架

## 1.3 组成

\
![](https://bbsmax.ikafan.com/static/L3Byb3h5L2h0dHBzL2ltZzIwMTguY25ibG9ncy5jb20vYmxvZy8xODI4ODAxLzIwMTkxMC8xODI4ODAxLTIwMTkxMDE1MjEzNzQ0MDQxLTE4OTYzOTkxNDMucG5n.jpg)

## 1.4 扩展

在Spring的官网的介绍:现代化的Java开发,就是基于Spring的开发

-   Spring Boot

    -   一个快速开发的脚手架

    -   基于Spring Boot可以快速的开发单个微服务

    -   约定大于配置

-   Spring Cloud

    -   Spring Cloud是基于Spring Boot实现的

现在大多数公司都在使用SpringBoot进行快速开发,学习SpringBoot的前提,需要完全掌握Spring及SpringMVC.

弊端:发展太久,违背了原来的理念,配置十分繁琐!"配置地狱"

# 2. IOC理论推导

## 2.1 分析实现

1.  UserDao接口

2.  UserDaoImpl实现类

3.  UserService业务接口

4.  UserServiceImpl业务实现类

在我们之前的业务中,用户的需求可能影响原来的代码,我们需要根据用户的需求去修改源代码!如果程序代码量十分大,修改一次的成本代价十分昂贵.

我们使用一个Set接口实现:已经发生了革命性的变化

```java
private UserDao userDao;

//利用set进行动态实现值的注入:
public void setUserDao(UserDao userDao){
    this.userDao = userDao;
}
```

-   之前程序主动创建对象,控制权在程序员手上

-   使用了set注入后,程序不再具有主动性,而是变成了控制程序的对象

这种思想从本质上解决了问题,程序员不用去管理对象的创建了,系统的耦合性大大降低. 可以更加专注在业务的实现上! 这就是IOC的原型.&#x20;

\\

## IoC本质

**控制反转IoC(Inversion of Control)，是一种设计思想，DI(依赖注入)是实现IoC的一种方法**，也有人认为DI只是IoC的另一种说法。没有IoC的程序中 , 我们使用面向对象编程 , 对象的创建与对象间的依赖关系完全硬编码在程序中，对象的创建由程序自己控制，控制反转后将对象的创建转移给第三方，个人认为所谓控制反转就是：获得依赖对象的方式反转了。

![](https://kuangstudy.oss-cn-beijing.aliyuncs.com/bbs/2021/04/13/kuangstudy710f2555-730a-45a2-9062-b9612520e73c.png)

采用XML方式配置Bean的时候，Bean的定义信息是和实现分离的，而采用注解的方式可以把两者合为一体，Bean的定义信息直接以注解的形式定义在实现类中，从而达到了零配置的目的。

**控制反转是一种通过描述（XML或注解）并通过第三方去生产或获取特定对象的方式。在Spring中实现控制反转的是IoC容器，其实现方法是依赖注入（Dependency Injection,DI）。**

# 3. HelloSpring

## 3.1 导入jar包

```xml
	<dependencies>
		<!-- https://mvnrepository.com/artifact/org.springframework/spring-webmvc -->
		<dependency>
			<groupId>org.springframework</groupId>
			<artifactId>spring-webmvc</artifactId>
			<version>5.2.5.RELEASE</version>
		</dependency>
	</dependencies>
```

## 3.2 编写代码

编写一个Hello实体类

```java
public class Hello {
    private String name;
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public void show(){
        System.out.println("Hello,"+ name );
    }
}
```

编写beans.xml

```xml
<bean id = "mysqlImpl" class = "com.hyf.dao.UserDaoMysqlImpl"/>
	<bean id = "oracleImpl" class = "com.hyf.dao.UserDaoOracleImpl"/>

	<bean id = "UserServiceImpl" class = "com.hyf.service.UserServiceImpl">
		<!--
		ref :引用Spring容器中创建好的对象'
		value:具体的值,基本数据类型
		-->
		<property name="userDao" ref="oracleImpl">
		</property>

	</bean>
```

测试

```java
@Test
public void test(){
    //解析beans.xml文件 , 生成管理相应的Bean对象
    ApplicationContext context = new ClassPathXmlApplicationContext("beans.xml");
    //getBean : 参数即为spring配置文件中bean的id .
    Hello hello = (Hello) context.getBean("hello");
    hello.show();
}
```

## 3.3 思考

-   Hello 对象是谁创建的 ? 【 hello 对象是由Spring创建的 】

-   Hello 对象的属性是怎么设置的 ? 【hello 对象的属性是由Spring容器设置的 】

这个过程就叫控制反转 : 

-   控制 : 谁来控制对象的创建 , 传统应用程序的对象是由程序本身控制创建的 , 使用Spring后 , 对象是由Spring来创建的 

-   反转 : 程序本身不创建对象 , 而变成被动的接收对象 .

依赖注入 : 就是利用set方法来进行注入的.

\==IOC是一种编程思想，由主动的编程变成被动的接收==

可以通过newClassPathXmlApplicationContext去浏览一下底层源码 .

# &#x20;4. IOC创建对象的方式

1.  使用无参构造创建对象,默认

2.  有参构造

    1.  下标赋值

        ```xml
        	<!--第一种:下标赋值-->
        	<bean id="user" class="com.hyf.pojo.User">
        		<constructor-arg index="0" value="何宇凡"/>
        	</bean>
        ```

    2.  类型

        ```xml
        <bean id="user" class="com.hyf.pojo.User">
        ```

    3.  参数名

        ```xml
        	<!--
        	第三种:直接通过参数名
        	-->
        	<bean id="user" class="com.hyf.pojo.User">
        		<constructor-arg name="name" value="张三"/>
        	</bean>
        ```

总结:在配置文件加载的时候,容器中管理的对象就已经初始化了!

# 5. Spring配置

## 5.1 别名

```xml
	<!--别名,如果有别名,我们可以通过别名来获取对象-->
	<alias name="user" alias="zz"/>
```

## 5.2 Bean的配置

```xml

	<!--
	id:bean的唯一标识符,也就是相当于我们学的对象名
	class:bean 对象所对应的全限定名 : 包名+类名
	name:别名,而且name可以同时取多个别名
	-->
	<bean id="userT" class="com.hyf.pojo.UserT" name="user2,u2">
		<constructor-arg name="name" value="hyf"></constructor-arg>
	</bean>
```

## 5.3 import

一般用于团队开发使用,可以将多个配置文件导入合并为一个.

假设项目中有多个人开发,有三个人负责不同的类开发,不同的类注册在不同地bean中,我们可以利用import将所有人的beans.xml合并为一个总的.

```xml
	<import resource="beans.xml"/>
	<import resource="beans2.xml"/>
	<import resource="beans3.xml"/>
```

# 6. DI(依赖注入)

## 6.1 构造器注入

已经学习

## 6.2 Set方式注入\[重点]

-   依赖注入\:Set注入

    -   依赖\:bean对象的创建依赖于容器

    -   注入\:bean对象中所有属性,由容器来注入

\[环境搭建]

1.  复杂类型

    ```java
    public class Address {
        private String address;

        public String getAddress() {
            return address;
        }

        public void setAddress(String address) {
            this.address = address;
        }

        @Override
        public String toString() {
            return "Address{" +
                    "address='" + address + '\'' +
                    '}';
        }
    }
    ```

2.  真实创建对象

    ```java
    public class Student {
        private String name;
        private Address address;
        private String[] books;
        private List<String> hobbies;
        private Map<String, String> card;
        private Set<String> games;
        private String wife;
        private Properties info;
    ```

3.  beans.xml

    ```xml
    		<bean id="address" class="com.hyf.pojo.Address">
    		<property name="address"   value="长沙"></property>
    	</bean>
    	<bean id="student" class="com.hyf.pojo.Student">
    		<!--1.普通值注入, 用value-->
    		<property name="name"   value="何宇凡"/>
    		<!--2.Bean注入, 用ref-->
    		<property name="address"   ref="address"/>
    		<!--3.数组注入, 用array-->
    		<property name="books">
    			<array>
    				<value>红楼梦</value>
    				<value>夜晚的潜水艇</value>
    				<value>黄金时代</value>
    			</array>
    		</property>

    		<!--list-->
    		<property name="hobbies">
    			<list>
    				<value>运动</value>
    				<value>写代码</value>
    				<value>读书</value>
    			</list>
    		</property>
    		<!--Map-->
    		<property name="card">
    			<map>
    				<entry key="身份证" value="4304xxxxxxxxx"></entry>
    				<entry key="学生卡" value="2015666"></entry>
    			</map>
    		</property>

    		<!--Set-->
    		<property name="games">
    			<set>
    				<value>LOL</value>
    				<value>塞尔达</value>
    				<value>健身环</value>
    			</set>
    		</property>

    		<!--Null-->
    		<property name="wife">
    			<null/>
    		</property>

    		<!--Properties-->

    		<property name="info">
    			<props>
    				<prop key="学号">2019543321</prop>
    				<prop key="性别">男</prop>
    				<prop key="姓名">二次元</prop>
    			</props>
    		</property>
    	</bean>
    ```

4.  测试类

    ```java
        public static void main(String[] args) {
            ApplicationContext context = new ClassPathXmlApplicationContext("beans.xml");
            Student student = (Student) context.getBean("student");
            System.out.println(student);

            /*Student{
            name='何宇凡',
            address=Address{address='长沙'},
            books=[红楼梦, 夜晚的潜水艇, 黄金时代],
            hobbies=[运动, 写代码, 读书],
            card={身份证=4304xxxxxxxxx, 学生卡=2015666},
            games=[LOL, 塞尔达, 健身环],
            wife='null',
            info={学号=2019543321, 性别=男, 姓名=二次元}}*/
        }
    ```

## 6.3 拓展方式

可以使用p命名空间和c命名空间进行注入

使用:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:p="http://www.springframework.org/schema/p"
       xmlns:c="http://www.springframework.org/schema/c"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd">

	<!--p命名空间注入,可以注入一些简单的值-->
	<bean id="user" class="com.hyf.pojo.User" p:name="何宇凡" p:age="18"/>

	<!--c命名空间,通过构造器注入-->
	<bean id="user2" class="com.hyf.pojo.User" c:age="19" c:name="何宇凡"/>



</beans>
```

测试:

```java
    @Test
    public void test2(){
        ApplicationContext context = new ClassPathXmlApplicationContext("userbeans.xml");
        User user1 = context.getBean("user2",User.class);
        System.out.println(user1 );
        User user2 = context.getBean("user2",User.class);
        System.out.println(user2 );
    }
```

***

注意点:

p命名和c命名空间不能直接使用,需要导入xml约束

```xml
xmlns:p="http://www.springframework.org/schema/p"
xmlns:c="http://www.springframework.org/schema/c"
```

6.4 bean的作用域\
![](https://github.com/Missyesterday/Picture/blob/main/Xnip2022-01-24_01-58-25.jpg?raw=true)
--------------------------------------------------------------------------------------------

1.  单例模式\:Spring默认机制

    ```xml
    <bean id="user" class="com.hyf.pojo.User" p:name="何宇凡" p:age="18" scope="singleton" />

    ```

2.  原型模式:每次从容器中get的时候都会产生一个新对象

    ```xml
    <bean id="user" class="com.hyf.pojo.User" p:name="何宇凡" p:age="18" scope="prototype" />
    ```

3.  其余的request, session, application这些只能在web开发中使用!

# 7. bean的自动装配

-   自动装配是Spring满足bean依赖的一种方式!

-   Spring会在上下文中自动寻找,并自动给bean装配属性!

在Spring中有三种装配的方式

1.  在xml中显示的配置

2.  在java中显示配置

3.  隐式的自动装配bean\[重要]

## 7.1 测试

1.  环境搭建:一个人有两个宠物

## 7.2 byName自动装配

```xml
	<!--
	byName:会自动在容器上下文中查找,和自己对象set方法后面值相对应的bean id
	-->

	<bean id="person" class="com.hyf.pojo.Person" autowire="byName">
		<property name="name"   value="何宇凡"/>

	</bean>
```

## 7.3 byType自动装配

```xml
	<!--
	byName:会自动在容器上下文中查找,和自己对象属性类型相同的bean,byType甚至可以不用属性的id
	-->

	<bean id="person" class="com.hyf.pojo.Person" autowire="byType">
		<property name="name"   value="何宇凡"/>

	</bean>
```

小结:

-   byName的时候,需要保证需要保证所有bean的id唯一,并且这个bean需要和自动注入的属性的set方法的值一致

-   byType的时候,需要保证需要保证所有bean的class唯一,并且这个bean需要和自动注入的属性的类型一致

## 7.4 使用注解自动装配

jdk1.5支持注解,Spring2.5支持注解

使用注解需要：

1.  导入约束

    ```xml
    xmlns:context="http://www.springframework.org/schema/context"
    ```

2.  配置注解的支持:   ` <context:annotation-config/>`

    ```xml
    <?xml version="1.0" encoding="UTF-8"?>
    <beans xmlns="http://www.springframework.org/schema/beans"
           xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xmlns:context="http://www.springframework.org/schema/context"
           xsi:schemaLocation="http://www.springframework.org/schema/beans
            http://www.springframework.org/schema/beans/spring-beans.xsd
            http://www.springframework.org/schema/context
            http://www.springframework.org/schema/context/spring-context.xsd">
        <context:annotation-config/>
    </beans>

    ```

[@Autowired](https://github.com/Autowired)(required=false) 说明： false，对象可以为null；true，对象必须存对象，不能为null。

```java
//如果允许对象为null，设置required = false,默认为true
@Autowired(required = false)
private Cat cat;
```

如果@Autowired自动装配的环境比较复杂，自动装配无法通过一个注解【@Autowired】完成的时候，我们可以使用@Qualifier(value="xxx")去配置@Autowired的使用，指定一个唯一的bean对象注入

```java
@Autowired
@Qualifier(value = "cat2")
private Cat cat;
@Autowired
@Qualifier(value = "dog2")
private Dog dog;
```

@Resource注解：

-   [@Resource](https://github.com/Resource)如有指定的name属性，先按该属性进行byName方式查找装配；

-   其次再进行默认的byName方式进行装配；

-   如果以上都不成功，则按byType的方式自动装配。

-   都不成功，则报异常。

```java
public class User {
    //如果允许对象为null，设置required = false,默认为true
    @Resource(name = "cat2")
    private Cat cat;
    @Resource
    private Dog dog;
    private String str;
}
```

小结：

@Resource和@Autowired的区别：

-   都是用来自动装配的，都可以放在属性字段上

-   @Autowired通过byType方式实现，而且这个对象必须存在

-   @Resource默认通过byName实现，如果找不到名字，则通过byType实现

-   执行顺序不同

# 8. 使用注解开发

在Spring4之后，使用注解开发，必须保证aop包导入了。使用注解需要在配置文件当中，引入一个context约束。

1.  bean

    配置扫描哪些包下的注解：

    ```xml
    	<context:component-scan base-package="com.hyf.pojo"/>
    ```

    编写类，增加注解

    ```java
    //等价于配置了一个bean
    //@Component 组件
    @Component
    public class User {
        public String name = "何宇凡";
    }

    ```

2.  属性如何注入

    ```java
    //等价于配置了一个bean
    //@Component 组件
    @Component
    public class User {
        //相当于	<bean id="user" class="com.hyf.pojo.User">
        //		<property name="name" value="何"/>
        //	</bean>
        @Value("何")
        public String name;
    }

    ```

3.  衍生的注解

    @Component有几个衍生注解，我们在web开发中，会按照mvc三层架构分层

    -   dao  \[@Repository]

    -   service  \[@Service]

    -   controller  \[@Controller]

        这四个注解功能是一样的，都是代表将某个类注册到Spring容器中，装配bean

4.  自动装配

    @Autowired, @Nullable, @Resource

5.  作用域

    ```java
    @Component
    @Scope("prototype")
    public class User {
        //相当于	<bean id="user" class="com.hyf.pojo.User">
        //		<property name="name" value="何"/>
        //	</bean>
        @Value("何")
        public String name;
    }
    ```

6.  小结

    xml与注解：

    -   xml更加万能，适用于任何场合，维护简单方便

    -   注解 ：不是自己的类，使用不了；维护相对复杂

    xml与注解的最佳实践：

    -   xml来管理bean

    -   注解只负责完成属性的注入

    -   我们在使用的过程中，只需要注意一个问题：必须让注解生效，就需要开启注解的支持

        ```xml
        	<!--指定要扫描的包，这个包下的注解就会生效 -->
        	<context:component-scan base-package="com.hyf.pojo"/>
        	<context:annotation-config></context:annotation-config>
        ```

# 9. 使用Java的方式配置Spring

我们现在要完全不使用Spring的xml配置了，全部交给Java来做！

JavaConfig是Spring的一个子项目，在Spring4之后，它成为了一个核心功能

1.  实体类

```java
//这里这个注解的意思，就是说明这个类被Spring接管了，注册到了容器中
@Component
public class User {
    private String name;

    public String getName() {
        return name;
    }

    @Value("hyf")//属性注入值
    public void setName(String name) {
        this.name = name;
    }
}
```

1.  MyConfig类

```java

//这个也会被Spring容器托管，注册到容器中，因为他本来就是一个@Component
// @Configuration代表这是一个配置类，与beans.xml一样
@Configuration
@ComponentScan("com.hyf.pojo")
@Import(MyConfig2.class)
public class MyConfig {

    //注册一个bean就相当与写了一个bean标签
    //这个方法的名字，就相当于bean标签中的id属性
    //这个方法的返回值，就相当于bean标签中的class属性
    @Bean
    public User getUser(){
        return new User();  //返回注入到bean的对象
    }
}
```

1.  测试类

```java
public class MyTest {
    public static void main(String[] args) {
        //如果完全使用了配置类方式去做，我们就只能通过AnnotationConfigApplicationContext来获取容器，通过配置类的class对象加载
        ApplicationContext context = new AnnotationConfigApplicationContext(MyConfig.class);
        User getUser = (User) context.getBean("getUser");//取的是MyCofig中的方法名
        System.out.println(getUser.getName());
    }
}
```

这种纯Java的配置方式，在SpringBoot中随处可见

# 10.  代理模式

SpringAOP的底层就是代理模式！【SpringAOP和SpringMVC】

代理模式的分类：

-   静态代理

-   动态代理&#x20;

## 10.1 静态代理

角色分析

-   抽象角色

-   真是角色

-   代理角色：代理真实角色，代理真实角色后，我们一般会做一些附属操作

代码步骤：

1.  接口

    ```java
    //租房
    public interface Rent {

        public void rent();
    }
    ```

2.  真实角色

    ```java
    //房东
    public class Host implements Rent{
        @Override
        public void rent() {
            System.out.println("房东要出租房子");
        }
    }

    ```

3.  代理角色

    ```
    public class Proxy implements Rent{
        private Host host;
        public Proxy(){

        }

        public Proxy(Host host) {
            this.host = host;
        }

        @Override
        public void rent() {
            seeHouse();
            host.rent();
            fare();
            hetong();
        }

        //看房
        public void seeHouse(){
            System.out.println("中介带你看房");
        }

        //收中介费
        public void fare(){
            System.out.println("收中介费");
        }

        //收中介费
        public void hetong(){
            System.out.println("签租赁合同");
        }
    }
    ```

4.  客户端访问代理角色

    ```java
    public class Client {
        public static void main(String[] args) {

            //房东要租房子
            Host host = new Host();
            //代理，中介帮房东租房子，但是代理角色一般有一些附属操作
            Proxy proxy = new Proxy(host);

            //不用面对房东，直接找中介租房就行
            proxy.rent();
        }

    }
    ```

代理模式的好处：

-   可以使真实角色的操作更加纯粹，不用去关注一些公共的业务！

-   公共的业务就交给代理角色，实现了业务的分工！

-   公共业务发生扩展的时候，方便集中管理！

缺点：

-   一个真实角色就会产生一个代理角色，代码量增加，开发效率变低

## 10.2 加深理解

代码 ：spring-08-demo02\
![](https://kuangstudy.oss-cn-beijing.aliyuncs.com/bbs/2021/04/13/kuangstudye7b78d74-50d1-4f73-99db-e7e3dc5adef8.png)

## 10.3 动态代理

-   动态代理和静态代理角色一样

-   动态代理的代理类是动态生成的，不是我们写的

-   动态代理分为两大类：基于接口的动态代理和基于类的动态代理

    -   基于接口-JDK动态代理  【我们在这里使用】

    -   基于类：cglib

    -   java字节码实现：javasist

需要了解两个类：proxy和InvocationHandler（调用处理程序）

动态代理的好处：

-   可以使真实角色的操作更加纯粹，不用去关注一些公共的业务！

-   公共的业务就交给代理角色，实现了业务的分工！

-   公共业务发生扩展的时候，方便集中管理！

-   一个动态代理类，一般代理某一类业务（一个接口）

-   一个动态代理类可以代理多个类，只要实现了同一个接口即可

# 11. AOP

## 11.1 什么是AOP

AOP（Aspect Oriented Programming）意为：面向切面编程，通过预编译方式和运行期动态代理实现程序功能的统一维护的一种技术。AOP是OOP的延续，是软件开发中的一个热点，也是Spring框架中的一个重要内容，是函数式编程的一种衍生范型。利用AOP可以对业务逻辑的各个部分进行隔离，从而使得业务逻辑各部分之间的耦合度降低，提高程序的可重用性，同时提高了开发的效率。\
![](https://kuangstudy.oss-cn-beijing.aliyuncs.com/bbs/2021/04/13/kuangstudyfffec70f-ce10-4ca2-a71b-dbc535b0e07c.png)

## 11.2 AOP在Spring中的作用

提供声明式事务：允许用户自定义切面

-   Joinpoint 是所有可能被织入 Advice 的候选的点, 在 Spring AOP中, 则可以认为所有方法执行点都是 Joint point.(包括构造方法调用，字段的设置和获取，方法的调用，方法的执行，异常的处理执行，类的初始化。）**spring只支持方法连接点.**

-   Pointcut归纳定义相应的Join point

-   Pointcut加advice就是aspect



-   advice是一个动作，也就是一段Java代码，作用于point cut限定的Joint point上.它有以下几种类型：

    -   before advice，在join point之前被执行的advice，虽然before advice是在join point之前被执行，但是它并不能阻止join point的执行，除非发生了异常

    -   after return advice,在一个join point正常返回后执行的advice

    -   after throwing advice ，当一个join point 抛出异常后执行的advice

    -   after (final) advice ，当一个join point 无论如何都要执行的advice

    -   around advice，在join point前和join point 退出后都执行的advice，这也是最常用的advice

    -   introduction，它能为原有的对象增加新的属性和方法



-   Target：织入advice的目标对象

-   weaving：将aspect和其他对象连接起来，并创建adviced object的过程

在Spring中，通过**动态代理**和动态字节码技术实现了AOP。

AOP在不改变原有代码的情况下，去增加新的功能

## 11.3 使用Spring实现AOP

【重点】使用AOP织入，需要导入一个依赖包！

```xml
		<!-- https://mvnrepository.com/artifact/org.aspectj/aspectjweaver -->
		<dependency>
			<groupId>org.aspectj</groupId>
			<artifactId>aspectjweaver</artifactId>
			<version>1.9.6</version>
		</dependency>
```

方法1:使用Spring接口【主要是SpringAPI接口实现】

1.  首先编写业务接口和实现类

    ```java
    public interface UserService {
        public void add();
        public void delete();
        public void update();
        public void search();
    }

    public class UserServiceImpl implements UserService{
        @Override
        public void add() {
            System.out.println("增加用户");
        }
        @Override
        public void delete() {
            System.out.println("删除用户");
        }
        @Override
        public void update() {
            System.out.println("更新用户");
        }
        @Override
        public void search() {
            System.out.println("查询用户");
        }
    }
    ```

2.  然后去写我们的增强类 , 我们编写两个 , 一个前置增强 一个后置增强

    ```java
    public class Log implements MethodBeforeAdvice {
        //method : 要执行的目标对象的方法
        //objects : 被调用的方法的参数
        //Object : 目标对象
        @Override
        public void before(Method method, Object[] objects, Object o) throws Throwable {
            System.out.println( o.getClass().getName() + "的" + method.getName() + "方法被执行了");
        }
    }

    public class AfterLog implements AfterReturningAdvice {
        //returnValue 返回值
        //method被调用的方法
        //args 被调用的方法的对象的参数
        //target 被调用的目标对象
        @Override
        public void afterReturning(Object returnValue, Method method, Object[] args, Object target) throws Throwable {
            System.out.println("执行了" + target.getClass().getName()
            +"的"+method.getName()+"方法,"
            +"返回值："+returnValue);
        }
    }
    ```

3.  最后去spring的文件中注册 , 并实现aop切入实现 , 注意导入约束.

    expression:表达式

    ```xml
    expression="execution(* com.hyf.service.UserServiceImpl.*(..))
    ```

    \*都是通配符

    第一个\*表示可以是任意返回值（包括void）

    第二个\*表示包com.hyf.service.UserServiceImpl下的任意方法，可以改成com.hyf.service.UserServiceImpl.insert\*代表这个包下所有以insert开头的方法

    (..)代表这个方法的参数可以是任何参数，也可以没有

    同时，在expression:表达式最前面可以加public等指定public的方法，如expression="execution(public \* com.hyf.service.UserServiceImpl.\*(..))

    ```xml
    	<!--方法1：使用原生的Spring API接口-->
    	<!--配置aop:需要导入aop的约束-->
    	<aop:config>
    		<!--切入点  expression:表达式  execution():要执行的位置-->
    		<aop:pointcut id="pointcut" expression="execution(* com.hyf.service.UserServiceImpl.*(..))"/>

    		<!--执行环绕增强-->
    		<aop:advisor advice-ref="log"  pointcut-ref="pointcut"/>
    		<aop:advisor advice-ref="afterLog" pointcut-ref="pointcut"/>
    	</aop:config>
    ```

4.  测试

    ```java
    public class MyTest {
        public static void main(String[] args) {
            ApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");

            //动态代理代理的是接口
            UserService userService = (UserService) context.getBean("userService");

            userService.add();
        }
    }


    ```

方法2:自定义类实现AOP【主要是切面自定义】

目标业务类不变依旧是userServiceImpl

1.  写我们自己的一个切入类

    ```java
    public class DiyPointcut {
        public void before(){
            System.out.println("---------方法执行前---------");
        }
        public void after(){
            System.out.println("---------方法执行后---------");
        }
    }
    ```

2.  去Spring中配置

    ```xml
    	<!--方法2：自定义类-->
    	<bean id="diy"  class="com.hyf.diy.DiyPointCut"/>
    	<aop:config>
    		<!--自定义切面，ref引用要引用的类-->
    		<aop:aspect ref="diy">
    		<!--切入点-->
    			<aop:pointcut id="point" expression="execution(* com.hyf.service.UserServiceImpl.*(..))"/>

    		<!--通知-->
    			<aop:before method="before" pointcut-ref="point"/>
    			<aop:after method="after" pointcut-ref="point"/>

     		</aop:aspect>
    	</aop:config>
    ```

3.  &#x20;测试

    ```java
    public class MyTest {
        public static void main(String[] args) {
            ApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");

            //动态代理代理的是接口
            UserService userService = (UserService) context.getBean("userService");

            userService.add();
        }
    }
    ```

方法3:使用注解实现

1.  编写一个注解实现的增强类

    ```java
    public class AnnotationPointCut {

        @Before("execution( * com.hyf.service.UserServiceImpl.*(..))")
        public void before(){
            System.out.println("方法执行前");
        }

        @After("execution( * com.hyf.service.UserServiceImpl.*(..))")
        public void after(){
            System.out.println("方法执行后");
        }

        //在环绕增强中，我们可以给定一个参数，代表我们要获取处理切入的点
        @Around("execution( * com.hyf.service.UserServiceImpl.*(..))")
        public void around(ProceedingJoinPoint jp) throws Throwable {
            System.out.println("环绕前");

            Signature signature = jp.getSignature();//获得签名
            System.out.println("signature " + signature);

            //执行方法
            Object proceed = jp.proceed();

            System.out.println("环绕后");

            System.out.println(proceed);
        }

    }
    ```

2.  在Spring配置文件中，注册bean，并增加支持注解的配置

    ```xml
    <!--方法3：-->

    <bean id="annotationPointCut" class="com.hyf.diy.AnnotationPointCut"/>
    <!--开启注解支持  JDK（默认proxy-target-class="false"）  cglib-->
    <aop:aspectj-autoproxy proxy-target-class="true"/>
    ```

# 12. 整合Mybatis

步骤：

1.  导入jar包

    -   junit

    -   mybatis

    -   mysql数据库

    -   spring相关的

    -   aop织入

    -   mybatis-spring【new】

    ```xml
    	<dependencies>
    	<dependency>
    		<groupId>junit</groupId>
    		<artifactId>junit</artifactId>
    		<version>4.12</version>
    		<scope>test</scope>
    	</dependency>
    	<dependency>
    		<groupId>mysql</groupId>
    		<artifactId>mysql-connector-java</artifactId>
    		<version>5.1.47</version>
    	</dependency>
    	<dependency>
    		<groupId>org.mybatis</groupId>
    		<artifactId>mybatis</artifactId>
    		<version>3.5.2</version>
    	</dependency>
    	<dependency>
    		<groupId>org.springframework</groupId>
    		<artifactId>spring-webmvc</artifactId>
    		<version>5.2.5.RELEASE</version>
    	</dependency>
    	<!--Spring操作数据库，还需要spring-jdbc-->
    	<dependency>
    		<groupId>org.springframework</groupId>
    		<artifactId>spring-jdbc</artifactId>
    		<version>5.1.9.RELEASE</version>
    	</dependency>
    	<dependency>
    		<groupId>org.aspectj</groupId>
    		<artifactId>aspectjweaver</artifactId>
    		<version>1.9.6</version>
    	</dependency>
    	<!-- https://mvnrepository.com/artifact/org.mybatis/mybatis-spring -->
    	<dependency>
    		<groupId>org.mybatis</groupId>
    		<artifactId>mybatis-spring</artifactId>
    		<version>2.0.6</version>
    	</dependency>

    </dependencies>
    ```

2.  编写配置文件

3.  测试

## 12.1 回忆mybatis

1.  编写实体类

    ```java

    public class User {
        private int id;  //id
        private String name;   //姓名
        private String pwd;   //密码
    }
    ```

2.  编写MyBatis核心配置文件

    ```java
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
            <property name="driver" value="com.mysql.jdbc.Driver"/>
            <property name="url" value="jdbc:mysql://localhost:3306/mybatis?useSSL=true&amp;useUnicode=true&amp;characterEncoding=UTF-8"/>
            <property name="username" value="root"/>
            <property name="password" value="输入密码"/>
          </dataSource>
        </environment>
      </environments>
    <!--每一个Mapper.XML都需要在Mybatis核心配置文件中注册-->
      <mappers>
        <mapper resource="com/hyf/dao/UserMapper.xml"></mapper>
      </mappers>
    </configuration>

    ```

3.  编写接口

    ```java
    public interface UserMapper {
        public List<User> selectUser();
    }
    ```

4.  编写Mapper.xml

    ```xml
    <?xml version="1.0" encoding="UTF-8" ?>
    <!DOCTYPE mapper
            PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
            "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
    <mapper namespace="com.hyf.dao.UserMapper">
        <select id="selectUser" resultType="User">
          select * from user
        </select>
    </mapper>
    ```

5.  测试

    ```java
    @Test
    public void selectUser() throws IOException {
        String resource = "mybatis-config.xml";
        InputStream inputStream = Resources.getResourceAsStream(resource);
        SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
        SqlSession sqlSession = sqlSessionFactory.openSession();
        UserMapper mapper = sqlSession.getMapper(UserMapper.class);
        List<User> userList = mapper.selectUser();
        for (User user: userList){
            System.out.println(user);
        }
        sqlSession.close();
    }
    ```

## 12.2 MyBatis-Spring

### 12.2.1 整合方法1

需要导入包

```xml
<dependency>
    <groupId>org.mybatis</groupId>
    <artifactId>mybatis-spring</artifactId>
    <version>2.0.2</version>
</dependency>
```

1.  编写数据源配置

    ```xml
    <!--配置数据源：数据源有非常多，可以使用第三方的，也可使使用Spring的-->
    <bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">
        <property name="driverClassName" value="com.mysql.jdbc.Driver"/>
        <property name="url" value="jdbc:mysql://localhost:3306/mybatis?useSSL=true&amp;useUnicode=true&amp;characterEncoding=utf8"/>
        <property name="username" value="root"/>
        <property name="password" value="123456"/>
    </bean>
    ```

2.  sqlSessionFactory

    ```xml
    <bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean">
      <property name="dataSource" ref="dataSource" />
    </bean>
    ```

3.  sqlSessionTemplate

    ```xml
    <bean id="sqlSession" class="org.mybatis.spring.SqlSessionTemplate">
      <constructor-arg index="0" ref="sqlSessionFactory" />
    </bean>
    ```

4.  给接口增加实现类  【新增】

    ```java
    public class UserDaoImpl implements UserDao {
      private SqlSession sqlSession;
      public void setSqlSession(SqlSession sqlSession) {
        this.sqlSession = sqlSession;
      }
      public User getUser(String userId) {
        return sqlSession.getMapper...;
      }
    }
    ```

5.  将自己写的实现类，注入到Spring中

    ```xml
    <bean id="userDao" class="com.kuang.dao.UserDaoImpl">
        <property name="sqlSession" ref="sqlSession"/>
    </bean>
    ```

6.  测试使用

    ```java
        @Test
        public void test2(){
            ApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");
            UserMapper mapper = (UserMapper) context.getBean("userDao");
            List<User> user = mapper.selectUser();
            System.out.println(user);
        }
    ```

### 12.2.2 整合方法2

1.  写一个UserDaoImpl2

    ```xml
    public class UserMapperImpl2 extends SqlSessionDaoSupport implements UserMapper{
        @Override
        public List<User> selectUser() {
            return getSqlSession().getMapper(UserMapper.class).selectUser();
        }
    }
    ```

2.  修改applicationContext.xml

    ```xml
    <bean id="userDao" class="com.kuang.dao.UserDaoImpl">
        <property name="sqlSessionFactory" ref="sqlSessionFactory" />
    </bean>
    ```

3.  测试

    ```java
      @Test
        public void test2(){
            ApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");

            UserMapper userMapper = context.getBean("userMapper2", UserMapper.class);
            for (User user : userMapper.selectUser()) {
                System.out.println(user);
            }
        }
    ```

# 13. 声明式事务

## 13.1 回顾事务

-   把一组业务当成一个业务来做，要么都成功，要么都失败

-   事务在项目开发过程中，十分重要，涉及到数据的一致性问题，不能马虎

-   确保完整性和一致性

事务的ACID原则：

-   原子性（atomicity）

    -   事务是原子性操作，由一系列动作组成，事务的原子性确保动作要么全部完成，要么完全不起作用

-   一致性（consistency）

    -   一旦所有事务动作完成，事务就要被提交。数据和资源处于一种满足业务规则的一致性状态中

-   隔离性（isolation）

    -   可能多个事务会同时处理相同的数据，因此每个事务都应该与其他事务隔离开来，防止数据损坏

-   持久性（durability）

    -   事务一旦完成，无论系统发生什么错误，结果都不会受到影响。通常情况下，事务的结果被写到持久化存储器中

1.  在之前的案例中，我们给userDao接口新增两个方法，删除和增加用户；

    ```java
    //添加一个用户
    int addUser(User user);
    //根据id删除用户
    int deleteUser(int id);
    ```

2.  mapper文件，我们故意把 deletes 写错，测试！

    ```java
     <insert id="addUser" parameterType="com.kuang.pojo.User">
     insert into user (id,name,pwd) values (#{id},#{name},#{pwd})
     </insert>
     <delete id="deleteUser" parameterType="int">
     deletes from user where id = #{id}
    </delete>
    ```

3.  编写接口的实现类

    ```java
    public class UserDaoImpl extends SqlSessionDaoSupport implements UserMapper {
        //增加一些操作
        public List<User> selectUser() {
            User user = new User(4,"小明","123456");
            UserMapper mapper = getSqlSession().getMapper(UserMapper.class);
            mapper.addUser(user);
            mapper.deleteUser(4);
            return mapper.selectUser();
        }
        //新增
        public int addUser(User user) {
            UserMapper mapper = getSqlSession().getMapper(UserMapper.class);
            return mapper.addUser(user);
        }
        //删除
        public int deleteUser(int id) {
            UserMapper mapper = getSqlSession().getMapper(UserMapper.class);
            return mapper.deleteUser(id);
        }
    }
    ```

4.  测试

    ```java
    @Test
    public void test2(){
        ApplicationContext context = new ClassPathXmlApplicationContext("beans.xml");
        UserMapper mapper = (UserMapper) context.getBean("userDao");
        List<User> user = mapper.selectUser();
        System.out.println(user);
    }
    ```

结果 ：插入成功！

没有进行事务的管理；我们想让他们都成功才成功，有一个失败，就都失败，我们就应该需要**事务！**

## 13.2 Spring中的事务

-   声明式事务：AOP

-   编程式事务：需要在代码中，执行对事务的管理

1.  导入约束

    ```xml
    xmlns:tx="http://www.springframework.org/schema/tx"
    http://www.springframework.org/schema/tx
    http://www.springframework.org/schema/tx/spring-tx.xsd">
    ```

2.  JDBC事务

    ```xml
    <bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
            <property name="dataSource" ref="dataSource" />
     </bean>
    ```

3.  **配置好事务管理器后我们需要去配置事务的通知**

    ```xml
    <!--配置事务通知-->
    <tx:advice id="txAdvice" transaction-manager="transactionManager">
        <tx:attributes>
            <!--配置哪些方法使用什么样的事务,配置事务的传播特性-->
            <tx:method name="add" propagation="REQUIRED"/>
            <tx:method name="delete" propagation="REQUIRED"/>
            <tx:method name="update" propagation="REQUIRED"/>
            <tx:method name="search*" propagation="REQUIRED"/>
            <tx:method name="get" read-only="true"/>
            <tx:method name="*" propagation="REQUIRED"/>
        </tx:attributes>
    </tx:advice>
    ```

这样一个函数就是一个事务，当我们删除失败，那么插入也会失败

为什么需要事务：

-   如果不配置事务，可能存在数据提交不一致的情况

-   如果我们不在Spring中配置事务，我们就需要在代码中手动配置事务

-   事务在项目的开发中非常重要，涉及到数据的一致性问题
