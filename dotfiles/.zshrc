# Lines configured by zsh-newuser-install
HISTFILE=~/.history
HISTSIZE=1000
SAVEHIST=10000
setopt autocd nomatch
unsetopt beep
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/hugo/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    alias dir='ls --color=auto --format=vertical'
    alias vdir='ls --color=auto --format=long'
fi

##################### CONFIGURE KEYS #####################
# See https://wiki.archlinux.org/index.php/Zsh#Key_bindings for details.

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"      beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"       end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"    overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}" backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"    delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"        up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"      down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"      backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"     forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"    beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"  end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}" reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search

key[Control-Left]="${terminfo[kLFT5]}"
key[Control-Right]="${terminfo[kRIT5]}"

[[ -n "${key[Control-Left]}"  ]] && bindkey -- "${key[Control-Left]}"  backward-word
[[ -n "${key[Control-Right]}" ]] && bindkey -- "${key[Control-Right]}" forward-word
##################### CONFIGURE KEYS END #####################

##################### CUSTOM ALIASES #####################
alias ll='ls -lArth  --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

alias ssh='TERM=xterm-256color ssh'

alias sshk='ssh luc@knowledge.univ-savoie.fr'
alias ssho='ssh luc@ontology.univ-savoie.fr'
alias sshb='ssh ldama@10.103.1.200'
alias sshd='ssh ldama@10.103.1.201'
alias sshl='ssh u79607323@home559055689.1and1-data.host'
alias sky='ssh hugo@sky'
alias lsky='ssh hugo@lsky'
alias cosmos='ssh cosmos'
alias lcosmos='ssh lcosmos'
alias lc='ssh lc'
alias hpe='ssh hpe'
alias monit='ssh monit'
alias projet='ssh projet@cosmos'
alias clip='xclip -selection clipboard'
alias padon='synclient TouchpadOff=0'
alias padoff='synclient TouchpadOff=1'
alias touchpad='sudo modprobe -r  elan_i2c && sudo modprobe elan_i2c'
#alias e='emacs -nw'
alias e='exit'
alias response-time="curl -s -w 'Testing Website Response Time for :%{url_effective}\n\nLookup Time:\t\t%{time_namelookup}\nConnect Time:\t\t%{time_connect}\nPre-transfer Time:\t%{time_pretransfer}\nStart-transfer Time:\t%{time_starttransfer}\n\nTotal Time:\t\t%{time_total}\n' -o /dev/null"
alias response-time-s="curl -s -w 'Testing Website Response Time for :%{url_effective}\n\nLookup Time:\t\t%{time_namelookup}\nConnect Time:\t\t%{time_connect}\nAppCon Time:\t\t%{time_appconnect}\nRedirect Time:\t\t%{time_redirect}\nPre-transfer Time:\t%{time_pretransfer}\nStart-transfer Time:\t%{time_starttransfer}\n\nTotal Time:\t\t%{time_total}\n' -o /dev/null"
alias ca='conda activate'

alias rm='trash'
alias i3config='vim ~/.i3/config'
alias code='cd ~/code/'
alias arm='sudo apt autoremove -y'
alias c='clear'
alias autobalance='amixer -D pulse set Master 20%'
alias rc='killall compton && compton --config /home/hugo/.config/compton.conf -b'
alias ip='ip -c a'
alias poule='git pull'
alias radio='bash ~/code/bash/radio.sh'

alias conso='node ~/code/nodejs/ssl-legit/red-conso.js'
alias izly='node ~/code/nodejs/ssl-legit/izly.js'
alias revolut='node ~/code/nodejs/ssl-legit/revolut.js'

alias bundletool='java -jar ~/code/android/bundletool-all-0.10.2.jar'

alias rs='systemctl --user restart spotifyd'

alias pip-upgrade-all='pip list --outdated --format=freeze | grep -v "^\-e" | cut -d = -f 1  | xargs -n1 pip install -U'

# Screens configurations
alias shpe='bash /home/hugo/.screenlayout/vertical-2k.sh'
alias sv='bash /home/hugo/.screenlayout/vertical.sh'
alias sn='bash /home/hugo/.screenlayout/normal.sh'

mdd() {
    mkdir -p "$@"
    cd "$@"
}

cd() { builtin cd "$@" && ls; }

cssh() { infocmp alacritty | ssh "$@" tic -x -o \~/.terminfo /dev/stdin }

alias vpn='sudo openconnect vpn.univ-smb.fr'
alias mountp='sudo mount -v -t cifs //srv-data2.iut-acy.local/home/etudiants/cartignh /media/p/ -o credentials=/home/hugo/.iut-creds.crd,domain=iut-acy.local,vers=1.0'
alias mountu='sudo mount -v -t cifs //srv-data2.iut-acy.local/public /media/u/ -o credentials=/home/hugo/.iut-creds.crd,domain=iut-acy.local,vers=1.0'
alias mountw='sudo mount -v -t cifs //srv-peda.iut-acy.local/www/cartignh /media/w/ -o credentials=/home/hugo/.iut-creds.crd,domain=iut-acy.local,vers=1.0'
alias mountall='mountp && mountu && mountw'
alias umountall='sudo umount -f /media/p && sudo umount -f /media/u && sudo umount -f /media/w'
##################### CUSTOM ALIASES END #####################

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-autosuggestions config (tab key modifier)
bindkey '^I' autosuggest-accept
ZSH_AUTOSUGGEST_STRATEGY=(completion history)

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

fpath=("$HOME/.config/yarn/global/node_modules/pure-prompt/functions" "$fpath[@]")
autoload -Uz promptinit
promptinit
prompt pure

# Fix for "maximum nested function level reached" is to leave this line at the end as per my tests
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

