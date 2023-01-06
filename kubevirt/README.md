# Kubevirt Playground

## Pre-requisites

The Kubevirt and Luigi addons must be enabled.

In addition, ensure that all pods are running in the `luigi-system` and `cdi` namespaces. These can take
up to 10 minutes to go into Running state after a fresh cluster install as there are multiple stages.

```shell
kubectl get pods -n cdi
kubectl get pods -n luigi-system
```

You can then either run `kubectl` and `virtctl` commands from a workstation or from one of the cluster nodes.

You must export KUBECONFIG environment variable.

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

Edit the `Makefile` and set some variables. The ones labeled optional can be left as-is
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
POD_CIDR := 10.20.0.0/16
SVC_CIDR := 10.21.0.0./16
KUBE_DNS_SERVER := 10.21.0.10
```

### Storage

If you do not have a `StorageClass` configured, run the following to install a `local-path` CSI.
Otherwise, set the `STRORAGE_CLASS_NAME` accordingly above in the Makefile to match your existing `StorageClass`.

```shell
kubectl apply -f local-storage-provisioner.yaml
```

## Render the templates

After updating the `Makefile` or the `admin.rc` file, you can render the templates at any time via:

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
ssh -i ~/.ssh/id_ed25519 fedora@VM_IP
```

Alternatively, console into the vm from one of the cluster nodes with the username / passwd from the `cloud-config`.
Be patient, `cloud-init` can take a few minutes before reaching the final stage. You will see that it has completed
via a console message.

```shell
/opt/pf9/pf9-kube/bin/virtctl console fedora-vm
```

Or via the `virt` plugin if you have installed it on your workstation using cloud-config user/pass.

```shell
kubectl virt console fedora-vm
```

Explore the other yaml files in the `rendered/` directory and try applying them.

## Golden Image

You may choose to host a "golden image" as a `DataVolume` type then clone VMs from it.

```shell
kubectl apply -f rendered/centos-golden-dv.yaml
```

```shell
kubectl apply -f rendered/centos-cloned.yaml
```

## Workstation virt kubectl plugin

```shell
make install-krew
make install-krew-virt
```

## Advanced Networking

Note: For all of the following examples, it's best to have a CSI / StorageClass set that allows RWX access mode.

With multus we can enable a secondary CNI with either `ovs` bridge or `sriov`. This allows us
to add a second NIC to the VM with direct access to the Host's network interface. Additionally, with
whereabouts, we can implement IPAM for the VM interfaces.

First, ensure the Host has an available NIC that is UP but without an IP assigned.

```
ip link set dev ens7 up
```


Set the following values in the Makefile:

```
STORAGE_CLASS_NAME := nfs-csi
SECONDARY_NIC := ens7
OVS_BRIDGE := ovs-br01
# vlan is only if interface has tagged vlan
WHEREABOUTS_VLAN_ID := 2504
WHEREABOUTS_NET_RANGE := 10.128.144.0/23
WHEREABOUTS_NET_START := 10.128.144.250
WHEREABOUTS_NET_END := 10.128.144.254
WHEREABOUTS_GATEWAY := 10.128.144.1
POD_CIDR := 10.20.0.0/16
SVC_CIDR := 10.21.0.0./16
KUBE_DNS_SERVER := 10.21.0.10
```

Ensure the templates are re-rendered with `make render`.

Apply the `NetworkPlugins`

```shell
kubectl apply -f rendered/networkplugins.yaml
```

Wait a few moments, waiting for all the pods to come up Running in the namespace. Then apply
the `HostNetworkTemplate`.

```shell
kubectl apply -f rendered/hostnetwork.yaml
```

This should provision an ovs bridge on each of the cluster nodes. You can exec into one of the ovs daemon
pods to verify:

```shell
$ kubectl exec -it ovs-daemons-blttz -n virtualmachines -- ovs-vsctl show
Defaulted container "ovs-services" out of: ovs-services, ovs-db-init (init)
2182276a-62b2-4a3c-84cc-932d4a7e73d0
    Bridge "ovs-br01"
        Port "ovs-br01"
            Interface "ovs-br01"
                type: internal
        Port "ens7"
            Interface "ens7"
        Port "vethfca11110"
            Interface "vethfca11110"
    ovs_version: "2.13.5"
```

Finally, apply the `NetworkAttachmentDefinition`

```shell
kubectl apply -f rendered/networkattachmentdef.yaml
```

You can then create a `VirtualMachineInstance` utilizing ovs for the interface

```shell
kubectl apply -f rendered/vmi-ubuntu-containerdisk-emptydisk-ovs.yaml
```

or a `VirtualMachine`

```shell
kubectl apply -f rendered/vm-ubuntu-http-readwritemany-ovs.yaml
```

## PMK master/worker `VirtualMachine`s in Kubevirt!

Create a copy of the `admin.rc` template

```shell
cp admin.rc.tmpl admin.rc
```

Edit the `admin.rc` file and configure the DU variables. Then source the file into your environment,
re-render the templates and then launch the VM.

```shell
source admin.rc
make render
kubectl apply -f rendered/vm-pmk-master.yaml
```

Watch the cloud init logs (be patient. cloud-init output takes several minutes to show up)

```shell
ssh -i ~/.ssh/id_ed25519 ubuntu@10.20.3.142 "tail -f /tmp/cloudinit.log"
```

Once the Master VirtualMachineInstance attaches to the control plane, install a single master PMK
cluster on it.

NOTE: You must choose a custom POD and SVC CIDR for it, so as not to collide with the "upper"
PMK cluster. For example: 10.22.0.0/16 and 10.23.0.0/16.

After the Master nodes finishes converging and the cluster is ready, take note of the cluster UUID
and update it in the `admin.rc` file. Source the file again, render the templates and spin up the worker.

```shell
source admin.rc
make render
kubectl apply -f rendered/vm-pmk-worker.yaml
```

The Worker VirtualMachine should auto join the cluser after it finishes converging.

## Live Migration

Note: Live migration can only occur when the pod network interface of the VMI is `masquerade` as opposed to `bridge`

Also, you must utilize a storage class that supports `ReadWriteMany` access mode for the datavolume.

Create a VM that uses `ReadWriteMany` PVC, a default pod interface in `masquerade` mode, and a secondary interface in multus ovs bridge mode.

```shell
apply -f rendered/vm-ubuntu-http-readwritemany-ovs.yaml
```

After it spins up, live migrate it

```shell
kubectl virt migrate ubuntu-rwx-ovs
```
