# 移除元素

## 暴力破解
使用两重循环:
1. 第一重循环用来找==val的情况
2. 如果true, 则第二重循环用来从后往前移动元素

```cpp
    //方法1:暴力破解
    int removeElement(vector<int>& nums, int val)
    {
        int size = nums.size();
        for (int i = 0; i != size; ++i)
        {
            if (nums.at(i) == val)
            {
                for (int j = i + 1; j != size; ++j)
                {
                    nums.at(j - 1) = nums.at(j);
                }
                i--;
                size--;
            }
        }
        return  size;
    }

```
## 快慢指针
首先需要理解快慢指针的含义:
- 快指针用来向后寻找符合条件(`!= val`)的元素
- 慢指针用来存储快指针找到的符合条件的元素, 用快指针找到的元素直接覆盖慢指针指向的位置即可
- 慢指针指向的是符合条件的数组的**下一个元素**, 因此直接返回slow即可
- 快慢指针的精髓在于: **不知道slow指向的位置的情况,只保证slow之前的元素符合条件, 用fast去找符合条件的元素**

```cpp
    //方法2: 快慢指针
    int removeElement(vector<int> &nums, int val)
    {
        int fast = 0, slow = 0;
        for(; fast < nums.size(); fast++)
        {
            //找到符合条件的数组元素, 也就是 != val
            if(nums.at(fast) != val)
            {
                //更新slow, slow++
                nums.at(slow) = nums.at(fast);
                slow++;
             }
        }
        return slow;
    }
}
```