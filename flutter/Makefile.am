lib_LTLIBRARIES = libflutter-@FLUTTER_VERSION@.la

DISTCHECK_CONFIGURE_FLAGS = --enable-introspection

INCLUDES = \
	$(EASE_CFLAGS)

AM_CPPFLAGS = \
	$(EASE_CFLAGS) \
	-include $(CONFIG_HEADER) \
	$(NULL)

# source files
libflutter_@FLUTTER_VERSION@_la_SOURCES = flutter.vala

# compiler flags
libflutter_@FLUTTER_VERSION@_la_VALAFLAGS = \
	--pkg clutter-1.0 \
	--vapi=$(top_srcdir)/vapi/flutter-@FLUTTER_VERSION@.vapi \
	--header=flutter.h \
	--thread \
	-g \
	$(NULL)

libflutter_@FLUTTER_VERSION@_la_CFLAGS = $(EASE_CFLAGS)
libflutter_@FLUTTER_VERSION@_la_LDFLAGS = $(EASE_LDFLAGS)

# header installation
flutter_includedir=$(includedir)/flutter/
flutter_include_HEADERS = flutter.h

# vapi installation
vapidir = $(datadir)/vala/vapi
vapi_DATA = \
	$(top_srcdir)/vapi/flutter-@FLUTTER_VERSION@.vapi \
	$(top_srcdir)/vapi/flutter-@FLUTTER_VERSION@.deps

# remove generated files on `make clean`
CLEANFILES = \
	flutter.c \
	$(top_srcdir)/vapi/flutter-@FLUTTER_VERSION@.vapi \
	flutter.h \
	libflutter_@FLUTTER_VERSION@_la-flutter.lo

EXTRA_DIST = \
	$(top_srcdir)/vapi/flutter-@FLUTTER_VERSION@.vapi \
	$(top_srcdir)/vapi/flutter-@FLUTTER_VERSION@.deps

#if HAVE_INTROSPECTION

#BUILT_GIRSOURCES = Flutter-0.3.gir

#Flutter-0.3.gir: $(INTROSPECTION_SCANNER) libflutter-0.3.la \
#	g-ir-scanner -v \
#	--namespace Flutter --nsversion=0.3 \
#	--strip-prefix=flutter \
#	--include=Clutter-1.0 \
#	--library=flutter-0.3 \
#	--libtool="$(LIBTOOL)" \
#	--output $@ \
#	--pkg clutter-1.0 \
#	$(top_srcdir)/flutter/flutter.h

#girdir = $(datadir)/gir-1.0
#gir_DATA = $(BUILT_GIRSOURCES)

#typelibsdir = $(libdir)/girepository-1.0
#typelibs_DATA = $(BUILT_GIRSOURCES:.gir=.typelib)

#%.typelib: %.gir $(INTROSPECTION_COMPILER)
#	$(AM_V_GEN) $(DEBUG) $(INTROSPECTION_COMPILER) --includedir=$(srcdir) --includedir=.$(INTROSPECTION_COMPILER_OPTS) $< -o $@

#CLEANFILES += Flutter-0.3.gir $(typelibs_DATA)

#endif

-include $(INTROSPECTION_MAKEFILE)
INTROSPECTION_GIRS =
INTROSPECTION_SCANNER_ARGS = --add-include-path=$(srcdir)
INTROSPECTION_COMPILER_ARGS = --includedir=$(srcdir)

if HAVE_INTROSPECTION
introspection_sources = flutter.c flutter.h

Flutter_0_3_gir: libflutter-@FLUTTER_VERSION@.la
Flutter_0_3_gir_INCLUDES = Clutter-1.0
Flutter_0_3_gir_CFLAGS = $(INCLUDES)
Flutter_0_3_gir_LIBS = libflutter-@FLUTTER_VERSION@.la 
Flutter_0_3_gir_FILES = $(introspection_sources)
INTROSPECTION_GIRS += Flutter-@FLUTTER_VERSION@.gir

girdir = $(datadir)/gir-1.0
gir_DATA = $(INTROSPECTION_GIRS)

typelibdir = $(libdir)/girepository-1.0
typelib_DATA = $(INTROSPECTION_GIRS:.gir=.typelib)

CLEANFILES += $(gir_DATA) $(typelib_DATA)
endif
