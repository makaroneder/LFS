#!/bin/bash
source Config.sh

sudo groupadd -f $HOSTUSER
id -u $HOSTUSER &>/dev/null || sudo useradd -s /bin/bash -g $HOSTUSER -m -k /dev/null $HOSTUSER
sudo chown -v $HOSTUSER $LFS/{usr{,/*},var,etc,tools}
case $(uname -m) in
    x86_64) sudo chown -v $HOSTUSER $LFS/lib64 ;;
esac
sudo passwd $HOSTUSER

sudo touch /home/$HOSTUSER/.bash_profile
sudo rm /home/$HOSTUSER/.bash_profile
sudo touch /home/$HOSTUSER/.bashrc
sudo rm /home/$HOSTUSER/.bashrc
sudo cp -a /etc/skel/. /home/$HOSTUSER/

cat > tmp.txt << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF
cat tmp.txt | sudo tee -a /home/$HOSTUSER/.bash_profile

cat > tmp.txt << EOF
set +h
umask 022
LFS=${LFS}
EOF
cat tmp.txt | sudo tee -a /home/$HOSTUSER/.bashrc

cat > tmp.txt << "EOF"
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS=-j$(nproc)
EOF
cat tmp.txt | sudo tee -a /home/$HOSTUSER/.bashrc