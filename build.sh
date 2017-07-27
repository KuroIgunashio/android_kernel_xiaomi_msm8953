#!/bin/bash
kernel_version=${1}
kernel_name="StockPlus"
device_name="mido"
zip_name="$kernel_name-$device_name-$kernel_version.zip"

export CONFIG_FILE="mido_defconfig"
export ARCH="arm64"
export CROSS_COMPILE="aarch64-linux-android-"
export KBUILD_BUILD_USER="KuroIgunashio"
export KBUILD_BUILD_HOST="StockPlus"
export TOOL_CHAIN_PATH="${HOME}/android/toolchains/aarch64-linux-android-4.9/bin"
export CONFIG_ABS_PATH="arch/${ARCH}/configs/${CONFIG_FILE}"
export PATH=$PATH:${TOOL_CHAIN_PATH}
export objdir="${HOME}/android/redminote4/stockplus-kernel/obj"
export sourcedir="${HOME}/android/redminote4/stockplus-kernel"
export anykernel="${HOME}/android/anykernel"
release_folder="${HOME}/android/redminote4"

compile() {
  make O=$objdir ARCH=arm64 CROSS_COMPILE=${TOOL_CHAIN_PATH}/${CROSS_COMPILE}  $CONFIG_FILE -j4
  make O=$objdir -j4
}

clean() {
  make O=$objdir ARCH=arm64 CROSS_COMPILE=${TOOL_CHAIN_PATH}/${CROSS_COMPILE}  $CONFIG_FILE -j4
  make O=$objdir mrproper
}

module_stock() {
  rm -rf $anykernel/modules/
  mkdir $anykernel/modules
  find $objdir -name '*.ko' -exec cp -av {} $anykernel/modules/ \;
  # strip modules
 ${TOOL_CHAIN_PATH}/${CROSS_COMPILE}strip --strip-unneeded $anykernel/modules/*
  cp -rf $objdir/arch/arm64/boot/Image.gz-dtb $anykernel/zImage
}

module_cm() {
  rm -rf $anykernel/modules/
  mkdir $anykernel/modules
  find $objdir -name '*.ko' -exec cp -av {} $anykernel/modules/ \;
  # strip modules
 ${TOOL_CHAIN_PATH}/${CROSS_COMPILE}strip --strip-unneeded $anykernel/modules/*
  cp -rf $objdir/arch/arm64/boot/Image.gz-dtb $anykernel/zImage
}

delete_zip() {
  cd $anykernel
  find . -name "*.zip" -type f
  find . -name "*.zip" -type f -delete
}

build_package() {
  zip -r9 UPDATE-AnyKernel2.zip * -x README UPDATE-AnyKernel2.zip
}

make_name() {
  mv UPDATE-AnyKernel2.zip $zip_name
}
export_it() {
  mv $zip_name ../redminote4
  rm zImage
  cd $releases_folder
}

turn_back() {
  cd $sourcedir
}

compile
module_stock
delete_zip
build_package
make_name
export_it
turn_back
