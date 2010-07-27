NULL =

SUBDIRS = po data ease-core
	
bin_PROGRAMS = ease

# source files
ease_SOURCES = src/main.vala

# compiler flags
ease_VALAFLAGS = \
	--pkg ease-core-0.3 \
	$(EASE_PACKAGES) \
	--vapidir ./ease-core

ease_LDADD = \
	./ease-core/libease-core-0.3.la \
	$(EASE_LIBS) \
	$(NULL)
	
INCLUDES = \
	-include config.h \
	$(EASE_CFLAGS)

EASE_CFLAGS += -w -I./ease-core/

AM_CPPFLAGS = \
	$(EASE_CFLAGS) \
	-include $(CONFIG_HEADER) \
	-O0 \
	$(NULL)

CLEANFILES = src/main.c

# distribution
EXTRA_DIST = data/ease.desktop.in.in  \
	$(NULL)

DISTCLEANFILES = data/ease.desktop \
	$(NULL)

ACLOCAL_AMFLAGS = -I m4

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = ease-core-0.3.pc

doc: ease-core/*.vala
	rm -rf doc
	
	valadoc \
		--internal \
		$(EASE_PACKAGES) \
		--directory=./doc --basedir=src ./ease-core/*.vala
	
	gnome-open doc/doc/Ease.html

archive: examples/*
	sh examples/build.sh

