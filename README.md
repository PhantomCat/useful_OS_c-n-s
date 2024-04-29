# Useful linux scripts

## Samba
- [Clean all samba database files (if you're experimenting with AD membership in samba)](samba/ad/clean_all_bd.sh)

## bash

To make your bash looks awesome you don't need to use zsh with 1001 stories (I know, it's powerfull and handy, but if the point only in good-looking then why?)
open your .bashrc file with your favorite editor (I bet - it's vim!) and change the PS1 string to look like this:
```bash
PS1='${debian_chroot:+($debian_chroot)}\[\033[42m\033[02;30m\]\u\033[43m@\h\[\033[00m\]\[\033[01;44m\]:\w\[\033[00m\]$(__git_ps1)\n└─ $ '
```
then save it and run the command:
```bash
source ~/.bashrc
```
It will be represented like this:

![shining_bash.png](screenshots/shining_bash.png)

yeah, it also shows a git branch if the directory is a git repository
