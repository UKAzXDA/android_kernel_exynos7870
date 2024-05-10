#!/bin/bash
# ===================== #
# Coded By @UKAzXDA     #
# Build Kernel android  #
# ===================== #
clear
echo " ╔══════════════════════════════════════════════════╗"
echo " ║                                                  ║"
echo " ║            L I M P O   K E R N E L               ║"
echo " ║      - - - - - - - - - - - - - - - - - -         ║"
echo " ║               Coded By @UKAzXDA                  ║"
echo " ║                  Build Kernel                    ║"
echo " ║                                                  ║"
echo " ╚══════════════════════════════════════════════════╝
"

BOOT="split_img"
DTSBOOT="arch/arm64/boot"
DTB="boot.img-dtb"
ZIMAGE_DTB="boot.img-dt"
ZIMAGE_IMG="boot.img-kernel"
COMPILE="aarch64-linux-android"
KYU="arch/arm64/Makefile"
SOC="exynos7870"
DEF="_defconfig"

export PLATFORM_VERSION=10
export ANDROID_MAJOR_VERSION=q
export SEC_BUILD_OPTION_VTS=true
export CONFIG_DEBUG_SECTION_MISMATCH=y
export CROSS_COMPILE=../gcc/bin/$COMPILE-
export SUBARCH=arm64
export ARCH=arm64

echo "                     "
echo " = SM-G610X [1] :    "
echo " = SM-G611X [2] :    "
echo " = SM-J600X [3] :    "
echo "                     "
echo -n " = Device config: "
	read choice
	case $choice in
	1) CODENAME="on7xelte";;
	2) CODENAME="on7xreflte";;
	3) CODENAME="j6lte";;
	*) echo " = Not found [X]:
	"; exit ;;
esac

echo -n " = Treble [y][n]: "
	read choice
	case $choice in
	y) TREBLE="-treble";;
	n) TREBLE="";;
	*) echo " = Not found [X]:
	"; exit ;;
esac

echo -n " = Cleanr [y][n]: "
	read choice
	case $choice in
	y) CLEAN="true";;
	n) CLEAN="false";;
	*) echo " = Not found [X]:
	"; exit ;;
esac

echo "
 = Def config   :  $SOC-$CODENAME$DEF
 = Device dtb   :  dts-$CODENAME$TREBLE
 = Compile cod  :  $COMPILE
 = Build clean  :  $CLEAN
"

if [ $CLEAN = "true" ]; then
	echo " ============================"
	echo " = Cleaning build directory ="
	echo " ============================"
	make clean && make mrproper
fi

#==[ CONFIG
	echo " =========================="
	echo " = Configuração do kernel ="
	echo " =========================="
	sed -i "s|boot :=.*|boot := $DTSBOOT/dts-$CODENAME$TREBLE|g" $KYU
	make $SOC-$CODENAME$DEF

#==[ ZIMAGE
	echo " ==================="
    echo " = Building zImage ="
	echo " ==================="
	make -j$(nproc)

KERNEL="$DTSBOOT/dts-$CODENAME$TREBLE/Image"

if [ -e $KERNEL ]; then
	echo " ================"
    echo " = Building DTB ="
	echo " ================"
    ./scripts/dtbTool/dtbTool -o "$DTB" -d "$DTSBOOT/dts-$CODENAME$TREBLE/dts/" -s 2048
fi

if [ -e $DTB ]; then
	echo " ======================"
	echo " = Preparando imagens ="
	echo " ======================"
	mkdir $BOOT
    rm $BOOT/$ZIMAGE_IMG
	rm $BOOT/$ZIMAGE_DTB
    mv $KERNEL $BOOT/$ZIMAGE_IMG
    mv $DTB $BOOT/$ZIMAGE_DTB
fi
