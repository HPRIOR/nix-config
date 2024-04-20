# {inputs,config, pkgs, lib ,...}:
# {
#
# 	home.stateVersion = "23.05";
# 	home.packages = with pkgs; [
# 		croc
# 	];
#
# }
{...}: {
  imports = [../../home];
}
