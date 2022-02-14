# the name of the build target (without extension)
NAME := hello

# the name of the java subpackage for this project
PACKAGE_NAME := helloandroid

# the parent organizational namespace
NAMESPACE := io.github.negativefnnancy

# the android api level to build with
API_LEVEL := 29

# the path to the root of the android SDK
SDK_DIR := /opt/android-sdk

# the path to the android build tools directory for same api level
BUILD_TOOLS_DIR := $(SDK_DIR)/build-tools/29.0.3

# the path to the keystore to sign with
# by placing it in home directory you can reuse it across projects
KEYSTORE := $(HOME)/.key.keystore

# the main activity
ACTIVITY := .MainActivity

# commands to invoke binaries
JAVAC     := javac
KEYTOOL   := keytool
ADB       := adb
ZIPALIGN  := $(BUILD_TOOLS_DIR)/zipalign
APKSIGNER := $(BUILD_TOOLS_DIR)/apksigner
DX        := $(BUILD_TOOLS_DIR)/dx
AAPT      := $(BUILD_TOOLS_DIR)/aapt

# relevant directories
OBJ_DIR := obj
BIN_DIR := bin
RES_DIR := res
SRC_DIR := src

# the package name
PACKAGE := $(NAMESPACE).$(PACKAGE_NAME)

# the package name as a filesystem path
PACKAGE_DIR := $(subst .,/,$(PACKAGE))

# the source directory
SOURCE_DIR := $(SRC_DIR)/$(PACKAGE_DIR)

# the platform jar for the desired android api level
PLATFORM := $(SDK_DIR)/platforms/android-$(API_LEVEL)/android.jar

# the manifest file
MANIFEST := AndroidManifest.xml

# the dex file
DEX_FILE := classes.dex

# the target paths
TARGET_UNALIGNED := $(BIN_DIR)/$(NAME).unaligned.apk
TARGET           := $(BIN_DIR)/$(NAME).apk

# the source files
R_FILE    := $(SOURCE_DIR)/R.java
SOURCES   := $(filter-out $(R_FILE),$(wildcard $(SOURCE_DIR)/*.java))
RESOURCES := $(wildcard $(RES_DIR)/*)

$(TARGET): $(TARGET_UNALIGNED) $(KEYSTORE)
	$(ZIPALIGN) -f 4 $(TARGET_UNALIGNED) $@
	$(APKSIGNER) sign --ks $(KEYSTORE) $@

$(TARGET_UNALIGNED): $(MANIFEST) $(PLATFORM) $(SOURCES) $(RESOURCES) $(R_FILE) | $(BIN_DIR) $(OBJ_DIR)
	$(JAVAC) -d $(OBJ_DIR) -classpath $(SRC_DIR) -bootclasspath $(PLATFORM) $(SOURCES) $(R_FILE)
	$(DX) --dex --output $(DEX_FILE) $(OBJ_DIR)
	$(AAPT) package -f -m -F $@ -M $(MANIFEST) -S $(RES_DIR) -I $(PLATFORM)
	$(AAPT) add $@ $(DEX_FILE)
	mv $(DEX_FILE) $(BIN_DIR)

$(R_FILE): $(MANIFEST) $(SOURCES) $(RESOURCES)
	$(AAPT) package -f -m -J $(SRC_DIR) -M $(MANIFEST) -S $(RES_DIR) -I $(PLATFORM)

$(BIN_DIR):
	mkdir $@

$(OBJ_DIR):
	mkdir $@

$(KEYSTORE):
	$(KEYTOOL) -genkeypair -validity 365 -keystore $@ -keyalg RSA -keysize 2048

test: $(TARGET)
	$(ADB) install -r $(TARGET)
	$(ADB) shell am start -n $(PACKAGE)/$(ACTIVITY)

clean:
	rm -rf $(BIN_DIR) $(OBJ_DIR) $(R_FILE)

.INTERMEDIATE: $(R_FILE)

.PHONY: test
.PHONY: clean
