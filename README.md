# FlyBrainLab-OOD

## Introduction

FlyBrainLab is a multi-component tool for neuroanatomic exploration and model simulation. It offers [...].

However, FBL is a relatively heavy application, with several gigabytes of files needing to be installed. FBL-OOD solves this issue by moving the burden of storage off of personal computers and onto organization-wide servers. It orchestrates a centralized architecture that consists of "login" nodes and "gpu" nodes.

Given it's formulation, FBL-OOD is suitable for organizations with access to servers.

## Setup

For this setup, we will assume that there are 3 types of nodes: setup, login, and gpu, and that deepops has been configured on the setup node such that it can access all login and gpu nodes. See below for information about how to set up these nodes on AWS, and the hardware requirements for each node.

Note that these nodes are arbitrary (through they must have Ubuntu 20), so they could all be the same server.

### Download DeepOps

Log into the setup node and execute the following command from the `$HOME` directory

```console
git clone https://github.com/jonmarty/deepops-fbl-ood
```

This will install the modified deepops directory that works with FBL-OOD (deepops is a tool for building GPU clusters, we use it because FBL-OOD runs on top of a GPU cluster). Now, we'll run the setup script for deepops.

```console
cd deepops-fbl-ood
./scripts/setup.sh
```

### Configure DeepOps

We now have deepops on our computer, but it knows nothing about our server configuration. Looking over the `deepops-fbl-ood directory`, you will notice a new `config` directory. It contains a `config/inventory` file, where we can input our server configuration. There's a lot in this file, but we're only interested in `[all]`, `[slurm-master]` and `[slurm-node]`. Under `[all]` add the following line for the login node

```console
login01 ansible_host=IP
```

replacing `IP` with the IPv4 address of your node. Note that if your nodes do not lie in the same local network, you will need to use a public IP. In the same way, add the following line for the gpu nodes

```console
gpuNUM ansible_host=IP
```

replacing `IP` with the IPv4 address of the GPU node and `NUM` with a different number for each gpu node. I would recommend the sequence `gpu01`, `gpu02`, etc. Note that it doesn't really matter what you call any of your nodes, but I find this naming scheme is best for organization.

Now, put the name of your login node in the line under `[slurm-master]` and, in seperate lines, put the names of your gpu nodes under `[slurm-node]`.

Now, make sure all of your nodes (login and gpu) have a common ssh private key file that can be used to access them. (for amazon, see TODO, for a private setup, see TODO) As well as a common username (which corresponds to a user with sudo privileges).

Now, under `[all:vars]`, specify

```console
ansible_user=COMMON-USERNAME
ansible_ssh_private_key_file=PRIVATE-KEY-FILE
```

making sure that the private key file is on the setup node and that `PRIVATE-KEY-FILE` is its full path (not relative, and do not have `~` as a shorthand).

Now, deepops can access all of our nodes.

### Options

If you would like to use SSL to encrypt web traffic to and from your login node, specify the following in `config/group_vars/slurm-cluster.yml`

```console
ood_use_ssl: yes
```

Additionally, make sure your certificate file and certificate file key are located on your setup node and specify

```console
ood_ssl_certificate: CERTIFICATE-FILE
ood_ssl_certificate_key: CERTIFICATE-KEY-FILE
```

If you would like to use CAS, TODO

### Run DeepOps

Now, we will apply our configuration over 
