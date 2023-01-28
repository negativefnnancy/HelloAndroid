# the name of the build target (without extension)
NAME := hello

# the package name
PACKAGE_NAME := helloandroid

# the parent organizational namespace
NAMESPACE := io.github.negativefnnancy

# the full package name
PACKAGE := $(NAMESPACE).$(PACKAGE_NAME)

# the android api level to build with
API_LEVEL := 30

# the path to the root of the android SDK
SDK_DIR := $(HOME)/Android/Sdk

# the path to the android build tools directory for same api level
BUILD_TOOLS_DIR := $(lastword $(wildcard $(SDK_DIR)/build-tools/*))

# the path to the root of the NDK
NDK_DIR := $(lastword $(wildcard $(SDK_DIR)/ndk/*))

# the path to the toolchain directory of the NDK
NDK_TOOLCHAIN_DIR := $(NDK_DIR)/toolchains/llvm/prebuilt/linux-x86_64

# the path to the keystore to sign with
# by placing it in home directory you can reuse it across projects
KEYSTORE := $(HOME)/.key.keystore

# the launchable activity
ACTIVITY := android.app.NativeActivity

# commands to invoke binaries
CC_ARM64  := $(NDK_TOOLCHAIN_DIR)/bin/aarch64-linux-android$(API_LEVEL)-clang
CC_ARM32  := $(NDK_TOOLCHAIN_DIR)/bin/armv7a-linux-androideabi$(API_LEVEL)-clang
KEYTOOL   := keytool
ADB       := adb
ZIPALIGN  := $(BUILD_TOOLS_DIR)/zipalign
APKSIGNER := $(BUILD_TOOLS_DIR)/apksigner
AAPT      := $(BUILD_TOOLS_DIR)/aapt

# relevant directories
BIN_DIR := bin
LIB_DIR := lib
RES_DIR := res
SRC_DIR := src
INC_DIR := inc
OBJ_DIR := obj

# compiler options
CFLAGS       := -I$(INC) -I$(NDK_DIR)/sysroot/usr/include -I$(NDK_DIR)/sysroot/usr/include/android -I$(NDK_TOOLCHAIN_DIR)/sysroot/usr/include/android -fPIC -DANDROIDVERSION=$(API_LEVEL)
CFLAGS_ARM64 := -m64
CFLAGS_ARM32 := -mfloat-abi=softfp -m32
LDFLAGS      := -lm -lGLESv3 -LEGL -landroid -llog -shared -uANativeActivity_onCreate

# platform specific directories
ARM64_DIR := arm64-v8a
ARM32_DIR := armeabi-v7a
OBJ_ARM64_DIR := $(OBJ_DIR)/$(ARM64_DIR)
OBJ_ARM32_DIR := $(OBJ_DIR)/$(ARM32_DIR)

# the platform jar for the desired android api level
PLATFORM := $(SDK_DIR)/platforms/android-$(API_LEVEL)/android.jar

# the manifest file
MANIFEST := AndroidManifest.xml

# the target paths
TARGET_UNALIGNED := $(BIN_DIR)/$(NAME).unaligned.apk
TARGET           := $(BIN_DIR)/$(NAME).apk
TARGET_ARM64     := $(LIB_DIR)/$(ARM64_DIR)/lib$(NAME).so
TARGET_ARM32     := $(LIB_DIR)/$(ARM32_DIR)/lib$(NAME).so

# the source files
SOURCES   := $(wildcard $(SRC_DIR)/*.c)
RESOURCES := $(wildcard $(RES_DIR)/*)

# the object files
OBJECTS_ARM64 := $(patsubst $(SRC_DIR)/%.c,$(OBJ_ARM64_DIR)/%.o,$(SOURCES))
OBJECTS_ARM32 := $(patsubst $(SRC_DIR)/%.c,$(OBJ_ARM32_DIR)/%.o,$(SOURCES))

$(TARGET): $(TARGET_UNALIGNED) $(KEYSTORE)
	$(ZIPALIGN) -v -f 4 $(TARGET_UNALIGNED) $@
	$(APKSIGNER) sign --ks $(KEYSTORE) $@

$(TARGET_UNALIGNED): $(TARGET_ARM64) $(TARGET_ARM32) $(MANIFEST) $(PLATFORM) $(RESOURCES) | $(BIN_DIR) $(LIB_DIR)
	$(AAPT) package -f -m -F $@ -M $(MANIFEST) -S $(RES_DIR) -I $(PLATFORM) -v --target-sdk-version $(API_LEVEL)
	$(AAPT) add $@ $(TARGET_ARM64) $(TARGET_ARM32)

$(TARGET_ARM64): $(OBJECTS_ARM64) | $(LIB_DIR) $(OBJ_ARM64_DIR)
	mkdir -p $(@D)
	$(CC_ARM64) $(CFLAGS) $(CFLAGS_ARM64) $(LDFLAGS) -o $@ $^

$(TARGET_ARM32): $(OBJECTS_ARM32) | $(LIB_DIR) $(OBJ_ARM32_DIR)
	mkdir -p $(@D)
	$(CC_ARM32) $(CFLAGS) $(CFLAGS_ARM32) $(LDFLAGS) -o $@ $^

$(OBJ_ARM64_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_ARM64_DIR)
	$(CC_ARM64) $(CFLAGS) $(CFLAGS_ARM64) -o $@ -c $<

$(OBJ_ARM32_DIR)/%.o: $(SRC_DIR)/%.c | $(OBJ_ARM32_DIR)
	$(CC_ARM32) $(CFLAGS) $(CFLAGS_ARM32) -o $@ -c $<

$(BIN_DIR):
	mkdir -p $@

$(LIB_DIR):
	mkdir -p $@

$(OBJ_ARM64_DIR):
	mkdir -p $@

$(OBJ_ARM32_DIR):
	mkdir -p $@

$(KEYSTORE):
	$(KEYTOOL) -genkeypair -validity 365 -keystore $@ -keyalg RSA -keysize 2048

push: $(TARGET)
	$(ADB) install -r $(TARGET)

run: push
	$(ADB) shell am start -n $(PACKAGE)/$(ACTIVITY)

debug: run
	$(ADB) logcat | grep $(PACKAGE)

clean:
	rm -rf $(BIN_DIR) $(OBJ_DIR) $(TARGET_ARM64) $(TARGET_ARM32)

.PHONY: push
.PHONY: run
.PHONY: debug
.PHONY: clean
