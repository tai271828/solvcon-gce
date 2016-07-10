# SOLVCON Shell Environment in Google Compute Engine

This repository sets up the bash environment for running [SOLVCON](http://solvcon.net/) in [Google Compute Engine (GCE)](https://cloud.google.com/compute/).  It provides tools for creating, provisioning, and accessing virtual-machine (VM) intances in GCE.  Clone the repository to install:

```bash
$ git clone http://github.com/solvcon/solvcon-gce ~/opt/gce
```

To enable it, run `source ~/etc/gcerc`.  Append the following line in ``.bashrc`` to enable it automatically:

```bash
if [ -f ~/etc/gcerc ]; then source ~/etc/gcerc; fi
```

## Set up Google Cloud Platform SDK

`solvcon-gce` are essentially wrappers to [Google Cloud Platform (GCP) SDK](https://cloud.google.com/sdk/) command-line tool.  `solvcon-gce` will try to load the SDK from `~/opt/google-cloud-sdk`.  If it's not there and not in `PATH`, you can install it (to the assumed path) using the following script:

```bash
~/opt/gce/bin/admin/install-google-cloud-sdk.sh
```

## Setup a Project

Before using `solvcon-gce` scripts, you need to sign up the GCE service and create a [project](https://cloud.google.com/compute/docs/projects), and initialize the cloud SDK by running `gcloud init`.  See https://cloud.google.com/sdk/docs/.  After a project is created, you also need to do the following setup in the [Google Compute Platform console](https://console.cloud.google.com):

1. [Enable "Compute Engine API"](https://console.cloud.google.com/apis/).
2. [Add a project-wide SSH key](https://console.cloud.google.com/compute/metadata/sshKeys).  Accounts logged into the GCE instance using a project-side SSH key can run `sudo` in the instance.

(GCP offers a 60-day free-trial program, including $300 credits: https://cloud.google.com/free-trial/.)

## Use an Instance

Run `gstart <instance_name>` to create a GCE VM instance.  It usually takes 2 minutes.  `gstart` also runs the provisioning scripts.

After `gstart` finishes, run `gssh <instance_name>` to connect to the instance.

To remove the instance (and stops being charged), run `gce-delete-instance <instance_name>`.

## Cache Conda Packages

To save time from downloading conda packages from the Anaconda server, `solvcon-gce` provides a script to make a local cache in [Google Cloud Storage](https://cloud.google.com/storage) bucket:

```bash
$ gce-prepare-conda-packages <bucket_name>
```

You need to create the bucket first.  Please note that the bucket should be created in the same zone of the `solvcon-gce` tools assume, otherwise additional charges may incur.  For now it is `asia-east1-c`.
