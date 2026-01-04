{
  config,
  pkgs,
  lib,
  flakeDir,
  ...
}: {
  home.shellAliases = {
    ls = "lsd"; # --color=always
    l = "lsd -F";
    la = "lsd -A";
    ll = "lsd -lArth";
    lt = "lsd --tree";
    llt = "lsd -lArth --tree";

    p = "${pkgs.python313}/bin/python -q";
    b = "bat -pp"; # Colored cat
    bp = "bat -p"; # Colored cat (keep pager)
    cyme = "cyme --headings"; # Stylish lsusb

    # Docker/podman compose
    dc = "docker compose";
    dcu = "docker compose up -d";
    dcd = "docker compose down";
    dcp = "docker compose pull";
    dcb = "docker compose build";

    # Nix aliases
    repl = "nix repl ${flakeDir}#nixosConfigurations.$(hostname)";

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
    # Nix string litterals (here indented string) escape chars: https://nix.dev/manual/nix/2.28/language/string-literals.html
    initContent = lib.mkAfter ''
      # Custom cd function, defined after zoxide's init
      cd() { __zoxide_z "$@" && l }

      # Highlight lines matching pattern without trimming output
      hl() { grep --color=always -Ei "^|.*$@.*" }

      # Alias for `ns pkg1 pkg2` -> `nix shell nixpkgs#pkg1 nixpkgs#pkg2`
      ns() { nix shell ''${@/#/nixpkgs#} }

      # Custom docker/podman compose commands
      dcr() { docker compose down $* && docker compose up -d  $* }
      dcrl() { docker compose down $* && docker compose up -d  $* && docker compose logs -f $* }
      dcf() { docker compose pull && docker compose build && docker compose down $* && docker compose up -d  $* }

      # is.gd url shortener
      shorten() { out=$(curl -s --fail-with-body "https://is.gd/create.php?format=simple&url=$1") && wl-copy "$out" 2> /dev/null && echo '✅ Copied to clipboard!' || echo $out }
    '';
  };

  # TODO: add back `alias -s py=python` (suffix alias)

  home.packages = with pkgs;
    [
      (writeShellScriptBin "upgrade-firmware" ''
        sudo fwupdmgr get-devices
        echo Waiting 2 sec...
        sleep 2
        sudo fwupdmgr refresh --force
        sudo fwupdmgr get-updates
        sudo fwupdmgr update
      '')
    ]
    ++ (let
      script = {
        updateFlakeInputs ? false,
        fancyOutput ? false,
      }:
      # `lib.optionalString` defaults to "" if condition is false
      ''
        sudo true

        ${lib.optionalString updateFlakeInputs "nix flake update --flake ${flakeDir}"}

        sudo nixos-rebuild switch --flake ${flakeDir} \
          --cores $(${pkgs.coreutils-full}/bin/nproc --all) \
          --max-jobs 100 ${lib.optionalString fancyOutput " |& ${nix-output-monitor}/bin/nom"}
      '';
    in [
      # Rebuild/sync system
      (writeShellScriptBin "s" (script {}))
      # Update flake inputs + rebuild system
      (writeShellScriptBin "us" (script {updateFlakeInputs = true;}))
      # Rebuild/sync system (fancy)
      (writeShellScriptBin "sf" (script {fancyOutput = true;}))
      # Update flake inputs + rebuild system (fancy)
      (writeShellScriptBin "usf" (script {
        updateFlakeInputs = true;
        fancyOutput = true;
      }))
    ]);

  # Some tools need some global vars to enable colors
  home.sessionVariables = {
    LESS = "-R --use-color -Dd+r\\$Du+b";
    MANPAGER = "less -R --use-color -Dd+r -Du+b";
  };
}
