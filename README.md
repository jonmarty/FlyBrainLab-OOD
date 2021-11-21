# FlyBrainLab-OOD

## Introduction

FlyBrainLab provides an environment where computational researchers can present configurable, executable neural circuits, and experimental scientists can interactively explore circuit structure and function ultimately leading to biological validation. However, FBL is a relatively heavy application, with several gigabytes of files needing to be installed. FBL-OOD solves this issue by moving the burden of storage off of personal computers and onto organization-wide servers. It orchestrates a centralized architecture that consists of "login" nodes and "gpu" nodes.

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

Now, make sure all of your nodes (login and gpu) have a common ssh private key file that can be used to access them. (for amazon, see "Setting up nodes on Amazon AWS" in the Appendix, for a private setup, see "Setting up nodes on physical servers" in the Appendix) As well as a common username (which corresponds to a user with sudo privileges).

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

If you would like to use CAS to handle logins, please set the following option in `config/group_vars/slurm-cluster.yml`

```console
ood_use_cas: yes
```

Next, you will need to set TODO

### Run DeepOps

Navigate to the root of the `deepops-fbl-ood` directory.

First, run the following command to make sure all our nodes are accounted for (we can access them)

```console
ansible all -m raw -a "hostname"
```

Next, we apply our configuration

```console
ansible-playbook -l slurm-cluster playbooks/slurm-cluster.yml
```

This should take around 15-30 minutes. That's the full setup process.

## Appendix

### Setting up nodes on Amazon AWS

In order to set up FBL-OOD on AWS you will need to create `setup`, `login`, and `gpu` nodes. 

#### Setup Node

For the setup node, any node type will work, so I'd advise going with a free-tier option.

#### Login Node

For the login node, make sure there is at least 32 GB of space on the instance. Additionally, make sure it can be accessed on any web ports you're interested in, on top of port 22 for SSH. The most generic options would be 80 if you're not using SSL and 443 if you are.

#### GPU Node

For the gpu node, make sure there is at least 128 GB of space on the instance. Also, choose a node type which has access to at least 1 GPU.

When you launch your AWS instances, you will see that an IP is assigned to them. This IP is different with each launch, which messes with the setup. As such, you will need to assign a more permanent IP to these nodes. If you have access to your own pool of IPs, you can look on AWS for how to use these. Otherwise, you can allocate one of Amazon's Public IPs using as an Elastic IP. See [] for further details.

Finally, this whole setup process can be rather buggy, and sometimes your `login` or `gpu` nodes will stop working properly. However, because the setup of these nodes is fully determined by your `setup` node's configuration, you can erase them and start over. To do this, select your node in the EC2 instances screen, click `Actions -> Monitor and Troubleshoot -> Replace root volume`.

### Setting up nodes on physical servers

TODO

### Adding and Removing Users

In order to add or remove users, I have provided a set of utility playbooks under playbooks/fbl-ood. In order to add an fbl user, run

```console
ansible-playbook playbooks/fbl-ood/add-fbl-user --extra-vars="user=USER password=PASSWORD new_user=yes/no"
```

To remove an fbl user

```console
ansible-playbook playbooks/fbl-ood/rm-fbl-user --extra-vars="user=USER"
```

To list existing fbl users

```console
ansible-playbook playbooks/fbl-ood/list-fbl-users
```
