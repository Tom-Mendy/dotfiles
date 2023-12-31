#!/usr/bin/env bash
VERSION="v2.4.2"
URL="https://github.com/Snaipe/Criterion/releases/download/$VERSION"
TARBALL="criterion-$VERSION-linux-x86_64.tar.bz2"
DIR="criterion-$VERSION"
DST="/usr/local/"
SUDO=/usr/bin/sudo

if [ $UID -eq "0" ]; then
    SUDO=""
    echo "[no sudo for root]"
fi

cd /tmp
rm -f $TARBALL
rm -fr $DIR

wget $URL/$TARBALL
if [ $? != 0 ]; then
    echo "failled, exiting"
    exit;
fi

echo
echo "untaring $TARBALL"
tar xjf $TARBALL
if [ $? != 0 ]; then
    echo "failled, exiting"
    exit;
fi

echo "creating custom ld.conf"
$SUDO sh -c "echo "/usr/local/lib" > /etc/ld.so.conf.d/criterion.conf"
echo "cp headers to $DST/include..."
$SUDO cp -r $DIR/include/* $DST/include/
echo "cp lib to $DST/include..."
$SUDO cp -r $DIR/lib/* $DST/lib/
echo "run ldconfig."
$SUDO ldconfig
echo "all good."
