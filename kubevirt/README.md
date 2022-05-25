# Kubevirt

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

Change the `PUB_SSH_KEY` in the Makefile

export your KUBECONFIG environment variable

```shell
export KUBECONFIG=~/Downloads/cluster-name.yaml
```

## Start up an ubuntu vm instance

```shell
make containerdisk-demo
```

## Watch progress

```shell
make watch
```

## Console access

```shell
VM=ubuntu-vm make get-console
```

## SSH

From the cluster node where you created an ssh key run:

```shell
ssh -i ~/.ssh/id_ed25519 ubuntu@x.x.x.x
```
