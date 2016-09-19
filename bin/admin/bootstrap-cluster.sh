#!/bin/bash

usage_description() {
  cat << EOM

  This script is the basic component to bootstrap GCE instances to be a
  very simple Beowulf cluster. Besides, this cluster could be used for
  SOLVCON parallel computing with this bootstrap script. This commit is
  the 1st step of the whole story of the issue #10. Wrappers to use this
  bootstrap script will follow up in the later commits.

  Test Case

  1. gstart <master_node> to create a master node of our Beowulf cluster.

  2. gstart <client_node_01> to create a client node of our Beowulf cluster.

  3. gstart <client_node_02> to create another client node of our Beowulf
  cluster.

  4. gssh <master_node> to login <master_node>, and then issue
  ./opt/gce/bin/admin/bootstrap-cluster.sh master to make this node be a NFS
  server node, which will be a master node of our Beowulf cluster. Issue the
  command hostname -i to get <master_node_IP>, which is the IP address we will
  use when creating the other NFS client nodes.[1]

  5. gssh <client_node_01> to login <client_node_01>, and then issue
  ./opt/gce/bin/admin/bootstrap-cluster.sh client <master_node_IP> to make this
  node be a NFS client node, which will be a client node of our Beowulf
  cluster. <master_node_IP> could be known by the above step.[2]

  6. go to ~/solvcon-remote/solvcon-src in <client_node_01>, issue source
  activate to enable Conda environment, and then issue python setup.py
  build_ext --inplace to build SOLVCON.

  7. gssh <client_node_02> to login <client_node_02>, and then issue
  ./opt/gce/bin/admin/bootstrap-cluster.sh client <master_node_IP> to make this
  node be a NFS client node, which will be a client node of our Beowulf
  cluster. <master_node_IP> could be known by the above step.[2]

  8. go back to login <client_node_01>, and then export
  SOLVCON_NODELIST=~/solvcon-remote/node_list to tell SOLVCON where to find the
  available cluster nodes for parallel computing.

  9. run nosetests ftests/parallel/test_remote.py -v to test the cluster.[3]
  Please note this commit should be tested together with some customized setup
  according your github repository and branch name. Please refer to this commit
  5dc868b to create your test case branch as well.

  Expected Result

  [1] A default SOLVCON working directory, $HOME/solvcon-remote will be
  created, and set up as a NFS folder. Besides, $HOME/.ssh will be set up as a
  NFS folder as well to share the connection SSH key. Check the NFS setup is as
  expected by issuing cat cat /etc/exports, and the output should has lines
  like:

  /home/tai271828/solvcon-remote *(rw,sync)
  /home/tai271828/.ssh *(rw,sync)

  [2] A default SOLVCON node list will be created (or appended IP if there is
  one or more nodes already). Check ~/solvcon-remote/node_list to make sure the
  IP of the node is appended in the node list.

  [3] The test result should be

  test_dsoln_and_parallel_output (test_remote.TestPresplitRemoteParallel) ... SKIP
  test_dsoln (test_remote.TestRemoteParallel) ... ok
  test_dsoln_cluster (test_remote.TestRemoteParallel) ... ok
  test_runparallel (test_remote.TestTorqueParallel) ... SKIP

  ----------------------------------------------------------------------
  Ran 4 tests in 11.318s

  OK (SKIP=2)

EOM
}

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

usage="Usage : $0 <node_type>\n"
usage="${usage}\tnode_type: master, client, nfs_server\n"

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
  usage_description
  printf "$usage"
  exit
  ;;
  *)
  # unknown option
  echo "uknown option"
  printf "$usage"
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
  printf "$usage"
  exit
  ;;
esac

# vim: set et nobomb fenc=utf8 ft=sh ff=unix sw=2 ts=2:
