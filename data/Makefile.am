@INTLTOOL_DESKTOP_RULE@

desktopdir = $(datadir)/applications
desktop_in_files = ease.desktop.in
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)

svgdir = $(datadir)/ease/svg
svg_DATA = $(wildcard $(top_srcdir)/data/svg/*.svg)

uidir = $(datadir)/ease/ui
ui_DATA = $(wildcard $(top_srcdir)/data/ui/*.ui)

EXTRA_DIST = $(ui_DATA) $(svg_DATA) $(desktop_in_files)

