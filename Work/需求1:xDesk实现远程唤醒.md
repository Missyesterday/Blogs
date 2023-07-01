# xDesk远程唤醒

## 需求背景

当前「纳管工作站」不支持跨网段远程唤醒，在部分客户侧无法满足其要求；如果依赖第三方工具，对用户侧网络的影响比较大，期望有一种成熟的方案（屏蔽第三方工具）远程唤醒跨网段的纳管工作站。

## 需求陈述

当 VDC 和 托管工作站 处于不同网段的时候，当前无法支持远程唤醒。

## 竞品分析

1.   华三

     跨网段远程唤醒需要实测，还没测；同网段测试偶尔失败

2.   思杰

     支持两种远程唤醒模式[https://docs.citrix.com/zh-cn/citrix-virtual-apps-desktops/install-configure/remote-pc-access.html](https://docs.citrix.com/zh-cn/citrix-virtual-apps-desktops/install-configure/remote-pc-access.html)

     1.   自研唤醒
     2.   SCCM 集成

     

## 补充

不要改变客户已有的网络架构，例如 IP 获取方式