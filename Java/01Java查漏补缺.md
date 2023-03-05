# java常见问题

## 一些细节

1. 数组不能在函数中修改长度

2. this 关键字表示的是当前实例

3. 实际上，Java编译器一般也会将get和set方法的调用转换为直接访问实例变量，避免函数调用的开销。

4. 实例方法隐含this参数。

5. 每个类封装其内部细节，对外提供高层次的功能。

6. **引用变量**（保存的是实际内容的地址）分配在栈中，实际内容保存在堆中，其中实际内容也可以是引用变量（类中有类）。

7. instanceof关键字是一个二元运算符，判断左边的实例是否属于右边的类，返回bool。

8. 一个类只能有一个public类

9. Java的自动装箱和自动开箱

## "=="和equals()和hashCode

1. "=="判断的是地址值，equals()方法判断的是内容，这是片面的，Object类中equals()比较的就是地址，但是这显然不符合我们对equals的要求，所以很多类都重写了euqals()方法。

2. hashCode:

   1. 对象的hashCode经过hash函数计算后，不会解决冲突，所以不同的类可以有相同的hashcode

   2. 如果两个对象equals相等，那么这两个对象的HashCode一定也相同

   3. 如果两个对象的HashCode相同，不代表两个对象就相同，只能说明这两个对象在散列存储结构中，存放于同一个位置

   4. 重写equals()时，也同时重写hashCode()，保证两个对象equals相等时，hashcode也相等，因为在HashMap等底层用到了哈希桶的类中，会先比较两个对象的哈希值，如果相等再用equals比较实际值。

## Spring、SpringMVC、SpringBoot之间有什么关系？

Spring 包含了多个功能模块（上面刚刚提高过），其中最重要的是 Spring-Core（主要提供 IoC 依赖注入功能的支持） 模块， Spring 中的其他模块（比如 Spring MVC）的功能实现基本都需要依赖于该模块。

下图对应的是 Spring4.x 版本。目前最新的 5.x 版本中 Web 模块的 Portlet 组件已经被废弃掉，同时增加了用于异步响应式处理的 WebFlux 组件。

![](https://raw.github.com/Missyesterday/picgo/main/picgo/20220408185015.png)

Spring主要模块

Spring MVC 是 Spring 中的一个很重要的模块，主要赋予 Spring 快速构建 MVC 架构的 Web 程序的能力。MVC 是模型(Model)、视图(View)、控制器(Controller)的简写，其核心思想是通过将业务逻辑、数据、显示分离来组织代码。

![](<https://raw.github.com/Missyesterday/picgo/main/picgo/20220408185051.png>)

使用 Spring 进行开发各种配置过于麻烦比如开启某些 Spring 特性时，需要用 XML 或 Java 进行显式配置。于是，Spring Boot 诞生了！

Spring 旨在简化 J2EE 企业应用程序开发。Spring Boot 旨在简化 Spring 开发（减少配置文件，开箱即用！）。

Spring Boot 只是简化了配置，如果你需要构建 MVC 架构的 Web 程序，你还是需要使用 Spring MVC 作为 MVC 框架，只是说 Spring Boot 帮你简化了 Spring MVC 的很多配置，真正做到开箱即用！

## 未解决

单例模式、模板方法
Redis 分布式锁
Redis 的缓存击穿
为什么要用反射？反射的应用场景和优缺点。
子线程中获取父线程的 ThreadLocal 中的值、ThreadLocal 的数据结构
Spring 事务
InnoDB 锁算法
InnoDB存储引擎对MVCC的实现
Integer 可以和 int 用 equals，会进行自动装箱和拆箱，内部实际用 == 进行比较。
MQ 存在的意义，你用过哪些 MQ，最喜欢哪一个，为什么。
MQ 中消费时，业务逻辑出现异常怎么办
JVM 调优经历有么？
Redis 各个数据类型的底层数据结构
SpringBoot 的配置文件的加载顺序
MyISAM 和 InnoDB 的区别