#! /bin/bash

set -e

if [ "$TRAVIS_OS_NAME" = 'linux' ]; then
  # Remove the CMake provided by travis
  sudo rm -rf /usr/local/cmake*
  if [ "$BUILD_SUIT" = 'autotools' ]; then
    if [ ! -z "$WITH_COVERALLS" ]; then
      sudo pip3 install -U pip
      sudo pip3 install -U cpp-coveralls
    fi
    git submodule --quiet init
    git submodule --quiet update vendor/googletest
  else
    pushd /usr/src/googletest
    sudo cmake .
    sudo make install -j2
    popd
  fi
fi

# FIXME: penlight has 1.10
sudo luarocks install penlight 1.9.2 > /dev/null  ||  sudo luarocks install --server https://raw.githubusercontent.com/rocks-moonscript-org/moonrocks-mirror/master/ penlight 1.9.2 > /dev/null
sudo luarocks install busted     > /dev/null  ||  sudo luarocks install --server https://raw.githubusercontent.com/rocks-moonscript-org/moonrocks-mirror/master/ busted     > /dev/null
sudo luarocks install moonscript > /dev/null  ||  sudo luarocks install --server https://raw.githubusercontent.com/rocks-moonscript-org/moonrocks-mirror/master/ moonscript > /dev/null
sudo luarocks install uuid       > /dev/null  ||  sudo luarocks install --server https://raw.githubusercontent.com/rocks-moonscript-org/moonrocks-mirror/master/ uuid       > /dev/null
