#!/bin/sh

echo "  Archiving themes..."

cd data/themes

for THEME in `find ./* -maxdepth 0 -type d | sed "s/.\///g"`
	do
		echo "    Archiving $THEME to $THEME.easetheme ..."
		cd $THEME
		tar -cf ../$THEME.easetheme `ls`
		cd ..
	done

echo "  Done archiving themes."

