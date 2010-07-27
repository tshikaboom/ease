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
	--library Flutter-0.3 \
	--gir=Flutter-0.3.gir \
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

# gir installation
girdir = $(datadir)/gir-1.0
gir_DATA = Flutter-0.3.gir
EXTRA_DIST = Flutter-0.3.gir

# remove generated files on `make clean`
CLEANFILES = \
	$(subst .vala,.c,$(flutter_0_3_la_SOURCES)) \
	../vapi/flutter-0.3.vapi \
	Flutter-0.3.gir \
	flutter.h

