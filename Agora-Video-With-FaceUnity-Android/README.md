# Agora Video With Faceunity

This tutorial enables you to quickly get started in your development efforts to create an Android app with real-time video calls, voice calls, and interactive broadcasting. With this sample app you can:

* Join and leave a channel.
* Choose between the front or rear camera.
* Real time Sticky/Effect/Filter for video(provided by Faceunity SDK)


## Prerequisites

* Android Studio 3.1 or above.
* Android device (e.g. Nexus 5X). A real device is recommended because some simulators have missing functionality or lack the performance necessary to run the sample.

## Quick Start
This section shows you how to prepare, build, and run the sample application.

### Create an Account and Obtain an App ID
In order to build and run the sample application you must obtain an App ID:

1. Create a developer account at [agora.io](https://dashboard.agora.io/signin/). Once you finish the signup process, you will be redirected to the Dashboard.
2. Navigate in the Dashboard tree on the left to **Projects** > **Project List**.
3. Locate the file **app/src/main/res/values/strings.xml** and replace <#YOUR APP ID#> with the App ID in the dashboard.

```xml
<string name="agora_app_id"><#YOUR APP ID#></string>
```
4. Contact sales@agora.io and get authpack.java for Faceunity SDK, then replace **faceunity/src/main/java/com/faceunity/authpack.java** with your authpack.java

### Prepare agora SDK
1. Download agora SDK from the official download page: https://www.agora.io/en/download/.
2. Unpack the zip file, copy all .so libraries to their corresponding abi folders (app\src\main\jniLibs). The folder structure of jniLibs should be like this:

````
jniLibs
  |__arm64-v8a
     |__ libagora-crypto.so
     |__ libagora-rtc-sdk-jni.so

  |__ armeabi-v7a
     |__ libagora-crypto.so
     |__ libagora-rtc-sdk-jni.so

  |__x86
     |__ libagora-crypto.so
     |__ libagora-rtc-sdk-jni.so

````
3. If you need to implement raw data interfaces, please copy the header files under "include" folder in the zip file into the CPP source folder.
4. Besides, copy agora-rtc-sdk.jar into "app/libs" folder.
