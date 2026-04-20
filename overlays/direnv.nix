self: super: {
  direnv = super.direnv.overrideAttrs (oldAttrs: {
    checkPhase =
      if super.stdenv.isDarwin
      then ''
        runHook preCheck

        make test-go test-bash test-zsh

        runHook postCheck
      ''
      else oldAttrs.checkPhase;
  });
}
