
# disk partition
# partition table
# partition 1: EFI - 2G
# partition 2: Linux LVM - all
#    

fdisk /dev/disk_block_file

# LVM config

# phyical volume
pvcreate /dev/partition2
# or use this command to alignment block
# pvcreate --dataalignment <size> /dev/partition2

# volume group
vgcreate System0 /dev/partition2 ["other partitiong u need"]
# if u got any other pv need to add into this vg use command under
# vgextend <vg_name> <partition_name>

# logic volume
lvcreate -l +100%FREE System0 -n root_p
lvresize -L -8G /dev/System0/root_p
lvcreate -L +8G System0 -n swap_p


# ---

# make file system and mount logic volume
mkfs.fat -F 32 /dev/partition1
mkfs.fs /dev/System0/root_p
mkswap /dev/System0/swap_p

# mount partition
mount /dev/System0/root_p /mnt
mount --mkdir /dev/sda1 /mnt/boot
swapon /dev/System0/swap_p

# brtfs config



# ---






# config pacman source
curl -L 'https://archlinux.org/mirrorlist/?country=CN&protocol=https' -o /etc/pacman.d/mirrorlist
# find one to enable

# install system
pacstrap -K /mnt base linux linux-firmware zsh git wget grub efibootmgr


# config mkinitcpio (do it when ur root file system in a LVM logic volume)
echo 'HOOKS=(base systemd ... block lvm2 filesystems)'
mkinitcpio -P

# generate fstab file
genfstab -U /mnt >> /mnt/etc/fstab

# timezone setting
timedatectl set-timezone Asia/Shanghai
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc
locale-gen

# generate locale.conf
echo 'LANG=en_GB.UTF-8' >> /mnt/etc/locale.gen

# edit hostname
vim /mnt/etc/hostname

grub-install --target=x86_64-efi --efi-directory=esp --bootloader-id=GRUB