# 长度最小的子数组
经典问题

## 暴力破解
两个for循环

## 滑动窗口
双指针方法
**用一个for循环做两个for循环的事情.**

for循环的j是终止位置, 如果想计算起始位置, 需要额外定义一个i来动态移动起始位置,如何移动起始位置则是滑动窗口的精髓.

- 如果集合里的所有元素和大于等于s, 则调整起始位置,这样就能收集不同区间的和

**滑动窗口的重点是:**
1. for循环里面是终止位置
2. sum是动态变化的,不需要每次循环赋0
3. 起始位置的变化很关键, 同时起始位置遍历过就不再返回了.
```cpp
    //滑动窗口
    int minSubArrayLen(int target, vector<int> &nums)
    {
        int result = INT32_MAX;
        int sum = 0;
        int i = 0; //起始位置
        int subLen = 0;
        for(int j = 0; j < nums.size(); j++)
        {
            sum += nums.at(j);
            while(sum >= target)
            {
                subLen = j - i + 1;
                result = result > subLen ? subLen : result;
                sum -= nums.at(i++);//滑动窗口的精髓
            }
        }
        return  result == INT32_MAX ? 0 : result;
    }
```