bin_PROGRAMS = ease

# source files
ease_SOURCES = main.vala

# compiler flags
ease_VALAFLAGS = \
	--pkg ease \
	$(EASE_PACKAGES) \
	--vapidir ../libease

ease_LDADD = \
	../libease/libease-0.1.la \
	$(EASE_LIBS) \
	$(NULL)
	
ease_CFLAGS = $(EASE_CFLAGS) -I../libease/
ease_LDFLAGS = $(EASE_LDFLAGS)
