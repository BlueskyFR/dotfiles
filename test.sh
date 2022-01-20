link_root() {
    local src="$(realpath $1)"
    local dst=${2:-"$HOME/$1"} # Defaults to $HOME if only 1 arg is supplied
    [ -d $dst ] && rm -r $dst # If $dst is a directory, remove it to replace it with a symlink
    sudo ln -sf $src $dst
}



echo "Installing sddm (display manager)..."
yay -S --removemake --noeditmenu --nodiffmenu --noconfirm sddm sddm-sugar-candy-git
sudo systemctl enable sddm
echo "Installing sddm config file..."
sudo mkdir -p /etc/sddm.conf.d
link_root ./config/sddm.conf /etc/sddm.conf.d/sddm.conf


