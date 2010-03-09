.PHONY: clean run gitclean todo vapi

EASE_CFLAGS = `pkg-config --cflags gobject-2.0 gtk+-2.0 pango \
    clutter-1.0 clutter-gtk-0.10 gee-1.0 libxml-2.0 cogl-1.0`

EASE_LDFLAGS = `pkg-config --libs gobject-2.0 gtk+-2.0 pango \
    clutter-1.0 clutter-gtk-0.10 gee-1.0 libxml-2.0 cogl-1.0`

VALA_FLAGS = --pkg "glib-2.0"  --pkg "gtk+-2.0"  --pkg "clutter-1.0"  --pkg "gdk-2.0"  --pkg "libxml-2.0"  --pkg "gee-1.0"  --pkg "clutter-gtk-0.10"  --pkg "cogl-1.0"

all: libease.so ease player

libease.so: src/libease/*.vala
	valac $(VALA_FLAGS) -C -H src/libease/libease.h src/libease/*.vala --basedir src/libease -d src/libease
	gcc -g -O0 $(EASE_CFLAGS) --shared -fPIC src/libease/*.c -o libease.so
	rm src/libease/*.c

ease: libease.so src/ease/*.c
	gcc -g -O0 $(EASE_CFLAGS) $(EASE_LDFLAGS) -Isrc -L. -lease src/ease/*.c -o ease

player: libease.so src/ease-player/*.c
	gcc -g -O0 $(EASE_CFLAGS) $(EASE_LDFLAGS) -Isrc -L. -lease src/ease-player/main.c -o ease-player
	
asone:
	valac $(VALA_FLAGS) -C -H src/libease/libease.h src/libease/*.vala --basedir src/libease -d src/libease
	gcc -g -O0 $(EASE_CFLAGS) $(EASE_LDFLAGS) -fPIC src/libease/*.c src/ease/*.c -o ease
	rm src/libease/*.c

vapi:

todo:
	cd src ; grep -n "TODO" libease/*.vala ease/*.vala ease-player/*.vala ease/*.c ease-player/*.c

gitclean:
	git clean -x -f -d

clean:
	rm -f src/libease/*.o src/libease/*.so src/libease/*.vapi
	rm -f src/ease/*.o
	rm -f src/ease-player/*.o
	rm -f ease
	rm -f ease-player
	rm -f libease.so

run: all
	LD_LIBRARY_PATH=. ./ease
