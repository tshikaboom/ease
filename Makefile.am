NULL =

SUBDIRS = po data flutter ease-core ease

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
    
run: ease/ease
	ease/ease

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

