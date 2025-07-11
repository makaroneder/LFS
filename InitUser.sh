#!/bin/bash
source Config.sh

sudo groupadd -f $USER
id -u $USER &>/dev/null || sudo useradd -s /bin/bash -g $USER -m -k /dev/null $USER
sudo chown -v $USER $LFS/{usr{,/*},var,etc,tools}
case $(uname -m) in
    x86_64) sudo chown -v $USER $LFS/lib64 ;;
esac
sudo passwd $USER

sudo cat > /home/$USER/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF
sudo cat > /home/$USER/.bashrc << EOF
set +h
umask 022
LFS=${LFS}
EOF
sudo cat >> /home/$USER/.bashrc << "EOF"
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS=-j$(nproc)
EOF