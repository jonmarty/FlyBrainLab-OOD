# FlyBrainLab-OOD

## Introduction

FlyBrainLab is a multi-component tool for neuroanatomic exploration and model simulation. It offers [...].

However, FBL is a relatively heavy application, with several gigabytes of files needing to be installed. FBL-OOD solves this issue by moving the burden of storage off of personal computers and onto organization-wide servers. It orchestrates a centralized architecture that consists of "login" nodes and "gpu" nodes.

Given it's formulation, FBL-OOD is suitable for organizations with access to servers.

## Setup

For this setup, we will assume that there are 3 types of nodes: setup, login, and gpu, and that deepops has been configured on the setup node such that it can access all login and gpu nodes. See below for information about how to set up these nodes on AWS, and the hardware requirements for each node.

Note that these nodes are arbitrary (through they must have Ubuntu 20), so they could all be the same server.

Log into the setup node and execute the following commands

```console
git clone https://github.com/NVIDIA/deepops
cd deepops
git checkout tags/21.09
git switch fbl-ood
```

This set of commands will download deepops to the 

TODO: Make these all one script run over ssh
