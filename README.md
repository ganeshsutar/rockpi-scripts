# rockpi-scripts
These are some of the script that are useful for creating and handling rock pi SD card image


### Backup Card
This script backup the SD card into the given Image file.
This script is used full to create a backup of the SD card to a small image
so that you can store.

`Usage: `

`$ ./backup-card.sh <sdcard device> <image filename>`

`e.g `

`$ ./backup-card.sh /dev/sdb small.img`

An example usage of the script would be. Suppose you have a SD card of 16 GB
but the rootfs is only filled with 5 GB, hence you can accomodate all of it
into 8 GB image file. To do this
1. Create a file of 8 GB using following command
`$ dd if=/dev/zero of=small.img bs=1M count=8192`
1. Suppose the SD card is in `/dev/sdb`. Then to backup into `small.img` execute following command
`$ sudo ./backup-card.sh /dev/sdb small.img`

**NOTE**
1. This only works for Rock PI 4B Ubuntu Server, please update the number in script from
following command

`$ gdisk -l /dev/sdb`

#### TODO: 
1. This only works for Rock PI 4B Ubuntu Server, make it to work with and card
