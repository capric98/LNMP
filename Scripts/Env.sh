#!/bin/bash
sed -i "/PS1='$/d" ~/.bashrc
echo "TZ='Asia/Shanghai'; export TZ" >> ~/.bashrc
echo "PS1='\${debian_chroot:+($debian_chroot)}\[\e[1;31m\]\u\[\e[1;33m\]@\[\e[1;36m\]\h \[\e[1;33m\]\w \[\e[1;35m\]\\\$ \[\e[0m\]'" >> ~/.bashrc

mkdir -p ~/.ssh
touch ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 644 ~/.ssh/authorized_keys

echo -e "set mouse-=a
set number
\" Highlighting
syntax on
colorscheme slate
\" Remember Cursor
if has(\"autocmd\")
  au BufReadPost * if line(\"'\\\"\") > 1 && line(\"'\\\"\") <= line(\"$\") | exe \"normal! g'\\\"\" | endif
endif" > ~/.vimrc
