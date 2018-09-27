# Agora-FaceUnity-Tutorial-Windows

* 其他语言版本： [简体中文](README.zh.md)*

The Agora FaceUnity Tutorial sample app supports the following platforms: 

* [Android](https://github.com/AgoraIO-Community/Agora-Video-With-FaceUnity-Android)
* [iOS](https://github.com/AgoraIO-Community/Agora-Video-With-FaceUnity-IOS)
* [Windows](https://github.com/AgoraIO-Community/Agora-Video-With-FaceUnity-Windows)

This readme describes the steps and considerations for demonstrating the Agora FaceUnity Tutorial Windows sample app.

## Introduction

Agora FaceUnity Tutorial Windows sample app is built using **C++** language. It contains the following modules

- Agora Live Streaming
- Faceunity Stickers, Filters, Beauty

## Preparing the Developer Environment

* Visual C++ 2013 or later
* Windows 7 or later
* Agora Video SDK 2.1.0 

## Running the Sample App

1. Create a developer account at [Agora.io] (https://dashboard.agora.io/cn/signup/).
2. Create your own test project and obtain an App ID.
   
   NOTE: For more information, see [Obtaining an App ID](https://docs.agora.io/en/2.2/addons/Signaling/Agora%20Basics/key_signaling?platform=All%20Platforms). 
   
3. Modify the configuration file *AgoraFaceUnity.ini*.

         [LoginInfo]

          AppId=//Your App ID
 
          ChannelName= //ChannelName

          LoginUid= //Uid

          VideoSolutinIndex= //VideoSolutinoIndex default 40

4. Use Visual Studio 2013 to open Agora-FaceUnity-Tutorial-Windows.sln. 

Note: The default capturing parameter is 640x480, so the corresponding VideoSolutionIndex should be 40. If the camera does not support a resolution of 640x480, you need to change the capturing resolution and change the VideoSolutionIndex accordingly.

