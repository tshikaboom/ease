#!/bin/sh

cd data/themes

for THEME in `find ./* -maxdepth 0 -type d | sed "s/.\///g"`
	do
		cd $THEME
		tar -cf ../$THEME.easetheme `ls`
		cd ..
	done

