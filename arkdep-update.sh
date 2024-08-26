#!/bin/bash
CURRENTDIR=$(pwd)

cat << EOF > my-package.list
bash-completion
btop
curl
glances
htop
nano
tailscale
terminator
micro
gedit
pluma
code
neovim
deno
nodejs
nginx
expac
krfb
remmina
keychain
plasma-meta
aspell
tigervnc
cosmic-session
EOF

function onexit {
	echo "Exit Trap..."
	cd $CURRENTDIR
	pwd
	#Restore original package.list
	cp ./package.list-orig  $BUILD_DIR/$CURRENT_SOURCE/package.list
	#Remove the lock file now script has completed successfully
	rm ./my-package.list.lock
}
trap onexit EXIT

echo "Updating..."
CURRENT_SOURCE="arkanelinux-kde4"
BUILD_DIR="$HOME/arkdep-build.d"
echo "Using: $CURRENT_SOURCE and BUILD_DIR: $BUILD_DIR"

echo "Appending my-package.list..."
if [[  -f ./my-package.list.lock ]]; then
	echo "Lock file exists, so aborting"
	exit 1
else
	echo "Lock file does not exist, so proceeding..."
	cp $BUILD_DIR/$CURRENT_SOURCE/package.list ./package.list-orig
	cat ./my-package.list >> $BUILD_DIR/$CURRENT_SOURCE/package.list
	touch ./my-package.list.lock
fi

echo "Building the image..."
cd "$HOME"
sudo arkdep-build "$CURRENT_SOURCE"
if [[  "$?" -ne 0  ]]; then
	echo "Build failed. Exiting"
	exit 1
fi

echo "Image has been built."
cd $CURRENTDIR

IMAGE=$(ls -t "$HOME/target" | grep tar.zst | head -n 1)
#extension="${IMAGE##*.}"
#filename1="${IMAGE%.*}"
BASEIMAGE="${IMAGE%%[.]*}"

echo "Built Image is: $IMAGE, BASEIMAGE: $BASEIMAGE"

echo "Clearing Arkdep Cache just is case..."

#Odd couldn't 
for file in /arkdep/cache/*
do
	sudo rm -f "$file"
done

echo "Copying new image to cache..."
sudo cp $HOME/target/$IMAGE /arkdep/cache/

echo "Installing..."
sudo arkdep deploy cache $BASEIMAGE
echo "RETURN: $?"

pwd
cd $CURRENTDIR
pwd

echo "Done"

