#!/bin/bash
set -e

export ROOTUSER=x
export HOSTUSER=lfs

export DISK=/dev/sda
export BOOTPARTITION=${DISK}1
export ROOTPARTITION=${DISK}2

export LFS=/mnt/lfs