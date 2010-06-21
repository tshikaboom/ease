NULL =

INCLUDES = 
	-include config.h \
	$(EASE_CFLAGS)

bin_PROGRAMS = ease

AM_CPPFLAGS = \
	$(EASE_CFLAGS) \
	-include $(CONFIG_HEADER) \
	$(NULL)

ease_SOURCES = \
	src/ease-about-dialog.vala \
	src/ease-actor.vala \
	src/ease-close-confirm-dialog.vala \
	src/ease-document.vala \
	src/ease-editor-embed.vala \
	src/ease-editor-window.vala \
	src/ease-element-map.vala \
	src/ease-element-map-value.vala \
	src/ease-element.vala \
	src/ease-enums.vala \
	src/ease-handle.vala \
	src/ease-html-exporter.vala \
	src/ease-image-actor.vala \
	src/ease-image-element.vala \
	src/ease-inspector-pane.vala \
	src/ease-inspector.vala \
	src/ease-inspector-window.vala \
	src/ease-json-parser.vala \
	src/ease-main-toolbar.vala \
	src/ease-media-element.vala \
	src/ease-open-dialog.vala \
	src/ease-pdf-exporter.vala \
	src/ease-player.vala \
	src/ease-scrollable-embed.vala \
	src/ease-slide-actor.vala \
	src/ease-slide-button-panel.vala \
	src/ease-slide-button.vala \
	src/ease-slide-pane.vala \
	src/ease-slide-set.vala \
	src/ease-slide.vala \
	src/ease-temp.vala \
	src/ease-text-actor.vala \
	src/ease-text-element.vala \
	src/ease-theme.vala \
	src/ease-transition-pane.vala \
	src/ease-transitions.vala \
	src/ease-undo-actions.vala \
	src/ease-undo-controller.vala \
	src/ease-utilities.vala \
	src/ease-video-actor.vala \
	src/ease-video-element.vala \
	src/ease-welcome-actor.vala \
	src/ease-welcome-window.vala \
	src/ease-zoom-slider.vala \
	src/main.vala \
	src/source-base-group.vala \
	src/source-base-view.vala \
	src/source-expandable-group.vala \
	src/source-group.vala \
	src/source-item.vala \
	src/source-list.vala \
	src/source-pane-view.vala \
	src/source-view.vala \
	$(NULL)

# ease_VALAFLAGS = $(EASE_PACKAGES)
VALAFLAGS = --pkg glib-2.0 \
		--pkg gtk+-2.0 \
		--pkg clutter-1.0 \
		--pkg gdk-2.0 \
		--pkg gee-1.0 \
		--pkg clutter-gtk-0.10 \
		--pkg cogl-1.0 \
		--pkg gio-2.0 \
		--pkg clutter-gst-1.0\
		--pkg json-glib-1.0\
		--pkg libarchive\
		-g \
		$(NULL)

SUBDIRS = po

ease_LDADD = \
	$(EASE_LIBS) \
	$(NULL)

EXTRA_DIST = data/ease.desktop.in  \
	$(NULL)

DISTCLEANFILES = \
	$(NULL)

ACLOCAL_AMFLAGS = -I m4

desktopdir = $(datadir)/applications
desktop_IN = data/ease.desktop.in
desktop_DATA = \
	$(desktop_IN:.in=)
@INTLTOOL_DESKTOP_RULE@

Applicationsdir = /usr/share/applications
Applications_DATA = data/ease.desktop.in

themedir = $(datadir)/ease/themes
theme_DATA = themes/*.easetheme

svgdir = $(datadir)/ease/svg
svg_DATA = data/svg/*.svg

doc: src/*.vala
	rm -rf doc
	valadoc --internal --private --pkg "json-glib-1.0" --pkg "gee-1.0"  --pkg "clutter-gtk-0.10" --pkg "clutter-gst-1.0" --pkg "libarchive" --directory=./doc --basedir=src ./src/*.vala
	gnome-open doc/doc/Ease.html

archive: themes/* examples/*
	sh themes/build.sh
	sh examples/build.sh

