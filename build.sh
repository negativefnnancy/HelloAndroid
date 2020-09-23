#!/usr/bin/env sh

# the name of the build target (without extension)
NAME=hello

# the package name
PACKAGE=com.gmail.negativefnnancy.helloandroid

# the source files
SOURCES=src/com/gmail/negativefnnancy/helloandroid/*.java

# the platform jar for the desired android api level
PLATFORM=/opt/android-sdk/platforms/android-21/android.jar

# the target paths
TARGET_UNALIGNED=bin/$NAME.unaligned.apk
TARGET=bin/$NAME.apk

# generate the source code for the R class
echo "Generating R.java file..."
aapt package -f -m -J src -M AndroidManifest.xml -S res -I $PLATFORM

# compile the source code
echo "Compiling..."
javac -d obj -classpath src -bootclasspath $PLATFORM $SOURCES

# transpile to a dex file
echo "Transpiling..."
dx --dex --output bin/classes.dex obj

# create the android package
echo "Packaging..."
aapt package -f -m -F $TARGET_UNALIGNED -M AndroidManifest.xml -S res -I $PLATFORM
mv bin/classes.dex .
aapt add $TARGET_UNALIGNED classes.dex
mv classes.dex bin

# align the package
echo "Aligning..."
zipalign -f 4 $TARGET_UNALIGNED $TARGET

# sign the package
echo "Signing..."
apksigner sign --ks key.keystore $TARGET

# test on device
if [ "$1" == "test" ]; then
    echo "Launching..."
    adb install -r $TARGET
    adb shell am start -n $PACKAGE/.MainActivity
fi
