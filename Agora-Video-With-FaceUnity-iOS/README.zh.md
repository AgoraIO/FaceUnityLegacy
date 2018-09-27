

这个开源示例项目演示了如果快速集成 [Agora](www.agora.io) 视频 SDK 和 [Faceunity](http://www.faceunity.com) 美颜 SDK，实现一对一视频聊天。

在这个示例项目中包含以下功能：

Agora 

- 加入通话和离开通话
- 实现一对一视频聊天
- 静音和解除静音

Faceunity

- 贴纸，滤镜，美颜滤镜，美肤，美型功能
- 切换采集模式
- 切换前置摄像头和后置摄像头

本项目采用了 Faceunity 提供的视频采集，美颜，本地渲染等视频前处理功能，使用了 Agora 提供的声音采集，编码，传输，解码和远端渲染功能。

Faceunity 美颜功能实现请参考 [Faceunity 官方文档](http://www.faceunity.com/technical/)

Agora 功能实现请参考 [Agora 官方文档](https://docs.agora.io/cn/2.1.2/product/Interactive%20Broadcast/API%20Reference/live_video_ios?platform=iOS)

由于在使用美颜的时候需要使用第三方采集，请特别参考[自定义设备API](https://docs.agora.io/cn/2.1.2/product/Interactive%20Broadcast/API%20Reference/custom_live_ios?platform=iOS#agoravideosourceprotocol)  或者 [自采集API](https://docs.agora.io/cn/2.1.2/product/Interactive%20Broadcast/API%20Reference/custom_live_ios?platform=iOS#agoravideosourceprotocol)

## 运行示例程序
首先在 [Agora.io 注册](https://dashboard.agora.io/cn/signup/) 注册账号，并创建自己的测试项目，获取到 AppID。将 AppID 填写进 KeyCenter.m

```
+ (NSString *)AppId {
     return @"Your App ID";
}
```
然后在 [Agora.io SDK](https://www.agora.io/cn/download/) 下载 视频通话 + 直播 SDK，解压后将其中的 libs/AgoraRtcEngineKit.framework 复制到本项目的 “AgoraWithFaceunity” 文件夹下。

请联系 [Faceunity](http://www.faceunity.com) 获取证书文件替换本项目/AgoraWithFaceunity/Faceunity 文件夹中的 ”authpack.h“ 文件。

最后使用 XCode 打开 AgoraWithFaceunity.xcodeproj，连接 iPhone／iPad 测试设备，设置有效的开发者签名后即可运行。

## 运行环境
* XCode 8.0 +
* iOS 真机设备
* 不支持模拟器

## 联系我们

- 完整的 API 文档见 [文档中心](https://docs.agora.io/cn/)
- 如果在集成中遇到问题，你可以到 [开发者社区](https://dev.agora.io/cn/) 提问
- 如果有售前咨询问题，可以拨打 400 632 6626，或加入官方Q群 12742516 提问
- 如果需要售后技术支持，你可以在 [Agora Dashboard](https://dashboard.agora.io) 提交工单
- 如果发现了示例代码的bug，欢迎提交 [issue](https://github.com/AgoraIO/Agora-Video-With-FaceUnity-iOS/issues)

## 代码许可

The MIT License (MIT).


