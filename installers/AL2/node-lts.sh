sudo yum install -y gcc10 gcc10-c++ ninja-build
MISE_NODE_VERBOSE_INSTALL=1 \
    MISE_NODE_COMPILE=1 \
    CC=gcc10-gcc CXX=gcc10-g++ \
    NINJA=ninja-build CONFIGURE_OPTS=--ninja \
    mise install node@22.13.0
