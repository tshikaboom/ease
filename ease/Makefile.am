# build ease executable
bin_PROGRAMS = ease

# source files
ease_SOURCES = \
	ease-about-dialog.vala \
	ease-close-confirm-dialog.vala \
	ease-editor-embed.vala \
	ease-editor-window.vala \
	ease-handle.vala \
	ease-inspector-element-pane.vala \
	ease-inspector-pane.vala \
	ease-inspector-slide-pane.vala \
	ease-inspector-transition-pane.vala \
	ease-inspector.vala \
	ease-main.vala \
	ease-player.vala \
	ease-scrollable-embed.vala \
	ease-selection-rectangle.vala \
	ease-slide-actor.vala \
	ease-slide-button-panel.vala \
	ease-slide-sorter.vala \
	ease-welcome-actor.vala \
	ease-welcome-window.vala

# compiler flags
ease_VALAFLAGS = \
	--pkg ease-core-0.3 \
	--pkg flutter-0.3 \
	--disable-warnings \
	$(EASE_PACKAGES) \
	--vapidir ../vapi \
	--thread \
	-g

EASE_CFLAGS += -w -I../ease-core/ -I../flutter
ease_LDFLAGS = --export-dynamic

ease_LDADD = \
	../ease-core/libease-core-0.3.la \
	../flutter/libflutter-0.3.la \
	-lm \
	$(EASE_LIBS) \
	$(NULL)
	
INCLUDES = \
	-include ../config.h \
	$(EASE_CFLAGS)

AM_CPPFLAGS = \
	$(EASE_CFLAGS) \
	-include $(CONFIG_HEADER) \
	-O0 \
	$(NULL)

CLEANFILES = $(subst .vala,.c,$(ease_SOURCES))

