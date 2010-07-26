NULL =

INCLUDES = 
	-include config.h \
	$(EASE_CFLAGS)

bin_PROGRAMS = ease

AM_CPPFLAGS = \
	$(EASE_CFLAGS) \
	-include $(CONFIG_HEADER) \
	-O0 \
	$(NULL)

ease_SOURCES = \
	src/ease-about-dialog.vala \
	src/ease-actor.vala \
	src/ease-animated-zoom-slider.vala \
	src/ease-close-confirm-dialog.vala \
	src/ease-clutter-iterables.vala \
	src/ease-color.vala \
	src/ease-dialogs.vala \
	src/ease-document.vala \
	src/ease-editor-embed.vala \
	src/ease-editor-window.vala \
	src/ease-element.vala \
	src/ease-enums.vala \
	src/ease-gradient.vala \
	src/ease-handle.vala \
	src/ease-html-exporter.vala \
	src/ease-image-actor.vala \
	src/ease-image-element.vala \
	src/ease-inspector-pane.vala \
	src/ease-inspector.vala \
	src/ease-inspector-window.vala \
	src/ease-iterables.vala \
	src/ease-media-element.vala \
	src/ease-player.vala \
	src/ease-scrollable-embed.vala \
	src/ease-selection-rectangle.vala \
	src/ease-slide-actor.vala \
	src/ease-slide-button-panel.vala \
	src/ease-slide-pane.vala \
	src/ease-slide.vala \
	src/ease-temp.vala \
	src/ease-text-actor.vala \
	src/ease-text-element.vala \
	src/ease-theme.vala \
	src/ease-transformations.vala \
	src/ease-transition-pane.vala \
	src/ease-transitions.vala \
	src/ease-undo-action.vala \
	src/ease-undo-actions-element.vala \
	src/ease-undo-actions-slide.vala \
	src/ease-undo-controller.vala \
	src/ease-undo-item.vala \
	src/ease-undo-source.vala \
	src/ease-utilities.vala \
	src/ease-welcome-actor.vala \
	src/ease-welcome-window.vala \
	src/ease-zoom-slider.vala \
	src/main.vala \
	$(NULL)

# ease_VALAFLAGS = $(EASE_PACKAGES)
VALAFLAGS = \
	--pkg glib-2.0 \
	--pkg gtk+-2.0 \
	--pkg clutter-1.0 \
	--pkg gdk-2.0 \
	--pkg gee-1.0 \
	--pkg clutter-gtk-0.10 \
	--pkg cogl-1.0 \
	--pkg gio-2.0 \
	--pkg json-glib-1.0\
	--pkg libarchive\
	--pkg gmodule-2.0\
	-g \
	$(NULL)

SUBDIRS = po data

ease_LDADD = \
	$(EASE_LIBS) \
	-lm \
	$(NULL)

EXTRA_DIST = data/ease.desktop.in.in  \
	$(NULL)

DISTCLEANFILES = data/ease.desktop \
	$(NULL)

ACLOCAL_AMFLAGS = -I m4

doc: src/*.vala
	rm -rf doc
	valadoc --internal --private --pkg "json-glib-1.0" --pkg "gee-1.0"  --pkg "clutter-gtk-0.10" --pkg "libarchive" --directory=./doc --basedir=src ./src/*.vala
	gnome-open doc/doc/Ease.html

archive: data/themes/* examples/*
	sh data/themes/build.sh
	sh examples/build.sh

