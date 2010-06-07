#!/bin/sh

echo "  Archiving example .ease files..."

cd examples

for DOC in `find ./* -maxdepth 0 -type d | sed "s/.\///g"`
	do
		echo "    Archiving $DOC to $DOC.ease ..."
		cd $DOC
		tar -cf ../$DOC.ease `ls`
		cd ..
	done

echo "  Done archiving example .ease files."

