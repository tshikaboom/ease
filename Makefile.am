NULL =

SUBDIRS = po data flutter ease-core
	
bin_PROGRAMS = ease

# source files
ease_SOURCES = \
	src/ease-about-dialog.vala \
	src/ease-close-confirm-dialog.vala \
	src/ease-editor-embed.vala \
	src/ease-editor-window.vala \
	src/ease-handle.vala \
	src/ease-inspector-element-pane.vala \
	src/ease-inspector-pane.vala \
	src/ease-inspector-slide-pane.vala \
	src/ease-inspector-transition-pane.vala \
	src/ease-inspector.vala \
	src/ease-main.vala \
	src/ease-player.vala \
	src/ease-scrollable-embed.vala \
	src/ease-selection-rectangle.vala \
	src/ease-slide-actor.vala \
	src/ease-slide-button-panel.vala \
	src/ease-welcome-actor.vala \
	src/ease-welcome-window.vala

# compiler flags
ease_VALAFLAGS = \
	--pkg ease-core-0.3 \
	--pkg flutter-0.3 \
	$(EASE_PACKAGES) \
	--vapidir vapi \
	--thread \
	-g

ease_LDADD = \
	./ease-core/libease-core-0.3.la \
	./flutter/libflutter-0.3.la \
	-lm \
	$(EASE_LIBS) \
	$(NULL)
	
INCLUDES = \
	-include config.h \
	$(EASE_CFLAGS)

EASE_CFLAGS += -w -I./ease-core/ -I./flutter

AM_CPPFLAGS = \
	$(EASE_CFLAGS) \
	-include $(CONFIG_HEADER) \
	-O0 \
	$(NULL)

CLEANFILES = $(subst .vala,.c,$(ease_SOURCES))

# distribution
EXTRA_DIST = data/ease.desktop.in.in  \
	$(NULL)

DISTCLEANFILES = data/ease.desktop \
	$(NULL)

ACLOCAL_AMFLAGS = -I m4

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = \
    pkgconfig/ease-core-0.3.pc \
    pkgconfig/flutter-0.3.pc

doc: ease-core/*.vala
	rm -rf doc
	
	valadoc \
		$(EASE_PACKAGES) \
		--directory=./doc --basedir=src ./ease-core/*.vala
	
	gnome-open doc/doc/Ease.html

doc-internal:
	rm -rf doc
	
	valadoc \
		--internal \
		$(EASE_PACKAGES) \
		--directory=./doc --basedir=src ./ease-core/*.vala
	
	gnome-open doc/doc/Ease.html

archive: examples/*
	sh examples/build.sh

