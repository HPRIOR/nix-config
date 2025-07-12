{ unstable }:
self: super: {
  vimPlugins = super.vimPlugins // {
    avante-nvim = unstable.vimPlugins.avante-nvim;
  };
}
