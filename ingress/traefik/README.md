# Installs traefik ingress controller

The default configuration is for Traefik to be installed as a Daemonset on the master node(s) with a NodePort type service.

```shell
make check
```

If needed, you can install the latest version of helm with `make install_helm`

# Setup

Ensure you are installing the [version](https://github.com/traefik/traefik-helm-chart/tags) of the [chart](https://github.com/traefik/traefik-helm-chart) that suits your needs.

Once decided, edit this line in the Makefile

```
CHART_VERSION := 10.19.5
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
