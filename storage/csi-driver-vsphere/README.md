# Installs vSphere CSI

# Setup

```shell
make setup
```

Edit the `Makefile` in this directory and change these two lines as needed:

```
CSI_VERSION := v2.5.1
K8S_MAJOR_VERSION := v1.21
```

Export the KUBECONFIG environment variable, pointing to the PMK cluster's kubeconfig.yaml

```
export KUBECONFIG=~/Downloads/cluster-name.yaml
```

# Installation

```shell
make apply
```

# Validation

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
