#!/bin/bash
source Config.sh

sudo fdisk $DISK <<EOF
g
n
1

+1G
t
uefi
n
2


w
EOF
sudo mkfs.vfat -v -F 32 $BOOTPARTITION
sudo mkfs -v -t ext4 $ROOTPARTITION

source Mount.sh

wget https://www.linuxfromscratch.org/lfs/view/stable/wget-list-sysv
wget --input-file=wget-list-sysv --continue --directory-prefix=$LFS/sources
wget https://www.linuxfromscratch.org/lfs/view/stable/md5sums
mv md5sums $LFS/sources/
pushd $LFS/sources
    md5sum -c md5sums
popd
chown $ROOTUSER:$ROOTUSER $LFS/sources/*