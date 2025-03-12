{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    plugins = with pkgs; [rofi-emoji rofi-rbw-wayland];
    theme = let
      # Use `mkLiteral` for string-like values that should show without
      # quotes, e.g.:
      # {
      #   foo = "abc"; => foo: "abc";
      #   bar = mkLiteral "abc"; => bar: abc;
      # };
      # TLDR: `lit` converts `"hey"` to `hey` instead of `"hey"`
      lit = config.lib.formats.rasi.mkLiteral;
    in {
      /*
      * ROFI One Dark
      *
      * Based on OneDark.vim (https://github.com/joshdick/onedark.vim)
      *
      * Author: Benjamin Stauss
      * User: me-benni
      *
      */
      "*" = {
        black = lit "#000000";
        red = lit "#eb6e67";
        green = lit "#95ee8f";
        yellow = lit "#f8c456";
        blue = lit "#0091EA";
        magenta = lit "#d886f3";
        purple = lit "#d886f3";
        cyan = lit "#6cdcf7";
        emphasis = lit "#50536b";
        text = lit "#dfdfdf";
        text-alt = lit "#b2b2b2";
        fg = lit "#abb2bf";
        bg = lit "#282c34";

        spacing = 0;
        background-color = lit "transparent";

        font = "Knack Nerd Font 14";
        text-color = lit "@text";
      };

      window = {
        transparency = "real";
        fullscreen = true;
        background-color = lit "#282c34dd";
      };

      mainbox = {
        padding = lit "30% 30%";
      };

      inputbar = {
        margin = lit "0px 0px 20px 0px";
        children = ["prompt" "textbox-prompt-colon" "entry" "case-indicator"];
      };

      prompt = {
        text-color = lit "@blue";
      };

      textbox-prompt-colon = {
        expand = false;
        str = ":";
        text-color = lit "@text-alt";
      };

      entry = {
        margin = lit "0px 10px";
      };

      listview = {
        spacing = lit "5px";
        dynamic = true;
        scrollbar = false;
      };

      element = {
        padding = lit "5px";
        text-color = lit "@text-alt";
        highlight = lit "bold #95ee8f"; # green
        border-radius = lit "3px";
      };

      "element selected" = {
        background-color = lit "@emphasis";
        text-color = lit "@text";
      };

      "element urgent, element selected urgent" = {
        text-color = lit "@red";
      };

      "element active, element selected active" = {
        text-color = lit "@purple";
      };

      message = {
        padding = lit "5px";
        border-radius = lit "3px";
        background-color = lit "@emphasis";
        border = lit "1px";
        border-color = lit "@cyan";
      };

      "button selected" = {
        padding = lit "5px";
        border-radius = lit "3px";
        background-color = lit "@emphasis";
      };
    };
  };
}
