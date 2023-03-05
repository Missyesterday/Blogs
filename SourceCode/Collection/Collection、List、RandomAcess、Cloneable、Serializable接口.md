# Collection、List、RandomAcess、Cloneable、Serializable接口

## 简介

Java的各种容器有一些共性的操作，这些共性的操作以接口的方式体现，有Iterable接口(可见[这篇文章](迭代器.md))，除此之外，还有几个重要的接口：Collection、List、RandomAcess、Cloneable、Serializable接口。

## Collection

`Collection`表示一个数据集合，数据间没有位置或顺序的概念，Java 8中的接口定义为：

```java
public interface Collection<E> extends Iterable<E> {
    int size();
    boolean isEmpty();
    boolean contains(Object o);
    Iterator<E> iterator();
    Object[] toArray();
    <T> T[] toArray(T[] a);
    boolean add(E e);
    boolean remove(Object o);
    boolean addAll(Collection<? extends E> c);
    boolean removeAll(Collection<?> c);
    default boolean removeIf(Predicate<? super E> filter) {XXX}
    boolean retainAll(Collection<?> c);
    void clear();
    boolean equals(Object o);
    int hashCode();
    default Spliterator<E> spliterator() {XXX}
    default Stream<E> stream() {XXX}
 		default Stream<E> parallelStream() {XXX}
  
}
```

其中默认方法是Java 8 新增的。`toArray()`方法是把`Collection`对象转为数组。`addAll()`表示添加，`removeAll()`表示删除，`containsAll()`表示检查是否包含了参数容器中的所有元素，只有全包含才返回true, `retainAll()`表示只保留参数容器中的元素，其他元素会进行删除。

抽象类`AbstractCollection`实现了`Collection`接口，对上面的方法都提供了默认实现，实现的方法就是利用迭代器方法逐个操作。例如`removeAll()`的代码：

```java
public boolean removeAll(Collection<?> c) {
  Objects.requireNonNull(c);
  boolean modified = false;
  Iterator<?> it = iterator();
  while (it.hasNext()) {
    if (c.contains(it.next())) {
      it.remove();
      modified = true;
    }
  }
  return modified;
}
```

代码比较简单。

`ArrayList`继承了 `AbstractList`，而`AbstractList`又继承了`AbstractCollection`，`ArrayList`对其中的一些方法进行了重写，来提供更为高效的实现。



## List

`List`表示有顺序或者位置的顺序集合，它扩展了`Collection`，**增加的主要方法有（Java 8 ）**

```java
public interface List<E> extends Collection<E> {
    E get(int index);
    E set(int index, E element);
    void add(int index, E element);
    E remove(int index);
    int lastIndexOf(Object o);
    ListIterator<E> listIterator();
    ListIterator<E> listIterator(int index);
    List<E> subList(int fromIndex, int toIndex);
    default void sort(Comparator<? super E> c){XXX}
    default void replaceAll(UnaryOperator<E> operator) {XXX}
		default Spliterator<E> spliterator() {XXX}
}
```

这些方法都和位置有关，默认方法会有实现。



##  RandomAccess

`RandomAccess`的定义为：

```java
public interface RandomAccess {
}

```

这个接口里面没有任何代码。<u>这种没有任何代码的接口在Java中被称为标记接口，用于声明类的一种属性。</u>

<u>实现了`RandomAccess`接口的类表示可以随机访问。</u>

> 声明了`RandomAccess`在一些通用的算法代码中，它可以根据这个声明而选择效率更高的实现。

例如，`Collections`类中有一个方法`binarySearch()`，在`List`中进行二分查找，他的实现代码就根据`list`是否实现了`RandomAccess`而采用不同的实现机制。

```java
public static <T>
  int binarySearch(List<? extends Comparable<? super T>> list, T key) {
  if (list instanceof RandomAccess || list.size()<BINARYSEARCH_THRESHOLD)
    return Collections.indexedBinarySearch(list, key);
  else
    return Collections.iteratorBinarySearch(list, key);
}
```

## Cloneable、Serializable

它们都是标记接口，代表是否能被clone和序列化