{pkgs, ...}: {
  # For uv-installed python versions
  environment.localBinInPath = true;
  programs.nix-ld.enable = true;

  home-manager.users.hugo.programs.uv.enable = true;
}
