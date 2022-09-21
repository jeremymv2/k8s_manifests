# Installs MS Teams Alertmanager Integration

This installs the [prometheus-msteams](https://github.com/prometheus-msteams/prometheus-msteams) via a templated helm [chart](https://github.com/prometheus-msteams/prometheus-msteams/tree/master/chart/prometheus-msteams)

# Overview

The `Makefile` here pretty much takes care of the installation of all the K8s components.

# Pre-requisites

```shell
make check
```

# Setup

Edit the `Makefile` in this directory and change these lines as needed:

```
CHART_VERSION := 1.3.1
APP_VERSION_TAG := v1.5.1
CONNECTOR_NAME_URL := Some Long URL at webhook.office.com
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

# Uninstall

```shell
make destroy
```
