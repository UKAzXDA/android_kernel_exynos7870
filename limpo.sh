#!/bin/bash
# ===================== #
# Coded By @UKAzXDA		#
# Build Kernel android	#
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

LIMPAR() {
	echo " ============================"
	echo " = Cleaning build directory ="
	echo " ============================"
	make clean && make mrproper
}

CONFIG() {
	echo " =========================="
	echo " = Configuração do kernel ="
	echo " =========================="
	sed -i "s|boot :=.*|boot := $DTSBOOT/dts-$CODENAME$TREBLE|g" $KYU
	make $SOC-$CODENAME$DEF
}

ZIMAGE() {
	echo " ==================="
    echo " = Building zImage ="
	echo " ==================="
	make -j$(nproc)
}

BUILD_DTB() {
	echo " ================"
    echo " = Building DTB ="
	echo " ================"
    ./scripts/dtbTool/dtbTool -o $DTB -d $DTSBOOT/dts-$CODENAME$TREBLE/ -s 2048
}

BOOT_IMG() {
	echo " ======================"
	echo " = Preparando imagens ="
	echo " ======================"
	mkdir $BOOT
    rm $BOOT/$ZIMAGE_IMG
	rm $BOOT/$ZIMAGE_DTB
    mv $KERNEL $BOOT/$ZIMAGE_IMG
    mv $DTB $BOOT/$ZIMAGE_DTB
}

# =========== #
# C O N F I G #
# =========== #

	BOOT="split_img"
	DTSBOOT="arch/arm64/boot"
	KERNEL="arch/arm64/boot/Image"
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

	G610X() { CODENAME="on7xelte"; }
	G611X() { CODENAME="on7xreflte"; }
	J600X() { CODENAME="j6lte"; }

	YYYTT() { TREBLE="-treble"; }
	NNNTT() { TREBLE=""; }

	echo "                      "
	echo " = SM-G610X [1] :     "
	echo " = SM-G611X [2] :     "
	echo " = SM-J600X [3] :     
	"
	echo -n " = Device config: "
	read choice
	case $choice in
		1) G610X;;
		2) G611X;;
		3) J600X;;
		*) echo " = Not found [X]:
		"; exit ;;
	esac
	echo -n " = Treble [y][n]: "
	read choice
	case $choice in
		y) YYYTT;;
		n) NNNTT;;
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
 = Device dtb   :  dtb-$CODENAME$TREBLE
 = Compile cod  :  $COMPILE
 = Build clean  :  $CLEAN
"

# ============ #
#     BUILD    #
# ============ #
if [ $CLEAN = "true" ]; then
	LIMPAR 
fi
CONFIG
ZIMAGE
if [ -e $KERNEL ]; then
	BUILD_DTB
	if [ -e $DTB ]; then
		BOOT_IMG
	fi
fi
