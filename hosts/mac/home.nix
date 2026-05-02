{...}: {
  imports = [
    ../../home
    ../../home/mac
  ];

  my.features.darwin = {
    enable = true;
    rectangle.enable = true;
  };
}
