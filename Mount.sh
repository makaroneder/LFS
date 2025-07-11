#!/bin/bash
source Config.sh

umask 022
mkdir -pv $LFS
mount -v -t ext4 $ROOTPARTITION $LFS
chown root:root $LFS
chmod 755 $LFS

mkdir -pv $LFS/{etc,var,tools,sources,usr,usr/{bin,lib,sbin}}
chmod -v a+wt $LFS/sources
for i in bin lib sbin; do
    ln -sv usr/$i $LFS/$i
done
case $(uname -m) in
    x86_64) mkdir -pv $LFS/lib64 ;;
esac