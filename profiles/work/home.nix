{
  config,
  pkgs,
  lib,
  flakeDir,
  ...
}: {
  home.packages = with pkgs; [
    teams-for-linux
    slack
    remmina

    # Kubernetes
    kubectl
    kubecolor
    kubectx
    k9s
    kubernetes-helm
  ];

  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "[workspace 4 silent] teams-for-linux"
      "[workspace 4 silent] slack"
    ];
    windowrule = ["workspace 4 silent, match:class teams-for-linux"];
  };

  # Shell aliases
  home.shellAliases = {
    # Kubernetes
    ks = "toggle_show_k8s_env";
    kubectl = "kubecolor";
    k = "show_k8s_env; kubectl";
    kexec = "k exec --stdin --tty";
    kg = "k get";
    kk = "k get all";
    kc = "show_k8s_env; kubectx";
    kn = "show_k8s_env; kubens";
    k9s = "k9s -c wk";
  };

  programs.zsh = {
    # shellGlobalAliases = {};
    # Nix string litterals (here indented string) escape chars: https://nix.dev/manual/nix/2.28/language/string-literals.html
    initContent = lib.mkAfter ''
      # Kubernetes
      ## Starship prompt integration
      show_k8s_env() { export SHOW_K8S_ENV=1; }
      toggle_show_k8s_env() { [[ -v SHOW_K8S_ENV ]] && unset SHOW_K8S_ENV || export SHOW_K8S_ENV=1; }
      ## Decode base64 kubernetes secrets
      kgs() { kubectl get secret $1 -o json | jq '.data | map_values(@base64d)' }
    '';
  };
}
