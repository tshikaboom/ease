lib_LTLIBRARIES = libease-0.1.la

INCLUDES = \
	$(EASE_CFLAGS)

AM_CPPFLAGS = \
	$(EASE_CFLAGS) \
	-include $(CONFIG_HEADER) \
	$(NULL)

# source files
libease_0_1_la_SOURCES = \
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
	ease-inspector-pane.vala \
	ease-inspector.vala \
	ease-inspector-window.vala \
	ease-iterables.vala \
	ease-main.vala \
	ease-media-element.vala \
	ease-player.vala \
	ease-scrollable-embed.vala \
	ease-selection-rectangle.vala \
	ease-slide-actor.vala \
	ease-slide-button-panel.vala \
	ease-slide-pane.vala \
	ease-slide.vala \
	ease-temp.vala \
	ease-text-actor.vala \
	ease-text-element.vala \
	ease-theme.vala \
	ease-transformations.vala \
	ease-transition-pane.vala \
	ease-transitions.vala \
	ease-undo-action.vala \
	ease-undo-actions-element.vala \
	ease-undo-actions-slide.vala \
	ease-undo-item.vala \
	ease-undo-source.vala \
	ease-undo-controller.vala \
	ease-utilities.vala \
	ease-welcome-actor.vala \
	ease-welcome-window.vala \
	ease-zoom-slider.vala \
	$(NULL)

# compiler flags
libease_0_1_la_VALAFLAGS = \
	$(EASE_PACKAGES) \
	--vapi=ease-0.1.vapi \
	--header=libease.h \
	--thread \
	--library Ease-0.1 \
	--gir=Ease-0.1.gir \
	-g \
	$(NULL)

libease_0_1_la_CFLAGS = $(EASE_CFLAGS)
libease_0_1_la_LDFLAGS = $(EASE_LDFLAGS)

# build typelib

# header installation
libease_includedir=$(includedir)/ease-0.1/
libease_include_HEADERS = libease.h

# vapi installation
vapidir = $(datadir)/vala/vapi
vapi_DATA = ease-0.1.vapi

# gir installation
girdir = $(datadir)/gir-1.0
gir_DATA = Ease-0.1.gir
EXTRA_DIST = Ease-0.1.gir

# remove generated c files on `make clean`
CLEANFILES = $(subst .vala,.c,$(libease_0_1_la_SOURCES))

