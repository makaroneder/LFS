#!/bin/bash
source Config.sh

umask 022
mkdir -pv $LFS
sudo mount -v -t ext4 $ROOTPARTITION $LFS
sudo chown $ROOTUSER:$ROOTUSER $LFS
sudo chmod 755 $LFS

mkdir -pv $LFS/{etc,var,tools,sources,usr,usr/{bin,lib,sbin}}
sudo chmod -v a+wt $LFS/sources
for i in bin lib sbin; do
    ln -sv usr/$i $LFS/$i
done
case $(uname -m) in
    x86_64) mkdir -pv $LFS/lib64 ;;
esac