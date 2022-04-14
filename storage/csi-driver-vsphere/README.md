# Installs vSphere CSI

VMware documentation for [vSphere CSI](https://docs.vmware.com/en/VMware-vSphere-Container-Storage-Plug-in/index.html)

# Overview

The `Makefile` here pretty much takes care of the installation of all the K8s components:
- vSphere Cloud Provider Interface
- vSphere Container Storage Interface driver and storageclass

# Pre-requisites

There are [vCenter](https://docs.vmware.com/en/VMware-vSphere-Container-Storage-Plug-in/2.0/vmware-vsphere-csp-getting-started/GUID-0AB6E692-AA47-4B6A-8CEA-38B754E16567.html#GUID-FFE45B20-576F-42D9-953F-6E91AC76C641__GUID-B272488E-6A7B-4BEE-9206-0FD55996AA14) items to address first, before installing any K8s components.

# Setup

```shell
make setup
```

Edit the `Makefile` in this directory and change these two lines as needed:

```
CSI_VERSION := v2.5.1
K8S_MAJOR_VERSION := v1.21
```

NOTE: For the above, utilize the [compatibility Matrix](https://docs.vmware.com/en/VMware-vSphere-Container-Storage-Plug-in/2.0/vmware-vsphere-csp-getting-started/GUID-D4AAD99E-9128-40CE-B89C-AD451DA8379D.html#GUID-D4AAD99E-9128-40CE-B89C-AD451DA8379D__SECTION_85EB5376-E31A-438A-83FA-9FB19EA46D43)

Export the KUBECONFIG environment variable, pointing to the PMK cluster's kubeconfig.yaml

```
export KUBECONFIG=~/Downloads/cluster-name.yaml
```

# Installation

```shell
make apply
```

# Validation

The vsphere-cloud-controller-manager is responsible for putting this label on each node `ProviderID: vsphere://<provider-id1>`
Double-check that it exists in the output below.

```shell
make validate
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
