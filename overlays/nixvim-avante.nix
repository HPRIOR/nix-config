self: super: {
  vimPlugins = super.vimPlugins // {
    avante-nvim = super.vimUtils.buildVimPlugin {
      pname = "avante-nvim";
      version = "574b0d37";
      src = super.fetchFromGitHub {
        owner = "yetone";
        repo = "avante.nvim";
        rev = "574b0d37a32fcaf7ade1f76422ac4c8793af0301";
        hash = "sha256-Mi0BG+RY2qsJcsO2uTxnw0le3AaobaVCplAchyc7/XM=";
      };
    };
  };
}
