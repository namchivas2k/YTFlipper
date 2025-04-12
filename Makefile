ifeq ($(THEOS_PACKAGE_SCHEME),rootless)
	TARGET = iphone:clang:latest:15.0
else ifeq ($(THEOS_PACKAGE_SCHEME),roothide)
	TARGET = iphone:clang:latest:15.0
else
	TARGET = iphone:clang:latest:11.0
endif

ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = YouTube
PACKAGE_VERSION = 1.12.7

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTFlipper

YTFlipper_FILES = Tweak.x
YTFlipper_CFLAGS = -fobjc-arc
YTFlipper_FRAMEWORKS = UIKit CoreGraphics AVFoundation
YTFlipper_RESOURCE_FILES = Resources/FlipIcon.png

include $(THEOS_MAKE_PATH)/tweak.mk
