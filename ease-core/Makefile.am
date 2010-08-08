lib_LTLIBRARIES = libease-core-0.3.la

INCLUDES = \
	$(EASE_CFLAGS)

EASE_CFLAGS += -w -I../flutter

AM_CPPFLAGS = \
	$(EASE_CFLAGS) \
	-include $(CONFIG_HEADER) \
	$(NULL)

# source files
libease_core_0_3_la_SOURCES = \
	ease-actor.vala \
	ease-animated-zoom-slider.vala \
	ease-archiver.vala \
	ease-background.vala \
	ease-background-widget.vala \
	ease-cairo-actor.vala \
	ease-cairo-element.vala \
	ease-color.vala \
	ease-dialog-progress.vala \
	ease-dialogs.vala \
	ease-document.vala \
	ease-element.vala \
	ease-enums.vala \
	ease-gradient.vala \
	ease-html-exporter.vala \
	ease-image-actor.vala \
	ease-image-element.vala \
	ease-image.vala \
	ease-iterable-models.vala \
	ease-media-element.vala \
	ease-shape-element.vala \
	ease-slide.vala \
	ease-temp.vala \
	ease-text-actor.vala \
	ease-text-element.vala \
	ease-theme.vala \
	ease-transformations.vala \
	ease-transitions.vala \
	ease-undo-actions-element.vala \
	ease-undo-actions-slide.vala \
	ease-undo-action.vala \
	ease-undo-controller.vala \
	ease-undo-item.vala \
	ease-undo-source.vala \
	ease-utilities.vala \
	ease-video-actor.vala \
	ease-video-element.vala \
	ease-zoom-slider.vala \
	$(NULL)

# compiler flags

# I don't _want_ to --disable-warnings, but the choices appear to be:
#    - enable warnings, mark signal handlers for GtkBuilder as public
#    - disable warnings, hide functionality properly \
#    - enable warnings, hide functionality, get spammed with unused
#      function warnings
# Therefore, warnings are off.

libease_core_0_3_la_VALAFLAGS = \
	$(EASE_PACKAGES) \
	--vapi=../vapi/ease-core-0.3.vapi \
	--header=libease-core.h \
	--thread \
	--disable-warnings \
	--vapidir=../vapi \
	--pkg flutter-0.3 \
	-g \
	$(NULL)

libease_core_0_3_la_LIBADD = ../flutter/libflutter-0.3.la
libease_core_0_3_la_CFLAGS = $(EASE_CFLAGS)
libease_core_0_3_la_LDFLAGS = $(EASE_LDFLAGS) --export-dynamic

# header installation
libease_includedir=$(includedir)/ease/
libease_include_HEADERS = libease-core.h

# vapi installation
vapidir = $(datadir)/vala/vapi
vapi_DATA = ../vapi/ease-core-0.3.vapi ../vapi/ease-core-0.3.deps

# remove generated files on `make clean`
CLEANFILES = \
	$(subst .vala,.c,$(libease_core_0_3_la_SOURCES)) \
	../vapi/ease-core-0.3.vapi \
	libease-core.h

EXTRA_DIST = \
	../vapi/ease-core-0.3.vapi \
	../vapi/ease-core-0.3.deps

