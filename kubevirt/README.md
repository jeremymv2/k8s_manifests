# Kubevirt

## Install krew kubectl plugin

```shell
make install_krew
```

```shell
make install-krew-virt
```

## On one of the cluster nodes create a ssh key

```shell
ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519
```

## Edit Makefile

Change the `PUB_SSH_KEY` in the Makefile

## Start up an ubuntu vm instance

```shell
make containerdisk-demo
```
