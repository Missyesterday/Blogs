# 剖析HashMap

## 前言

### 概述

首先，Map在这里不是地图的意思，而是表示映射关系，是一个接口，实现`Map`接口有多种方式。`HashMap`实现的方式利用了哈希（Hash，有的地方也称之为散列）。

```java
public class HashMap<K,V> extends AbstractMap<K,V>
    implements Map<K,V>, Cloneable, Serializable {

```



-   `HashMap`，来自于JDK1.2的哈希表实现，JDK1.8底层使用数组+链表+红黑树来实现的（JDK1.7是使用数组+链表来实现的），使用拉链法解决冲突。

-   实现了`Map`接口，允许`null`键和`null`值，元素无序。
-   实现了`Cloneable`、`Serializable`标志性接口，支持克隆、序列化操作。
-   默认不同步，可以使用`Collections.synchronizedMap()`获得一个同步的`Map`。

### Map接口

`Map`有键和值的概念。一个键映射到一个值，`Map`按照键存储和访问值，键不能重复，每个键只会存储一份，给同一个键重复设值会覆盖原来的值。使用`Map`可以方便地处理需要根据键访问对象的场景，例如：

-   词典
-   记录某个字段出现的次数，键为字段，值为次数
-   管理配置文件中的配置项，每个配置项视为一个键值对

数组、`ArrayList`、`LinkedList`可以视为一种特殊的`Map`，键为索引，值为对象。



Java 8中`Map`接口的定义：

```java
public interface Map<K,V> {
  int size();//返回Map中键值对的个数
  boolean isEmpty()；//判空
  boolean containsKey(Object key)；//查看是否包含某个键
  boolean containsValue(Object value);//查看是否包含某个Value
  V get(Object key);//返回指定键的值，没有返回null
  V put(K key,V value);//保存键值对，如果键存在则覆盖
  V remove(Object key);//根据键删除键值对，返回被删除的Value，不存在返回null
  void putAll(Map<? extends K,? extends V> m);//保存m中所有的键值对到当前Map
  void clear();//清空Map
  Set<K> keySet();//返回Map中所有的键的集合，Set不允许有重复的元素，最多有一个null元素对象
  Collection<V> values();//返回Map中所有的Value的集合，Collection允许有重复的元素，可以用多个null
  Set<Map.Entry<K,V>> entrySet();//获取Map中所有键值对，返回Map.Entry<K,V>的一个Set
  boolean equals(Object o);
  int hashCode();
  /**
  从Java 8 开始新增的默认方法，未展示全部代码
  */
  //输入key和defaultValue，如果在Map中存在key则返回key对应的value，如果不存在key则返回defaultValue
  default V getOrDefault(Object key,V defaultValue){
    //...
  }
  //
  default void forEach(BiConsumer<? super K,? super V> action){
  	//...
  }
  default void replaceAll(BiFunction<? super K, ? super V, ? extends V> function) {
  	//...
  }
  //如果key没有对应的value或者对应的value为null，则将参数value对应到key，返回value
 	default V putIfAbsent(K key, V value) {
    //...
  }
  //当Map中存在<key,value>时才删除
  default boolean remove(Object key, Object value) {
    //...
  }
  //当Map中存在<key,oldValue>时，用newValue替代oldValue，没有则不替换
  default boolean replace(K key, V oldValue, V newValue) {
    //...
  }
  //输入ky，仅当当前的key存在对应的value且value不为null时才替换
  default V replace(K key, V value) {
    //...
  }
  //
  default V computeIfAbsent(K key,Function<? super K, ? extends V> mappingFunction) {
   //...
  }
  default V computeIfPresent(K key,BiFunction<? super K, ? super V, ? extends V> remappingFunction) {
    //...
  }
  default V merge(K key, V value, BiFunction<? super V, ? super V, ? extends V> remappingFunction) {
    //...
  }

}
  


```

Java 8中`Map`接口中的`Map.Entry`嵌套接口： 

```java
interface Entry<K,V> { //嵌套接口，表示一条键值对
  K getKey();//返回键值对的键
  V getValue();//返回键值对的值
  V setValue(V value);//设置新Value，返回旧的value
  boolean equals(Object o);
  int hashCode();
  public static <K extends Comparable<? super K>, V> Comparator<Map.Entry<K,V>> comparingByKey() {
    return (Comparator<Map.Entry<K, V>> & Serializable)
      (c1, c2) -> c1.getKey().compareTo(c2.getKey());
  }

  /**
   从Java 8开始新增的静态方法，根据key或value来比较Map.Entry,只列出ByValue的，ByKey的与ByValue一致。
    */
  public static <K, V extends Comparable<? super V>> Comparator<Map.Entry<K,V>> comparingByValue() {//返回Comparable ，按Value自然顺序比较Map.Entry 。
    return (Comparator<Map.Entry<K, V>> & Serializable)
      (c1, c2) -> c1.getValue().compareTo(c2.getValue());
  }
  public static <K, V extends Comparable<? super V>> Comparator<Map.Entry<K,V>> comparingByValue() {//返回一个Comparator，按Value的自然顺序比较Map.Entry
    return (Comparator<Map.Entry<K, V>> & Serializable)
      (c1, c2) -> c1.getValue().compareTo(c2.getValue());
  }
 }
```

### Set接口

`Set`是一个接口，表示没有重复元素的集合。

```java
public interface Set<E> extends Collection<E>
```

它扩展了`Collection`，但是没有添加任何新方法。不过它要求它的所有实现者保持`Set`的语义，即不能有重复元素。

所以`keySet()`方法返回了一个`Set`。`keySet()`、`values()`、`entrySet()`有一个共同特点：

**它们返回的都是视图，而不是复制的值**。因此基于返回值的修改会改变`Map`自身，例如：

```java
map.keySet().clear();
```

会删除所有的键值对。

## 实现原理

### 主要类属性

主要类属性包括一些默认值常量属性，还有一些关键属性。

```java
//默认初始容量为16，所有容量都必须是2的幂次
static final int DEFAULT_INITIAL_CAPACITY = 1 << 4; // aka 16
//最大容量为1 << 30，也就是2的30次方，int类型的范围是[-2^31 ~ 2^31-1]，所以2的30次方也就是int范围内最大的2的幂次
static final int MAXIMUM_CAPACITY = 1 << 30;
//默认加载因子为0.75
static final float DEFAULT_LOAD_FACTOR = 0.75f;
//链表转换为红黑树的阈值，当链表长度大于8时，链表转换为红黑树
static final int TREEIFY_THRESHOLD = 8;
/**
 * 红黑树还原为链表的阈值，当在扩容时，resize()方法的split()方法中使用到该字段
 * 在重新计算红黑树的节点存储位置后，当拆分成的红黑树链表内节点数量 小于等于6时，则将红黑树节点链表转换成普通节点链表。
 * <p>
 * 该字段仅仅在split()方法中使用到，在真正的remove删除节点的方法中时没有用到的，实际上在remove方法中，
 * 判断是否需要还原为普通链表的个数不是固定为6的，即有可能即使节点数量小于6个，也不会转换为链表，因此不能使用该变量！
 */
static final int UNTREEIFY_THRESHOLD = 6;
/**  * 哈希表树形化的最小容量阈值，
即当哈希表中的容量  大于等于64时，才允许树形化链表，否则不进行树形化，而是扩容。  */
static final int MIN_TREEIFY_CAPACITY = 64;
/**
 * 底层存储key-value数据的数组，长度必须是2的幂次方。由于HashMap使用"链地址法"解决哈希冲突，table中的一个节点是链表头节点或者红黑树的根节点。节点类型为Node类型，Node的实际类型可能表示链表节点，也可能是红黑树节点。
 这也是一个Java 8 和 Java 7 的区别
 */
transient Node<K, V>[] table;//也叫做哈希表或者哈希桶
//集合中键值对的数量
transient int size;
/**
 * 扩容阈值(容量 * 加载因子)，当哈希表的大小大于等于扩容阈值时，哈希表就会扩容。
 */
int threshold;
// 哈希表的加载因子
final float loadFactor;
```

### 主要内部类

`HashMap`的内部类非常多：

<img src="https://raw.github.com/Missyesterday/picgo/main/picgo/image-20220429174842264.png" alt="image-20220429174842264" style="zoom:40%;" />

我们主要看`Node`和`TreeNode`:

#### Node

Java 8的`HashMapo`的链表节点实现类，Java 7使用`Entry`类，只是名字不一样。

```java
static class Node<K,V> implements Map.Entry<K,V> {
    final int hash;//key的哈希值
    final K key;//键
    V value;//值
    Node<K,V> next;//下一个，拉链法处理冲突

    Node(int hash, K key, V value, Node<K,V> next) {
        this.hash = hash;
        this.key = key;
        this.value = value;
        this.next = next;
    }

    public final K getKey()        { return key; }
    public final V getValue()      { return value; }
    public final String toString() { return key + "=" + value; }

    public final int hashCode() {
        return Objects.hashCode(key) ^ Objects.hashCode(value);
    }

    public final V setValue(V newValue) {
        V oldValue = value;
        value = newValue;
        return oldValue;
    }

    public final boolean equals(Object o) {
        if (o == this)
            return true;
        if (o instanceof Map.Entry) {
            Map.Entry<?,?> e = (Map.Entry<?,?>)o;
            if (Objects.equals(key, e.getKey()) &&
                Objects.equals(value, e.getValue()))
                return true;
        }
        return false;
    }
}
```

其中，`key`和`value`表示键值对，`next`指向下一个节点，`hash`是`key`的哈希值。直接存储哈希值是为了在比较的时候加速计算。

#### TreeNode

Java 8中`HashMap`的红黑树节点实现类，直接实现了`LinkedHashMap.Entry`节点类。

有链表树化和树还原链表的方法，具有查找、存放、移除树节点的方法，具有调整平衡、左旋、右旋的方法。

```java
static final class TreeNode<K,V> extends LinkedHashMap.Entry<K,V> {
        TreeNode<K,V> parent;  // 父节点索引
        TreeNode<K,V> left;		//左子节点索引
        TreeNode<K,V> right;  //右子节点索引
        TreeNode<K,V> prev;    // 删除节点使用的辅助节点，指向原链表的前一个节点
        boolean red;   //节点的颜色，默认为红色
        TreeNode(int hash, K key, V val, Node<K,V> next) {
            super(hash, key, val, next);
        }

        /**
         * 返回包含此节点的树的根节点
         */
        final TreeNode<K,V> root() {
            //....
        }

        /**
         * 将该节点
         */
        static <K,V> void moveRootToFront(Node<K,V>[] tab, TreeNode<K,V> root) {
           //...
        }

        /**
         * Finds the node starting at root p with the given hash and key.
         * The kc argument caches comparableClassFor(key) upon first use
         * comparing keys.
         */
        final TreeNode<K,V> find(int h, Object k, Class<?> kc) {
            TreeNode<K,V> p = this;
            do {
                int ph, dir; K pk;
                TreeNode<K,V> pl = p.left, pr = p.right, q;
                if ((ph = p.hash) > h)
                    p = pl;
                else if (ph < h)
                    p = pr;
                else if ((pk = p.key) == k || (k != null && k.equals(pk)))
                    return p;
                else if (pl == null)
                    p = pr;
                else if (pr == null)
                    p = pl;
                else if ((kc != null ||
                          (kc = comparableClassFor(k)) != null) &&
                         (dir = compareComparables(kc, k, pk)) != 0)
                    p = (dir < 0) ? pl : pr;
                else if ((q = pr.find(h, k, kc)) != null)
                    return q;
                else
                    p = pl;
            } while (p != null);
            return null;
        }

        /**
         * Calls find for root node.
         */
        final TreeNode<K,V> getTreeNode(int h, Object k) {
            return ((parent != null) ? root() : this).find(h, k, null);
        }

        /**
         * Tie-breaking utility for ordering insertions when equal
         * hashCodes and non-comparable. We don't require a total
         * order, just a consistent insertion rule to maintain
         * equivalence across rebalancings. Tie-breaking further than
         * necessary simplifies testing a bit.
         */
        static int tieBreakOrder(Object a, Object b) {
            int d;
            if (a == null || b == null ||
                (d = a.getClass().getName().
                 compareTo(b.getClass().getName())) == 0)
                d = (System.identityHashCode(a) <= System.identityHashCode(b) ?
                     -1 : 1);
            return d;
        }

        /**
         * Forms tree of the nodes linked from this node.
         */
        final void treeify(Node<K,V>[] tab) {
            TreeNode<K,V> root = null;
            for (TreeNode<K,V> x = this, next; x != null; x = next) {
                next = (TreeNode<K,V>)x.next;
                x.left = x.right = null;
                if (root == null) {
                    x.parent = null;
                    x.red = false;
                    root = x;
                }
                else {
                    K k = x.key;
                    int h = x.hash;
                    Class<?> kc = null;
                    for (TreeNode<K,V> p = root;;) {
                        int dir, ph;
                        K pk = p.key;
                        if ((ph = p.hash) > h)
                            dir = -1;
                        else if (ph < h)
                            dir = 1;
                        else if ((kc == null &&
                                  (kc = comparableClassFor(k)) == null) ||
                                 (dir = compareComparables(kc, k, pk)) == 0)
                            dir = tieBreakOrder(k, pk);

                        TreeNode<K,V> xp = p;
                        if ((p = (dir <= 0) ? p.left : p.right) == null) {
                            x.parent = xp;
                            if (dir <= 0)
                                xp.left = x;
                            else
                                xp.right = x;
                            root = balanceInsertion(root, x);
                            break;
                        }
                    }
                }
            }
            moveRootToFront(tab, root);
        }

        /**
         * Returns a list of non-TreeNodes replacing those linked from
         * this node.
         */
        final Node<K,V> untreeify(HashMap<K,V> map) {
            Node<K,V> hd = null, tl = null;
            for (Node<K,V> q = this; q != null; q = q.next) {
                Node<K,V> p = map.replacementNode(q, null);
                if (tl == null)
                    hd = p;
                else
                    tl.next = p;
                tl = p;
            }
            return hd;
        }

        /**
         * Tree version of putVal.
         */
        final TreeNode<K,V> putTreeVal(HashMap<K,V> map, Node<K,V>[] tab,
                                       int h, K k, V v) {
            Class<?> kc = null;
            boolean searched = false;
            TreeNode<K,V> root = (parent != null) ? root() : this;
            for (TreeNode<K,V> p = root;;) {
                int dir, ph; K pk;
                if ((ph = p.hash) > h)
                    dir = -1;
                else if (ph < h)
                    dir = 1;
                else if ((pk = p.key) == k || (k != null && k.equals(pk)))
                    return p;
                else if ((kc == null &&
                          (kc = comparableClassFor(k)) == null) ||
                         (dir = compareComparables(kc, k, pk)) == 0) {
                    if (!searched) {
                        TreeNode<K,V> q, ch;
                        searched = true;
                        if (((ch = p.left) != null &&
                             (q = ch.find(h, k, kc)) != null) ||
                            ((ch = p.right) != null &&
                             (q = ch.find(h, k, kc)) != null))
                            return q;
                    }
                    dir = tieBreakOrder(k, pk);
                }

                TreeNode<K,V> xp = p;
                if ((p = (dir <= 0) ? p.left : p.right) == null) {
                    Node<K,V> xpn = xp.next;
                    TreeNode<K,V> x = map.newTreeNode(h, k, v, xpn);
                    if (dir <= 0)
                        xp.left = x;
                    else
                        xp.right = x;
                    xp.next = x;
                    x.parent = x.prev = xp;
                    if (xpn != null)
                        ((TreeNode<K,V>)xpn).prev = x;
                    moveRootToFront(tab, balanceInsertion(root, x));
                    return null;
                }
            }
        }

        /**
         * Removes the given node, that must be present before this call.
         * This is messier than typical red-black deletion code because we
         * cannot swap the contents of an interior node with a leaf
         * successor that is pinned by "next" pointers that are accessible
         * independently during traversal. So instead we swap the tree
         * linkages. If the current tree appears to have too few nodes,
         * the bin is converted back to a plain bin. (The test triggers
         * somewhere between 2 and 6 nodes, depending on tree structure).
         */
        final void removeTreeNode(HashMap<K,V> map, Node<K,V>[] tab,
                                  boolean movable) {
            int n;
            if (tab == null || (n = tab.length) == 0)
                return;
            int index = (n - 1) & hash;
            TreeNode<K,V> first = (TreeNode<K,V>)tab[index], root = first, rl;
            TreeNode<K,V> succ = (TreeNode<K,V>)next, pred = prev;
            if (pred == null)
                tab[index] = first = succ;
            else
                pred.next = succ;
            if (succ != null)
                succ.prev = pred;
            if (first == null)
                return;
            if (root.parent != null)
                root = root.root();
            if (root == null
                || (movable
                    && (root.right == null
                        || (rl = root.left) == null
                        || rl.left == null))) {
                tab[index] = first.untreeify(map);  // too small
                return;
            }
            TreeNode<K,V> p = this, pl = left, pr = right, replacement;
            if (pl != null && pr != null) {
                TreeNode<K,V> s = pr, sl;
                while ((sl = s.left) != null) // find successor
                    s = sl;
                boolean c = s.red; s.red = p.red; p.red = c; // swap colors
                TreeNode<K,V> sr = s.right;
                TreeNode<K,V> pp = p.parent;
                if (s == pr) { // p was s's direct parent
                    p.parent = s;
                    s.right = p;
                }
                else {
                    TreeNode<K,V> sp = s.parent;
                    if ((p.parent = sp) != null) {
                        if (s == sp.left)
                            sp.left = p;
                        else
                            sp.right = p;
                    }
                    if ((s.right = pr) != null)
                        pr.parent = s;
                }
                p.left = null;
                if ((p.right = sr) != null)
                    sr.parent = p;
                if ((s.left = pl) != null)
                    pl.parent = s;
                if ((s.parent = pp) == null)
                    root = s;
                else if (p == pp.left)
                    pp.left = s;
                else
                    pp.right = s;
                if (sr != null)
                    replacement = sr;
                else
                    replacement = p;
            }
            else if (pl != null)
                replacement = pl;
            else if (pr != null)
                replacement = pr;
            else
                replacement = p;
            if (replacement != p) {
                TreeNode<K,V> pp = replacement.parent = p.parent;
                if (pp == null)
                    root = replacement;
                else if (p == pp.left)
                    pp.left = replacement;
                else
                    pp.right = replacement;
                p.left = p.right = p.parent = null;
            }

            TreeNode<K,V> r = p.red ? root : balanceDeletion(root, replacement);

            if (replacement == p) {  // detach
                TreeNode<K,V> pp = p.parent;
                p.parent = null;
                if (pp != null) {
                    if (p == pp.left)
                        pp.left = null;
                    else if (p == pp.right)
                        pp.right = null;
                }
            }
            if (movable)
                moveRootToFront(tab, r);
        }

        /**
         * Splits nodes in a tree bin into lower and upper tree bins,
         * or untreeifies if now too small. Called only from resize;
         * see above discussion about split bits and indices.
         *
         * @param map the map
         * @param tab the table for recording bin heads
         * @param index the index of the table being split
         * @param bit the bit of hash to split on
         */
        final void split(HashMap<K,V> map, Node<K,V>[] tab, int index, int bit) {
            TreeNode<K,V> b = this;
            // Relink into lo and hi lists, preserving order
            TreeNode<K,V> loHead = null, loTail = null;
            TreeNode<K,V> hiHead = null, hiTail = null;
            int lc = 0, hc = 0;
            for (TreeNode<K,V> e = b, next; e != null; e = next) {
                next = (TreeNode<K,V>)e.next;
                e.next = null;
                if ((e.hash & bit) == 0) {
                    if ((e.prev = loTail) == null)
                        loHead = e;
                    else
                        loTail.next = e;
                    loTail = e;
                    ++lc;
                }
                else {
                    if ((e.prev = hiTail) == null)
                        hiHead = e;
                    else
                        hiTail.next = e;
                    hiTail = e;
                    ++hc;
                }
            }

            if (loHead != null) {
                if (lc <= UNTREEIFY_THRESHOLD)
                    tab[index] = loHead.untreeify(map);
                else {
                    tab[index] = loHead;
                    if (hiHead != null) // (else is already treeified)
                        loHead.treeify(tab);
                }
            }
            if (hiHead != null) {
                if (hc <= UNTREEIFY_THRESHOLD)
                    tab[index + bit] = hiHead.untreeify(map);
                else {
                    tab[index + bit] = hiHead;
                    if (loHead != null)
                        hiHead.treeify(tab);
                }
            }
        }

        /* ------------------------------------------------------------ */
        // Red-black tree methods, all adapted from CLR

        static <K,V> TreeNode<K,V> rotateLeft(TreeNode<K,V> root,
                                              TreeNode<K,V> p) {
            TreeNode<K,V> r, pp, rl;
            if (p != null && (r = p.right) != null) {
                if ((rl = p.right = r.left) != null)
                    rl.parent = p;
                if ((pp = r.parent = p.parent) == null)
                    (root = r).red = false;
                else if (pp.left == p)
                    pp.left = r;
                else
                    pp.right = r;
                r.left = p;
                p.parent = r;
            }
            return root;
        }

        static <K,V> TreeNode<K,V> rotateRight(TreeNode<K,V> root,
                                               TreeNode<K,V> p) {
            TreeNode<K,V> l, pp, lr;
            if (p != null && (l = p.left) != null) {
                if ((lr = p.left = l.right) != null)
                    lr.parent = p;
                if ((pp = l.parent = p.parent) == null)
                    (root = l).red = false;
                else if (pp.right == p)
                    pp.right = l;
                else
                    pp.left = l;
                l.right = p;
                p.parent = l;
            }
            return root;
        }

        static <K,V> TreeNode<K,V> balanceInsertion(TreeNode<K,V> root,
                                                    TreeNode<K,V> x) {
            x.red = true;
            for (TreeNode<K,V> xp, xpp, xppl, xppr;;) {
                if ((xp = x.parent) == null) {
                    x.red = false;
                    return x;
                }
                else if (!xp.red || (xpp = xp.parent) == null)
                    return root;
                if (xp == (xppl = xpp.left)) {
                    if ((xppr = xpp.right) != null && xppr.red) {
                        xppr.red = false;
                        xp.red = false;
                        xpp.red = true;
                        x = xpp;
                    }
                    else {
                        if (x == xp.right) {
                            root = rotateLeft(root, x = xp);
                            xpp = (xp = x.parent) == null ? null : xp.parent;
                        }
                        if (xp != null) {
                            xp.red = false;
                            if (xpp != null) {
                                xpp.red = true;
                                root = rotateRight(root, xpp);
                            }
                        }
                    }
                }
                else {
                    if (xppl != null && xppl.red) {
                        xppl.red = false;
                        xp.red = false;
                        xpp.red = true;
                        x = xpp;
                    }
                    else {
                        if (x == xp.left) {
                            root = rotateRight(root, x = xp);
                            xpp = (xp = x.parent) == null ? null : xp.parent;
                        }
                        if (xp != null) {
                            xp.red = false;
                            if (xpp != null) {
                                xpp.red = true;
                                root = rotateLeft(root, xpp);
                            }
                        }
                    }
                }
            }
        }

        static <K,V> TreeNode<K,V> balanceDeletion(TreeNode<K,V> root,
                                                   TreeNode<K,V> x) {
            for (TreeNode<K,V> xp, xpl, xpr;;) {
                if (x == null || x == root)
                    return root;
                else if ((xp = x.parent) == null) {
                    x.red = false;
                    return x;
                }
                else if (x.red) {
                    x.red = false;
                    return root;
                }
                else if ((xpl = xp.left) == x) {
                    if ((xpr = xp.right) != null && xpr.red) {
                        xpr.red = false;
                        xp.red = true;
                        root = rotateLeft(root, xp);
                        xpr = (xp = x.parent) == null ? null : xp.right;
                    }
                    if (xpr == null)
                        x = xp;
                    else {
                        TreeNode<K,V> sl = xpr.left, sr = xpr.right;
                        if ((sr == null || !sr.red) &&
                            (sl == null || !sl.red)) {
                            xpr.red = true;
                            x = xp;
                        }
                        else {
                            if (sr == null || !sr.red) {
                                if (sl != null)
                                    sl.red = false;
                                xpr.red = true;
                                root = rotateRight(root, xpr);
                                xpr = (xp = x.parent) == null ?
                                    null : xp.right;
                            }
                            if (xpr != null) {
                                xpr.red = (xp == null) ? false : xp.red;
                                if ((sr = xpr.right) != null)
                                    sr.red = false;
                            }
                            if (xp != null) {
                                xp.red = false;
                                root = rotateLeft(root, xp);
                            }
                            x = root;
                        }
                    }
                }
                else { // symmetric
                    if (xpl != null && xpl.red) {
                        xpl.red = false;
                        xp.red = true;
                        root = rotateRight(root, xp);
                        xpl = (xp = x.parent) == null ? null : xp.left;
                    }
                    if (xpl == null)
                        x = xp;
                    else {
                        TreeNode<K,V> sl = xpl.left, sr = xpl.right;
                        if ((sl == null || !sl.red) &&
                            (sr == null || !sr.red)) {
                            xpl.red = true;
                            x = xp;
                        }
                        else {
                            if (sl == null || !sl.red) {
                                if (sr != null)
                                    sr.red = false;
                                xpl.red = true;
                                root = rotateLeft(root, xpl);
                                xpl = (xp = x.parent) == null ?
                                    null : xp.left;
                            }
                            if (xpl != null) {
                                xpl.red = (xp == null) ? false : xp.red;
                                if ((sl = xpl.left) != null)
                                    sl.red = false;
                            }
                            if (xp != null) {
                                xp.red = false;
                                root = rotateRight(root, xp);
                            }
                            x = root;
                        }
                    }
                }
            }
        }

        /**
         * Recursive invariant check
         */
        static <K,V> boolean checkInvariants(TreeNode<K,V> t) {
            TreeNode<K,V> tp = t.parent, tl = t.left, tr = t.right,
                tb = t.prev, tn = (TreeNode<K,V>)t.next;
            if (tb != null && tb.next != t)
                return false;
            if (tn != null && tn.prev != t)
                return false;
            if (tp != null && t != tp.left && t != tp.right)
                return false;
            if (tl != null && (tl.parent != t || tl.hash > t.hash))
                return false;
            if (tr != null && (tr.parent != t || tr.hash < t.hash))
                return false;
            if (t.red && tl != null && tl.red && tr != null && tr.red)
                return false;
            if (tl != null && !checkInvariants(tl))
                return false;
            if (tr != null && !checkInvariants(tr))
                return false;
            return true;
        }
    }
```



## 参考

[HashMap源码深度解析（深入至红黑树实现）以及与JDK7的区别【四万字】](https://blog.csdn.net/weixin_43767015/article/details/106889320)

[《Java编程的逻辑》 马俊昌](https://weread.qq.com/book-detail?type=1&senderVid=22415367&v=b51320f05e159eb51b29226kcfc32da010cfcd208495488 )