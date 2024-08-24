#!/bin/bash

echo "Checking Arkdep for updates..."

CURENTDIR=$(pwd)
echo "Running in: $PWD"
ARKANE="$HOME/Devel/ArkaneLinux/"
ARKDEP="$HOME/Devel/ArkaneLinux/arkdep"

SOURCE="$HOME/Devel/ArkaneLinux/arkdep/arkdep-build.d/test-arkanelinux-kde"
WORKINGDIR="my-arkdep-build.d"
WORKINGPATH="$HOME/Devel/ArkaneLinux/$WORKINGDIR"
DEST="my-arkanelinux-kde"

echo "Using $ARKDEP"

if [[ -d $ARKDEP ]]; then
	echo "Arkdep Git package already cloned. Pulling"
	cd $ARKDEP
	RESULT=$(git pull)
	RET=$?
	cd $CURENTDIR
else
	echo "Arkdep Git package not present. cloning"
	cd $ARKANE
	RESULT=$(git clone https://github.com/arkanelinux/arkdep.git)
	RET=$?
	cd $CURENTDIR
fi

echo "RESULT=$RESULT"
echo "RETURN=$RET"

if [[ "$RET" != 0 ]]; then
	echo "Git error: Quiting"
	exit 1
fi

echo "Making working copy of chosen custom linux"
#Remove any previous working directory and recreate as empty
rm -rf "$WORKINGPATH"
mkdir -p "$WORKINGPATH"

#Copy provided KDE sample and rename
cp -r $ARKDEP/arkdep-build.d/test-arkanelinux-kde/ $WORKINGPATH/
mv "$WORKINGPATH/test-arkanelinux-kde/" "$WORKINGPATH/$DEST/"

echo "Done..."
exit 0

