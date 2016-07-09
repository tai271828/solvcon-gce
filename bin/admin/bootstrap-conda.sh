#!/bin/bash

workdir=$(mktemp -d -t conda.install.XXXXXXXXXX) || exit
cd $workdir
echo "working in $workdir ..."

pkgdir=/var/lib/conda/packages/

if [[ `which conda` != "${HOME}/opt/conda3/bin/conda" ]]; then
  bash $pkgdir/Miniconda3-latest-Linux-x86_64.sh -b -p ${HOME}/opt/conda3
  PATH=${HOME}/opt/conda3/bin:$PATH
  conda config --system --add channels file:///var/lib/conda/packages
fi

if [[ `which conda` != "${HOME}/opt/conda2/bin/conda" ]]; then
  bash $pkgdir/Miniconda2-latest-Linux-x86_64.sh -b -p ${HOME}/opt/conda2
  PATH=${HOME}/opt/conda2/bin:$PATH
  conda config --system --add channels file:///var/lib/conda/packages
fi

# vim: set et nobomb fenc=utf8 ft=sh ff=unix sw=2 ts=2:
