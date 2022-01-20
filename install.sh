#!/bin/bash
set -e

# Check if current user is root
if [ $(id -u) = 0 ]; then
	echo "You cannot be root to run this script!"
	exit 1
fi

# Symlink helper
link() {
    local src="$(realpath $1)"
    local dst=${2:-"$HOME/$1"} # Defaults to $HOME if only 1 arg is supplied
    [ -d $dst ] && rm -r $dst # If $dst is a directory, remove it to replace it with a symlink
    ln -sf $src $dst
}

link_root() {
    local src="$(realpath $1)"
    local dst=${2:-"$HOME/$1"} # Defaults to $HOME if only 1 arg is supplied
    [ -d $dst ] && rm -r $dst # If $dst is a directory, remove it to replace it with a symlink
    sudo ln -sf $src $dst
}

clear
echo "Welcome to HugoCorp installer! :D"
echo
sleep 2

echo "Before running this script, please install basic stuff such as networking (networkmanager) and install the video drivers"
echo "you want (for example xf86-video-intel, mesa and nvidia + nvidia-prime on a laptop), and then ONLY run this script."
echo "Also install the amd-ucode or intel-ucode package depending on you CPU to update the CPU microcode during Kernel's early loading phase."
echo
read -p "Press enter to continue!"
echo
echo
echo Here is your current video configuration:
echo
lspci -k | grep -A 2 -E "(VGA|3D)"
echo
read -p "Make sure you are happy with it or cancel with ctrl+c. Press enter to begin the installation!"
clear

# Run full system update
echo "Running a full system update, because some stuff may break if it is not the latest version..."
sudo pacman --noconfirm -Syu

echo "###########################################################################"
echo "HUGOCORP INSTALLER"
echo "###########################################################################"
echo
echo "# [1/3] Basic components"
echo

# Install base-devel if not installed
echo "Installing base-devel, wget, curl and git..."
sudo pacman -S --noconfirm --needed base-devel wget curl git

# Install xorg if not installed
echo "Installing xorg, xmonad and some basic tools..."
sudo pacman -S --noconfirm --needed rofi feh xorg xorg-xinit xorg-xinput xmonad

# Install fonts
echo "Installing fonts..."
mkdir -p ~/.local/share/fonts

cp -r ./fonts/* ~/.local/share/fonts/
fc-cache -f

# Install yay (AUR helper)
echo "Installing yay (AUR helper)..."
git clone https://aur.archlinux.org/yay.git ~/yay
(cd ~/yay/ && makepkg -si)
rm -rf ~/yay

echo "Now installing a lot of stuff! :D"
yay -S --removemake --noeditmenu --nodiffmenu --noconfirm \
       picom-jonaburg-git\
       acpi              \
       candy-icons-git   \
       wmctrl            \
       alacritty         \
       playerctl         \
       dunst             \
       xmonad-contrib    \
       jq                \
       xclip             \
       maim              \
       rofi-greenclip    \
       xautolock         \
       betterlockscreen

echo
echo "# [2/3] Config files + scripts"
echo

# Install custom picom config file
mkdir -p ~/.config/
    echo "Installing rofi configs..."
    link ./config/rofi ~/.config/rofi
    
    EWW_DIR='config/eww-1920'
    echo "Installing eww configs..."
    link ./$EWW_DIR ~/.config/eww
    
    echo "Installing picom configs..."
    link ./config/picom.conf ~/.config/picom.conf
    
    echo "Installing alacritty configs..."
    link ./config/alacritty.yml ~/.config/alacritty.yml
    
    echo "Installing dunst configs..."
    link ./config/dunst ~/.config/dunst
    
    echo "Installing wallpapers..."
    link ./wallpapers ~/wallpapers
    
    echo "Installing tint2 configs..."
    link ./config/tint2 ~/.config/tint2
    
    echo "Installing xmonad configs..."
    link ./xmonad ~/.xmonad
    
    echo "Installing bin scripts..."
    link ./bin ~/bin
    SHELLNAME=$(echo $SHELL | grep -o '[^/]*$')
    case $SHELLNAME in
        bash)
            echo "Adding $HOME/bin to your PATH..."
            echo "export PATH=\$PATH:\$HOME/bin" >> $HOME/.bashrc
            ;;

        zsh)
            echo "Adding $HOME/bin to your PATH..."
            echo "export PATH=\$PATH:\$HOME/bin" >> $HOME/.zshrc
            ;;
    
        fish)
            echo "Adding $HOME/bin to your PATH..."
            fish -c fish_add_path -P $HOME/bin
            ;;

        *)
            echo "Please add: export PATH='\$PATH:$HOME/bin' to your .bashrc or whatever shell you use."
            echo "If you know how to add stuff to shells other than bash, zsh and fish please help out here!"
    esac

echo
echo "[3/3] Additional packages"
echo

# Install essential packages, following HugoCorp strategies
echo "Installing many other packages..."
yay -S --removemake --noeditmenu --nodiffmenu --noconfirm \
       visual-studio-code-bin \
       github-cli \
       trash-cli \
       flameshot \
       discord \
       vivaldi vivaldi-widevine vivaldi-update-ffmpeg-hook \
       ttf-twemoji \
       spotify

# Login screen / Display manager + theme
echo "Installing sddm (display manager)..."
yay -S --removemake --noeditmenu --nodiffmenu --noconfirm sddm sddm-sugar-candy-git
sudo systemctl enable sddm
echo "Installing sddm config file..."
sudo mkdir -p /etc/sddm.conf.d
link_root ./config/sddm.conf /etc/sddm.conf.d/sddm.conf

# Done
echo
echo
echo "Done!"
echo
echo "PLEASE MAKE .xinitrc TO LAUNCH, or just use your Display Manager (i.e. lightdm or sddm, etc.)" | tee ~/Note.txt
printf "\n" >> ~/Note.txt
echo "For startpage, copy the startpage directory into wherever you want, and set it as new tab in firefox settings." | tee -a ~/Note.txt
echo "For more info on startpage (Which is a fork of Prismatic Night), visit https://github.com/dbuxy218/Prismatic-Night#Firefoxtheme" | tee -a ~/Note.txt
echo "ALL DONE! Reboot for all changes to take place!" | tee -a ~/Note.txt
echo "Install Museo Sans as well. Frome Adobe I believe." | tee -a ~/Note.txt
echo "If the bar doesn't work, use tint2conf and set stuff up, if you're hopelessly lost, open an issue." | tee -a ~/Note.txt
echo "These instructions have been saved to ~/Note.txt. Make sure to go through them."
sleep 5
xmonad --recompile
