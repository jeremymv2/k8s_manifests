# Kubevirt Playground

## Pre-requisites

The Kubevirt and Luigi addons must be enabled.

In addition, ensure that all PODS are running in the `luigi-system` and `cdi` namespaces. These can take
up to 10 minutes to go into Running state after a fresh cluster install as there are multiple stages.

```shell
kubectl get pods -n cdi
kubectl get pods -n luigi-system
```

You can then either run `kubectl` and `virtctl` commands from a workstation or from one of the cluster nodes.

Export KUBECONFIG environment variable
If from a cluster node:

```shell
export KUBECONFIG=/etc/pf9/kube.d/kubeconfigs/admin.yaml
export PATH=/opt/pf9/pf9-kube/bin:$PATH
```

Otherwise:

```shell
export KUBECONFIG=~/Downloads/cluster-name.yaml
```

If you wish to ssh into the `VirtualMachineInstance`, create an ssh key on a cluster node:

```shell
ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519
```

## Configuration

Edit the `Makefile` and set some variables. The ones labeled optional below can be left as-is
until or if needed later for more advanced configurations.

```
NAMESPACE  ?= default
STORAGE_CLASS_NAME ?= local-path
# All below are optional
PUB_SSH_KEY ?= ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDu4qXbvrPPzHEurHD0XL47GHHIln96ct+fcvSZbHMgR root@jmiller01
SECONDARY_NIC ?= ens7
OVS_BRIDGE := ovs-br01
WHEREABOUTS_VLAN_ID := 2504
WHEREABOUTS_NET_RANGE := 10.128.144.0/23
WHEREABOUTS_NET_START := 10.128.144.250
WHEREABOUTS_NET_END := 10.128.144.254
WHEREABOUTS_GATEWAY := 10.128.144.1
```

### Storage

If you do not have a `StorageClass` configured, run the following to install a `local-path` CSI.
Otherwise, set the `STRORAGE_CLASS_NAME` accordingly above in the Makefile.

```shell
kubectl apply -f local-storage-provisioner.yaml
```

## Render the templates

After updating the `Makefile` or the `admin.rc` file, you can render the templates via:

```shell
make render
```

## Quick Example

Create the namespace

```shell
kubectl apply -f rendered/namespace.yaml
```

Launch a `VirtualMachineInstance`

```shell
kubectl apply -f rendered/vmi-fedora-containerdisk-emptydisk.yaml
```

See the resources being created

```shell
kubectl get pv,pvc,datavolume,virtualmachine,virtualmachineinstance,pods
```

Ssh into the VM from the cluster node where you generated the ssh key

```shell
ssh -i ~/.ssh/id_ed25519 ubuntu@VM_IP
```

Alternatively, console into the vm from one of the cluster nodes

```shell
/opt/pf9/pf9-kube/bin/virtctl console ubuntu-vm
```

Or via the `virt` plugin

```shell
kubectl virt console VM
```

Explore the other objects in the `rendered/` directory and try applying them.


## Join a VM to a PMK cluster

Create a copy of the `admin.rc` template

```shell
cp admin.rc.tmpl admin.rc
```

Edit the `admin.rc` file and configure the DU variables. Then source the file into your environment,
re-render the templates and then launch the VM.

```shell
source admin.rc
make render
kubectl apply -f rendered/vmi-ubuntu-containerdisk-emptydisk-join-cluster.yaml
```

Watch the cloud init logs

```shell
ssh -i ~/.ssh/id_ed25519 ubuntu@10.20.3.142 "tail -f /tmp/cloudinit.log"
```

## Install krew and virt kubectl plugin

```shell
make install-krew
make install-krew-virt
```
