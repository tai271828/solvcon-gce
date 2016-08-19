#!/bin/bash
if [ $# -lt 1 ]
then
    echo "Usage : $0 <solvcon env configuration file>"
    exit
fi
solvcon_env_file=$1
git clone https://github.com/solvcon/solvcon.git

# you never know the env is ready to use SOLVCON or not, so
# enable the env anyway.
source $solvcon_env_file
# basic env
export SCSRC=$HOME/solvcon
# prepare the ssh configuration to test rpc features on the localhost
ssh-keygen -t rsa -f ~/.ssh/id_rsa -N "" -q
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
ssh-keyscan -t rsa localhost >> ~/.ssh/known_hosts

# make sure that everything are installed.
$HOME/solvcon/contrib/conda.sh

# lets build
cd $SCSRC
python setup.py install
python setup.py build_ext --inplace

# perform basic tests
cd $SCSRC
nosetests
nosetests ftests/parallel/

# vim: set et nobomb fenc=utf8 ft=sh ff=unix sw=2 ts=2:
