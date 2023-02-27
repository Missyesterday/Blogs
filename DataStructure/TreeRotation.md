# 树的旋转

在数据结构中，旋转是对二叉树的一种操作，但是在数据结构的一般教材中，并没有对其有过多介绍，这就导致了很多误解：

- 什么是旋转？

- 如何旋转？

## 什么是旋转

首先，树的旋转一般发生在排序二叉树中，比如：BST、红黑树等。他们本身的数据之间是有序的，左孩子的值<根<右孩子。

树的旋转很简单，就是将一个结点上移，一个结点下移，同时不能改变元素的顺序，旋转后依旧满足左孩子的值<根<右孩子。

如图是一颗排序二叉树，A、B是结点，$\alpha$、$\beta$、$\gamma$ 是子树：

![](pic/Tree_rotation_animation_250x250.gif)

该图有两次旋转

- 一次是A结点上移，B结点下移

- 另一次则是反过来

同时排序二叉树的性质未被破坏。

## 如何旋转

旋转的部分一般是子树，因此我们形容旋转的时候用：以某节点为轴左旋转或右旋转

## 旋转的方向

那么问题又来了，怎么判断旋转是左旋转还是右旋转呢？

其实这个问题是有争议的，有些人认为旋转方向应该反映节点的移动方向（左子树旋转到父节点的位置为右旋），有些人则认为旋转方向应该反映被旋转的子树是哪棵（左子树旋转到父节点的位置为左旋，与前一种说法相反）。

==一般来说，采用前一种定义，也就是左子树旋转到父节点称为右旋转。==

那么上图的旋转完整的说法就是：针对A节点左旋转和针对B节点的右旋转。