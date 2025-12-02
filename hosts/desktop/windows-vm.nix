{ config, pkgs, lib, ... }:
let
  cfg = config.windowsVM;
  hasAttrByPath = lib.hasAttrByPath;
  hasAMD = hasAttrByPath ["hardware" "cpu" "amd"] config;
  hasIntel = hasAttrByPath ["hardware" "cpu" "intel"] config;
  kvmModules = lib.optional hasAMD "kvm-amd" ++ lib.optional hasIntel "kvm-intel";
  requiredKernelModules = ["kvm"] ++ kvmModules;
in {
  options.windowsVM.enable = lib.mkEnableOption "Support for running Windows virtual machines via libvirt";

  config = lib.mkIf cfg.enable {
    boot.kernelModules = lib.mkAfter requiredKernelModules;

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
