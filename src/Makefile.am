bin_PROGRAMS = ease

# source files
ease_SOURCES = main.vala

# compiler flags
ease_VALAFLAGS = --pkg ease --pkg gtk+-2.0 --pkg clutter-1.0 --pkg gee-1.0 --pkg json-glib-1.0 --vapidir ../libease

ease_LDADD = \
	../libease/libease-0.1.la \
	$(EASE_LIBS) \
	$(NULL)
	
ease_CFLAGS = `pkg-config --cflags \
	glib-2.0 \
	gtk+-2.0 \
	clutter-1.0 \
	gdk-2.0 \
	gee-1.0 \
	clutter-gtk-0.10 \
	cogl-1.0 \
	gio-2.0 \
	clutter-gst-1.0 \
	json-glib-1.0 \
	libarchive \
	gmodule-2.0 `
	
ease_LDFLAGS = `pkgconfig --libs \
	glib-2.0 \
	gtk+-2.0 \
	clutter-1.0 \
	gdk-2.0 \
	gee-1.0 \
	clutter-gtk-0.10 \
	cogl-1.0 \
	gio-2.0 \
	clutter-gst-1.0 \
	json-glib-1.0 \
	libarchive \
	gmodule-2.0 `
