{
  pkgs,
  lib,
  ...
}: {
  # SDDM
  services = {
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = false;
        autoNumlock = true;
        # theme = "where_is_my_sddm_theme"; # The QT6 version does not work currently
        theme = "${pkgs.where-is-my-sddm-theme.override {variants = ["qt6"];}}/share/sddm/themes/where_is_my_sddm_theme";
        extraPackages = with pkgs; [kdePackages.qt5compat];
      };

      ly.enable = lib.mkForce false;
    };

    # Required by SDDM
    xserver.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # SDDM theme
    #(where-is-my-sddm-theme.override {
    #  themeConfig.General = {
    #    passwordFontSize = 45;
    #  };
    #})
    (where-is-my-sddm-theme.override {variants = ["qt5" "qt6"];})
  ];
}
