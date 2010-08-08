AC_INIT([Ease], [0.3], [https://bugzilla.gnome.org/enter_bug.cgi?product=ease], [ease], [http://live.gnome.org/Ease])

AC_PREREQ([2.59])

AC_CONFIG_FILES([
	Makefile
	po/Makefile.in
	data/Makefile
	ease-core/Makefile
	flutter/Makefile
	ease/Makefile
	pkgconfig/ease-core-0.3.pc
	pkgconfig/flutter-0.3.pc])

AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADERS([config.h])

AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2 subdir-objects -Wno-portability])
AM_MAINTAINER_MODE()

# Enable silent rules is available
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AC_PROG_CC
AC_PROG_CC_STDC

if test "x$USE_MAINTAINER_MODE" = "xyes" ; then
  AM_PROG_VALAC([0.9.1])
fi

AM_PROG_CC_C_O
AC_PROG_INSTALL
AC_PROG_INTLTOOL([0.35])
AM_PROG_LIBTOOL

# GObject introspection
AC_CONFIG_MACRO_DIR([m4])
GOBJECT_INTROSPECTION_CHECK([0.6.7])

dnl this is preferred, but doesn't work for me :
dnl LT_PREREQ([2.2.6])

GNOME_COMPILE_WARNINGS([maximum])
GNOME_MAINTAINER_MODE_DEFINES

dnl packages
pkg_modules=" \
	gee-1.0 \
	clutter-gtk-0.10 >= 0.10 \
	libarchive \
	json-glib-1.0 >= 0.7.6\
	clutter-gst-1.0 \
	gmodule-2.0 \
	unique-1.0"

EASE_PACKAGES=" \
	--pkg gee-1.0 \
	--pkg clutter-gtk-0.10 \
	--pkg libarchive \
	--pkg json-glib-1.0 \
    --pkg clutter-gst-1.0 \
	--pkg gmodule-2.0 \
	--pkg unique-1.0"

PKG_CHECK_MODULES(EASE, [$pkg_modules])

AC_SUBST(EASE_CFLAGS)
AC_SUBST(EASE_LIBS)
AC_SUBST(EASE_PACKAGES)

dnl internationalization
GETTEXT_PACKAGE=ease
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [Gettext Package])
AC_SUBST(GETTEXT_PACKAGE)
AM_GLIB_GNU_GETTEXT

AC_OUTPUT
