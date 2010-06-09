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
	src/AboutDialog.vala \
	src/Actor.vala \
	src/Document.vala \
	src/EditorEmbed.vala \
	src/EditorWindow.vala \
	src/ElementMap.vala \
	src/ElementMapValue.vala \
	src/Element.vala \
	src/Enums.vala \
	src/ErrorDialog.vala \
	src/Handle.vala \
	src/HTMLExporter.vala \
	src/ImageActor.vala \
	src/Inspector.vala\
	src/InspectorPane.vala\
	src/InspectorWindow.vala\
	src/JSONParser.vala\
	src/MainToolbar.vala \
	src/Main.vala \
	src/MasterElement.vala \
	src/OpenDialog.vala \
	src/PDFExporter.vala \
	src/Player.vala \
	src/ScrollableEmbed.vala \
	src/SlideActor.vala \
	src/SlideButtonPanel.vala \
	src/SlideButton.vala \
	src/SlidePane.vala \
	src/SlideSet.vala \
	src/Slide.vala \
	src/Temp.vala \
	src/TextActor.vala \
	src/Theme.vala \
	src/TransitionPane.vala \
	src/Transitions.vala \
	src/UndoActions.vala \
	src/UndoController.vala \
	src/VideoActor.vala \
	src/WelcomeActor.vala \
	src/WelcomeWindow.vala \
	src/ZoomSlider.vala \
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
		$(NULL)

SUBDIRS = po

ease_LDADD = \
	$(EASE_LIBS) \
	$(NULL)

EXTRA_DIST = config.rpath m4/ChangeLog data/ease.desktop.in  \
	$(NULL)

DISTCLEANFILES = \
	$(NULL)

ACLOCAL_AMFLAGS = -I m4

desktopdir = $(datadir)/applications
desktop_in_files = data/ease.desktop.in
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

Applicationsdir = /usr/share/applications
Applications_DATA = data/ease.desktop.in

themedir = $(datadir)/ease/themes
theme_DATA = themes/*.easetheme

svgdir = $(datadir)/ease/svg
svg_DATA = data/svg/*.svg

