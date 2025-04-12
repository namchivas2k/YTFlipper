TARGET := iphone:clang:latest:7.0


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = YTFlipper

YTFlipper_FILES = Tweak.x
YTFlipper_CFLAGS = -fobjc-arc
YTFlipper_FRAMEWORKS = UIKit CoreGraphics AVFoundation

include $(THEOS_MAKE_PATH)/tweak.mk
