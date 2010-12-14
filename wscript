#!/usr/bin/env python

from waflib import TaskGen

PACKAGE_VERSION = "ease-0.5"
VERSION = "0.5"
EASE_VERSION = "0.5"
EASE_CORE_VERSION = "0.5"
FLUTTER_VERSION = "0.5"
APPNAME = "ease"

top = '.'
out = ''

def options(opt):
    opt.tool_options('compiler_c')
    opt.tool_options('gnu_dirs')

def library_check(conf):
    libraries =  (
        ("clutter-1.0", "CLUTTER", None),
        ("clutter-gst-1.0", "CLUTTERGST", None),
        ("gee-1.0", "GEE", None),
        ("gmodule-2.0", "GMODULE", None),
        ("libarchive", "LIBARCHIVE", None),
        ("poppler-glib", "POPPLERGLIB", None),
        ("rest-0.6", "REST", None),
        ("rest-extras-0.6", "RESTEXTRAS",None),
        ("unique-1.0", "UNIQUE", None),
        ("clutter-gtk-0.10", "CLUTTERGTK", "0.10"),
        ("json-glib-1.0", "JSONGLIB", "0.7.6")
     )
    for (package, uselib, version) in libraries:
        conf.check_cfg(package=package, uselib_store=uselib, 
                       mandatory=True, version=version, 
                       args='--cflags --libs')

def write_config_header(conf):
    conf.define('PACKAGE', APPNAME)
    conf.define('PACKAGE_NAME', APPNAME)
    conf.define('PACKAGE_STRING', APPNAME + '-' + VERSION)
    conf.define('PACKAGE_VERSION', APPNAME + '-' + VERSION)

    conf.define('EASE_VERSION', EASE_VERSION)
    conf.define('FLUTTER_VERSION', FLUTTER_VERSION)
    conf.define('EASE_CORE_VERSION', EASE_CORE_VERSION)
    
    conf.define('EASE_DATA_DIR', '%{DATADIR}')
    
    conf.define('GETTEXT_PACKAGE', 'ease')

    conf.write_config_header('config.h')

def configure(conf):
    conf.load('intltool')
    conf.check_tool('compiler_c vala gnu_dirs')
    

    # For pkgconfig substitution.
    conf.env.append_value('FLUTTER_VERSION', FLUTTER_VERSION)
    conf.env.append_value('EASE_CORE_VERSION', EASE_CORE_VERSION)
    conf.env.append_value('EASE_VERSION', EASE_VERSION)
    conf.env.append_value('PACKAGE_VERSION', PACKAGE_VERSION)
    
    write_config_header(conf)
    
    library_check(conf)



def build_pkgconfig_file(bld, name):
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
    
    build_pkgconfig_file(bld, "pkgconfig/ease-core-0.5.pc.in")
    build_pkgconfig_file(bld, "pkgconfig/flutter-0.5.pc.in")
    
    build_po(bld)
    



