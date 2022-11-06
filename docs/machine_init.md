# Machine initialization

NixOS is a great tool for declaratively managing system configurations (namely
what packages and other config files are available), but there are still a
number of imperative steps to run when setting up a brand new machine before
installation. (Okay, there *are* some projects which seek to automate this
process as well, but unless you are constantly (re-)provisioning new machines,
it is probably overkill...). There's a number of available tutorials and guides
on how to prepare a machine for NixOS installation, but I found all of them to
be incredibly basic (e.g.  set up single ext4 partition and move on), or didn't
quite fit the requirements I was imposing.

Since this was also my first "real" Linux install, there were a number of things
I was unsure of and had to research on my own to figure out whether it was
relevant or what configurations to choose. Here I document all the steps I went
through, along with (an attempt!) to capture my assumptions and deliberate
decisions so that whether I got something wrong, it stops being correct in the
future, or you simply disagree with my choices, it becomes easy to spot where to
stray and where to follow this guide.

Hope this is useful.

## Acknowledgements

Huge thanks to [Graham Christensen](https://grahamc.com) whose blog posts were
my main inspiration and guide for installation:
* [NixOS on a Dell 9560](https://web.archive.org/web/20190831102758/https://grahamc.com/blog/nixos-on-dell-9560)
* [ZFS Datasets for NixOS](https://web.archive.org/web/20200621003223/https://grahamc.com/blog/nixos-on-zfs)
* [Erase your darlings](https://web.archive.org/web/20201124122057/https://grahamc.com/blog/erase-your-darlings)

## Assumptions and Requirements

Below is a quick summary of the assumptions and requirements I had for the
system to provide some historical context and keep the rest of the guide
focused on running each step.

The installation was done in early December of 2020 on a brand new 1 TiB SSD.
The disk has four partitions, and here is the final result:
1. A 1 GiB unencrypted boot partition (more on this later). I chose 1 GiB
   because I've been bitten by having too small of a boot partition in the
   past, and it will be a headache to try to resize the partition if it turns
   out too small. Most people recommend using 300-500 MiB, but since I have
   plenty of storage to spare I decided to use 1 GiB and forget about it (note
   that every NixOS generation adds links in this partition, so having too
   many generations laying around can fill it up as well).
1. A 32 MiB LUKS encrypted partition which contains the key for the remaining
   partitions. I forget exactly why I went with 32 MiB exactly, but I wanted
   to make this partition large enough to handle any LUKS upgrades or extra
   key configurations, and I have space to spare (I think the LUKS2 max header
   size is 4 MiB, and most people recommend having a partition about this big
   plus some space for the actual key).
1. A 32 GiB swap partition because this machine has 16 GiB of RAM and I left
   some headroom in case I upgrade it. I don't plan on enabling swap (to avoid
   wearing out my SSD), but I made the partition anyway in case I change my
   mind.
1. The remainder of the disk is managed by ZFS split into the following
   datasets:
   * `/local` - dataset for mounting `/nix/store`. It is not snapshotted since
     the nix store can be trivially repopulated/rebuilt if the data is lost or
     corrupted
   * `/reserved` - A 100 GiB reserved partition to act as an over-provisioning
     guard and preserve the SSD performance (SSDs avoid wearing out individual
     blocks by moving writes around. But if the drive fills up, the speed and
     health of the drive will decrease. By never mounting this dataset, and
     asking ZFS to ensure there is always 100 GiB available for it, I'm
     effectively capping the disk at 90%).
   * `/system` - dataset for mounting `/root` and `/var`. This dataset is
     regularly snapshotted so I can rollback in case something catastrophic
     happens. I have not yet decided to [erase my
     darlings](https://grahamc.com/blog/erase-your-darlings) but if I do I
     would move my `/root` mount...
   * `/user` - dataset for storing user home directories, regularly
     snapshotted

### Why ZFS?

I had generally heard good things about it, namely that it's a stable file
system implementation which supports efficient snapshots, rollbacks, and data
exports. I briefly looked into btrfs which also supports very similar
features, but the NixOS support (at the time) was lacking, and since I had
not previously used neither btrfs nor zfs, I went with the latter since I
expected the experience to be smoother.

### What about SSD over-provisioning?

SSDs are made up of flash storage which supports a (large, but) finite number
of write operations before the medium begins to degrade. The SSD controller
performs wear leveling by effectively writing new data in a new location by
transparently remapping the block identifier to the new location. This
requires having some free space on the disk to "move" the blocks around. If
the disk fills up, the controller will be forced to do subsequent writes in
the same spot.

Over-provisioning is a name that storage vendors give to the concept of
reserving some storage capacity to avoid accidentally filling it up and
degrading performance. Some vendors state that their modern products
automatically achieve this in their firmware without any manual intervention
(maybe the drive itself has more storage than advertised?). Other vendors
peddle special tools like Samsung Data Magician (which simply creates an empty
partition) to achieve the task.

Since I have lots of storage to spare on my 1 TiB drive, I decided to
over-provision 10% of its capacity by creating a reserved ZFS pool which I
will never mount. I can easily remove or shrink that reservation if needed, so
this seemed like a sensible choice.

### Why an unencrypted boot partition?

Ultimately, you have to trust some piece of software somewhere to take your
keyboard input and unlock the disk without leaking the key somehow. An
unencrypted boot partition means someone who gets access to the disk can put a
compromised boot loader that can steal the key. Using an encrypted boot
partition avoids this risk, but that means that the UEFI implementation needs
to do the decryption, and someone who can access it could flash a compromised
implementation which also steals the key. A solution to that can be to use
Secure boot/Trusted boot but now we have to trust that the hardware itself
isn't compromised with some other back-door... It's turtles all the way down.

My threat model does not include someone physically accessing my machine, so
an unencrypted boot partition works fine for me. Setting up a trusted boot
sequence sounds interesting, but it's a project for another time.

### Why LUKS and not native-ZFS encryption?

I chose to go with using LUKS to encrypt the entire disk and run ZFS from
within it. LUKS has been around for a while and there is plenty of
tooling/documentation/guides around it, so it seemed like a safe approach.

ZFS apparently supports natively encrypting the disk, which avoids some double
indirection when trimming SSD blocks (and then having the decryption mapper
propagate those to the device). There are some potential security concerns
(like leaking dataset names/sizes and dedup tables), but none of them are
within my threat model. What really convinced me against using native-ZFS
encryption was the impression that the feature was somewhat newer, and I
didn't want to risk having it eat my laundry...

### Why use the `allowDiscards` flag with LUKS?

The `allowDiscards` option instructs the mapper to propagate trim commands
issued by the underlying filesystem, which allows the SSD to better perform
wear leveling. This option is disabled by default since there are some
theoretical attack vectors from having it enabled (namely leaking which blocks
are trimmed, an some potential oracle attacks if the attacker can influence
what data is written to the disk).

Since this doesn't fit my threat model (namely someone gaining physical access
to my disk) and since I am more worried about maintaining my SSD performance,
I decided to enable this option.

## Installation

On to the good stuff, actual installation steps start here! Note all commands
should be run as root.

### Installer preparation

1. [Download an installer](https://nixos.org/download.html) and burn it to a
   bootable USB drive. Worth noting that if you already have an existing nix
   install you can create your own custom installer (e.g. if you're a power
   user or you need specific tools available during installation), but the
   base installer should cover all the bases.
1. If there is an existing Windows installation on this machine (even if it is
   on an entirely separate drive), consider [turning off the "Enable fast
   startup" option](https://askubuntu.com/questions/1291758/ubuntu-20-04-and-fenvi-ax200-wifi-bluetooth-card-drivers-or-soolution-to-wifi)
   and rebooting before continuing. I had to do this to get my bluetooth/wifi
   (AX200) adapter to work (yay Windows hacks to gain speedup!).
1. (Optional) if you have other drives in the machine, consider unplugging
   them to avoid accidentally overwriting the wrong disk due to a typo...
1. Plug in the USB, reboot the computer, hit the appropriate keys during the
   BIOS, and boot into the USB

### Partitioning the Disk

1. If a graphical installer image was used, it should drop us in a desktop
   environment which should set up some basic stuff like networking. The rest
   of the commands all need root privileges, so open a terminal and switch to
   root to avoid having to prefix everything with `sudo`.

   ```sh
   sudo su
   ```
1. Next, we need to figure out which disk we want to use.

   ```sh
   ls /dev
   ```
1. In my case this is my second NVMe in this machine so I will be using
   `nvme1n1`, but you may see a different number based on what is connected.
   We'll store this in a variable to make it easier to copy-paste other
   commands, so **make sure to replace the `...` with your selected drive**:

   ```sh
   DISK=/dev/...
   ```
1. Next, it's time to partition the actual disk. I'm going to be creating the
   following partitions:
   * 1 GiB (unencrypted) boot partition - for storing the initial boot files
   * 32 MiB LUKS key partition - the key for the rest of the disk. This will be
     encrypted with a password that we remember (and type in during boot)
   * 32 GiB swap partition - for enabling system swap
   * The remainder of the drive will be our actual, usable, partition

   We're going to be using `gdisk` below, but if you know how to use another
   disk partition program, feel free to use it instead.

   ```sh
   gdisk "${DISK}"
   ```

   <details>
     <summary>Click to expand!</summary>

     ```
     GPT fdisk (gdisk) version 1.0.5

     Partition table scan:
       MBR: not present
       BSD: not present
       APM: not present
       GPT: not present

     Creating new GPT entries in memory.

     Command (? for help): o
     This option deletes all partitions and creates a new protective MBR.
     Proceed? (Y/N): Y

     Command (? for help): n
     Partition number (1-128, default 1):
     First sector (34-1953525134, default = 2048) or {+-}size{KMGTP}:
     Last sector (2048-1953525134, default = 1953525134) or {+-}size{KMGTP}: +1G
     Current type is 8300 (Linux filesystem)
     Hex code or GUID (L to show codes, Enter = 8300): EF00
     Changed type of partition to 'EFI system partition'

     Command (? for help): n
     Partition number (2-128, default 2): 2
     First sector (34-1953525134, default = 2099200) or {+-}size{KMGTP}:
     Last sector (2099200-1953525134, default = 1953525134) or {+-}size{KMGTP}: +32M
     Current type is 8300 (Linux filesystem)
     Hex code or GUID (L to show codes, Enter = 8300):
     Changed type of partition to 'Linux filesystem'

     Command (? for help): c
     Partition number (1-2): 2
     Enter name: luks key

     Command (? for help): n
     Partition number (3-128, default 3):
     First sector (34-1953525134, default = 2164736) or {+-}size{KMGTP}:
     Last sector (2164736-1953525134, default = 1953525134) or {+-}size{KMGTP}: +32G
     Current type is 8300 (Linux filesystem)
     Hex code or GUID (L to show codes, Enter = 8300):
     Changed type of partition to 'Linux filesystem'

     Command (? for help): c
     Partition number (1-3): 3
     Enter name: swap

     Command (? for help): n
     Partition number (4-128, default 4):
     First sector (34-1953525134, default = 69273600) or {+-}size{KMGTP}:
     Last sector (69273600-1953525134, default = 1953525134) or {+-}size{KMGTP}:
     Current type is 8300 (Linux filesystem)
     Hex code or GUID (L to show codes, Enter = 8300):
     Changed type of partition to 'Linux filesystem'

     Command (? for help): c
     Partition number (1-4): 4
     Enter name: root

     Command (? for help): p
     Disk /dev/nvme1n1: 1953525168 sectors, 931.5 GiB
     Model: Samsung SSD 970 EVO Plus 1TB
     Sector size (logical/physical): 512/512 bytes
     Disk identifier (GUID): 22610B10-DB5F-467D-8B9E-ECD88878ABA5
     Partition table holds up to 128 entries
     Main partition table begins at sector 2 and ends at sector 33
     First usable sector is 34, last usable sector is 1953525134
     Partitions will be aligned on 2048-sector boundaries
     Total free space is 2014 sectors (1007.0 KiB)

     Number  Start (sector)    End (sector)  Size       Code  Name
        1            2048         2099199   1024.0 MiB  EF00  EFI system partition
        2         2099200         2164735   32.0 MiB    8300  luks key
        3         2164736        69273599   32.0 GiB    8300  swap
        4        69273600      1953525134   898.5 GiB   8300  root

     Command (? for help): w

     Final checks complete. About to write GPT data. THIS WILL OVERWRITE EXISTING
     PARTITIONS!!

     Do you want to proceed? (Y/N): Y
     OK; writing new GUID partition table (GPT) to /dev/nvme1n1.
     The operation has completed successfully.
     ```
   </details>

### LUKS Setup

1. Now that the disk is partitioned, it's time to turn on encryption! First
   we'll initialize our `cryptkey` partition and fill it with random data.
   This will eventually become the key to decrypt our actual drive. Note that
   **this is the day-to-day password used to unlock the computer at boot**.

   ```sh
   cryptsetup luksFormat --type luks1 "${DISK}p2"
   cryptsetup luksOpen "${DISK}p2" cryptkey
   dd if=/dev/urandom of=/dev/mapper/cryptkey bs=1024 status=progress
   ```
1. Next, we initialize the swap partition (which will share the same key
   written to our `cryptkey` partition along with the rest of the drive). Note
   that there is no backup key set for this partition, but there should never
   be any reason to try to recover any data written in the swap in case the
   `cryptkey` partition is damaged.

   ```sh
   cryptsetup luksFormat --type luks1 --keyfile-size 8192 --key-file /dev/mapper/cryptkey "${DISK}p3"
   # Mount the partition after creation
   cryptsetup luksOpen --keyfile-size 8192 --key-file /dev/mapper/cryptkey "${DISK}p3" cryptswap
   ```
1. Now it's time to encrypt the rest of the drive. Note that first we'll
   initialize the drive with a *backup passphrase*. Make this a strong
   password (e.g. diceware) **and write it down and store is someplace safe**.
   If the `cryptkey` partition becomes damaged, this will be the only way to
   recover the data on the drive!

   ```sh
   # Initialize with a passphrase
   cryptsetup luksFormat --type luks1 "${DISK}p4"
   # Add the cryptkey partition as a keyfile for unlocking during boot
   cryptsetup luksAddKey --new-keyfile-size 8192 "${DISK}p4" /dev/mapper/cryptkey
   ```
1. Finally, mount the root partition. **Note the use of `--allow-discards`
   which may be a security risk**. Read about the choices and assumptions
   above as to why I have chosen to use this flag, but feel free to omit it if
   desired.
   ```sh
   cryptsetup luksOpen --keyfile-size 8192 --key-file /dev/mapper/cryptkey --allow-discards "${DISK}p4" cryptroot
   ```
1. Note that some guides recommend filling the drive with random data before
   doing the encryption to avoid leaking information about how big the drive
   is and which blocks are encrypted, etc. I am going to omit this step since
   I want to avoid wearing out my SSD,

### Filesystem setup

1. Initialize the boot partition as vfat
   ```sh
   mkfs.vfat "${DISK}p1"
   ```
1. Initialize the swap partition
   ```sh
   mkswap /dev/mapper/cryptswap
   ```
1. Next, it's time to initialize zfs. Feel free to pick any pool name you want,
   but consider keeping it unique if you manage other zfs pools elsewhere
   ```sh
   POOL=nvme-pool # change as desired
   zpool create "${POOL}" /dev/mapper/cryptroot
   # autotrim enabled to maintain SSD performance
   zpool set autotrim=on "${POOL}"
   ```
1. Create the desired root datasets (or mounts) in the pool. Note that at the
   time of writing, using `mountpoint=legacy` is required for correct NixOS
   interoperation.

   ```
   zfs create -o compression=on -o mountpoint=legacy "${POOL}/local"
   zfs create -o compression=on -o mountpoint=legacy "${POOL}/system"
   zfs create -o compression=on -o mountpoint=legacy "${POOL}/user"
   zfs create -o compression=on -o mountpoint=legacy "${POOL}/reserved"
   ```
1. Set a variable with the default username you wish to use which we'll use
   for creating a home directory later
   ```sh
   MY_USER=...
   ```
1. Next, we create any child datasets. Note that the `acltype=posixacl` flag
   is required wherever `/var` will be mounted, so that users can access their
   own journal logs

   ```sh
   zfs create -o xattr=sa -o acltype=posixacl "${POOL}/system/var"

   zfs create "${POOL}/system/root"
   zfs create "${POOL}/user/home"
   zfs create "${POOL}/user/home/${MY_USER}"
   ```
1. Set a quota and reservation on the `reserved` data set. This will ensure
   that the disk always has the specified amount of space available, and since
   we will never mount this partition, we're effectively saving some space
   from never being written (i.e. over-provisioning the SSD to maintain its
   performance)


   ```sh
   zfs set reservation=100G "${POOL}/reserved"
   zfs set quota=100G "${POOL}/reserved" # ensure we can't accidentally write more than 100G to this partition
   ```
1. Next, we enable local snapshotting so that we can quickly recover past
   state if something goes wrong. Note that we only need to snapshot user data
   and the system root. Other easily-rebuilt partitions (like `local`) don't
   need snapshotting enabled. Also note that the actual snapshot frequency
   will be managed by our NixOS configuration

   ```sh
   zfs set com.sun:auto-snapshot=true "${POOL}/system"
   zfs set com.sun:auto-snapshot=true "${POOL}/user"
   ```

1. Lastly, *mount everything*! If you forget to mount a zfs dataset to the
   right place, then data may get written in the wrong place and fail during
   boot!
   * I made the mistake of forgetting to mount the `/nix/store` path on the
     new drive. The installer happily filled the root partition with the data,
     but when my configuration correctly mounted the right dataset during
     boot, suddenly all the packages were missing!

   ```sh
   # Mount the root partition itself
   mount -t zfs "${POOL}/system/root" /mnt

   # Make directory entries for the subsequent mounts
   mkdir -p /mnt/boot
   mkdir -p /mnt/nix
   mkdir -p /mnt/var
   mkdir -p "/mnt/home/${MY_USER}"

   # Mount the boot partition
   mount "${DISK}p1" /mnt/boot

   # Mount the rest of our zfs datasets
   mount -t zfs "${POOL}/local/nix" /mnt/nix
   mount -t zfs "${POOL}/system/var" /mnt/var
   mount -t zfs "${POOL}/user/home/${MY_USER}" "/mnt/home/${MY_USER}"
   ```

### NixOS installation

1. Finally it's time to get nix involved! Run the generation command below
   and it should do a good job at auto-detecting any hardware and filesystem
   configurations

   ```sh
   nixos-generate-config --root /mnt
   ```
1. Edit the generated config in `/mnt/etc/nixos/configuration.nix`. If you're
   new to NixOS, or missing your favorite editor/environment setup, consider
   lightly tweaking the default config (e.g. turning on ssh, setting up
   networking, etc.) to get things going and come back to flesh it out later.
   But before we continue there are a few more things to double check:
   1. Make sure that the `initrd.luks.devices` are correctly configured. If
      anything is missing, or the disk uuid is incorrect, **carefully** update
      the config and double check everything
   1. Also carefully note that the `cryptkey` declaration shows up before any
      other partions which are unlocked by it!
   1. Make sure to update the `keyFileSize` parameter to whatever was used
      during initialization
   1. Also make sure to set the `allowDiscards` flag if used above
      (**noting the security caveats from before**)
   1. Make sure that all filesystems are correctly mapped to their zfs data
      sets.
   1. Add any missing `boot.initrd.availableKernelModules`. For example, I
      had to add `"amdgpu"` to fix some screen resolution issues during early
      boot.
   1. Add your default user and set their home directory
1. Time to actually install NixOS now! After the initial install is done,
   reboot and hope everything went well...

   ```sh
   nixos-install
   reboot
   ```
1. If you got this far and were able to log in, congrats, you did it! A few
   more things to consider doing:
   * Change the password for your default user
   * Change the root password, or even better, lock the root account so no one
     can log into it directly
