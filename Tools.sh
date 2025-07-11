#!/bin/bash
set -e

# Binutils
cd $LFS/sources
tar -xvf binutils-2.44.tar.xz
mkdir -v binutils-2.44/build
cd binutils-2.44/build
../configure --prefix=$LFS/tools --with-sysroot=$LFS --target=$LFS_TGT --disable-nls --enable-gprofng=no --disable-werror --enable-new-dtags --enable-default-hash-style=gnu
make
make install

# GCC
cd $LFS/sources
tar -xvf gcc-14.2.0.tar.xz
cd gcc-14.2.0
tar -xvf ../mpfr-4.2.1.tar.xz
mv -v mpfr-4.2.1 mpfr
tar -xvf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xvf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc
case $(uname -m) in
    x86_64) sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64 ;;
esac
mkdir -v build
cd build
../configure --target=$LFS_TGT --prefix=$LFS/tools --with-glibc-version=2.41 --with-sysroot=$LFS --with-newlib --without-headers --enable-default-pie --enable-default-ssp --disable-nls --disable-shared --disable-multilib --disable-threads --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libssp --disable-libvtv --disable-libstdcxx --enable-languages=c,c++
make
make install
cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include/limits.h

# Linux API headers
cd $LFS/sources
tar -xvf linux-6.13.4.tar.xz
cd linux-6.13.4
make mrproper
make headers
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include $LFS/usr

# Glibc
cd $LFS/sources
tar -xvf glibc-2.41.tar.xz
cd glibc-2.41
case $(uname -m) in
    i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
    ;;
    x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
    ;;
esac
patch -Np1 -i ../glibc-2.41-fhs-1.patch
mkdir -v build
cd build
echo "rootsbindir=/usr/sbin" > configparms
../configure --prefix=/usr --host=$LFS_TGT --build=$(../scripts/config.guess) --enable-kernel=5.4 --with-headers=$LFS/usr/include --disable-nscd libc_cv_slibdir=/usr/lib
make
make DESTDIR=$LFS install
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
echo 'int main(){}' | $LFS_TGT-gcc -xc -
readelf -l a.out | grep ld-linux
rm -v a.out

# Libstdc++
cd $LFS/sources/gcc-14.2.0
mkdir -v libcxxBuild
cd libcxxBuild
../libstdc++-v3/configure --host=$LFS_TGT --build=$(../config.guess) --prefix=/usr --disable-multilib --disable-nls --disable-libstdcxx-pch --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/14.2.0
make
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/lib{stdc++{,exp,fs},supc++}.la

# M4
cd $LFS/sources
tar -xvf m4-1.4.19.tar.xz
cd m4-1.4.19
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

# Ncurses
cd $LFS/sources
tar -xvf ncurses-6.5.tar.gz
cd ncurses-6.5
mkdir -v build
pushd build
    ../configure AWK=gawk
    make -C include
    make -C progs tic
popd
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess) --mandir=/usr/share/man --with-manpage-format=normal --with-shared --without-normal --with-cxx-shared --without-debug --without-ada --disable-stripping AWK=gawk
make
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
ln -sv libncursesw.so $LFS/usr/lib/libncurses.so
sed -e 's/^#if.*XOPEN.*$/#if 1/' -i $LFS/usr/include/curses.h

# Bash
cd $LFS/sources
tar -xvf bash-5.2.37.tar.gz
cd bash-5.2.37
./configure --prefix=/usr --build=$(sh support/config.guess) --host=$LFS_TGT --without-bash-malloc
make
make DESTDIR=$LFS install
ln -sv bash $LFS/bin/sh

# Coreutils
cd $LFS/sources
tar -xvf coreutils-9.6.tar.xz
cd coreutils-9.6
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess) --enable-install-program=hostname --enable-no-install-program=kill,uptime
make
make DESTDIR=$LFS install
mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8

# Diffutils
cd $LFS/sources
tar -xvf diffutils-3.11.tar.xz
cd diffutils-3.11
./configure --prefix=/usr --host=$LFS_TGT --build=$(./build-aux/config.guess)
make
make DESTDIR=$LFS install

# File
cd $LFS/sources
tar -xvf file-5.46.tar.gz
cd file-5.46
mkdir -v build
pushd build
    ../configure --disable-bzlib --disable-libseccomp --disable-xzlib --disable-zlib
    make
popd
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/libmagic.la

# Findutils
cd $LFS/sources
tar -xvf findutils-4.10.0.tar.xz
cd findutils-4.10.0
./configure --prefix=/usr --localstatedir=/var/lib/locate --host=$LFS_TGT --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

# Gawk
cd $LFS/sources
tar -xvf gawk-5.3.1.tar.xz
cd gawk-5.3.1
sed -i 's/extras//' Makefile.in
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

# Grep
cd $LFS/sources
tar -xvf grep-3.11.tar.xz
cd grep-3.11
./configure --prefix=/usr --host=$LFS_TGT --build=$(./build-aux/config.guess)
make
make DESTDIR=$LFS install

# Gzip
cd $LFS/sources
tar -xvf gzip-1.13.tar.xz
cd gzip-1.13
./configure --prefix=/usr --host=$LFS_TGT
make
make DESTDIR=$LFS install

# Make
cd $LFS/sources
tar -xvf make-4.4.1.tar.gz
cd make-4.4.1
./configure --prefix=/usr --without-guile --host=$LFS_TGT --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

# Patch
cd $LFS/sources
tar -xvf patch-2.7.6.tar.xz
cd patch-2.7.6
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

# Sed
cd $LFS/sources
tar -xvf sed-4.9.tar.xz
cd sed-4.9
./configure --prefix=/usr --host=$LFS_TGT --build=$(./build-aux/config.guess)
make
make DESTDIR=$LFS install

# Tar
cd $LFS/sources
tar -xvf tar-1.35.tar.xz
cd tar-1.35
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess)
make
make DESTDIR=$LFS install

# Xz
cd $LFS/sources
tar -xvf xz-5.6.4.tar.xz
cd xz-5.6.4
./configure --prefix=/usr --host=$LFS_TGT --build=$(build-aux/config.guess) --disable-static --docdir=/usr/share/doc/xz-5.6.4
make
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/liblzma.la

# Binutils
cd $LFS/sources/binutils-2.44
sed '6031s/$add_dir//' -i ltmain.sh
mkdir -v build2
cd build2
../configure --prefix=/usr --build=$(../config.guess) --host=$LFS_TGT --disable-nls --enable-shared --enable-gprofng=no --disable-werror --enable-64-bit-bfd --enable-new-dtags --enable-default-hash-style=gnu
make
make DESTDIR=$LFS install
rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes,sframe}.{a,la}

# GCC
cd $LFS/sources/gcc-14.2.0
sed '/thread_header =/s/@.*@/gthr-posix.h/' -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in
mkdir -v build2
cd build2
../configure --build=$(../config.guess) --host=$LFS_TGT --target=$LFS_TGT LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc --prefix=/usr --with-build-sysroot=$LFS --enable-default-pie --enable-default-ssp --disable-nls --disable-multilib --disable-libatomic --disable-libgomp --disable-libquadmath --disable-libsanitizer --disable-libssp --disable-libvtv --enable-languages=c,c++
make
make DESTDIR=$LFS install
ln -sv gcc $LFS/usr/bin/cc