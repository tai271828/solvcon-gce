#!/bin/bash

repotype=${1:-http}
if [ "$repotype" == http ] ; then
  repo=http://github.com/solvcon/solvcon-gce
elif [ "$repotype" == ssh ] ; then
  repo=ssh://git@github.com/solvcon/solvcon-gce
else
  echo "Usage: `basename $0` [http|ssh]"
  exit
fi

target=$HOME/opt/gce
mkdir -p $target
git clone $repo $target

acctfile=~/.bash_acct
enablestring='if [ -f ~/opt/gce/etc/gcerc ]; then source ~/opt/gce/etc/gcerc; fi'
echo $enablestring >> $acctfile

# vim: set et nobomb fenc=utf8 ft=sh ff=unix sw=2 ts=2:
