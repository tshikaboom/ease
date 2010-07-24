@INTLTOOL_DESKTOP_RULE@

desktopdir = $(datadir)/applications
desktop_in_files = ease.desktop.in
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)

svgdir = $(datadir)/ease/svg
svg_DATA = $(wildcard $(top_srcdir)/data/svg/*.svg)

uidir = $(datadir)/ease/ui
ui_DATA = $(wildcard $(top_srcdir)/data/ui/*.ui)

jsondir = $(datadir)/ease
json_DATA = theme-defaults.json

themedir = $(datadir)/ease/themes
theme_DATA = \
	themes/White.easetheme \
	themes/Black.easetheme \
	themes/Blue.easetheme \
	themes/Red.easetheme \
	themes/Green.easetheme \
	themes/Goddard.easetheme \
	$(NULL)

EXTRA_DIST = \
    $(ui_DATA) \
    $(svg_DATA) \
    $(desktop_in_files) \
    $(json_DATA)
