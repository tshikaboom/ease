# libease-bind
lib_LTLIBRARIES = libease-bindings-@BINDINGS_VERSION@.la

INCLUDES = \
	$(EASE_CFLAGS)

EASE_CFLAGS += -w

AM_CPPFLAGS = \
	$(EASE_CFLAGS) \
	-include $(CONFIG_HEADER) \
	$(NULL)

# source files
libease_bindings_@BINDINGS_VERSION@_la_SOURCES = bindings.vala

# compiler flags
libease_bindings_@BINDINGS_VERSION@_la_VALAFLAGS = \
	--pkg gee-1.0 \
	--pkg glib-2.0 \
	--vapi=$(top_srcdir)/vapi/ease-bindings-@BINDINGS_VERSION@.vapi \
	--header=ease-bindings.h \
	--thread \
	-g \
	$(NULL)

libease_bindings_@BINDINGS_VERSION@_la_CFLAGS = $(EASE_CFLAGS)
libease_bindings_@BINDINGS_VERSION@_la_LDFLAGS = $(EASE_LDFLAGS)

# header installation
ease_bindings_includedir=$(includedir)/ease-bindings/
ease_bindings_include_HEADERS = ease-bindings.h

# vapi installation
vapidir = $(datadir)/vala/vapi
vapi_DATA = \
	$(top_srcdir)/vapi/ease-bindings-@BINDINGS_VERSION@.vapi \
	$(top_srcdir)/vapi/ease-bindings-@BINDINGS_VERSION@.deps

# remove generated files on `make clean`
CLEANFILES = \
	bindings.c \
	$(top_srcdir)/vapi/ease-bindings-@BINDINGS_VERSION@.vapi \
	ease-bindings.h

EXTRA_DIST = \
	$(top_srcdir)/vapi/ease-bindings-@BINDINGS_VERSION@.vapi \
	$(top_srcdir)/vapi/ease-bindings-@BINDINGS_VERSION@.deps


# bindings test
noinst_PROGRAMS = bindings-test

bindings_test_SOURCES = bindings-test.vala

bindings_test_VALAFLAGS = \
	--pkg ease-bindings-@BINDINGS_VERSION@ \
	--pkg gtk+-2.0 \
	--vapidir $(top_srcdir)/vapi \
	-g

bindings_test_CFLAGS = \
	$(EASE_CFLAGS) \
	-w \
	-I$(top_srcdir)/ease-bindings \
	-include $(top_srcdir)/config.h

bindings_test_LDFLAGS = $(EASE_LIBS) --export-dynamic

bindings_test_LDADD = \
	$(top_builddir)/ease-bindings/libease-bindings-@BINDINGS_VERSION@.la \
	-lm \
	$(NULL)
