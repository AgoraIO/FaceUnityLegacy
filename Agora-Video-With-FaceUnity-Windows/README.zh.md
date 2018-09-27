# Agora-FaceUnity-Tutorial-Windows

* 其他语言版本: [英文](README.md)

 这个开源示例代码演示了如何快速的集成 Agora-FaceUnity-Tutorial-Windows. 这个demo包含以下功能模块

 - Agora直播功能
 - Faceunity 贴纸，滤镜，美颜

 本开源程序采用 **C++** 语言

Agora-FaceUnity-Tutorial-Windows 还支持 Android / IOS 平台，你可以查看对应其他平台的示例程序

- https://github.com/AgoraIO-Community/Agora-Video-With-FaceUnity-Android
- https://github.com/AgoraIO-Community/Agora-Video-With-FaceUnity-IOS

## 运行示例程序
首先在 [Agora.io 注册](https://dashboard.agora.io/cn/signup/) 注册账号，并创建自己的测试项目，获取到 AppID。修改配置文件AgoraFaceUnity.ini


[LoginInfo]

AppId=//Your AppID

ChannelName= //ChannelName

LoginUid= //Uid

VideoSolutinIndex= //VideoSolutinoIndex default 40

用VS2013 打开 Agora-FaceUnity-Tutorial-Windows.sln，程序中默认填写采集参数是640x480 ，那么对应的 VideoSolutinIndex 必须为40，如果摄像头不支持640x480 ，需要修改采集宽高，同时VideoSolutionIdnex 也需要相应的修改.

## Developer Environment Requirements
* VC++ 2013(or higher)
* win7(or higher)
* SDK 2.1.0

## Connect Us

- You can find full API document at [Document Center](https://docs.agora.io/en/)
- You can fire bugs about this demo at [issue](https://github.com/AgoraIO/OpenLive-Windows/issues)

## License

The MIT License (MIT).