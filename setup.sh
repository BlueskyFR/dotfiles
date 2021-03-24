info() {
  echo "$@"
}

warn() {
  echo "$(tput setaf 1)$@$(tput sgr0)"
}

link() {
  local src="$(pwd)/dotfiles/$1"
  local dst=${2:-"$HOME/$1"} # Defaults to $HOME if only 1 arg supplied
  info "Linking $src to $dst..."
  ln -sf $src $dst
  #ln -sf $(pwd)/dotfiles/.zshrc $HOME/.zshrc
}

gitstall() {
  if [ -d "$2" ]; then
    rm -rf "$2"
  fi
  git clone "$1" "$2"
  info "cloning $1 to $2"
}

pamac upgrade -a

# Pamac build in one command to avoid asking multiple times for password
# List of programs:
# - Vivaldi browser
# - ncspot (CLI version of Spotify)
# - Twemoji (emoji font)
# - Hyper (terminal)
pamac build --no-confirm vivaldi vivaldi-widevine vivaldi-codecs-ffmpeg-extra-bin ttf-twemoji hyper

# Remove palemoon (default browser)
sudo pacman -R palemoon-bin

# i3 config
link i3-config "$HOME/.i3/config"

# SSH config
link ssh-config "$HOME/.ssh/config"

# Install snapcraft
sudo pamac install --no-confirm snapd
sudo systemctl enable --now snapd.socket

# Install snap packages
sudo snap install code --classic
code --install-extension Shan.code-settings-sync --force
echo "Do not forget to open VS Code and use the Settings Sync extension to finish the editor setup\!"
sudo snap install wormhole
sudo snap install cordless

# Install emacs + spacemacs
sudo pamac install --no-confirm emacs
rm -rf ~/.emacs.d
git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d

# Install Discord
sudo pamac install --no-confirm discord

# Install hub
sudo pamac install --no-confirm hub

# Install Thunderbird
sudo pamac install --no-confirm thunderbird

# Install Flameshot
sudo pamac install --no-confirm flameshot

# Install Spotify
sudo snap install spotify

# Symlink Twemoji and to enable it
sudo ln -sf ../conf.avail/75-twemoji.conf /etc/fonts/conf.d/75-twemoji.conf

# Install Node.JS, npm and yarn (both installed by NodeSource)
sudo snap install node --classic --channel=13 # Installs Node.JS 13.X (channel 13)
# To switch from node channel, use:
# sudo snap refresh node --channel=10 # To switch to channel 10
# Export npm global bin dir in .profile if the line does not already exists
grep -qxF 'export PATH=~/.npm-global/bin:$PATH' ~/.profile || echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.profile

# Install trash-cli
sudo pamac install --no-confirm trash-cli

# Install playctl to play/pause/skip music from Spotify and others
sudo pamac install --no-confirm playerctl

# Install xev (cli tool used to display xevent keys names, such as media keys)
sudo pamac install --no-confirm xorg-xev

# Install Rofi
sudo pamac install --no-confirm rofi
mkdir "$HOME/.config/rofi"
link rofi/config "$HOME/.config/rofi/config"
link rofi/fullscreen.rasi "$HOME/.config/rofi/fullscreen.rasi"

# Install zsh
sudo pamac install --no-confirm zsh
# Install Kitty shell
#sudo pamac install --no-confirm kitty
# Install Alacritty (better than Kitty)
sudo pamac install --no-confirm alacritty

# Install Fire Code font
sudo pamac install --no-confirm ttf-fira-code

link .zshrc
# Install Kitty plugins and themes
curl -o ~/.config/kitty/snazzy.conf https://raw.githubusercontent.com/connorholyday/kitty-snazzy/master/snazzy.conf
sudo pamac install zsh-syntax-highlighting zsh-autosuggestions --no-confirm
# Link Kitty config file
link kitty.conf "$HOME/.config/kitty/kitty.conf"

# Export terminal name in .profile if the line does not already exists
grep -qxF 'export TERMINAL="kitty"' ~/.profile || echo 'export TERMINAL="kitty"' >> ~/.profile

# Install yarn global packages
# Pure-prompt for sh
#sudo npm install --global pure-prompt
yarn global add pure-prompt

# Change default shell to zsh
chsh -s $(which zsh)

# At the end, remove all orphans
sudo pamac remove -o --no-confirm
