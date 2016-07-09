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

scratch=$(mktemp -d -t tmp.XXXXXXXXXX) || exit
rm -rf $scratch/*
git clone $repo $scratch
mv $scratch/.git ~/
git checkout -- .

# vim: set et nobomb fenc=utf8 ft=sh ff=unix sw=2 ts=2:
