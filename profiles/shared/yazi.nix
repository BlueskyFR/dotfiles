{
  config,
  pkgs,
  lib,
  flakeDir,
  ...
}: let
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "bb758e2fd774738f14cd260642631ebbd568741a";
    hash = "sha256-uV5KZE+4gT/o7hzer/hwAfU5lyDYgMnRlsQX+BkCRhM=";
  };
in {
  programs.yazi = {
    enable = true;
    shellWrapperName = "f"; # For "files" ;)

    settings = {
      mgr = {
        show_hidden = true;
      };
      preview = {
        max_width = 1000;
        max_height = 1000;
      };
    };

    plugins = {
      chmod = "${yazi-plugins}/chmod.yazi";
      full-border = "${yazi-plugins}/full-border.yazi";
      toggle-pane = "${yazi-plugins}/toggle-pane.yazi";
      starship = pkgs.fetchFromGitHub {
        owner = "Rolv-Apneseth";
        repo = "starship.yazi";
        rev = "159eaba5b5052bf78ff6cfbfe4e527b946818c82";
        sha256 = "sha256-I21to4cxlszRpsb58cvsmwX7VglQBSJC0rrsFIltzC8=";
      };
    };

    initLua = ''
      require("full-border"):setup()
      require("starship"):setup()
    '';

    keymap = {
      mgr.prepend_keymap = [
        {
          on = "T";
          run = "plugin toggle-pane max-preview";
          desc = "Maximize or restore the preview pane";
        }
        {
          on = ["c" "m"];
          run = "plugin chmod";
          desc = "Chmod on selected files";
        }
      ];
    };
  };
}
