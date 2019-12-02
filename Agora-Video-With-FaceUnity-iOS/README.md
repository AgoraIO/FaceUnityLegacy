# Agora Video With Faceunity

*其他语言版本： [简体中文](README.zh.md)*

This open source demo project demonstrates how to implement 1to1 video chat with  [Agora] (www.agora.io) video SDK and the [Faceunity] (http://www.faceunity.com) beauty SDK.

With this sample app you can:

Agora 

- Join / leave channel
- Implement 1to1 video chat 
- Mute / unmute audio

Faceunity

- face tracking, beauty, Animoji, props stickers, AR mask, face transfer , face recognition, music filter, background segmentation
- Switch capture format
- Switch camera


This project uses the video pre-processing functions provided by Faceunity such as video capture, beauty, and local rendering, and uses Agora's functions of voice collection, encoding, transmission, decoding, and remote rendering.

Faceunity beauty function please refer to. [Faceunity Document](http://www.faceunity.com/docs_develop_en/#/)

Agora function implementation please refer to [Agora Document](https://docs.agora.io/en/Interactive%20Broadcast/API%20Reference/oc/docs/headers/Agora-Objective-C-API-Overview.html)

Due to the need to use third-party capture when using beauty function, please refer to [Customized Media Source API](https://docs.agora.io/en/2.2/product/Interactive%20Broadcast/API%20Reference/custom_live_ios?platform=iOS#agoravideosourceprotocol)  or [Configuring the External Data API](https://docs.agora.io/en/2.2/product/Interactive%20Broadcast/API%20Reference/custom_live_ios?platform=iOS#configuring-the-external-data-api)

## Running the App
First, create a developer account at [Agora.io](https://dashboard.agora.io/signin/), and obtain an App ID. Update "KeyCenter.m" with your App ID. 

```
+ (NSString *)AppId {
     return @"Your App ID";
}
```
Next, download the **Agora Video SDK** from [Agora.io SDK](https://www.agora.io/en/download/). Unzip the downloaded SDK package and copy the "libs/AgoraRtcEngineKit.framework" to the "AgoraWithFaceunity" folder.

Contact [Faceunity](http://www.faceunity.com)  to get the certificate file replace the "authpack.h" file in the "/AgoraWithFaceunity/Faceunity" folder of this project.

Finally, Open AgoraWithFaceunity.xcodeproj, connect your iPhone／iPad device, setup your development signing and run.

## FAQ

- Please do not use the raw data interface provided by Agora to integrate beauty features
- Videosource internal is a strong reference, you must set nil when not in use, otherwise it will cause a circular reference
- If you encounter a big head problem, please contact technical support

## Developer Environment Requirements
* XCode 8.0 +
* Real devices (iPhone or iPad)
* iOS simulator is NOT supported

## Connect Us

- You can find full API document at [Document Center](https://docs.agora.io/en/)
- You can file bugs about this demo at [issue](https://github.com/AgoraIO/Agora-iOS-Tutorial-Swift-1to1/issues)

## License

The MIT License (MIT).


