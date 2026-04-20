self: prev: {
  spotify = prev.spotify.overrideAttrs (oldAttrs: {
    src =
      if (prev.stdenv.isDarwin && prev.stdenv.isAarch64)
      then
        prev.fetchurl {
          url = "https://web.archive.org/web/20251029235406/https://download.scdn.co/SpotifyARM64.dmg";
          hash = "sha256-gEZxRBT7Jo2m6pirf+CreJiMeE2mhIkpe9Mv5t0RI58=";
        }
      else oldAttrs.src;
  });
}
