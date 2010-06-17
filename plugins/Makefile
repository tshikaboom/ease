CFLAGS = --pkg gtk+-2.0 --pkg gmodule-2.0 --pkg json-glib-1.0 --pkg rest-extras-0.6
OCAFLAGS = --pkg gtk+-2.0 --pkg libsexy --pkg rest-extras-0.6 --pkg libxml-2.0 -o openclipart

flickr:flickr.vala
	valac $(CFLAGS) flickr.vala
	
oca: oca-dialog.vala oca-image.vala
	valac -g $(OCAFLAGS) oca-dialog.vala oca-image.vala

clean:
	rm -rf flickr
	rm -rf openclipart
