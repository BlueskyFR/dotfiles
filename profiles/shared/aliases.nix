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
    zz = "zz";

    # Make aliases work with sudo X
    # sudo = "sudo"; # Breaks the `sudo` oh-my-zsh plugin

    diff = "diff --color=auto";
    grep = "grep --color=auto";
    ip = "ip -color=auto";
  };

  programs.zsh.shellGlobalAliases = {
    aa = "aa";
    g = "grep -i";
  };

  # TODO: add back `alias -s py=python` (suffix alias)

  # Some tools need some global vars to enable colors
  home.sessionVariables = {
    LESS = "-R --use-color -Dd+r\\$Du+b";
    MANPAGER = "less -R --use-color -Dd+r -Du+b";
  };
}
