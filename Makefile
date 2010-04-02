.PHONY: clean run gitclean todo vapi

EASE_CFLAGS = `pkg-config --cflags gobject-2.0 gtk+-2.0 pango \
    clutter-1.0 clutter-gtk-0.10 gee-1.0 libxml-2.0 cogl-1.0 gio-2.0`

EASE_LDFLAGS = `pkg-config --libs gobject-2.0 gtk+-2.0 pango \
    clutter-1.0 clutter-gtk-0.10 gee-1.0 libxml-2.0 cogl-1.0 gio-2.0`

VALA_FLAGS = --vapidir=./vapi --pkg "glib-2.0"  --pkg "gtk+-2.0"  --pkg "clutter-1.0"  --pkg "gdk-2.0"  --pkg "libxml-2.0"  --pkg "gee-1.0"  --pkg "clutter-gtk-0.10"  --pkg "cogl-1.0" --pkg "gio-2.0"

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
	grep -n "TODO" src/libease/*.vala src/ease/*.c src/ease-player/*.c | less

gitclean:
	git clean -x -f -d

clean:
	rm -f src/libease/*.o src/libease/*.so src/libease/*.vapi
	rm -f src/ease/*.o
	rm -f src/ease-player/*.o
	rm -f src/libease/*.c
	rm -f ease
	rm -f ease-player
	rm -f libease.so

run: all
	LD_LIBRARY_PATH=. ./ease
	
play:
	LD_LIBRARY_PATH=. ./ease-player ./Examples/Example.ease/
	
edit:
	LD_LIBRARY_PATH=. ./ease ./Examples/Example.ease/
