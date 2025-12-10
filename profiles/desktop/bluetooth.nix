{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Shows battery charge of connected devices but may make bluetooth mice buggy?
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        # FastConnectable = true;
      };
    };
  };

  # Automatically switch audio to the bluetooth device when it connects
  services.pulseaudio.extraConfig = ''
    load-module module-switch-on-connect
  '';
  # Also enable a bluetooth device pairing GUI
  services.blueman.enable = true;
}
