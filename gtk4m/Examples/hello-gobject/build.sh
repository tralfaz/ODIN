#!/bin/sh

if [ -h ../../LIBS ]; then
  if [ ! -e ../../LIBS/libgio-2.0.dylib ]; then 
    echo gio shared library not found
    exit 1
  fi
  if [ ! -e ../../LIBS/libglib-2.0.dylib ]; then
    echo glib shared library not found
    exit 1
  fi
  if [ ! -e ../../LIBS/libgobject-2.0.dylib ]; then
    echo gobject shared library not found
    exit 1
  fi
  if [ ! -e ../../LIBS/libgmodule-2.0.dylib ]; then
    echo gmodule shared library not found
    exit 1
  fi
else
  echo ../../LIBS symlink missing
  exit 1
fi

odin build hello-gobject.odin -file -out:hello-gobject
