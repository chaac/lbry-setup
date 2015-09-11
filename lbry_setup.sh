#!/bin/bash

exec >  >(tee -a setup.log)
exec 2> >(tee -a setup.log >&2)

ROOT=.
GIT_URL_ROOT="https://github.com/lbryio/"
CONF_DIR=~/.lbrycrd
CONF_PATH=$CONF_DIR/lbrycrd.conf
PACKAGES="build-essential libtool autotools-dev autoconf git pkg-config libssl-dev libboost-all-dev libdb-dev libdb++-dev libqt4-dev libprotobuf-dev protobuf-compiler libgmp3-dev build-essential python-dev python-pip python-virtualenv"

#install/update requirements
if hash apt-get 2>/dev/null; then
	printf "Installing $PACKAGES\n\n"
	sudo apt-get update && sudo apt-get install $PACKAGES
else
	printf "Running on a system without apt-get. Install requires the following packages or equivalents: $PACKAGES\n\nPull requests encouraged if you have an install for your system!\n\n"
fi

#create config file
if [ ! -f $CONF_PATH ]; then
	printf "Adding lbry config in $CONF_PATH\n";
	mkdir -p $CONF_DIR
	printf "rpcuser=lbryrpc" > $CONF_PATH
	printf "\nrpcpassword=" >> $CONF_PATH
	tr -dc A-Za-z0-9 < /dev/urandom | head -c ${1:-12} | xargs >> $CONF_PATH 
else
	printf "Config $CONF_PATH already exists\n";
fi

#Clone/pull repo and return true/false whether or not anything changed
#$1 : repo name
UpdateSource() 
{
	if [ ! -d "$ROOT/$1/.git" ]; then
       		printf "$1 does not exist, checking out\n";
	        git clone "$GIT_URL_ROOT$1.git"
		return 0 
	else
		cd $1
		#http://stackoverflow.com/questions/3258243/git-check-if-pull-needed
		git remote update;
		LOCAL=$(git rev-parse @{0})
		REMOTE=$(git rev-parse @{u})
		cd ..
		if [ $LOCAL = $REMOTE ]; then
			printf "No changes to $1 source\n"
			return 1 
		else
			printf "Fetching source changes to $1\n"
			git pull --rebase
			return 0
		fi
	fi
}

#setup lbrycrd
printf "\n\nInstalling/updating lbrycrd\n";
if UpdateSource lbrycrd || [ ! -f $ROOT/lbrycrd/src/qt/lbrycrd-qt ]; then
	cd lbrycrd
	./autogen.sh
	./configure --with-incompatible-bdb
	make
        cd ..
else
	printf "lbrycrd installed and nothing to update\n"
fi

#setup lbry-console
printf "\n\nInstalling/updating lbry-console\n";
if UpdateSource lbry || [ ! -d $ROOT/lbry/dist ]; then
	printf "Running lbry-console setup\n"
	cd lbry
	sudo python setup.py install
	cd ..
else
	printf "lbry-console installed and nothing to update\n"
fi
