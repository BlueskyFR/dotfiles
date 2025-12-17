{
  config,
  pkgs,
  lib,
  ...
}: {
  home.shellAliases = {
    ls = "lsd"; # --color=always
    l = "lsd -F";
    la = "lsd -A";
    ll = "lsd -lArth";
    lt = "lsd --tree";
    llt = "lsd -lArth --tree";

    ns = "nix-shell -p";
    p = "${pkgs.python313}/bin/python";
    b = "bat -pp"; # Colored cat
    bp = "bat -p"; # Colored cat (keep pager)
    cyme = "cyme --headings"; # Stylish lsusb

    # Docker/podman compose
    dc = "docker compose";
    dcu = "docker compose up -d";
    dcd = "docker compose down";
    dcp = "docker compose pull";
    dcb = "docker compose build";

    zz = "zz";

    # Make aliases work with sudo X
    # sudo = "sudo"; # Breaks the `sudo` oh-my-zsh plugin

    diff = "diff --color=auto";
    grep = "grep --color=auto";
    ip = "ip -color=auto";
  };

  programs.zsh = {
    shellGlobalAliases = {
      aa = "aa";
      g = "grep -i";
    };
    initContent = lib.mkAfter ''
      # Custom cd function, defined after zoxide's init
      cd() { __zoxide_z "$@" && l }

      # Custom docker/podman compose commands
      dcr() { docker compose down $* && docker compose up -d  $* }
      dcrl() { docker compose down $* && docker compose up -d  $* && docker compose logs -f $* }
      dcf() { docker compose pull && docker compose build && docker compose down $* && docker compose up -d  $* }
    '';
  };

  # TODO: add back `alias -s py=python` (suffix alias)

  # Some tools need some global vars to enable colors
  home.sessionVariables = {
    LESS = "-R --use-color -Dd+r\\$Du+b";
    MANPAGER = "less -R --use-color -Dd+r -Du+b";
  };
}
