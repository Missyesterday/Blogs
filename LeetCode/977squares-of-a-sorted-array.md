# 有序数组的平方

## 方法1: 暴力破解
先平方, 再排序. 调用库函数
```cpp
    //直接暴力破解
    vector<int> sortedSquares(vector<int>& nums) {
        //先平方
        for(int i = 0; i < nums.size(); ++i)
        {
            nums.at(i) *= nums.at(i);
        }
        //再排序
        sort(nums.begin(),  nums.end());
        return nums;
    }
```
时间复杂度为 O(n + nlogn)排序算法的时间复杂度为O(nlogn)

## 方法2: 使用双指针
由于数组是有序的,但是存在负数
设置两个指针,分别从前往后和从后往前遍历, 比较他们平方的大小, 放入result数组里

需要注意的是:
1. vector需要初始化设置大小
2. 循环语句的跳出需要包含相等的情况

```cpp
    vector<int> sortedSquares(vector<int>& nums) {
        //双指针法, 需要注意数组是有序的,只是分了正负
        //比较首位指针的平方大小,放入results数组里
        //vector需要分配空间, 因为使用的是at插入,而且是从后往前插入
        vector<int> result(nums.size(), 0);
        int i = nums.size() - 1;

        //需要注意,中间的那个元素也需要处理, for语句的跳出需要注意
        for(int left = 0, right = nums.size() - 1; left <= right; )
        {
            if(nums.at(left) * nums.at(left) < nums.at(right) * nums.at(right))
            {
                result.at(i--) = nums.at(right) * nums.at(right);
                right--;
            }
            else
            {
                result.at(i--) = nums.at(left) * nums.at(left);
                left++;
            }
        }
        return result;
    }
```
时间复杂度为 O(n)