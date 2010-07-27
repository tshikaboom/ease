lib_LTLIBRARIES = libease-core-0.3.la

INCLUDES = \
	$(EASE_CFLAGS)

EASE_CFLAGS += -w

AM_CPPFLAGS = \
	$(EASE_CFLAGS) \
	-include $(CONFIG_HEADER) \
	$(NULL)

# source files
libease_core_0_3_la_SOURCES = \
	ease-about-dialog.vala \
	ease-actor.vala \
	ease-animated-zoom-slider.vala \
	ease-close-confirm-dialog.vala \
	ease-clutter-iterables.vala \
	ease-color.vala \
	ease-dialogs.vala \
	ease-document.vala \
	ease-editor-embed.vala \
	ease-editor-window.vala \
	ease-element.vala \
	ease-enums.vala \
	ease-gradient.vala \
	ease-handle.vala \
	ease-html-exporter.vala \
	ease-image-actor.vala \
	ease-image-element.vala \
	ease-inspector-element-pane.vala \
	ease-inspector-pane.vala \
	ease-inspector-slide-pane.vala \
	ease-inspector-transition-pane.vala \
	ease-inspector-window.vala \
	ease-inspector.vala \
	ease-iterables.vala \
	ease-media-element.vala \
	ease-player.vala \
	ease-scrollable-embed.vala \
	ease-selection-rectangle.vala \
	ease-slide-actor.vala \
	ease-slide-button-panel.vala \
	ease-slide.vala \
	ease-temp.vala \
	ease-text-actor.vala \
	ease-text-element.vala \
	ease-theme.vala \
	ease-transformations.vala \
	ease-transitions.vala \
	ease-undo-action.vala \
	ease-undo-actions-element.vala \
	ease-undo-actions-slide.vala \
	ease-undo-controller.vala \
	ease-undo-item.vala \
	ease-undo-source.vala \
	ease-utilities.vala \
	ease-welcome-actor.vala \
	ease-welcome-window.vala \
	ease-zoom-slider.vala \
	ease-main.vala \
	$(NULL)

# compiler flags
libease_core_0_3_la_VALAFLAGS = \
	$(EASE_PACKAGES) \
	--vapi=ease-core-0.3.vapi \
	--header=libease-core.h \
	--thread \
	--library EaseCore-0.3 \
	--gir=EaseCore-0.3.gir \
	-g \
	$(NULL)

libease_core_0_3_la_CFLAGS = $(EASE_CFLAGS)
libease_core_0_3_la_LDFLAGS = $(EASE_LDFLAGS)

# build typelib

# header installation
libease_includedir=$(includedir)/ease-0.3/
libease_include_HEADERS = libease-core.h

# vapi installation
vapidir = $(datadir)/vala/vapi
vapi_DATA = ease-core-0.3.vapi

# gir installation
girdir = $(datadir)/gir-1.0
gir_DATA = EaseCore-0.3.gir
EXTRA_DIST = EaseCore-0.3.gir

# remove generated files on `make clean`
CLEANFILES = \
	$(subst .vala,.c,$(libease_core_0_3_la_SOURCES)) \
	ease-core-0.3.vapi \
	EaseCore-0.3.gir \
	libease-core.h

