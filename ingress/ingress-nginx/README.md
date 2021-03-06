# Installs ingress-nginx

```shell
make check
```

If needed, you can install the latest version of helm with `make install_helm`

# Setup

Ensure you are installing the [version](https://github.com/kubernetes/ingress-nginx/releases) of the [chart](https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx) that suits your needs.

Once decided, edit this line in the Makefile

```
CHART_VERSION := 4.0.17
```

# Installation

```shell
make apply
```

# Test

Add a host entry to your hosts file on your workstation or add a DNS entry to point to the `LoadBalancer` IP
of the ingress-nginx controller svc. Then edit this line in the Makefile to match:

```
TEST_INGRESS_FQDN := demo-ingress.tld
```

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
