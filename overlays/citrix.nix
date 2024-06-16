self: super: {
  citrix_workspace = super.citrix_workspace.overrideAttrs (oldAttrs: {
    nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [super.pkgs.xmlstarlet]; # adding xmlstarlet to the build inputs

    postFixup =
      (super.lib.optionalString (super.lib.hasAttr "postFixup" oldAttrs) oldAttrs.postFixup)
      + ''
        # Crashes citrix so removing for now
        # Path to the configuration file
        # configPath=$out/opt/citrix-icaclient/config/AuthManConfig.xml

        # xmlstarlet ed -L -s /dict -t elem -n key -v "ScreenPinEnabled" -s /dict -t elem -n value -v "true" "$configPath"
      '';
  });
}
