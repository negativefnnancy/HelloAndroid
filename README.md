# Hello Android

My reference template for Android Development! :3

_Credit to this [article](https://medium.com/@authmane512/how-to-build-an-apk-from-command-line-without-ide-7260e1e22676)._

_Also credit to this [article](https://noirscape.github.io/guides/2018/06/14/android-sdk-arch-linux.html) for Arch Linux setup._

## Dependencies

On Arch Linux, install these packages for your desired Android API level from the AUR first:
```android-sdk android-sdk-build-tools android-sdk-platform-tools android-platform```

## Configuration

Edit `Makefile` as much as you need for your particular project and build setup. All the stuff you are most likely to want to change are towards the top.

## Build

To build, just run `make`. If you haven't generated a keystore, it'll prompt you to create one, and then you won't have to create it again for subsequent builds, but it will prompt you to sign each new build.

## Run

To run the build on a connected Android device, make sure your device is connected and recognized with developer mode enabled by running ```adb devices``` and see if it shows up on the list. And then just run `make run`.

## Debug

Once it's running, debug the app using ```adb logcat```. [Filter](https://developer.android.com/studio/command-line/logcat#filteringOutput) for relevant messages, for example, like this: ```adb logcat HelloAndroid *:S```
