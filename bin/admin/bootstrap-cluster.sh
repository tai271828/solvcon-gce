#!/bin/bash

build_master_node() {
  echo "building a master node..."
  # fetch SOLVCON source
  if [ -z "$1" ]; then
    parallel_working_dir_name="solvcon-remote"
  else
    parallel_working_dir_name=$1
  fi
  echo "working dir: $parallel_working_dir_name"
  parallel_working_dir=$HOME/$parallel_working_dir_name
  git clone https://github.com/solvcon/solvcon.git $parallel_working_dir/solvcon-src
  # make this node be a NFS server
  build_nfs_server $parallel_working_dir
  # build SSH key configuration to establish connection
  ssh-keygen -t rsa -f ~/.ssh/id_rsa -N "" -q
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

  echo "building a master node...done!"
}

build_client_node() {
  echo "building a client node..."

  if [ -z "$1" ]; then
    echo "No master IP specified when the node_type is client."
    echo $usage
    exit
  else
    master_ip=$1
  fi

  if [ -z "$2" ]; then
    parallel_working_dir_name="solvcon-remote"
  else
    parallel_working_dir_name=$2
  fi

  echo "working dir: $parallel_working_dir_name"

  sudo apt-get install nfs-client -y
  # Against SOLVCON, this does not need to be touched
  # because SOLVCON use its own node list
  #echo "`hostname -i` `hostname`" | sudo tee -a /etc/hosts

  parallel_working_dir=$HOME/$parallel_working_dir_name
  mkdir $parallel_working_dir
  sudo mount $master_ip:$parallel_working_dir $parallel_working_dir
  sudo mount $master_ip:$HOME/.ssh $HOME/.ssh
  solvcon_nodelist=$parallel_working_dir/node_list
  hostname -i >> $solvcon_nodelist
  # client node should install necessary package as well
  $parallel_working_dir/solvcon-src/contrib/conda.sh
  echo "building a client node...done!"
}

build_nfs_server() {
  parallel_working_dir=$1
  # build a NFS server
  echo "building a NFS server..."

  # enable NFS service
  echo "installing necessary packages for a NFS server..."
  sudo apt-get install nfs-kernel-server -y

  echo "configurating the NFS server..."
  echo "$parallel_working_dir *(rw,sync)" | sudo tee -a /etc/exports
  # share SSH connection information
  echo "$HOME/.ssh *(rw,sync)" | sudo tee -a /etc/exports
  sudo service nfs-kernel-server restart
  echo "building a NFS server...done!"
}

usage="Usage : $0 <node_type>"
usage="$usage\n node_type: master, client, nfs_server"

node_type=$1
shift
if [ -z "$node_type" ]
then
  echo $usage
  exit
fi

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
  -d|--dir-name)
  dir_name="$2"
  shift
  ;;
  -i|--ip-address)
  master_ip="$2"
  shift
  ;;
  -h|--help)
  help="1"
  ;;
  *)
  # unknown option
  echo "uknown option"
  echo $usage
  exit
  ;;
esac
shift # past argument or value
done

case $node_type in
  master)
  build_master_node $dir_name
  ;;
  client)
  build_client_node $master_ip $dir_name
  ;;
  nfs_server)
  build_nfs_server
  ;;
  *)
  # unknown node_type
  echo "unknown node_type"
  echo $usage
  exit
  ;;
esac

if [ -n "$help" ]; then
  echo $usage
  exit
fi

# vim: set et nobomb fenc=utf8 ft=sh ff=unix sw=2 ts=2:
