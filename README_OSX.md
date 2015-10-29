Mac OS X Build Instructions and Notes
====================================
This guide will show you how to build lbry for OSX.

Notes
-----

* Tested on OS X 10.10 through 10.11 on 64-bit Intel processors only.

* All of the commands should be executed in a Terminal application. The
built-in one is located in `/Applications/Utilities`.

Preparation
-----------

If you're running El Capitan, you may need to disable rootless mode. To do so follow the instructions [here](https://www.quora.com/How-do-I-turn-off-the-rootless-in-OS-X-El-Capitan-10-11)

You need to install XCode with all the options checked so that the compiler
and everything is available in /usr not just /Developer. XCode should be
available on your OS X installation media, but if not, you can get the
current version from https://developer.apple.com/xcode/. If you install
Xcode 4.3 or later, you'll need to install its command line tools. This can
be done in `Xcode > Preferences > Downloads > Components` and generally must
be re-done or updated every time Xcode is updated.

You will also need to install [Homebrew](http://brew.sh) in order to install library
dependencies. If you don't have it, run the following:

        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

You will also need pip. If you don't have it, run the following:

        sudo easy_install pip

The installation of the actual dependencies is covered in the instructions below.

### Install dependencies using Homebrew

        brew install autoconf automake libtool boost150 openssl pkg-config protobuf qt5 git gmp

### Installing berkeley-db4 using Homebrew

The homebrew package for berkeley-db4 has been broken for some time.  It will install without Java though.

Running this command takes you into brew's interactive mode, which allows you to configure, make, and install by hand:

    brew install https://raw.github.com/homebrew/homebrew/master/Library/Formula/berkeley-db4.rb -–without-java 

The rest of these commands are run inside brew interactive mode:

    /private/tmp/berkeley-db4-UGpd0O/db-4.8.30 $ cd ..
    /private/tmp/berkeley-db4-UGpd0O $ db-4.8.30/dist/configure --prefix=/usr/local/Cellar/berkeley-db4/4.8.30 --mandir=/usr/local/Cellar/berkeley-db4/4.8.30/share/man --enable-cxx
    /private/tmp/berkeley-db4-UGpd0O $ make
    /private/tmp/berkeley-db4-UGpd0O $ make install
    /private/tmp/berkeley-db4-UGpd0O $ exit


After exiting, you'll get a warning that the install is keg-only, which means it wasn't symlinked to `/usr/local`.  You don't need it to link it to build lbry, but if you want to, here's how:

    brew link --force berkeley-db4


### Installing miniupnpc-1.9

Unfortunatly, the miniupnpc available with brew isn't compatible with lbry. Download the compatable version [here](http://miniupnp.free.fr/files/download.php?file=miniupnpc-1.9.tar.gz) and double click the downloaded file to decompress it. Then enter the following:

    cd ~/Downloads/miniupnpc-1.9
    sudo make
    sudo make install

### Installing gmpy

Run the following:

    pip install gmpy

### Building lbrycrd

1. Clone the github tree to get the source code and go into the directory.

        git clone https://github.com/lbryio/lbrycrd.git
        cd lbrycrd

2.  Build lbrycrd:

        ./autogen.sh
        ./configure
        make

3.  It is also a good idea to build and run the unit tests:

        make check

4.  (Optional) You can also install lbrycrd to your path:

        make install

### Installing lbrynet

1. Clone the github tree to get the source code and go into the directory (assuming you want to download to your home directory).

        cd ~/
        git clone https://github.com/lbryio/lbry.git
        cd lbry
        sudo python setup.py install

Running
-------

It's now available at `./lbrycrdd`, provided that you are in the `lbrycrd/src`
directory. We have to first create the RPC configuration file, though.

To setup your configuration file, enter the following:

    sudo echo -e "rpcuser=lbryrpc\nrpcpassword=$(xxd -l 16 -p /dev/urandom)" > "/Users/${USER}/Library/Application Support/Bitcoin/lbrycrd.conf"
    sudo chmod 600 "/Users/${USER}/Library/Application Support/Bitcoin/lbrycrd.conf"

The next time you run it, it will start downloading the blockchain, give it a few minutes to do its thing.

To start up the gui, navigate to the folder containing lbrycrd and enter the following:

        cd lbrycrd/src
        ./lbrycrdd -server -gen -daemon
        lbrynet-gui

To start the console, enter lbrynet-console instead of lbrynet-gui.

To stop the daemon enter the following (while in lbrycrd/src):

        ./lbrycrd-cli stop
