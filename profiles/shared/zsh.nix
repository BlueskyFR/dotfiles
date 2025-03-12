{
  config,
  pkgs,
  lib,
  ...
}: {
  # Enable ZSH integrations for all programs by default
  home.shell.enableZshIntegration = true;

  programs = {
    zoxide = {
      enable = true;
      # Creates the `cd` and `cdi` aliases instead of `z`/`zi`
      options = ["--cmd cd"];
    };

    fzf = {
      enable = true;
      # Do not source the init script since oh-my-zsh plugin already does it.
      # Note: if we disable the oh-my-zsh plugin then the history shortcut breaks
      enableZshIntegration = false;
    };

    zsh = {
      enable = true;
      autosuggestion = {
        enable = true;
        strategy = ["history" "completion"]; # "match_prev_cmd"
      };
      syntaxHighlighting = {
        enable = true;
        # List of highlighters to enable, on top of "main"
        highlighters = ["brackets" "cursor"];
      };
      enableCompletion = true;
      autocd = true;
      dirHashes = {
        docs = "$HOME/docs";
        dl = "$HOME/dl";
        pics = "$HOME/pics";
        vids = "$HOME/vids";
        music = "$HOME/music";
      };
      history = {
        ignoreSpace = true; # Don't save to hist. commands starting with a space
        path = "$HOME/.history";
        save = 99000000; # Max size on disk
        size = 99000000; # Max size in mem
        share = true; # Share history between zsh sessions
      };

      oh-my-zsh = {
        enable = true;
        plugins = [
          "git" # Defines many aliases and functions: https://is.gd/OwBPmf
          "colored-man-pages"
          "cp" # Defines `cpv` (uses rsync)
          "sudo" # Prefixes current command with `sudo` by pressing `esc` twice! 🤩
          "fzf" # Setup completions & keyboard shortcuts for an existing fzf installation
          "poetry" #"poetry-env"
        ];
      };
    };
    # TODO: Enable oh-my-zsh here?

    # Zsh prompt
    starship = {
      enable = true;
      settings = {
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$env_var"
          "$all"
        ];

        username = {
          format = "[$user]($style) ";
          style_user = "bright-black";
        };

        directory = {
          style = "blue";
          truncation_length = 0;
          truncate_to_repo = false;
        };

        character = {
          success_symbol = "[❯](purple)";
          error_symbol = "[❯](red)";
          vimcmd_symbol = "[❮](green)";
        };

        git_branch = {
          format = "[$branch]($style)";
          style = "bright-black";
        };

        git_status = {
          format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
          style = "cyan";
          conflicted = "​";
          untracked = "​";
          modified = "​";
          staged = "​";
          renamed = "​";
          deleted = "​";
          stashed = "≡";
        };

        git_state = {
          format = "\([$state( $progress_current/$progress_total)]($style)\) ";
          style = "bright-black";
        };

        cmd_duration = {
          format = " [⏱ $duration]($style)  ";
          style = "yellow";
        };

        sudo = {
          disabled = false;
          format = " [$symbol]($style)";
        };

        kubernetes = {
          format = " [$symbol$context( \($namespace\))]($style) ";
          disabled = false;
          detect_env_vars = ["SHOW_K8S_ENV"];
        };

        env_var.SLURM_JOB_ID = {
          symbol = "💼";
          format = " $symbol [$env_value]($style) ";
          style = "bright-black bold dimmed";
        };

        python = {
          format = "[$virtualenv]($style) ";
          style = "bright-black";
        };
      };
    };
  };
}
