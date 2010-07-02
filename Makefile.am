NULL =

INCLUDES = \
	-include config.h \
	$(EASE_CFLAGS)

AM_CPPFLAGS = \
	$(EASE_CFLAGS) \
	-include $(CONFIG_HEADER) \
	$(NULL)

SUBDIRS = po data libease src

EXTRA_DIST = data/ease.desktop.in  \
	$(NULL)

DISTCLEANFILES = data/ease.desktop \
	$(NULL)

ACLOCAL_AMFLAGS = -I m4

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = ease-0.1.pc

themedir = $(datadir)/ease/themes
theme_DATA = $(wildcard $(top_srcdir)/themes/*.easetheme)

doc: libease/*.vala
	rm -rf doc
	valadoc --internal --private --pkg "json-glib-1.0" --pkg "gee-1.0"  --pkg "clutter-gtk-0.10" --pkg "clutter-gst-1.0" --pkg "libarchive" --directory=./doc --basedir=src ./libease/*.vala
	gnome-open doc/doc/Ease.html

archive: themes/* examples/*
	sh themes/build.sh
	sh examples/build.sh

