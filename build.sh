#!/bin/bash

KERNEL_SRC=${pwd}
PATH="$PATH:$HOME/Documents/gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu/bin"
CROSS_COMPILE="$HOME/Documents/gcc-linaro-7.4.1-2019.02-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-"
ARCH=arm64
DEFCONFIG=lubancat2_defconfig
NUM_CORES=4

make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" -j${NUM_CORES} mrproper
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" -j${NUM_CORES} "$DEFCONFIG"
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" -j${NUM_CORES} bindeb-pkg RK_KERNEL_DTS=rk356x-lubancat-rk_series
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" -j${NUM_CORES} rk356x-lubancat-rk_series.img
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" -j${NUM_CORES} dtbs 
make ARCH="$ARCH" CROSS_COMPILE="$CROSS_COMPILE" -j${NUM_CORES} bindeb-pkg RK_KERNEL_DTS=rk356x-lubancat-rk_series

KERNEL_VERSION=$(cat $KERNEL_SRC/include/config/kernel.release)

EXTBOOT_IMG=${KERNEL_SRC}/../extboot.img
EXTBOOT_DIR=${KERNEL_SRC}/../extboot
EXTBOOT_DTB=${EXTBOOT_DIR}/dtb/

KERNEL_VERSION=$(cat $KERNEL_SRC/include/config/kernel.release)

rm -rf $EXTBOOT_DIR
mkdir -p $EXTBOOT_DTB/overlay
mkdir -p $EXTBOOT_DIR/uEnv
mkdir -p $EXTBOOT_DIR/kerneldeb

cp ${KERNEL_SRC}/arch/${ARCH}/boot/Image $EXTBOOT_DIR/Image-$KERNEL_VERSION
cp ${KERNEL_SRC}/arch/${ARCH}/boot/dts/rockchip/*.dtb $EXTBOOT_DTB
cp ${KERNEL_SRC}/arch/${ARCH}/boot/dts/rockchip/overlay/*.dtbo $EXTBOOT_DTB/overlay
cp ${KERNEL_SRC}/arch/${ARCH}/boot/dts/rockchip/uEnv/uEnv*.txt $EXTBOOT_DIR/uEnv

cp -f $EXTBOOT_DTB/rk356x-lubancat-rk_series.dtb $EXTBOOT_DIR/rk-kernel.dtb

cp ${KERNEL_SRC}/.config $EXTBOOT_DIR/config-$KERNEL_VERSION
cp ${KERNEL_SRC}/System.map $EXTBOOT_DIR/System.map-$KERNEL_VERSION
cp ${KERNEL_SRC}/logo.bmp $EXTBOOT_DIR/

cp ${KERNEL_SRC}/../linux-headers-"$KERNEL_VERSION"_"$KERNEL_VERSION"-*.deb $EXTBOOT_DIR/kerneldeb
cp ${KERNEL_SRC}/../linux-image-"$KERNEL_VERSION"_"$KERNEL_VERSION"-*.deb $EXTBOOT_DIR/kerneldeb

rm -rf $EXTBOOT_IMG && truncate -s 128M $EXTBOOT_IMG
fakeroot mkfs.ext4 -F -L "boot" -d $EXTBOOT_DIR $EXTBOOT_IMG
