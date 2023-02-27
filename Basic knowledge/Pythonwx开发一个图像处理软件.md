# Pythonwx开发一个图像处理软件

## 1. 需求

最近接到老师的一个任务，要求开发一个图像处理的软件，处理图像的算法是学姐提供的，我只需要将其封装，做出一个界面，主要有如下功能：

-   选择一张图片进行增强
-   选择两张图片进行融合



在网上调研一番后，选择使用pythonwx开发，主要原因有下：

-   mac上qt太大了，256G存储空间捉襟见肘
-   pyqt也是，并且安装费劲
-   pythonwx很小，通过anaconda安装后，能够顺利运行。但是需要注意，通过anaconda安装的pythonwx，路径要选择`pthonw`而不是那个python。



## 2. 从0开始

### 2.1 Helloworld

OK，直接开始吧。



```python
import wx

# 每个wxpython程序都必须有一个应用程序对象
app = wx.App()

# wx.Frame是一个重要的容器组件,它是其他组件的父组件
frame = wx.Frame(None, title='Simple application')
# 创建了wx.Frame后，必须用show()将其显示在屏幕上
frame.Show()

# 主循环是一个无限循环
app.MainLoop()
```



如果不调用`Show()`，则会没有页面，但是会显示程序。

>   需要注意的是，wxpython的所有函数都是首字母大写，非常地不友好。





### 2.2 wx.Frame

`wx.Frame`是wxPython最重要的组件之一。它可以包含其他组件。`wx.Frame`包含一个标题栏`title bar`、边框borders和一个中央容器区域central container area。标题栏和边框是可选的。它们可以通过各种标志flags去除。

`wxFrame`的构造函数：

```python
wx.Frame(wx.Window parent, int id=-1, string title='', wx.Point pos=wx.DefaultPosition, wx.Size size=wx.DefaultSize,style=wx.DEFAULT_FRAME_STYLE, string name="frame")
```



构造函数有七个参数。第一个参数没有默认值。其他六个参数有。我们可以通过改变`style=wx.DEFAULT_FRAME_STYLE`的值来修改`wx.Frame`组件的样式，例如可伸缩、可以最小化等等。



### 2.2 大小和位置

我们可以通过两种方式指定应用程序的大小：

-   在构造函数中使用`size`参数
-   调用`SetSize()`方法





**set_size.py**

```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# set_size.py

import wx


#设置应用程序的大小为1200 * 700，前者为宽，后者为高
class Example(wx.Frame):
    def __init__(self, parent, title):
        super(Example, self).__init__(parent, title=title,
            size=(1200, 700))
        #保证窗口在中央
        self.Centre()

def main():
    app = wx.App()
    ex = Example(None, title='Sizing')
    ex.Show()
    app.MainLoop()


if __name__ == '__main__':
    main()
```

这样可以保证窗口大小合适，且在中央。





## 2. 菜单栏和工具栏



### 2.1 简单的菜单栏

（几乎）每个GUI程序都有菜单栏。在wxPython中，有三个类用于创建菜单栏：`wx.MenuBar`，`wx.Menu`和`wx.MenuItem`。



**simple_menu.py**

```python

import wx


class Example(wx.Frame):

    def __init__(self, *args, **kwargs):
        super(Example, self).__init__(*args, **kwargs)

        self.InitUI()

    def InitUI(self):

        #创建一个菜单栏对象
        menubar = wx.MenuBar()
        #创建一个菜单对象
        fileMenu = wx.Menu()

        #将某一项添加到一个菜单中
        #第一个参数是menuItem的id，标准id会自动添加图标和快捷键
        #第二个参数是menuItem的名称，也就是显示在屏幕上的
        #第三个参数是简短帮助
        # 返回创建的菜单项，之后可以用来绑定事件
        fileItem = fileMenu.Append(wx.ID_EXIT, 'Quit', 'Quit application')

        #将菜单添加到菜单栏中, menubar
        menubar.Append(fileMenu, '&File')
        self.SetMenuBar(menubar)

        #将菜单栏的退出事件绑定器绑定到自定义方法 OnQuit，它将关闭应用程序
        self.Bind(wx.EVT_MENU, self.OnQuit, fileItem)

        self.SetSize((300, 200))
        self.SetTitle('Simple menu')
        self.Centre()

    def OnQuit(self, e):
        self.Close()


def main():

    app = wx.App()
    ex = Example(None)
    ex.Show()
    app.MainLoop()


if __name__ == '__main__':
    main()
```



但是这个代码在我的电脑（M1 Mac）上，没有显示Quit，只显示了File。

### 2.2 子菜单和分隔符





## 3. 布局

在 wxPython 中，可以使用绝对定位或使用 sizers 来布局组件。

绝对定位有几个缺点：

-   如果调整窗口大小，组件的大小不会随之改变。
-   在不同平台看起来不同
-   重做非常麻烦



### 3.1 绝对布局



**absolute.py**

```python


import wx


class Example(wx.Frame):

    def __init__(self, parent, title):
        super(Example, self).__init__(parent, title=title,
            size=(350, 300))

        self.InitUI()
        self.Centre()

    def InitUI(self):

        self.panel = wx.Panel(self)

        self.panel.SetBackgroundColour("gray")

        self.LoadImages()

        self.mincol.SetPosition((20, 20))
        self.bardejov.SetPosition((40, 160))
        self.rotunda.SetPosition((170, 50))


    def LoadImages(self):

        self.mincol = wx.StaticBitmap(self.panel, wx.ID_ANY,
            wx.Bitmap("../assets/bars.jpg", wx.BITMAP_TYPE_ANY))

        self.bardejov = wx.StaticBitmap(self.panel, wx.ID_ANY,
            wx.Bitmap("../assets/base.jpg", wx.BITMAP_TYPE_ANY))

        self.rotunda = wx.StaticBitmap(self.panel, wx.ID_ANY,
            wx.Bitmap("../assets/burning.png", wx.BITMAP_TYPE_ANY))


def main():

    app = wx.App()
    ex = Example(None, title='Absolute positioning')
    ex.Show()
    app.MainLoop()


if __name__ == '__main__':
    main()
```



我们调用 `SetBitmap()` 方法来显示图片，调用`self.mincol.SetPosition((20, 20))`来控制图片放置的坐标。



### 3.2 使用`sizer`

