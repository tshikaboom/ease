.PHONY: clean run gitclean todo vapi

EASE_CFLAGS = `pkg-config --cflags gobject-2.0 gtk+-2.0 pango clutter-gst-1.0 \
    clutter-1.0 clutter-gtk-0.10 gee-1.0 libxml-2.0 cogl-1.0 gio-2.0`

EASE_LDFLAGS = `pkg-config --libs gobject-2.0 gtk+-2.0 pango clutter-gst-1.0 \
    clutter-1.0 clutter-gtk-0.10 gee-1.0 libxml-2.0 cogl-1.0 gio-2.0 `

VALA_FLAGS = --vapidir=./vapi --pkg "glib-2.0"  --pkg "gtk+-2.0"  --pkg "clutter-1.0"  --pkg "gdk-2.0"  --pkg "libxml-2.0"  --pkg "gee-1.0"  --pkg "clutter-gtk-0.10"  --pkg "cogl-1.0" --pkg "gio-2.0" --pkg "clutter-gst-1.0"

DOC_FLAGS = --vapidir=./vapi --pkg "glib-2.0"  --pkg "gtk+-2.0"  --pkg "clutter-1.0"  --pkg "gdk-2.0"  --pkg "libxml-2.0"  --pkg "gee-1.0"  --pkg "clutter-gtk-0.10"  --pkg "cogl-1.0" --pkg "gio-2.0" --pkg "clutter-gst-1.0"

all: clang

clang: src/*.vala
	valac $(VALA_FLAGS) -C -H src/libease.h src/*.vala --basedir src/ -d src/
	clang -O0 $(EASE_CFLAGS) $(EASE_LDFLAGS) -Wno-unused-value -Wno-pointer-sign -Wno-switch-enum -o ease src/*.c
	rm src/*.c
	
vapi:

doc: src/*.vala
	rm -rf doc
	valadoc $(DOC_FLAGS) --directory=./doc ./src/*.vala

todo:
	grep -n "TODO" src/*.vala | less

gitclean:
	git clean -x -f -d

clean:
	rm -f src/*.o src/*.so src/*.vapi
	rm -f src/*.c
	rm -f ease
	rm -rf doc

