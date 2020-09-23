# TODO: figure out why it's rebuilding every time....

# the name of the build target (without extension)
NAME := hello

# relevant directories
OBJ_DIR := obj
BIN_DIR := bin
RES_DIR := res
SRC_DIR := src

# the package name
PACKAGE := com.gmail.negativefnnancy.helloandroid

# the source directory
SOURCE_DIR := $(SRC_DIR)/com/gmail/negativefnnancy/helloandroid

# the platform jar for the desired android api level
PLATFORM := /opt/android-sdk/platforms/android-21/android.jar

# the main activity
ACTIVITY := .MainActivity

# the keystore to sign with
KEYSTORE := key.keystore

# the manifest file
MANIFEST := AndroidManifest.xml

# the dex file
DEX_FILE := classes.dex

# the target paths
TARGET_UNALIGNED := $(BIN_DIR)/$(NAME).unaligned.apk
TARGET           := $(BIN_DIR)/$(NAME).apk

# the source files
SOURCES := $(SOURCE_DIR)/*.java
R_FILE  := $(SOURCE_DIR)/R.java

$(TARGET): $(TARGET_UNALIGNED)
	zipalign -f 4 $(TARGET_UNALIGNED) $@
	apksigner sign --ks $(KEYSTORE) $@

$(TARGET_UNALIGNED): $(MANIFEST) $(PLATFORM) $(SOURCES) $(R_FILE) $(BIN_DIR) $(OBJ_DIR)
	javac -d $(OBJ_DIR) -classpath $(SRC_DIR) -bootclasspath $(PLATFORM) $(SOURCES) $(R_FILE)
	dx --dex --output $(DEX_FILE) $(OBJ_DIR)
	aapt package -f -m -F $@ -M $(MANIFEST) -S $(RES_DIR) -I $(PLATFORM)
	aapt add $@ $(DEX_FILE)
	mv $(DEX_FILE) $(BIN_DIR)

$(R_FILE): $(MANIFEST) $(SOURCES)
	aapt package -f -m -J $(SRC_DIR) -M $(MANIFEST) -S $(RES_DIR) -I $(PLATFORM)

$(BIN_DIR):
	mkdir $@

$(OBJ_DIR):
	mkdir $@

$(KEYSTORE):
	keytool -genkeypair -validity 365 -keystore $@ -keyalg RSA -keysize 2048

test: $(TARGET)
	adb install -r $(TARGET)
	adb shell am start -n $(PACKAGE)/$(ACTIVITY)

clean:
	rm -rf $(BIN_DIR) $(OBJ_DIR)

.INTERMEDIATE: $(R_FILE)

.PHONY: test
.PHONY: clean
