
# Installing NixOS on a Raspberry Pi

In this tutorial, we are going to setup a `home server` using `NixOS` on `Raspberry Pi`.

## Requirements

* A Raspberry Pi 4B Model
* A microSD card image with atleast 32 GB of storage
* A microSD card reader
* A linux or macOS machine for flashing the image
* A LAN Cable for ethernet
* An HDMI cable
* A monitor
* A keyboard

## Download & Copy NixOS Image to SD Card

You can download a pre-built microSD image from [Hydra](https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image.aarch64-linux)

Once the sd image is download, we can proceed to flash the image into the sd card.

Plug in your SD card and run

```sh
lsblk
```

This should print output like this

```sh
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda           8:0    1 57.8G  0 disk
└─sda1        8:1    1 57.8G  0 part /mnt/test
mmcblk1     179:0    0 29.7G  0 disk
├─mmcblk1p1 179:1    0   30M  0 part
└─mmcblk1p2 179:2    0 29.7G  0 part /nix/store
```

Note the name of device where you want to copy the nixos image. For me, it is `/dev/sda`.

Run the below command to copy the nixos image to the sd card.

```sh
sudo dd bs=4M if=nixos-sd-image-24.05.20231211.a9bf124-aarch64-linux.img of=/dev/sda status=progress conv=fsync
```

where

- `nixos-sd-image-24.05.20231211.a9bf124-aarch64-linux.img` is the downloaded nixos sd image from [Hydra](https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image.aarch64-linux)
- `/dev/sda` is the SD card where I want to copy this image

After it finishes copying the image into the sd card, run the below command to flush any still-in-cache data to the sd card.

```sh
sudo sync
```

Now you can safely remove the sd card.

## Boot NixOS Live Image in Raspberry Pi

Plug in the SD card, keyboard, HDMI cable and ethernet cable into the Raspberry Pi and boot.

Once booted, note the IP of the Pi by running

```sh
ifconfig
```

## Configuring NixOS

Now we are going to rewrite the NixOS Configuration to our own.

Create a file named `configuration.nix` in `/etc/nixos` and add the following to it

```nix
{ config, pkgs, lib, ... }:
{

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking.hostName = "pi";

  environment.systemPackages = with pkgs; [ vim ];

  services.openssh.enable = true;
  
 # Set a password using `passwd` for the user
  users = {
    users.john = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };
  };

  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "23.11";
}
```

Save and exit the file and run the below command to apply this configuration.

```sh
nixos-rebuild boot
reboot
```

This will create a user named `john` and enable `openssh` so that we can connect through remotely to the raspberry pi.

## Bonus

Convert your NixOS Configuration into `Flakes`

See [this](https://nixos.asia/en/nixos-install-flake#flakeify) tutorial.
