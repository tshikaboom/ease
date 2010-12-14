#!/usr/bin/env python

from waflib import TaskGen

VERSION = PACKAGE_VERSION = "0.5"
EASE_VERSION = "0.5"
EASE_CORE_VERSION = "0.5"
FLUTTER_VERSION = "0.5"
APPNAME = "ease"

top = '.'
out = '_build_'

def options(opt):
    opt.tool_options('compiler_c')
    opt.tool_options('gnu_dirs')

def configure(conf):
    conf.load('intltool')
    conf.check_tool('compiler_c vala gnu_dirs')
    
    conf.env.append_value('FLUTTER_VERSION', FLUTTER_VERSION)
    conf.env.append_value('EASE_CORE_VERSION', EASE_CORE_VERSION)
    conf.env.append_value('EASE_VERSION', EASE_VERSION)
    conf.env.append_value('PACKAGE_VERSION', PACKAGE_VERSION)
    
    conf.check_cfg(package='clutter-1.0', uselib_store='CLUTTER',
                   mandatory=True, args='--cflags --libs')
    conf.check_cfg(package='clutter-gst-1.0', uselib_store='CLUTTERGST',
                   mandatory=True, args='--cflags --libs')
    conf.check_cfg(package='gee-1.0', uselib_store='GEE',
                   mandatory=True, args='--cflags --libs')
    conf.check_cfg(package='gmodule-2.0', uselib_store='GMODULE',
                   mandatory=True, args='--cflags --libs')
    conf.check_cfg(package='libarchive', uselib_store='LIBARCHIVE',
                   mandatory=True, args='--cflags --libs')
    conf.check_cfg(package='poppler-glib', uselib_store='POPPLERGLIB',
                   mandatory=True, args='--cflags --libs')
    conf.check_cfg(package='rest-0.6', uselib_store='REST',
                   mandatory=True, args='--cflags --libs')
    conf.check_cfg(package='rest-extras-0.6', uselib_store='RESTEXTRAS',
                   mandatory=True, args='--cflags --libs')
    conf.check_cfg(package='unique-1.0', uselib_store='UNIQUE',
                   mandatory=True, args='--cflags --libs')
    conf.check_cfg(package='clutter-gtk-0.10', uselib_store='CLUTTERGTK',
                   atleast_version='0.10', mandatory=True, args='--cflags --libs')

    conf.check_cfg(package='json-glib-1.0', uselib_store='JSONGLIB',
                   atleast_version='0.7.6', mandatory=True, args='--cflags --libs')

    conf.define('PACKAGE', APPNAME)
    conf.define('PACKAGE_NAME', APPNAME)
    conf.define('PACKAGE_STRING', APPNAME + '-' + VERSION)
    conf.define('PACKAGE_VERSION', APPNAME + '-' + VERSION)

    conf.define('EASE_VERSION', EASE_VERSION)
    conf.define('FLUTTER_VERSION', FLUTTER_VERSION)
    conf.define('EASE_CORE_VERSION', EASE_CORE_VERSION)
    
    conf.define('EASE_DATA_DIR', '%{PREFIX}/share')
    
    conf.define('GETTEXT_PACKAGE', 'ease')

    conf.write_config_header('config.h')

def build_pkgconfig(bld, name):
    obj = bld(features = "subst_pc",
              source = name,
              install_path = "${LIBDIR}/pkgconfig")

def build_po(bld):
    bld(features='intltool_po', 
        appname=APPNAME, 
        podir='po', install_path="${LOCALEDIR}")


def build(bld):
    bld.EASE_VERSION = EASE_VERSION
    bld.EASE_CORE_VERSION = EASE_CORE_VERSION
    bld.FLUTTER_VERSION = FLUTTER_VERSION
    bld.srcdir = top 
    bld.builddir = out
    
    bld.add_subdirs('data')

    bld.add_subdirs('flutter')
    bld.add_group()
    bld.add_subdirs('ease-core')
    bld.add_group()
    bld.add_subdirs('ease')
    bld.add_group()
    
    build_pkgconfig(bld, "pkgconfig/ease-core-0.5.pc.in")
    build_pkgconfig(bld, "pkgconfig/flutter-0.5.pc.in")
    
    build_po
    



