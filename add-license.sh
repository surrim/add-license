#!/bin/bash

# Copyright 2015-2022 surrim
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

NAME=$1
COPYRIGHT=$2
LICENSE=$3
WORKING_DIRECTORY=$4

ADD_LICENSE_DIRECTORY=$(dirname "$0")
TEMP_FILE="/tmp/add-license.$$"

if [ "$NAME" == "" ] || [ "$COPYRIGHT" == "" ]; then
	echo "Usage: $0 NAME COPYRIGHT [LICENSE [WORKING_DIRECTORY]]"
	echo "   Example: add-license.sh \"My new project\" \"2022 surrim\" gpl ."
	exit 1
fi

if [ "$LICENSE" == "" ]; then
	LICENSE="gpl"
fi
LICENSE_DIRECTORY="$ADD_LICENSE_DIRECTORY/snippets/$LICENSE"
if [ ! -e "$LICENSE_DIRECTORY" ]; then
	echo "License \"$LICENSE\" not found"
	exit 1
fi

if [ "$WORKING_DIRECTORY" == "" ]; then
	WORKING_DIRECTORY="."
fi
if [ ! -e "$WORKING_DIRECTORY" ]; then
	echo "Directory \"$WORKING_DIRECTORY\" not found"
	exit 1
fi

cp "$LICENSE_DIRECTORY/LICENSE" "$WORKING_DIRECTORY"
find "$WORKING_DIRECTORY" -type f -regex "^.+\..+$" | while read FILE; do
	if ! grep -q Copyright "$FILE"; then
		FILE_EXT=${FILE##*\.}
		TEMPLATE="$LICENSE_DIRECTORY/template.$FILE_EXT"
		if [ -e "$TEMPLATE" ]; then
			echo "$FILE"
			sed "$TEMPLATE" -E \
				-e "s/APP_COPYRIGHT/$COPYRIGHT/g" \
				-e "s/APP_NAME/$NAME/g" > "$TEMP_FILE"
			cat "$FILE" >> "$TEMP_FILE"
			mv "$TEMP_FILE" "$FILE"
		fi
	fi
done
