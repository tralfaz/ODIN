#!/bin/sh

if [ -h ../../LIBS ]; then
  if [ ! -e ../../LIBS/libcairo.2.dylib ]; then 
    echo cairo shared library not found
    exit 1
  fi
else
  echo ../../LIBS symlink missing
  exit 1
fi

odin build hello-cairo.odin -file -out:hello-cairo
