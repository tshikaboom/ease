NULL =

SUBDIRS = po data ease-bindings flutter ease-core ease

# distribution
EXTRA_DIST = data/ease.desktop.in.in  \
	$(NULL)

DISTCLEANFILES = data/ease.desktop \
	$(NULL)

ACLOCAL_AMFLAGS = -I m4

pkgconfigdir = $(libdir)/pkgconfig
pkgconfig_DATA = \
	pkgconfig/ease-bindings-@BINDINGS_VERSION@.pc \
    pkgconfig/ease-core-@EASE_CORE_VERSION@.pc \
    pkgconfig/flutter-@FLUTTER_VERSION@.pc 
    
run: ease/ease
	ease/ease

db: ease/ease
	libtool --mode=execute gdb ease/ease

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

potfiles:
	echo "# List of source files which contain translatable strings." > po/POTFILES.in
	echo "[encoding: UTF-8]" >> po/POTFILES.in
	echo "data/ease.desktop.in" >> po/POTFILES.in
	echo "data/ease.desktop.in.in" >> po/POTFILES.in
	ls ease-core | grep ease- | grep .vala | sed "s/ease/ease-core\/ease/g" >> po/POTFILES.in
	ls ease | grep ease- | grep .vala | sed "s/ease/ease\/ease/g" >> po/POTFILES.in
	ls data/ui | while read line; do echo "data/ui/$$line" >> po/POTFILES.in; done
	
	ls ease-core | grep ease- | grep "\.c" | sed "s/ease/ease-core\/ease/g" > po/POTFILES.skip
	ls ease | grep ease- | grep "\.c" | sed "s/ease/ease\/ease/g" >> po/POTFILES.skip
	ls flutter | while read line; do echo "flutter/$$line" >> po/POTFILES.skip; done
	echo "ease-core/libease-core.h" >> po/POTFILES.skip
	echo "flutter/libflutter.h" >> po/POTFILES.skip

