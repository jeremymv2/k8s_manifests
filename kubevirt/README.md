# Kubevirt

## Pre-requisites

It is required to have the Luigi and Kubevirt Add-ons enabled:

`kubevirt`, `luigi`

## Install krew and virt kubectl plugin

```shell
make install-krew
make install-krew-virt
```

## On one of the cluster nodes create a ssh key

```shell
ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519
```

## Set up environment

If you do not have a StorageClass already configured you can
use the local-path provisioner:

```
make local-storage
```

Change the following in the Makefile
Keep `local-path` if using the local path provisioner above.

```
PUB_SSH_KEY :=
STORAGE_CLASS_NAME :=
```

export your KUBECONFIG environment variable

```shell
export KUBECONFIG=~/Downloads/cluster-name.yaml
```

## Create the namespace for the virtual machines

```shell
make namespace
```

## Create a VM with ephemeral disk

```shell
make containerdisk-demo-fedora
```

## Watch progress

```shell
make watch
```

## Console access

```shell
VM=fedora-vm make get-console
```

## ssh

From the cluster node where you created an ssh key run:

```shell
ssh -i ~/.ssh/id_ed25519 fedora@x.x.x.x
```

## Cleanup

```
make destroy-all
```

## Create a VM from a Cloned Golden Image DataVolume

```
make centos-golden-dv
make centos-cloned
```

## Create a VM from HTTP disk image source and a dynamically created DataVolume

```
make centos-source-http
```

## Configure Secondary Network for Direct VM Access

Ensure that you have `SECONDARY_NIC` set correctly in the Makefile

```shell
make hostnetwork
```
