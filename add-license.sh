#!/bin/bash

# Copyright 2015 surrim
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

name=$1
copyright=$2
license=$3
path=$4
error=0

DIR=$(dirname "$0")
HEADERS_DIR="$DIR/headers"
GPLv3_C="GPLv3.c"
GPLv3_ECPP="GPLv3.ecpp"

if [ "$name" == "" ]; then
	echo "usage: $0 <name> <copyright> [license [path]]"
	exit 1
fi
if [ "$license" == "" ]; then
	license="gpl"
fi
if [ "$path" == "" ]; then
	path="."
fi
case "$license" in
	gpl|gplv3)
		C=$GPLv3_C
		ECPP=$GPLv3_ECPP
		;;
	*)
		echo "usage: $0 <name> <copyright> [license [path]]"
		exit 1
esac
for i in $C $ECPP; do
	sed "s/APP_COPYRIGHT/$copyright/g" "$HEADERS_DIR/$i" | sed "s/APP_NAME/$name/g" > "/tmp/$i"
done
find -L "$path" -type f -regex ".+\.\(h\|c\|cpp\|ecpp\)$" | while read i; do
	if ! grep -q Copyright "$i"
	then
		ext=${i##*\.}
		case "$ext" in
			c|cpp|h)
				file=$C
				;;
			ecpp)
				file=$ECPP
				;;
			*)
				echo "no license for $i ($ext)"
				error=1
		esac
		echo "$i"
		cat "/tmp/$file" "$i" > "$i.new" && mv "$i.new" "$i"
	fi
done
for i in $C $ECPP; do
	rm "/tmp/$i"
done
exit $error
