# 剖析ArrayList

## 基本用法

ArryList是一个泛型容器，新建ArrayList需要实例化泛型参数。

```java
ArrayList<Integer> intList = new ArrayList<Integer>();
```

ArrayList的主要方法有：

```java
public boolean add(E e)//添加元素到表尾
public boolean isEmpty()//判断是否为空
public int size()//获取长度
public E get(int index) //访问指定位置的元素
public int indexOf(Object o)//查找元素在list中的索引(Index of Object),没有返回1
public int lastIndexOf(Object o)//从后往前找
public boolean contains(Object o)//是否包含元素o，具体实现很有意思，return indexOf(o) >= 0;
public E remove(int index)//删除指定位置的对应的元素，返回被删除的元素
public boolean remove(Object o)//删除指定对象，如果o为null，则删第一个null的元素，如果o为指定对象，则只删除第一个相同的对象
public void clear()//删除所有元素
public void add(int index,E e)//在指定位置插入元素
```

> 这些函数的判断都是基于equals的。

## 基本原理

Array内部有一个数组`elementData`，一般会有一些预留的空间，有一个整数`size`记录实际的元素个数：

```java
    transient Object[] elementData; // non-private to simplify nested class access

    /**
     * The size of the ArrayList (the number of elements it contains).
     *
     * @serial
     */
    private int size;

```

各种public的方法内部操作都是基于这个数组和整数，`elementData`会随着实际元素个数的增加而重新分配，而size始终记录实际元素的个数。

### add()方法与扩容机制

`add()`的代码：

```java
public boolean add(E e) {
    ensureCapacityInternal(size + 1);  // Increments modCount!!
    elementData[size++] = e;
    return true;
}
```

它首先调用`ensureCapacityInternal()`方法来确保数组的容量是足够的，`ensureCapacityInternal()`的代码是：

```java
private void ensureExplicitCapacity(int minCapacity) {
        modCount++;

        // overflow-conscious code
        if (minCapacity - elementData.length > 0)//如果需要的长度大于当前数组的长度
            grow(minCapacity);
    }
```

`modCount`表示内部的修改次数

如果需要的长度大于当前数组的长度，则调用`grow()`方法，`grow()`方法：

```java
private void grow(int minCapacity) {
        // overflow-conscious code
        int oldCapacity = elementData.length;
  			//右移一位等价于除2（向下取整），所以newCapacity（约）是oldCapacity的1.5倍
        int newCapacity = oldCapacity + (oldCapacity >> 1);
  			//如果扩展1.5倍还是小于minCapacity，就直接把扩展为minCapacity
        if (newCapacity - minCapacity < 0)
            newCapacity = minCapacity;
  			//如果newCapacity比MAX_ARRAY_SIZE大时
        if (newCapacity - MAX_ARRAY_SIZE > 0)
            newCapacity = hugeCapacity(minCapacity);
        // minCapacity is usually close to size, so this is a win:
  			//会拷贝一份到新的数组
        elementData = Arrays.copyOf(elementData, newCapacity);
    }
```

当`newCapacity`比`MAX_ARRAY_SIZE`大时，则调用`hugeCapacity()`方法：

```java
    private static int hugeCapacity(int minCapacity) {
        if (minCapacity < 0) // overflow 如果容量<0，则抛出OOM minCapacity = Integer.MAX_VALUE+x (x>0时，就抛出OOM)
            throw new OutOfMemoryError();
        return (minCapacity > MAX_ARRAY_SIZE) ?
            Integer.MAX_VALUE :  //其中，MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;
            MAX_ARRAY_SIZE;
    }

```

`hugeCapacity()`是用来保证`newCapacity`不能超过`MAX_VALUE`，但是为什么会有两个选择：

1. Integer.MAX_VALUE
2. MAX_ARRAY_SIZE

最好是MAX_ARRAY_SIZE，如果minCapacity > MAX_ARRAY_SIZE，则newCapacity为Integer.MAX_VALUE。因为在某些虚拟机中，数据长度大于MAX_ARRAY_SIZE (Integer.MAX -8 )就容易OOM （注意只是有些）。

> 因此，数组的最大容量其实是Integer.MAX_VALUE，最大只扩容到 MAX_ARRAY_SIZE 是为了照顾有些虚拟机，如果还放不下没办法，就扩容到最大。



**扩容机制总结**

1. 构造函数。`ArrayList`有三种方式来初始化：
   1. 默认构造函数，构造一个初始容量为10的空列表
   2. 带初始容量参数的构造函数。（用户自己指定容量）
   3. 构造包含指定collection元素的列表，这些元素利用该集合的迭代器按顺序返回，如果集合为空则抛出`NullPointerException`
2. 添加第一个元素时扩容到10，所以添加第一个元素和第11个元素是符合扩容条件的
3. `grow()`，要分配的最大数组的大小
   1. 如果需要扩容首先`int newCapacity = oldCapacity + (oldCapacity >> 1);`
   2. 如果1.5倍不够则吧最小容量当作新容量
   3. 如果新容量比`MAX_ARRAY_SIZE`大，则进入`hugeCapacity`
4. `hugeCapacity()`:比较minCapacity和MAX_ARRAY_SIZE的大小

### remove()方法

```java
    /**
 			删除列表中指定位置的元素，然后从index后的元素都向前移1位，返回被删除的元素
     */
    public E remove(int index) {
        rangeCheck(index);

        modCount++;
        E oldValue = elementData(index);

      	//先计算需要移动的元素个数
        int numMoved = size - index - 1;
        if (numMoved > 0)
          	//实际上调用System.arraycopy来移动元素
            System.arraycopy(elementData, index+1, elementData, index,
                             numMoved);
        elementData[--size] = null; // 将size-1，同时释放引用以便原对象被垃圾回收

        return oldValue;
    }
```

`System.arraycopy`是一个本地函数，由C实现。

`elementData[--size] = null`；这行代码将size减1，同时将最后一个位置设为null，设为null后不再引用原来对象，如果原来对象也不再被其他对象引用，就可以被垃圾回收。

## 迭代

我们可以用foreach来遍历ArrayLIst：

```java
for(Integer a : intList){￼   
  System.out.println(a);￼
}
```

编译器会将它转换为如下代码：

```java
Iteartor<Integer> it = intList.iterator();
while(it.hasNext()){
  System.out.println(it.next());
}
```

关于`Iteartor`迭代器，可见[迭代器.md](迭代器.md)这篇文章。

## ArrayList实现的接口

可见[这篇文章](Collection、List、RandomAcess、Cloneable、Serializable接口.md)

## ArrayList的其他方法

`ArrayList`中还有一些其他方法，包括构造方法、与数组的相互转换、容量大小控制等。

### 构造方法

`ArrayList`有三个构造方法：

```java
public ArrayList()
public ArrayList(int initialCapacity) 
public ArrayList(Collection<? extends E> c) 
```

第一个是无参构造函数，初始化内部数组为一个空数组：

```java
private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};
public ArrayList() {
  this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
}
```

第二个方法以指定的大小`initialCapacity`初始化内部的数组大小，核心代码为：

```java
this.elementData = new Object[initialCapacity];
```

在事先知道元素长度的情况或者预先知道元素长度上限的情况下，使用这个构造方法可以避免重新分配和复制数组。

第三个构造方法以一个已有的`Collection`构建，数据会新复制一份。

### 返回数组的方法：toArray

`ArrayList`有两个方法可以返回数组：

```java
public Object[] toArray()
public <T> T[] toArray(T[] a)
```

第一个方法返回的是`Object`数组，代码为：

```java
public Object[] toArray() {
  //就是复制一份内部数组，然后返回
  return Arrays.copyOf(elementData, size);
}
```

第二个方法返回对应类型的数组，如果参数的数组长度足以容纳所有元素，就是用该数组，否则就新建一个数组，我们来测试一下：

```java
@Test
public void test02(){
  List<Integer> intList = new ArrayList();
  intList.add(123);
  intList.add(234);
  intList.add(345);
  Integer[] tmp = new Integer[0];
  Integer[] arrA = new Integer[3];
  intList.toArray(arrA);
  Integer[] arrB = intList.toArray(tmp);
  System.out.println(arrB == tmp); //false，如果tmp的长度>=3则为true
  System.out.println(Arrays.equals(arrA, arrB)); //true
  System.out.println(arrA == arrB); //false
  System.out.println(arrA.equals(arrB)); //false
}
```

表示这两种方法都可以创建数组。

>   其中，`==`是判断地址，为false，arrA.equals(arrB)，数组调用的是`Object`类的`equals()`方法，也是使用`==`判断，为false
>
>   Arrays.equals()判断两个数组的长度和每个元素是否相等，所以为true。

### Arrays.asList()

`Arrays`中有一个静态方法`asList()`可以返回对应的List：

```java
Integer[] a = {1,2,3};
List<Integer> list = Arrays.asList(a);
```

需要注意的是，这个方法返回的是`List`，它的实现类并不是`ArrayList`,而是`Arrays`类的一个内部类，在这个内部类的实现中，内部用的数组就是传入的数组，没有拷贝，也不会动态改变大小，所以对数组的修改也会反映到`List`中，对`List`调用`add()`、`remove()`方法会抛出异常。

所以，如果想使用`ArrayList`的完整方法，应该新建一个`ArrayList`：

```java
ArrayList<Integer> list = new ArrayList<>(Arrays.asList(a));
```

### ensureCapacity()和trimToSize()

`ArrayList`还提供了两个public方法，可以控制内部使用数组大小，一个是：

```java
public void ensureCapacity(int minCapacity)
```

它可以确保数组的大小容量至少为`minCapacity`，如果不够，会进行扩展。如果已预知`ArrayList`需要比较大的容量，调用这个方法可以减少`ArrayList`内部分配和扩展的次数。

另一个方法是`trimToSize()`：

```java
public void trimToSize() 
```

它会重新分配一个数组，大小刚好为实际内容的长度。调用这个方法可以节省数组占用的空间。

## ArrayList特点分析

不同的容器类有不同的特点。我们在使用的时候根据需求进行选择。

`ArrayList`有这些特点：

1.   可以随机访问，效率是O(1)。
2.   除非数组已排序，否则按内容查找元素效率为O(N)。
3.   插入和删除需要移动元素，时间复杂度为O(N)。
4.   `ArrayList`不是线程安全的
