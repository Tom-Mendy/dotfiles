#!/usr/bin/env bash
URL="https://github.com/Snaipe/Criterion/releases/download/v2.4.2/"
TARBALL="criterion-2.4.2-linux-x86_64.tar.xz"
DIR="criterion-2.4.2"
DST="/usr/local"
SUDO="/usr/bin/sudo"

if [ $UID -eq "0" ]; then
    SUDO=""
    echo "[no sudo for root]"
fi

cd /tmp
rm -f $TARBALL
rm -rf $DIR

wget $URL/$TARBALL
if [ $? != 0 ]; then
    echo "failed, exiting"
    exit;
fi

echo
echo "untaring $TARBALL"
tar -xf $TARBALL
if [ $? != 0 ]; then
    echo "failed, exiting"
    exit;
fi

echo "creating custom ld.conf"
$SUDO sh -c "echo "/usr/local/lib" > /etc/ld.so.conf.d/criterion.conf"
echo "cp headers to $DST/include/criterion"
$SUDO cp -r $DIR/include/* $DST/include/
echo "cp lib to $DST/include/criterion"
$SUDO cp -r $DIR/lib/* $DST/lib/
echo "run ldconfig."
$SUDO ldconfig
echo "Criterion installed."