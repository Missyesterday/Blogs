# 水果成篮

滑动窗口
先一直摘水果, 直到不符合规则, 再移动起始位置
用map记录水果的种类
滑动窗口的精髓在于判断条件
这里的判断条件是map >= 2,知道map的size为2代表水果满足两个
map 的key是水果种类,v是水果的个数(在当前窗口)
其余的操作类似于 209.长度最小的子数组

```cpp
//leetcode submit region begin(Prohibit modification and deletion)
class Solution{
public:
    int totalFruit(vector<int>& fruits)
    {
        //滑动窗口
        //先一直摘水果, 直到不符合规则, 再移动起始位置
        //用map记录水果的种类
        //滑动窗口的精髓在于判断条件
        //这里的判断条件是map >= 2,知道map的size为2代表水果满足两个
        //map 的key是水果种类,v是水果的个数(在当前窗口)
        unordered_map<int, int> fruits_map;
        int i = 0;
        int result = 0;
        for (int j = 0; j < fruits.size(); j++)
        {
            unordered_map<int, int>::iterator ret = fruits_map.find(fruits.at(j));
            if(ret == fruits_map.end())
            {
                //如果没有则插入
                fruits_map.insert(make_pair(fruits.at(j), 1));
            }
            else
            {
                //如果有，则value++
                (*ret).second++;
            }
            while(fruits_map.size() > 2)
            {
                //i++, fruits[i]对应的value--, 注意当value == 0, 需要remove
                unordered_map<int, int>::iterator ret2 = fruits_map.find(fruits.at(i));
                (*ret2).second--;
                if((*ret2).second <= 0)
                {
                    fruits_map.erase(ret2);
                }
                i++;
            }
            int subResult = 0;
            for(unordered_map<int, int>::iterator it = fruits_map.begin(); it != fruits_map.end(); it++)
            {
                subResult += (*it).second;
            }
            result = result > subResult ? result : subResult;
        }
        return result;
    }

};
```