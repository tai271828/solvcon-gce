#!/bin/bash

# bootstrap bash.
wscript=$(mktemp -t bash.bootstrap.XXXXXXXXXX) || exit
wget -q -O $wscript https://raw.githubusercontent.com/yungyuc/workspace/master/bin/admin/bootstrap-workspace.sh
echo "bootstrapping bash using $wscript ..."
bash $wscript

# now bootstrap GCE.
repotype=${1:-http}
if [ "$repotype" == http ] ; then
  repo=http://github.com/solvcon/solvcon-gce
elif [ "$repotype" == ssh ] ; then
  repo=ssh://git@github.com/solvcon/solvcon-gce
else
  echo "Usage: `basename $0` [http|ssh]"
  exit
fi

echo "bootstrapping GCE from $repo ..."
target=$HOME/opt/gce
mkdir -p $target
git clone $repo $target

echo "write to ~/.bash_acct ..."
acctfile=~/.bash_acct
enablestring="if [ -f $target/etc/gcerc ]; then source $target/etc/gcerc; fi"
echo $enablestring >> $acctfile

# install conda.
echo "install conda with Python 3 and 2 ..."
$HOME/opt/gce/bin/admin/install-conda.sh

# get ready to use SOLVCON
echo "building SOLVCON..."
$HOME/opt/gce/bin/admin/install-solvcon.sh $acctfile

# vim: set et nobomb fenc=utf8 ft=sh ff=unix sw=2 ts=2:
