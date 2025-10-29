{ config, pkgs, lib, ... }:
let
  cfg = config.windowsVM;
  hasAMD = config.hardware ? cpu && config.hardware.cpu ? amd;
  hasIntel = config.hardware ? cpu && config.hardware.cpu ? intel;
  kvmModules = lib.optional hasAMD "kvm-amd" ++ lib.optional hasIntel "kvm-intel";
in {
  options.windowsVM.enable = lib.mkEnableOption "Support for running Windows virtual machines via libvirt";

  config = lib.mkIf cfg.enable {
    boot.kernelModules = lib.mkAfter kvmModules;

    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          swtpm.enable = true;
          ovmf = {
            enable = true;
            packages = [ pkgs.OVMFFull.fd ];
          };
          vhostUserPackages = [ pkgs.virtiofsd ];
        };
      };
      spiceUSBRedirection.enable = true;
    };

    programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [
      virt-viewer
      spice-gtk
      virtio-win
      usbutils
    ];

    networking.firewall.trustedInterfaces = lib.mkAfter ["virbr0"];
  };
}
