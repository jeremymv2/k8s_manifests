# Installs NFS CSI

This installs the [csi-driver-nfs](https://github.com/kubernetes-csi/csi-driver-nfs) via a templated helm [chart](https://github.com/kubernetes-csi/csi-driver-nfs/tree/master/charts)

# Overview

The `Makefile` here pretty much takes care of the installation of all the K8s components.

# Pre-requisites

```shell
make check
```

Export an NFS share. For demo purposes, here is how you can accomplish that on ubuntu:

```
mkdir -p /srv/nfs/kubedata/
chown -R nobody:nogroup /srv/nfs/kubedata/
echo '/srv/nfs/kubedata/ *(rw,async,no_subtree_check,no_root_squash,insecure)' >> /etc/exports
exportfs -rav
```

Optional - Check that it can be mounted:

```
mount -t nfs SERVER_IP:/srv/nfs/kubedata /mnt/nfs
df -H /mnt/nfs
```

If you were able to mount the NFS share, you can now unmount it:

```
umount /mnt/nfs
```

You will need to install `nfs-common` and `nfs-client` on all the K8s worker nodes.

# Setup

Edit the `Makefile` in this directory and change these lines as needed:

```
CHART_VERSION := v4.0.0
# Equal to number of masters
CONTROLLER_REPLICAS := 1
DRIVER_MOUNT_PERMISSIONS := 0777
NFS_SERVER := 10.128.144.128
NFS_PATH   :=  /srv/nfs/kubedata
VOLUME_BINDING_MODE := Immediate
NFS_MOUNT_OPTIONS := rsize=1048576,wsize=1048576,soft,timeo=600,retrans=2,noresvport,_netdev,nofail
```

Export the KUBECONFIG environment variable, pointing to the PMK cluster's kubeconfig.yaml

```
export KUBECONFIG=~/Downloads/cluster-name.yaml
```

# Installation

```shell
make apply
```

```shell
make install-check
```

# Test

```shell
make test
```

Cleanup Test

```shell
make clean
```

# Uninstall

```shell
make destroy
```

# Default StorageClass

To make this the default storageclass
```
make default-sc
```
