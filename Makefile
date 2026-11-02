TARGET = iphone:clang:latest:15.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = igtap2
igtap2_FILES = Tweak.xm
igtap2_CFLAGS = -fobjc-arc
igtap2_FRAMEWORKS = Foundation

include $(THEOS)/makefiles/tweak.mk
