![](http://ww4.sinaimg.cn/large/7a1656d9gw1f343yvzdn5j20mf099jrk.jpg)

# RainReminder

**Version 1.2.1** | [![Build Status](https://ci.swift.org/job/oss-swift-incremental-RA-osx/badge/icon)](https://ci.swift.org/job/oss-swift-incremental-RA-osx)

> 简洁的Swift天气预报软件.(ps:简洁是因为复杂的我还不会orz)
   
明天要下雨,你记得要带伞了吗？  
明天要降温,你记得要多穿衣服了吗？  
明天要刮风,你记得要口罩了吗？  

简洁的天气预报软件,简洁的操作,手势下拉搜索,或上滑显示七天预报.  
还可以使用中文搜索中国其它地区的天气哦.  
目前只支持中国国内地区,搜索暂不支持海外.  
设置中可以设置提醒的时间.下雨或异常天气才会提醒哦.  

支持微博分享当天天气内容.  

联系邮箱: easyulife@gmail.com 
讨论Q群: 188255611

####WebSite: [RainReminder-Swift天气应用](http://www.tongchao.xyz/2016/05/04/rainreminder-swifttian-qi-ying-yong/)  
####AppStore: [已上架AppStore](https://itunes.apple.com/us/app/rainreminder/id1102738128?l=zh&ls=1&mt=8)   

## GIF

![探索应用](http://ww4.sinaimg.cn/large/7a1656d9gw1f3jrhog0r0g20af0ij48m.gif)
![七天预报](http://ww3.sinaimg.cn/large/7a1656d9gw1f3jrid7oqag20af0ij1e0.gif)
![通知](http://ww4.sinaimg.cn/large/7a1656d9gw1f3jrgot1p0g20af0ij7ot.gif)
![搜索](http://ww3.sinaimg.cn/large/7a1656d9gw1f3jrh3l5wmg20af0ijmzh.gif)
![分享到微博](http://ww4.sinaimg.cn/large/7a1656d9gw1f3jrhcmnj7g20af0ijgzi.gif)
![Today Widget](http://ww4.sinaimg.cn/large/7a1656d9gw1f3jri3fcalg20af0ijdsl.gif)


## Installing/Getting started  
  
  
- 拥有一台Mac,并且安装了最新的Xcode.
- 需要开发证书,个人证书(free自行google),苹果开发者购买(99$/year) or taobao(ps:虚拟机开发不许要证书,相关开发功能受限,区别自行google)
- 安装cocoapods.(自行google)
- git clone project,then 使用terminal 

```shell
pod install
```  

- 打开`RainReminder.xcworkspace`,修改`Bundle Identifier`名称,修改`Team`里的证书
- 在`Build Settings` -> `Code Signing`, 修改签名.

> 没有开发者证书的,把`today`相关信息删除.这个是Today Widget部分.
> 注意有两个分支通常以通过审核版本会放在master里,开发版会放在develop里。
> 出现任何问题可以make a issue,或者发送email:info@easyulife.com(尽可能一次性描述你的问题)

## Developing

如何学习此项目(首先,写的不好,仅限初学者学习)
代码比较易懂,没有过多的封装,所以没有很详细的介绍.
通过本项目可以比较熟悉的了解以下内容:

- 使用Alamofire库进行网络请求
- 使用SwiftyJSON解析JSON数据
- 使用UserDefault保存数据
- 使用NSCoding协议归档数据
- 使用TableView,CollectionView
- 使用SDWebImage获取网络图片
- WeiboSDK获取授权并发送微博
- 本地通知
- 商品内购
- 使用定位服务并获取`CLPlacemark`相关信息
- Today Widget

> 以上内容都会以项目代码为实例`‘尽快’`编写相关教程(如果这个项目有人star的话...目标100个就写好不好)

## Features  

***这款应用能干什么呢?***  

* 当然是获取天气啦,信息由和风天气提供3小时更新,7天预报  
* 搜索中国地区天气  
* 设置提醒(明天要下雨啦,明天降温了,明天热死了)  
* 分享到微博,App专用小尾巴(来自RainReminder)  
* Today Widget

## Contributing

- [Alamofire](https://github.com/Alamofire/Alamofire)
- [SDWebImage](https://github.com/rs/SDWebImage)
- [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)
- [icon](https://erikflowers.github.io/weather-icons/)
- [FloatingActionSheetController](https://github.com/ra1028/FloatingActionSheetController)
- 使用知乎日报启动图片api(总是推广告图片,烦死了,目前图片地址给我写死了，改天换代码家的妹子图)
- 我看这个入门的[SwiftWeather](https://github.com/JakeLin/SwiftWeather)(对了，图标也是他们家的)
- 搬了很多他的代码[UmbrellaWeather](https://github.com/ZeroJian/UmbrellaWeather)
- 和风天气api,记得用自己的key,免费用户一天只有3000(这个项目会有人看吗？)

## Contact Me

- [weibo](http://weibo.com/2048284377)
- <easyulife@gmail.com>
- Job for me[简历](https://github.com/ChaosTong/resume), 坐标: 上海

## Licensing

The MIT License (MIT)

Copyright (c) 2015 ChaosTong

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.