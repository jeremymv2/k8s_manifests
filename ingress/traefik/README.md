# Installs traefik ingress controller

The default configuration is for Traefik to be installed as a Daemonset on the master node(s) with a NodePort type service.

An external Load Balancer can then be configured to point to the following Ports on the master nodes:

|Port|Purpose|Endpoint|
|---|---|---|
|32080|http||
|32090|healthcheck|/ping|
|32091|prometheus|/metrics|
|32443|https||

# Pre-requisites

```shell
make check
```

If needed, you can install the latest version of helm with `make install_helm`

# Setup

Ensure you are installing the [version](https://github.com/traefik/traefik-helm-chart/tags) of the [chart](https://github.com/traefik/traefik-helm-chart) that suits your needs.

Once decided, edit these lines in the Makefile

```
CHART_VERSION := 10.19.5
TRAEFIK_VERSION := 2.6.6
```

# Installation

```shell
make apply
```

# Test

Then run the test:

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
