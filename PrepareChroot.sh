#!/bin/bash
source Config.sh

sudo chown --from $HOSTUSER -R $ROOTUSER:$ROOTUSER $LFS/{usr,lib,var,etc,bin,sbin,tools}
case $(uname -m) in
    x86_64) sudo chown --from $HOSTUSER -R $ROOTUSER:$ROOTUSER $LFS/lib64 ;;
esac

mkdir -pv $LFS/{dev,proc,sys,run}
sudo mount -v --bind /dev $LFS/dev
sudo mount -vt devpts devpts -o gid=5,mode=0620 $LFS/dev/pts
sudo mount -vt proc proc $LFS/proc
sudo mount -vt sysfs sysfs $LFS/sys
sudo mount -vt tmpfs tmpfs $LFS/run
if [ -h $LFS/dev/shm ]; then
    sudo install -v -d -m 1777 $LFS$(realpath /dev/shm)
else
    sudo mount -vt tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
fi