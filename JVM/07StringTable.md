## 1. String的基本特性

-   String：字符串，使用一对`""`引起来表示。
    -   `String s1 = "XXX";`字面量的定义方式
    -   `String s2 = new String("hello");`
-   String声明为`final`的，不可被继承
-   String实现了`Serializable`接口：表示字符串是支持序列化的。实现了`Comparable`接口：表示String可以比较大小
-   String在jdk8之前内部定义了`final char[] value`用于存储字符串数据。jdk9时改用`byte[]`。
-   String：代表不可变的字符序列。简称：不可变性。
    -   当对字符串重新赋值时，需要重写指定内存区域赋值，不能使用原有的value进行复制。
    -   当对现有的字符串进行连接操作（例如`s1 += "abc"`）时，也需要重新指定内存区域赋值，不能使用原有的value进行赋值。
    -   当调用String的`replace()`方法修改指定字符或字符串时，也需要重新指定内存区域赋值，不能使用原有的value进行赋值。
-   通过字面量的方式（区别于new）给一个字符串赋值，此时的字符串值声明在字符串常量池中。

### String在jdk9中存储结构变更

**动机**

大多数String类只包含一个拉丁字符，只需一个字节去存，而char是两个字节，也就是说有一个字节的空间被浪费。

**描述**

String不用char[]来存储了，改成byte[]加上编码标记，节约了一些空间，同时`StringBuffer`和`StringBuilder`等基于String的类也进行了修改。

### 字符串常量池是不会存储相同内容的字符串的

-   String的String Pool是一个固定大小的Hashtable，默认值大小长度是1009。如果放进String Pool的String非常多，就会造成Hash冲突严重，从而导致链表会很长，而链表长了后直接会造成的影响就是当调用`String.intern()`时性能会大幅下降。
    -   `String.intern()`：如果字符串常量池中没有对应String类型的字符串的话，则在常量池中生成。
-   使用`-XX:StringTableSize`可以设置StringTable的长度。
-   在jdk6中StringTable是固定的，就是**1009**的长度，所以如果常量池中的字符串过多就会导致效率下降很快。StringTableSize设置没有要求。
-   在jdk7中，StringTable长度默认是60013，StringTableSize设置没有要求
-   jdk8开始，设置StringTable的长度的话，1009是可设置的最小值

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220524110344393.png" alt="image-20220524110344393" style="zoom:40%;" />

如果在JDK8中设置小于1009的StringTableSize：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220524110738782.png" alt="image-20220524110738782" style="zoom:40%;" />

本机测试：对于读取100000行String，StringTableSize为1009，花费135ms；StringTableSize为10009，花费64ms。

## 2. String的内存分配

-   在Java类型语言中有8种基本数据类型和一种比较特殊的类型String。这些类型为了使它们在运行过程中速度更快、更节省内存，都提供了一种常量池的概念。
-   常量池就类似于一个Java系统级别的缓存。8种基本数据类型的常量池都是系统协调的，**String类型的常量池比较特殊。它的主要使用方法有两种。**
    -   直接使用双引号声明出来的String对象会直接存储在常量池中。例如：`String info = "hello";`
    -   如果不是双引号声明的String对象（拼接、new等），可以使用String提供的`intern()`方法。
-   Java 6及以前，字符串常量池存放在永久代的运行时常量池
-   Java 7中Oracle的工程师对字符串池的逻辑做了很大改变，即将**字符串常量池的位置调整到Java堆内**。
    -   所有的字符串都保存在堆（Heap）中，和其他普通对象一样，这样可以在进行调优应用时仅需调整堆大小就可以了。
    -   字符串常量池概念原本使用的比较多，但是这个改动使得我们有足够的理由让我们重新考虑在Java7中使用`String.intern()`
-   Java 8元空间，字符串常量在堆。

### StringTable为什么要调整

1.   永久代中，permSize默认比较小
2.   永久代垃圾回收频率低

## 3. String的基本操作

Java语言规范里要求完全相同的字符串字面量，应该包含同样的Unicode字符序列（包含同一份码点序列的常量），并且必须是指向同一个String类实例。

```java
class Memory {
    public static void main(String[] args) {//line 1
        int i = 1;//line 2
        Object obj = new Object();//line 3
        Memory mem = new Memory();//line 4
        mem.foo(obj);//line 5
    }//line 9

    private void foo(Object param) {//line 6
        String str = param.toString();//line 7
        System.out.println(str);
    }//line 8
}

```



<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220524173853440.png" alt="image-20220524173853440" style="zoom:40%;" />

一个字符串在line7被创建在堆空间的字符串常量池，并把地址返回给str。所以toString也是放在常量池（非new）

## 4. 字符串拼接操作

-   常量和常量的拼接结果在常量池，原理是编译期优化

    ```java
    String s1 = "a" + "b" + "c";//编译期优化：等同于"abc"
    ```

-   常量池中不会存在相同内容的常量

-   只要拼接的两个字符串其中一个是变量，结果就在堆（非堆中的常量池）中。变量拼接的原理是`StringBuilder`。

-   如果拼接的结果调用`intern()`方法，则主动将常量池中还没有的字符串对象放入池中，并返回此对象地址。

### 举例

#### 例子1

```java
    @Test
    public void test1(){
        String s1 = "a" + "b" + "c";//编译期优化：在生成字节码的时候优化,等同于"abc"
        String s2 = "abc"; //"abc"一定是放在字符串常量池中，将此地址赋给s2
        /*
         * 最终.java编译成.class,再执行.class
         * String s1 = "abc";
         * String s2 = "abc"
         */
        System.out.println(s1 == s2); //true,引用类型的变量"=="判断的是它们二者之间的地址,s1和s2指向的都是字符串常量池中的"abc"
        System.out.println(s1.equals(s2)); //true
    }
```

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220525142920428.png" alt="image-20220525142920428" style="zoom:40%;" />

#### 例子2

```java
    @Test
    public void test2(){
        String s1 = "javaEE";
        String s2 = "hadoop";

        String s3 = "javaEEhadoop";
        String s4 = "javaEE" + "hadoop";//编译期优化,等同于"javaEEhadoop"
        //如果拼接符号的前后出现了变量，则相当于在堆空间中new StringBuilder()，然后append()”JavaEE“和 ”hadoop“，最后toString()
        String s5 = s1 + "hadoop";
        String s6 = "javaEE" + s2;
        String s7 = s1 + s2;

        System.out.println(s3 == s4);//true
        System.out.println(s3 == s5);//false
        System.out.println(s3 == s6);//false
        System.out.println(s3 == s7);//false

        //s5 s6 s7之间都是false,它们都是new出来的
        System.out.println(s5 == s6);//false
        System.out.println(s5 == s7);//false
        System.out.println(s6 == s7);//false
        //intern():判断字符串常量池中是否存在s6引用(javaEEhadoop)值，如果存在，则返回常量池中javaEEhadoop的地址；
        //如果字符串常量池中不存在javaEEhadoop，则在常量池中加载一份javaEEhadoop，并返回次对象的地址。
        String s8 = s6.intern();
        System.out.println(s3 == s8);//true
    }

```

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220525151218832.png" style="zoom:40%;" />

#### 例子3

```java
    @Test
    public void test3(){
        String s1 = "a";
        String s2 = "b";
        String s3 = "ab";

        /*
        * 如下的 s1 + s2的连接操作的执行细节:(变量s是临时定义的)
        * 1. StringBuilder s = new StringBuilder(); //jdk5.0之前使用的是StringBuffer
        * 2. s.append("a");
        * 3. s.append("b");
        * 4. s.toString(); //约等于new String("ab");
        * */
        String s4 = s1 + s2;//符号左右两边出现变量
        System.out.println(s3 == s4);//false
    }
```

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220525151658565.png" alt="image-20220525151658565" style="zoom:40%;" />

#### 例子4

```java
    /*
    * 1.字符串拼接操作不一定使用的是StringBuilder
    *   如果拼接符号左右两边都是字符串常量或者常量引用,则仍然使用编译期优化,即非StringBuilder的方式
    * 2. 针对于用final修饰的类,方法,基本数据类型,引用数据类型的量的结构时,能用fianl修饰的尽量用final修饰
    * */
    @Test
    public void test4(){
        final String s1 = "a";
        final String s2 = "b";
        String s3 = "ab";
        String s4 = s1 + s2;
        System.out.println(s3 == s4);//true
    }
```

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220525151922799.png" alt="image-20220525151922799" style="zoom:40%;" />

#### 体会执行效率

```java

    /*通过StringBuilder的append()方式添加字符串的效率要远高于使用Stirng的字符串拼接方式
    * StringBuilder的append()方式的优点:
    * 1. 自始至终只创建一个StringBuilder对象,使用String字符串拼接方式:创建多个StringBuilder和String对象
    * 2. 内存中由于创建了较多的StringBuilder和String对象,内存占用更大,如果发生GC,需要花费额外空间
    *
    * 改进的空间:
    * 在实际开发中,如果基本确定要添加的字符串长度不高于某个限定值highlevel的情况下,
    * 建议使用构造方法 StringBuilder s = new StringBuilder(highlevel); 来实例化,这样StringBuilder不会扩容
    * */
    @Test
    public void test6(){

        long start = System.currentTimeMillis();

//        method1(100000);//2440
        method2(100000);//4

        long end = System.currentTimeMillis();

        System.out.println("花费的时间为：" + (end - start));
    }

    public void method1(int highLevel){
        String src = "";
        for(int i = 0;i < highLevel;i++){
            src = src + "a";//每次循环都会创建一个StringBuilder、String
        }
//        System.out.println(src);

    }
```

**通过StringBuilder的append()方式添加字符串的效率要远高于使用Stirng的字符串拼接方式。**

## 5. intern()的使用

如果不是双引号声明的String对象，可以使用String提供的`intern()`方法，`intern()`方法会从字符串常量池中查询当前字符串是否存在，若不存在就会将当前字符串放入常量池中。

-   比如：`String myInfo = new String("I want ").intern();`

也就是说，如果在任意字符串上调用`String.intern()`方法，那么其返回结果所指向的那个类实例，必须和直接以常量形式出现的字符串实例完全相同。因此下列表达式的值必定是true：

-   `("a" + "b" + "c").intern() == "abc";`

通俗来说，Interned String就是确保字符串在内存里只有一份拷贝，这样可以节约内存空间，加快字符串操作任务的执行速度。注意：这个值会被存放在字符串内部池(String Intern Pool)。

### new String("abc")会创建几个对象？

#### 1.new String("ab")会创建几个对象?

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220526230319013.png" alt="image-20220526230319013" style="zoom:40%;" />

 从字节码可知,是两个,:

-   一个对象是new关键字在堆空间创造的  
-   一个是字符串常量池的对象"ab" -->字节码指令 ldc
-    但是返回的是堆空间中的对象 

#### 2. String  str = new String("a") + new String("b");会创建几个对象?

<img src="/Users/heyufan1/Library/Application Support/typora-user-images/image-20220526230511831.png" alt="image-20220526230511831" style="zoom:40%;" />

1.   对象1 : new StringBuilder(); 
2.   对象2 : new String() 用来放a 
3.   对象3 : 常量池中的"a" 
4.   对象4 : new String()  用来放b 
5.   对象5 : 常量池中的"b"  
6.   深入剖析:StringBuilder.toString():  
     1.    对象6: new String("ab")  
     2.     强调一下,toString()方法的调用,在字符串常量池中没有生成"ab"



#### intern()方法

```java
package com.hyf.go;

/**
 * @author 旋风冲锋龙卷风
 * @description: 测试intern
 * @date 2022/05/25 15:45
 * @Copyright: 个人博客 : http://letsgofun.cn/
 **/
public class StringIntern {
    public static void main(String[] args) {

        String s = new String("1");
        //调用此方法之前,字符串常量池中已经存在了"1",所以调用此方法什么意义
        s.intern();
        String s2 = "1";
        System.out.println(s == s2); //jdk6:false jdk7/8:false

        //s3的变量记录的地址为:new String("11)
        String s3 = new String("1") + new String("1");
        //执行完上一行代码以后,字符串常量池中是否存在"11"呢?不存在"11"

        //此时在字符串常量池中生成"11"
        //在jdk6中创建了一个新的对象"11",也就有新的地址
        //非常重要：在jkd7/8中,此时常量池中并没有创建"11",而是创建了一个指向堆空间中new String("11)的地址(为了节省空间)
        s3.intern();

        //使用的是上一行代码执行时,在常量池中生成的"11"的地址
        String s4 = "11";
        System.out.println(s3 == s4);//jdk6：false  jdk7/8：true
    }


}
```

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220526230826335.png" alt="image-20220526230826335" style="zoom:40%;" />

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220526230839904.png" alt="image-20220526230839904" style="zoom:40%;" />

s3指向的是对象，s4指向的是引用。

```java
package com.hyf.go;

/**
 * @author 旋风冲锋龙卷风
 * @description: StringIntern.java中练习的拓展
 * @date 2022/05/26 23:11
 * @Copyright: 个人博客 : http://letsgofun.cn/
 **/
public class StringIntern1 {
    public static void main(String[] args) {

        String s3 = new String("1") + new String("1");
        String s4 = "11";//在字符串常量池生成11
        s3.intern();//字符串常量池已经有11了,所以它没有干什么


        System.out.println(s3 == s4);//false
    }
}
```

重点理解上图jdk7中s3的指针。

#### intern()的总结

-   jdk6 中，将这个字符串对象尝试放入字符串常量池
    -   如果串池中有，则并不会放入。返回已有的串池中的地址
    -   如果串池中没有，则会**把此对象复制一份**，放入串池，并返回串池中的对象地址
-   jdk7以后，将这个字符串对象尝试放入串池
    -   如果存在，则并不会放入。返回已有的串池中的地址
    -   如果没有，则会把**对象的引用地址复制一份**，放入串池，并返回串池中的引用地址
        -   原因是，对象和串池都在堆中，这样可以节省空间。  

#### 练习1

```java
public class StringExer1 {
    public static void main(String[] args) {
        String s = new String("a") + new String("b");
        //上一行代码执行完之后,字符串常量池中并没有"ab"
        //在jdk7/8中,此时字符串常量池有指向"ab"这个对象的地址,而不是保存"ab"对象
        String s2 = s.intern();

        System.out.println(s2 == "ab"); //true
        System.out.println(s == "ab");//true
    }
}
```

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220526233907879.png" alt="image-20220526233907879" style="zoom:40%;" />

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220526233918213.png" alt="image-20220526233918213" style="zoom:40%;" />

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220526234359589.png" alt="image-20220526234359589" style="zoom:40%;" />

#### 练习2

```java
public class StringExer2 {
    public static void main(String[] args) {

        //常量池中会放入"ab"
        String s1 = new String("ab");
        //常量池中不会放入"ab"
        //String s1 = new String("a") + new String("b");
        s1.intern();
        String s2 = "ab";
        System.out.println(s1 == s2); //s1为new String("ab")为true
        //s1 = new String("a") + new String("b");为false

    }
}
```



### intern()的注意点

-   `new String("XXX")`会在常量池中放入“ab”，但是返回的是堆空间中非常量池的“ab”
-   `s1 = new String("a") + new String("b")`，返回的是堆空间中非常量池的“ab”
-   在调用`intern()`前需要判断字符串常量池中是否存在，以及在Jdk6和jdk7以后的区别。
    -   **一定要注意在jdk7以后，如果没有，在字符串常量池中存放的是对象的地址**
-   `String s1 = new String("a") + new String("b");`和`String s2 = "ab";`在一起类似于` String s1 = new String("ab");`

### intern()的效率测试：空间角度

```java
public class StringIntern2 {
    static final int MAX_COUNT = 1000 * 10000;
    static final String[] arr = new String[MAX_COUNT];

    public static void main(String[] args) {
        Integer[] data = new Integer[]{1,2,3,4,5,6,7,8,9,10};

        long start = System.currentTimeMillis();
        for (int i = 0; i < MAX_COUNT; i++) {
            arr[i] = new String(String.valueOf(data[i % data.length]));
//            arr[i] = new String(String.valueOf(data[i % data.length])).intern();

        }
        long end = System.currentTimeMillis();
        System.out.println("花费的时间为：" + (end - start));

        try {
            Thread.sleep(1000000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.gc();
    }
}

```

**使用intern()**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220527141848728.png" alt="image-20220527141848728" style="zoom:40%;" />

**不使用intern()**

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220527141955367.png" alt="image-20220527141955367" style="zoom:40%;" />

>   结论：对于程序中大量存在的字符串，尤其其中存在很多重复字符串时，使用`intern()`可以节省内存空间。

大的网站平台，需要内存中存储大量的字符串。比如社交网站，很多人都存储：北京市、海淀区等信息。这时候如果字符串都调用`intern()`方法，就会明显降低内存的大小。

## 6.String Table的垃圾回收

参数：`-XX:+PrintStringTableStatistics`打印字符串常量池的统计信息。

```java
package com.hyf.go;

/**
 * @author 旋风冲锋龙卷风
 * @description:  * String的垃圾回收:
 *  * -Xms15m -Xmx15m -XX:+PrintStringTableStatistics -XX:+PrintGCDetails
 * @date 2022/05/27 14:29
 * @Copyright: 个人博客 : http://letsgofun.cn/
 **/
public class StringGCTest {
    public static void main(String[] args) {
        for (int j = 0; j < 100000; j++) {
            String.valueOf(j).intern();
        }
    }
}

```



仅有`main()`函数：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220527143634761.png" alt="image-20220527143634761" style="zoom:40%;" />

循环100次：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220527143725684.png" alt="image-20220527143725684" style="zoom:40%;" />

循环10000次：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220527143818740.png" alt="image-20220527143818740" style="zoom:40%;" />

循环100000次：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220527143946723.png" style="zoom:40%;" />

>   可以看到循环次数达到100000次的时候，产生了垃圾回收

## 7.G1中的String去重操作

**首先需要注意：对String去重，是对堆中非字符串常量池区域的String对象的去重**

-   背景：对许多Java应用（有大的也有小的）做的测试得出以下结果：
    -   堆存活数据集合里面String对象占了25%
    -   堆存活数据集合里面重复的String对象有13.5%
    -   String对象的平均长度是45
-   许多大规模的Java应用瓶颈在于内存，测试表明，在这些类型的应用里面，**Java堆中存活的数据集合差不多25%是String对象**。更进一步，这里面差不多一半String对象是重复的，重复的意思是说`str1.equals(str2) == true`。这个项目将在G1垃圾回收器中实现自动持续对重复的String对象进行去重，这样就能避免浪费内存。
-   实现
    -   当垃圾收集器工作的时候，会访问堆上存活的对象。**对每一个访问的对象都会检查是否是候选的要去重的String对象。**
    -   如果是，把这个对象的一个引用插入到队列中等待后续的处理。一个去重的线程在后台运行，处理这个队列。处理队列的一个元素意味着从队列删除这个元素，然后尝试去重它引用的String对象。
    -   使用一个hashtable来记录所有的被String对象使用的不重复的char数组，当去重的时候，会检查这个hashtable，来看堆上是否已经存在一个一模一样的char数组
    -   如果存在，String对象会被调整引用哪个数组，释放对原来数组空间的引用，最终会被垃圾收集器回收掉
    -   如果查找失败，char数组会被插入到hashtable，这样以后的时候就可以共享这个数组了。
-   命令行选项
    -   `UseStringDeduplication(bool)`：开启String去重，**默认是不开启的，需要手动开启。**
    -   `PrintStringDeduplicationStatistics(bool)`：打印详细的去重统计信息
    -   `StringDeduplicationAgeThreshold(uintx)`：达到这个年龄的String对象默认是去重的候选对象。

