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
	src/Actor.vala \
	src/Document.vala \
	src/EditorEmbed.vala \
	src/EditorWindow.vala \
	src/ElementMap.vala \
	src/ElementMapValue.vala \
	src/Element.vala \
	src/Enums.vala \
	src/Handle.vala \
	src/HTMLExporter.vala \
	src/ImageActor.vala \
	src/MainToolbar.vala \
	src/Main.vala \
	src/OpenDialog.vala \
	src/Player.vala \
	src/ScrollableEmbed.vala \
	src/SlideActor.vala \
	src/SlideButtonPanel.vala \
	src/SlideButton.vala \
	src/SlidePane.vala \
	src/Slide.vala \
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
		--pkg libxml-2.0 \
		--pkg gee-1.0 \
		--pkg clutter-gtk-0.10 \
		--pkg cogl-1.0 \
		--pkg gio-2.0 \
		--pkg clutter-gst-1.0
		$(NULL)

SUBDIRS = po

ease_LDADD = \
	$(EASE_LIBS) \
	$(NULL)

EXTRA_DIST = config.rpath m4/ChangeLog  \
	$(NULL)

DISTCLEANFILES = \
	$(NULL)

ACLOCAL_AMFLAGS = -I m4
