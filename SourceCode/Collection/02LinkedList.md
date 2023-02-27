# 剖析LinkedList

`ArrayLIst`的随机访问效率很高，但是插入和删除性能比较低；`LinkedList`同样实现了`List`接口，它的特点与`ArrayList`几乎正好相反。

除了实现`List`接口之外，`LinkedList`还实现了`Deque`和`Queue`接口，可以按照队列、栈和双端队列的方式进行操作。



## 用法

### 构造方法

`LinkedList`有两个构造方法，一个无参构造方法，一个可以接受一个已有的`Collection`：

```java
public LinkedList() 
public LinkedList(Collection<? extends E> c) 
```

可以这样创建：

```java
List<String> list = new LinkedList();
List<String> list2 = new LinkedList(
  Arrays.asList(new String[]{"a", "b", "c"})
);
```

`LinkedList`和`ArrayList`一样，同样实现了`List`接口，而`List`接口扩展了`Collection`接口，`Collection`又扩展了`Iterable`接口，所有这些接口的方法都是可以使用的。

### Queue接口

`LinkedList`还实现了队列接口`Queue`。它的定义为：

```java
public interface Queue<E> extends Collection<E> {
    boolean add(E e);
    boolean offer(E e);
    E remove();
    E poll();
    E element();
    E peek();
}

```

`Queue`扩展了`Collection`,它的主要操作有三个：

1.   在尾部添加元素：`add()`、`offer()`
2.   查看头部元素，返回头部元素，但是不改变队列：`element()`、`peek()`
3.   删除头部元素，返回头部元素，并同时从队列中删除：`remove()`、`poll()`

每种操作都有两种形式，它们的区别在于第一组会抛出异常，而第二组不会。例如，在队列为空时，前者会抛出异常NoSuchElementException，而peek和poll返回特殊值null；在队列为满时，add会抛出异常IllegalStateException，而offer只是返回false。

把`LinkedList`当作`Queue`使用：

```java
Queue<String> queue =  new LinkedList();
queue.offer("a");
queue.offer("b");
queue.offer("c");
while (queue.peek() != null){
  System.out.println(queue.poll());
}
```

>   注意如果用接口定义对象，这个对象只能用接口中的方法，例如：List<String> list = new LinkedList(); list没有offer()等Queue中方法

### Deque接口

说了队列，该说栈了，Java 中没有单独的栈接口，栈的相关方法包括在了表示双端队列的接口`Deque`中，主要有三个方法：

```java
void push(E e);//入栈
E pop();//出栈并删除
E peek();//查看头部元素
```

除此之外，Java中有一个类`Stack`，它是`Vector`的子类，也实现了栈的一些方法，如push/pop/peek等，并通过`synchronized`实现了线程安全，但它没有实现`Deque`接口。

`Deque`还有如下更为明确的操作两端的方法：

```java
void addFirst(E e);
void addLast(E e);
E getFirst();
E getLast();
boolean offerFirst(E e);
boolean offerLast(E e);
E peekFirst();
E peekLast();
E pollFirst();
E peekLast();
E removeFirst();
E removeLast();
```

`Deque`接口还有一个迭代器方法，可以从后往前遍历：

```java
Iterator<E> descendingIterator();
```

例如：

```java
Deque<String> deque = new LinkedList(Arrays.asList(new String[] {"a","b","c"}));
Iterator<String> it = deque.descendingIterator();
while(it.hasNext()){
  System.out.println(it.next());
}
```

它就是从后往前遍历

## 实现原理

### 内部组成

其实`LinkedList`的内部是**双向链表**，首先定义一个节点，节点是内部类：

```java
private static class Node<E> {
  E item;
  Node<E> next;
  Node<E> prev;

  Node(Node<E> prev, E element, Node<E> next) {
    this.item = element;
    this.next = next;
    this.prev = prev;
  }
}
```

`Node`类表示节点，`item`指向实际的元素。

`LinkedList`内部由三个实例变量组成：

```java
transient int size = 0;
transient Node<E> first;
transient Node<E> last;

```

`first`指向头节点，`last`指向尾节点，初始值都为`null`。

`LinkedList`的所有`public`方内部操作的都是这三个实例变量。

### add方法

`add`方法的代码为：

```java
public boolean add(E e) {
  linkLast(e);
  return true;
}
```

主要调用了`linkLast`：

```java
void linkLast(E e) {
  final Node<E> l = last;
  final Node<E> newNode = new Node<>(l, e, null);
  last = newNode;
  if (l == null)
    first = newNode;
  else
    l.next = newNode;
  size++;
  modCount++;
}
```

`linkLast(E e)`的步骤如下（其实就是尾插法）：

1.   创建一个新的节点`newNode`，`l`和`last`指向原来的尾节点，如果原来的链表为空，则为`null`。

     ```java
       final Node<E> newNode = new Node<>(l, e, null);
     ```

2.   修改尾节点`last`，指向新的最后节点`newNode`：

     ```java
     last = newNode;
     ```

3.   修改前节点的后向节点，这里需要注意，如果原来链表为空，则让头节点指向新的节点，否则让前一个节点的`next`指向新节点：

     ```java
       if (l == null)
         first = newNode;
       else
         l.next = newNode;
     ```

4.   增加链表的大小和记录修改次数

**举例：**

```java
List<String> list = new LinkedList<>();
list.add("a");
list.add("b");
```

执行顺序如图：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220426195734078.png" alt="image-20220426195734078" style="zoom: 50%;" />

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220426195741620.png" alt="image-20220426195741620" style="zoom:40%;" />

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220426195750036.png" alt="image-20220426195750036" style="zoom:40%;" />

`LinkedList`的内存是按需分配，添加元素只需要分配新元素的空间。



### 根据索引访问元素get方法

`get`方法根据索引访问元素：

```java
public E get(int index) {
  checkElementIndex(index);
  return node(index).item;
}

```

`checkElementIndex`检查索引位置的有效性，如果无效则抛出异常：

```java

private void checkElementIndex(int index) {
  if (!isElementIndex(index))
    throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
}
//判断参数是否有现元素的索引
private boolean isElementIndex(int index) {
  return index >= 0 && index < size;
}
```

如果`index`有效，则调用`node`方法查找对应的节点，其`item`属性就指向实际元素内容：

```java
Node<E> node(int index) {
  // assert isElementIndex(index);

  //size >> 1等于 size / 2
  if (index < (size >> 1)) {
    Node<E> x = first;
    for (int i = 0; i < index; i++)
      x = x.next;
    return x;
  } else {
    Node<E> x = last;
    for (int i = size - 1; i > index; i--)
      x = x.prev;
    return x;
  }
}
```

如果索引位置在前半部分，则从头节点开始查找，否则从后半部分开始查找。



### 根据内容查找元素indexOf

```java
public int indexOf(Object o) {
  int index = 0;
  if (o == null) {
    for (Node<E> x = first; x != null; x = x.next) {
      if (x.item == null)
        return index;
      index++;
    }
  } else {
    for (Node<E> x = first; x != null; x = x.next) {
      if (o.equals(x.item))
        return index;
      index++;
    }
  }
  return -1;
}

```

为什么`o`是`null`要单独拿出来？

>   原因在于`null`没有`equals`。
>
>   可能会有人问：那我把` if (o.equals(x.item))`改成`if(x.item.equals(o))`呢？
>
>   也不行，`x.item`也有可能是`null`。
>
>   `null`要用`==`来比较



### 在头部或中间插入元素add(index, element)

```java
public void add(int index, E element) {
  checkPositionIndex(index);

  if (index == size)
    linkLast(element);
  else
    linkBefore(element, node(index));
}
```

特殊情况是：如果`index`为`size`，添加到最后。一般情况下，插入到`index`对应节点的前面，调用`linkBefore`：

```java
void linkBefore(E e, Node<E> succ) {
  // assert succ != null;
  final Node<E> pred = succ.prev;
  final Node<E> newNode = new Node<>(pred, e, succ);
  succ.prev = newNode;
  if (pred == null)
    first = newNode;
  else
    pred.next = newNode;
  size++;
  modCount++;
}

```

`succ`表示后继节点，`pred`表示前驱节点，目标是在`succ`和`pred`之间插入一个节点：

1.   新建一个节点`newNode`，前驱为`pred`，后继为`succ`。

2.   让后继的前驱节点指向新节点。

     ```java
     succ.prev = newNode;
     ```

3.   让前驱的后继指向新节点，如果前驱为空，则修改头节点指向新节点。

     ```java
      if (pred == null)
         first = newNode;
       else
         pred.next = newNode;
     ```

4.   增加长度，修改次数。

### 删除元素 remove

```java
public E remove(int index) {
  checkElementIndex(index);
  return unlink(node(index));
}
```

通过`node`方法找到了节点后，调用了`unlink`方法：

```java
E unlink(Node<E> x) {
  // assert x != null;
  final E element = x.item;
  final Node<E> next = x.next;
  final Node<E> prev = x.prev;

  //如果前驱为空，则证明删除的是第一个节点
  if (prev == null) {
    //头指针first指向第二个节点
    first = next;
  } else {
    //前驱的后继等于x的后继
    prev.next = next;
    //x的前驱为空
    x.prev = null;
  }

  //如果后继为空，则证明删除的是最后一个元素
  if (next == null) {
    //尾指针last指向倒数第二个节点
    last = prev;
  } else {
    //后继的前驱等于x的前驱
    next.prev = prev;
    //x的后继为空
    x.next = null;
  }

  x.item = null;
  size--;
  modCount++;
  return element;
}
```

删除`x`节点，思路就是让`x`的前驱和后继连接起来。

## LinkedList的特点

1.   按需分配空间，不需要预先分配空间
2.   不可以随机访问，按照索引位置的访问效率比较低，为O(N)
3.   按内容查找也必须逐个比较
4.   在两端添加删除元素的时间复杂度为O(1)
5.   在中间插入、插入比较麻烦
6.   实现了`Deque`和`Queue`接口

