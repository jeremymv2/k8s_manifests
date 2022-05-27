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

Variation of quickstart with VM node registering to control plane and joining an existing cluster.

Edit the `admin.rc` file and fill out the DU portion, then source the file again.

```shell
source admin.rc
make quickstart-demo-join-cluster
```

Watch the cloud init logs

```shell
ssh -i ~/.ssh/id_ed25519 ubuntu@10.20.3.142 "tail -f /tmp/cloudinit.log"
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

Change the following in the Makefile
Keep `local-path` if using the local path provisioner above.

```
NAMESPACE :=
PUB_SSH_KEY :=
STORAGE_CLASS_NAME :=
```


```shell
make setup
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
