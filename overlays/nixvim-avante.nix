{ unstable }:
self: super: {
  vimPlugins = super.vimPlugins // {
    avante-nvim = unstable.legacyPackages.${super.system}.vimPlugins.avante-nvim;
  };
}
