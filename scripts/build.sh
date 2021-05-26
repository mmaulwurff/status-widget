#!/bin/bash

filename=build/status-widget-$(git describe --abbrev=0 --tags).pk3

mkdir -p build
rm -f   "$filename"
zip -R0 "$filename" "*.md" "*.txt" "*.zs" > /dev/null
gzdoom  "$filename" "$@" > output 2>&1; cat output
