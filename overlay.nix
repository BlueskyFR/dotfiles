final: prev: {
  /*
    flameshot = prev.flameshot.overrideAttrs (previousAttrs: {
    src = final.fetchFromGitHub {
      owner = "flameshot-org";
      repo = "flameshot";
      rev = "3d21e4967b68e9ce80fb2238857aa1bf12c7b905";
      sha256 = "sha256-OLRtF/yjHDN+sIbgilBZ6sBZ3FO6K533kFC1L2peugc=";
    };
    cmakeFlags = [
      "-DUSE_WAYLAND_CLIPBOARD=1"
      "-DUSE_WAYLAND_GRIM=1"
    ];
    buildInputs = previousAttrs.buildInputs ++ [final.libsForQt5.kguiaddons];
  });
  */

  # BSOL (Blue Screen Of Life) Grub theme
  bsol-grub2-theme = prev.stdenv.mkDerivation {
    name = "bsol-grub2-theme";
    buildInputs = [prev.victor-mono];
    src = prev.fetchFromGitHub {
      owner = "harishnkr";
      repo = "bsol";
      rev = "8f39f66967e2391b11ee554578f0b821070ec72a";
      hash = "sha256-UD5crwJdqnKVnxTN2vHIukJnQuzxmkko3E5wb8Xg6gs=";
    };
    installPhase = "cp -r bsol $out";
  };
}
