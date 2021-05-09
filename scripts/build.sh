#!/bin/bash

set -e

mkdir -p build

#filename=build/status-widget-$(git describe --abbrev=0 --tags).pk3
filename=build/status-widget.pk3

#git log --date=short --pretty=format:"-%d %ad %s%n" | \
#    grep -v "^$" | \
#    sed "s/HEAD -> master, //" | \
#    sed "s/, origin\\/master//" | \
#    sed "s/ (HEAD -> master)//" | \
#    sed "s/ (origin\\/master)//"  |\
#    sed "s/- (tag: \\(v\\?[0-9.]*\\))/\\n\\1\\n-/" \
#    > changelog.txt

rm -f "$filename"
zip -R0 "$filename" "*.md" "*.txt" "*.zs"

gzdoom -file "$filename" "$@"
