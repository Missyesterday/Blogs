# 剖析ArrayDeque

`LinkedList`实现了队列接口`Queue`和双端队列接口`Deque`，Java容器类中还有一个双端队列的实现类`ArrayDeque`，它是基于数组实现的。

`ArrayDeque`**的插入和删除效率非常高**

## 实现原理

`ArrayDeque`内部主要有如下实例变量：

```java
transient Object[] elements;
transient int head;
transient int tail;
```

`element`就是存储元素的数组。`head`和`tail`的存在使得数组变成了一个逻辑上循环的数组。

### 循环数组

在循环数组里，元素到了数组尾之后可以接着从数组头开始，数组的长度、第一个元素和最后一个元素都与`head`和`tail`这两个变量有关：

1.   `head==tail`，数组为空，长度（这个长度是指`ArrayDeque`的长度）为0
2.   `(tail + 1)% element.length == head`时数组满，需要留出一个空位
3.   队列中元素的个数为：`(tail - head + element.length ) % element.length`



为空：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220427145213948.png" alt="image-20220427145213948" style="zoom:40%;" />

循环存元素：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220427145313745.png" alt="image-20220427145313745" style="zoom:40%;" />



### 构造方法

`ArrayDeque`有三个构造方法：

**默认构造方法**：

```java
public ArrayDeque() {
  elements = new Object[16];
}
```

分配了一个长度为16的数组。

**ArrayDeque(int numElements)构造方法** 

```java
public ArrayDeque(int numElements) {
  allocateElements(numElements);
}
```

调用`allocateElements`函数分配长度。它的代码比较复杂，我们讲一下它分配的逻辑：

1.   如果`numElements`小于8，就是8
2.   **如果`numElements`大于等于8的情况下，分配的长度是严格大于`numElements`并且为2的整数次幂的最小数。例如`numElements`为10，则实际分配16，如果`numElements`为32，则分配64。**

2的次幂可以使得很多操作的效率很高，同时由于循环数组需要留一个空位，所以要严格大于`numElements`。

 **public ArrayDeque(Collection<? extends E> c) 构造方法**

```java
public ArrayDeque(Collection<? extends E> c) {
  allocateElements(c.size());
  addAll(c);
}
```

同样调用`allocateElements`分配数组，随后调用了`addAll`，而`addAll`只是循环调用了`add`。

### add方法

```java
public boolean add(E e) {
  addLast(e);
  return true;
}
```

`addLast`的代码为：

```java
public void addLast(E e) {
    if (e == null)
        throw new NullPointerException();
    elements[tail] = e;
  //先将tail后移，在比较与head是否相等
    if ( (tail = (tail + 1) & (elements.length - 1)) == head)
        doubleCapacity();
}
```

将元素添加到`tail`位置，如果队列满了，则`tail`循环移动一位，`tail`的后一个位置是`(tail + 1) & (elements.length - 1)`，由于`lements.length`为2的次幂，所以-1之后后几位全是1。

例如，如果elements.length为8，则(elements.length-1)为7，二进制表示为0111，对于正数8，与7相与，结果为0。这种操作效率很高，经常用到。

`doubleCapactiy()`会将数组扩大两倍：

```java
private void doubleCapacity() {
  //这句话可以理解为如果head == 太累
  assert head == tail;
  //p为头
  int p = head;
  int n = elements.length;
  int r = n - p; // r = p右侧的数据个数
  int newCapacity = n << 1; // 新的长度乘2
  if (newCapacity < 0) //不能超过int的最大
    throw new IllegalStateException("Sorry, deque too big");
  Object[] a = new Object[newCapacity];
  System.arraycopy(elements, p, a, 0, r);//将从p开始的elements中的元素复制到a数组的0开始r个元素
  System.arraycopy(elements, 0, a, r, p);//将从0开始的elements中的元素复制到a数组r开始p个元素
  elements = a;
  head = 0;
  tail = n;
}
```

`arraycopy`的函数头：

```java
    public static native void arraycopy(Object src,  int  srcPos,
                                        Object dest, int destPos,
                                        int length);
```



举例：

![image-20220427154855458](https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220427154855458.png)

### addFirst()方法

```java
public void addFirst(E e) {
  if (e == null)
    throw new NullPointerException();
  elements[head = (head - 1) & (elements.length - 1)] = e;
  if (head == tail)
    doubleCapacity();
}
```

可以看到`ArrayDeque`中是不能插入`null`的，而`LinkedList`和`ArrayList`可以。关于这个可以看[关于ArrayDeque不能添加null而ArrayList和LinkedList可以](关于ArrayDeque不能添加null而ArrayList和LinkedList可以.md)。

在头部添加，首先要先让`head`指向前一个位置，然后再赋值给`head`所在位置。head的前一个位置是`(head - 1) & (elements.length  - 1)`。刚开始`head`为0,`elements.length`为8，则`head`的前一个位置是7。

### removeFirst()方法

```java
public E removeFirst() {
  E x = pollFirst();
  if (x == null)
    throw new NoSuchElementException();
  return x;
}
```

调用了`pollFirst`：

```java
public E pollFirst() {
  int h = head;
  @SuppressWarnings("unchecked")
  E result = (E) elements[h];
  // 如果头部位置元素为空则整个deque为空
  if (result == null)
    return null;
  //将头部位置元素置空
  elements[h] = null;    
  //后移
  head = (h + 1) & (elements.length - 1);
  return result;
}
```

### size()方法查看长度

```java
public int size() {
  return (tail - head) & (elements.length - 1);
}

```

### contains()方法检查元素是否存在

```java
public boolean contains(Object o) {
  if (o == null)
    return false;
  int mask = elements.length - 1;
  int i = head;
  Object x;
  while ( (x = elements[i]) != null) {
    if (o.equals(x))
      return true;
    i = (i + 1) & mask;
  }
  return false;
}
```

就是从`head`开始遍历并进行对比，循环过程中没有使用`tail`，而是到元素为`null`就结束了，这是因为在`ArrayDeque`中，有效元素不能为`null`。

### toArray()

```
public Object[] toArray() {
    return copyElements(new Object[size()]);
}
```

返回了调用`copyElements()`：

```java
private <T> T[] copyElements(T[] a) {
  if (head < tail) {
    System.arraycopy(elements, head, a, 0, size());
  } else if (head > tail) {
    int headPortionLen = elements.length - head;
    System.arraycopy(elements, head, a, 0, headPortionLen);
    System.arraycopy(elements, 0, a, headPortionLen, tail);
  }
  return a;
}
```

如果head小于tail，就是从head开始复制size个，否则，复制逻辑与doubleCapacity方法中的类似，先复制从head到末尾的部分，然后复制从0到tail的部分



### 小结

`ArrayDeque`内部是一个动态扩展的循环数组，通过`head`和`tail`来维护数组的开始和结尾，数组的长度为2的幂次。它有这些特点：

1.   在两端删除、添加元素的效率很高
2.   根据元素内容查找和删除的效率比较低
3.   与`ArrayList`和`LinkedList`不同，没有索引位置的概念，不能根据索引位置进行操作
4.   如果只需要`Deque`接口，从两端进行操作，一般而言，`ArrayList`效率更高一些，应该优先被使用；如果需要索引位置进行操作，或者经常在中间插入和删除，则选`LinkedList`。
