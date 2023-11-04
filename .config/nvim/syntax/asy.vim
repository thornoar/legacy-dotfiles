" Vim syntax file
" Language:     Asymptote
" Maintainer:   Andy Hammerlindl
" Last Change:  2022 Jan 05

if version < 600
  syn clear
elseif exists("b:current_syntax")
  finish
endif

source /home/ramak/.config/nvim/syntax/asysyn.vim

let b:current_syntax = "asy"
