# 每日

 

## 2023年05月09日

1.  首先需要知道要 排除的「用户」和「用户组」（的 SID）？

2.  写在哪里？

要排除的用户和用户组作为一个成员，用 vector 存在 CUpmSvcCtrl 中，并在 Init 时初始化。

3.  已有指向用户数据的指针pUserData, 包括：

​	Session ID

​	用户名

​	域名

​	SID

​	用户目录路径

​	用户目录名

​	等