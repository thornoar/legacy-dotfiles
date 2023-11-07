export PATH=$HOME/projects/scripts:$PATH
export NVIM_LISTEN_ADDRESS=/tmp/nvimsocket
export ZDOTDIR="$HOME/.config/zsh"
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CACHE_HOME=$HOME/.cache
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export ZSH="$XDG_DATA_HOME"/oh-my-zsh
export HISTFILE=/home/ramak/.config/zsh/.zhistory

# File and Dir colors for ls and other outputs
export LS_OPTIONS='--color=auto'
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-R

export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="firefox"
export READER="zathura"
