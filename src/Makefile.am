bin_PROGRAMS = ease

# source files
ease_SOURCES = main.vala

# compiler flags
ease_VALAFLAGS = --pkg ease --pkg gtk+-2.0 --pkg clutter-1.0 --pkg gee-1.0 --pkg json-glib-1.0 --vapidir ../libease

ease_LDADD = \
	../libease/libease-0.1.la \
	$(EASE_LIBS) \
	$(NULL)
	
ease_CFLAGS = $(EASE_CFLAGS)
ease_LDFLAGS = $(EASE_LDFLAGS)
