# Dotfiles

This is the repository of my configuration for all my hosts running NixOS!

I have been trying to put my hands on NixOS for a couple years now and the lack of documentation and a couple things like [big Wayland-related NVIDIA drivers
issues](https://gitlab.freedesktop.org/wayland/wayland-protocols/-/merge_requests/90) held me back for a while, but I'm glad that I made the move now!

A lot of things are still missing compared to a "regular" distribution such as my previous [i3 Manjaro flavor](https://manjaro.org/products/download/x86), but I'm getting there!

And most importantly, learning a lot of things along the way, and making them persist in this repo!

This configuration is made of modules, which each host can pick (e.g. `desktop`, `work`, `server`...), and a shared module that everyone inherits.
Each host can then define its own unique traits (disks, GPU driver, specific kernel version if needed...).

> The goal is that if a feature is enabled when I use any computer, every other one gets it!

So everything graphical will logically be contained inside the `desktop` module, meaning you won't install any of it if you don't select it for your host!

I use [Home Manager](https://github.com/nix-community/home-manager) in order to run as much things as possible as non-root.

No real documentation other than that for the moment, this repo is mainly for myself but I felt like sharing it with the world because it took a lot of time & efforts
to get there and accumulate all this knowledge in a single place! ❤️

## nix github.com rate-limiting

Rate-limit caused by the amount of requests to github.com can be solved by [creating a personal access token](https://github.com/settings/personal-access-tokens) (default permissions, i.e. read-only access to public repos is enough) and pasting it under `~/.config/nix/nix.conf`:

```shell
mkdir -p ~/.config/nix
echo "access-tokens = github.com=<your token here>" >> ~/.config/nix/nix.conf
code ~/.config/nix/nix.conf
```

> TODO: migrate this to the config using secrets