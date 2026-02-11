(self: super: {
  inetutils = super.inetutils.overrideAttrs (attrs: rec {
    version = "2.6";
    src = super.fetchurl {
      url = "mirror://gnu/${attrs.pname}/${attrs.pname}-${version}.tar.xz";
      hash = "sha256-aL7b/q9z99hr4qfZm8+9QJPYKfUncIk5Ga4XTAsjV8o=";
    };
  });
})
