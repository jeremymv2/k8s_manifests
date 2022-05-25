# Installs NFS CSI

This installs the [nfs-subdir-external-provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner) via a templated helm [chart](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/tree/master/charts/nfs-subdir-external-provisioner)

# Overview

The `Makefile` here pretty much takes care of the installation of all the K8s components.

# Pre-requisites

```shell
make check
```

Export an NFS share as such:
```
/srv/nfs/kubedata/ *(rw,async,no_subtree_check,no_root_squash,insecure)
```

# Setup

Edit the `Makefile` in this directory and change these lines as needed:

```
CHART_VERSION := v4.0.16
APP_VERSION_TAG := v4.0.2
NFS_SERVER :=
NFS_PATH :=
STORAGE_CLASS_NAME :=
ARCHIVE_ON_DELETE_BOOL :=
ACCESS_MODE :=
```

Export the KUBECONFIG environment variable, pointing to the PMK cluster's kubeconfig.yaml

```
export KUBECONFIG=~/Downloads/cluster-name.yaml
```

# Installation

```shell
make apply
```

# Test

```shell
make test
```

Cleanup Test

```shell
make cleanup_test
```

# Uninstall

```shell
make destroy
```
