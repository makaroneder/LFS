#!/bin/bash

DISK=/dev/sda

fdisk $DISK <<EOF
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
exit 0