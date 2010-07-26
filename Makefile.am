NULL =

SUBDIRS = po data libease src

INCLUDES = \
	-include config.h \
	$(EASE_CFLAGS)

AM_CPPFLAGS = \
	$(EASE_CFLAGS) \
	-include $(CONFIG_HEADER) \
	-O0 \
	$(NULL)

EXTRA_DIST = data/ease.desktop.in.in  \
	$(NULL)

DISTCLEANFILES = data/ease.desktop \
	$(NULL)

ACLOCAL_AMFLAGS = -I m4

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = ease-0.1.pc

doc: libease/*.vala
	rm -rf doc
	
	valadoc \
		--internal \
		$(EASE_PACKAGES) \
		--directory=./doc --basedir=src ./libease/*.vala
	
	gnome-open doc/doc/Ease.html

archive: data/themes/* examples/*
	sh data/themes/build.sh
	sh examples/build.sh

