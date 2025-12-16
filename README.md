# Dotfiles

## nix github.com rate-limiting

Rate-limit caused by the amount of requests to github.com can be solved by [creating a personal access token](https://github.com/settings/personal-access-tokens) (default permissions, i.e. read-only access to public repos is enough) and pasting it under `~/.config/nix/nix.conf`:

```shell
mkdir -p ~/.config/nix
echo "access-tokens = github.com=<your token here>" >> ~/.config/nix/nix.conf
code ~/.config/nix/nix.conf
```

> TODO: migrate this to the config using secrets