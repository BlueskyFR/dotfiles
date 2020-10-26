update = sudo pacman -Syy
upgrade = sudo pacman -Syyu # With update included
search = sudo pacman -Ss $@
install = sudo pacman -Syy $@
remove = sudo pacman -R $@
purge = sudo pacman -Rns $@
autoremove = sudo pacman -Rns $(pacman -Qtdq)