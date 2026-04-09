{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  # More docs: https://wiki.nixos.org/wiki/Plymouth
  boot.plymouth = {
    enable = true;
    theme = "colorful";
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override {selected_themes = ["colorful"];})
    ];
  };
}
