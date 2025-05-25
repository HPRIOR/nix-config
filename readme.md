# NixOS install

> Note: If using LVM... 
> - The boot partition cannot be a logical volume. Partition this seperately before creating logical volumes. Recommended size for nixos (by the installer) is 1024 MiB. 
> - The GUI installer will not display the EFI boot partition when a logical volume is selected in the manual partition dropdown menu. First, select the relevant drive with the boot partition, click edit on the boot partition and select the mnt point as /boot. Then, select the logical volume from the drop down and edit the mnt points for /root and /home.


## Get access to git and neovim

```console
nix-shell -p git neovim
```

## Clone nix configuration into ~/.nix-config

```console
git clone https://github.com/HPRIOR/nix-config.git ~/.nix-config
```

> Note: if this is run as root you'll need to update the perms of the .git directory later: `sudo chown -R $(whoami) .git`

## Copy hardware config
```console
cp /etc/nixos/hardware-configuration.nix ~/.nix-config/hosts/desktop/hardware-configuration.nix
```

> Note: if you using a swap space you may need to add this to the configuration.

## Enable experimental features in nixOS

```console
mkdir -p ~/.config/nix/nix.conf
cp /etc/nix/nix.conf ~/.config/nix/
nvim ~/.config/nix/nix.conf
```

Add the following line:
```conf
experimental-features = nix-command flakes
```

## Sops nix :
Grab the private sops nix keys from somewhere and copy to `/etc/sops/age/keys.txt`


## Build the system 
```console
sudo nixos-rebuild switch --flake ~/.nix-config#[host_name]
```

> Note: you may need to uncomment out citrix workspace, as this relies on downloading a tarball file (todo: make this more convenient/optional...)

# Todo
- Allow more configuration instead of if/else darwin/linux
- Home server setup
- Fix hacky sops-nix work-around

