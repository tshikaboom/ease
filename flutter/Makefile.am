lib_LTLIBRARIES = libflutter-0.3.la

INCLUDES = \
	$(EASE_CFLAGS)

EASE_CFLAGS += -w

AM_CPPFLAGS = \
	$(EASE_CFLAGS) \
	-include $(CONFIG_HEADER) \
	$(NULL)

# source files
libflutter_0_3_la_SOURCES = flutter.vala

# compiler flags
libflutter_0_3_la_VALAFLAGS = \
	--pkg clutter-1.0 \
	--vapi=../vapi/flutter-0.3.vapi \
	--header=flutter.h \
	--thread \
	-g \
	$(NULL)

libflutter_0_3_la_CFLAGS = $(EASE_CFLAGS)
libflutter_0_3_la_LDFLAGS = $(EASE_LDFLAGS)

# build typelib

# header installation
flutter_includedir=$(includedir)/flutter/
flutter_include_HEADERS = flutter.h

# vapi installation
vapidir = $(datadir)/vala/vapi
vapi_DATA = ../vapi/flutter-0.3.vapi ../vapi/flutter-0.3.deps

# remove generated files on `make clean`
CLEANFILES = \
	flutter.c \
	../vapi/flutter-0.3.vapi \
	flutter.h \
	libflutter_0_3_la-flutter.lo

