# Kubevirt

## Pre-requisites

It is required to have checked the "Enable Kubevirt" Add-ons when creating the cluster.
If enabled after creation, make sure `kubevirt` and `luigi` addons are enabled and healthy.
Ensure that all PODS are running in the `luigi-system` and `cdi` namespaces. These can take
up to 10 minutes to go into Running state after a fresh cluster install.

Export your KUBECONFIG environment variable

```shell
export KUBECONFIG=~/Downloads/cluster-name.yaml
```

```shell
kubectl get pods -n cdi
kubectl get pods -n luigi-system
```

## Minimal Quickstart

This quickstart will launch a Ubuntu VirtualMachineInstance using an ephemeral disk image.

On one of the cluster nodes, create a ssh key. This key will be used to ssh into the VirtualMachineInstance.

```shell
ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519
```

The above will save the value for `PUB_SSH_KEY` in the `~/.ssh/id_ed25519.pub` file.

Copy the `admin.rc.tmpl` file to `admin.rc`

```shell
cp admin.rc.tmpl admin.rc
```

Now edit the `admin.rc` file and set the `PUB_SSH_KEY` variable, then source the file into your environment
and launch the VM.

```shell
source admin.rc
make quickstart-demo
```

Watch the resources being created

```shell
watch kubectl get pv,pvc,datavolume,virtualmachine,virtualmachineinstance,pods -n virtualmachines
```

Ssh into the VM from one of the cluster nodes

```shell
ssh -i ~/.ssh/id_ed25519 ubuntu@VM_IP
```

Alternatively, console into the vm from one of the cluster nodes

```shell
/opt/pf9/pf9-kube/bin/virtctl console ubuntu-vm -n virtualmachines
```

### Variation of quickstart

In this variation, we have the VM node registering to control plane and joining an existing cluster.

Edit the `admin.rc` file and fill out the DU portion, then source the file again.

```shell
source admin.rc
make quickstart-demo-join-cluster
```

Watch the cloud init logs

```shell
ssh -i ~/.ssh/id_ed25519 ubuntu@10.20.3.142 "tail -f /tmp/cloudinit.log"
```

You should eventually see something like:

```
Installing Platform9 CLI...

Platform9 CLI installation completed successfully !

To start building a Kubernetes cluster execute:
        pf9ctl help

✓ Stored configuration details successfully
✓ Loaded Config Successfully
✓ Missing package(s) installed successfully
✓ Removal of existing CLI
✓ Existing Platform9 Packages Check
✓ Required OS Packages Check
✓ SudoCheck
! CPUCheck - At least 2 CPUs are needed on host. Number of CPUs found: 1
! DiskCheck - At least 30 GB of total disk space and 15 GB of free space is needed on host. Disk Space found: 2 GB
! MemoryCheck - At least 12 GB of memory is needed on host. Total memory found: 4 GB
✓ PortCheck
✓ Existing Kubernetes Cluster Check
✓ Check lock on dpkg
✓ Check lock on apt
✓ Check if system is booted with systemd
✓ Check time synchronization
✓ Check if firewalld service is not running
✓ Disabling swap and removing swap in fstab

✓ Completed Pre-Requisite Checks successfully


Proceeding for prep-node with failed optional check(s)
✓ Platform9 packages installed successfully
✓ Initialised host successfully
✓ Host successfully attached to the Platform9 control-plane
✓ Loaded Config Successfully
Attaching node to the cluster k8s-calico
2022-05-27T16:25:02.752Z        INFO    Worker node(s) [e4ae4979-1ce2-4f11-8de7-9da57ee6b27f] attached to cluster
```

Cleanup the demo instances

```shell
make destroy-quickstart-demo
```

# Other Options

The following sections are for more advanced and varied scenarios.

## Install krew and virt kubectl plugin

```shell
make install-krew
make install-krew-virt
```

If you do not have a StorageClass already configured you can
use the local-path provisioner:

```
make local-storage
```

Change the following in the Makefile if you wish to use a custom StorageClasss.
Keep `local-path` if using the local path provisioner from above.

```
STORAGE_CLASS_NAME :=
```

## Watch progress

Watch resources being created

```shell
make watch
```

## Console access

Get console access via kubectl virt plugin

```shell
VM=fedora-vm make get-console
```

## Cleanup

Destroy all the resources created

```
make destroy
```

## Create a VM from a Cloned Golden Image DataVolume

```
make centos-golden-dv centos-cloned
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
