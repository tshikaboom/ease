@INTLTOOL_DESKTOP_RULE@

desktopdir = $(datadir)/applications
desktop_in_files = ease.desktop.in
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)

# install an icon for the app
appicondir = $(datadir)/icons/hicolor/scalable/apps
appicon_DATA = icons/hicolor/scalable/apps/ease.svg

svgdir = $(datadir)/ease/svg
svg_DATA = $(wildcard $(top_srcdir)/data/svg/*.svg)

uidir = $(datadir)/ease/ui
ui_DATA = $(wildcard $(top_srcdir)/data/ui/*.ui)

jsondir = $(datadir)/ease
json_DATA = theme-defaults.json

blackdir = $(datadir)/ease/themes/Black
black_DATA = themes/Black/Theme.json

bluedir = $(datadir)/ease/themes/Blue
blue_DATA = themes/Blue/Theme.json

goddarddir = $(datadir)/ease/themes/Goddard
goddard_DATA = themes/Goddard/Theme.json

goddardmediadir = $(datadir)/ease/themes/Goddard/Media
goddardmedia_DATA = themes/Goddard/Media/default.jpg

greendir = $(datadir)/ease/themes/Green
green_DATA = themes/Green/Theme.json

reddir = $(datadir)/ease/themes/Red
red_DATA = themes/Red/Theme.json

whitedir = $(datadir)/ease/themes/White
white_DATA = themes/White/Theme.json

EXTRA_DIST = \
    $(appicon_DATA) \
    $(ui_DATA) \
    $(svg_DATA) \
    $(desktop_in_files) \
    $(json_DATA) \
    $(black_DATA) \
    $(blue_DATA) \
    $(goddard_DATA) \
    $(goddardmedia_DATA) \
    $(green_DATA) \
    $(red_DATA) \
    $(white_DATA)
