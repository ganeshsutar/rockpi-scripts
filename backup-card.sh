#! /bin/bash

IMG_FILE=$2
DEV_FILE=$1

if [[ "${IMG_FILE}" == "" ]]; then
    echo Usage: ./backup-card.sh '<SD Card Device File> <Image filename>'
    exit 1
fi

if [[ "${DEV_FILE}" == "" ]]; then
    echo Usage: ./backup-card.sh '<SD Card Device File> <Image filename>'
    exit 1
fi

# For rock pi 4b only
ROOT_UUID="B921B045-1DF0-41C3-AF44-4C6F280D3FAE"

echo Backing up ${DEV_FILE} to ${IMG_FILE}

parted -s ${IMG_FILE} mklabel gpt
parted -s ${IMG_FILE} unit s mkpart loader1 34 8063
parted -s ${IMG_FILE} unit s mkpart loader2 16384 24575
parted -s ${IMG_FILE} unit s mkpart trust 24576 32767
parted -s ${IMG_FILE} unit s mkpart boot 32768 262143
parted -s ${IMG_FILE} set 4 boot on
parted -s ${IMG_FILE} -- unit s mkpart rootfs 262144 -34s

echo "
x
c
5
${ROOT_UUID}
w
y
"  | gdisk ${IMG_FILE}

LOOP_DEV=$(sudo losetup -f --show ${IMG_FILE})
echo ${LOOP_DEV}
sudo partprobe ${LOOP_DEV}

echo ${DEV_FILE}1 => ${LOOP_DEV}p1 
dd if=${DEV_FILE}1 of=${LOOP_DEV}p1

echo ${DEV_FILE}2 => ${LOOP_DEV}p2 
dd if=${DEV_FILE}2 of=${LOOP_DEV}p2

echo ${DEV_FILE}3 => ${LOOP_DEV}p3 
dd if=${DEV_FILE}3 of=${LOOP_DEV}p3

echo ${DEV_FILE}4 => ${LOOP_DEV}p4 
dd if=${DEV_FILE}4 of=${LOOP_DEV}p4

echo Formatting ${LOOP_DEV}p5
sudo mkfs.ext4 ${LOOP_DEV}p5

echo Mounting SD Card rootfs and rootfs

mkdir rootfs card-rootfs

if [[ ! -d rootfs ]]; then
    mkdir rootfs
fi

if [[ ! -d card-rootfs ]]; then
    mkdir card-rootfs
fi

sudo mount ${LOOP_DEV}p5 rootfs
sudo mount ${DEV_FILE}5 card-rootfs

echo Copying card-rootfs to rootfs 
sudo cp -r card-rootfs/* rootfs/ >cp-files.txt

sudo umount rootfs
sudo umount card-rootfs

sudo losetup -d ${LOOP_DEV}

echo DONE
