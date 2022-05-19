# Installs Calico GlobalNetworkPolicy

This is an example Calico GlobalNetworkPolicy that disallows any egress traffic to 8.8.8.8 for any
PODs in the "development" environment.

Calico Docs
- [Getting Started](https://projectcalico.docs.tigera.io/security/calico-network-policy)
- [Policy Tutorial](https://docs.projectcalico.org/security/tutorials/calico-policy)

# Pre-requisites

```shell
export KUBECONFIG=~/path/to/kubconfig.yaml
```

# Installation

```shell
make apply
```

# Test

The test spins up a pod in the production and development namespaces and sends ICMP pings to 8.8.8.8
As expected, only pings from the production namespace POD will be received back.


```shell
17:35 $ make test
Pinging 8.8.8.8 - should work only for production namespace
===========================================================
for ns in production development; do \
        echo "Running in ${ns}" ; \
        kubectl run tmp-shell \
                        --restart=Never --rm -i --tty \
                        --image nicolaka/netshoot -n ${ns} \
                        --context default \
                        --kubeconfig /home/jmiller/Downloads/calico-k8s.yaml \
                        -- bash -c "ping -v -c 5 8.8.8.8 || true" ; \
        echo ; \
done
Running in production
If you don't see a command prompt, try pressing enter.
64 bytes from 8.8.8.8: icmp_seq=2 ttl=117 time=2.13 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=117 time=2.16 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=117 time=2.34 ms
64 bytes from 8.8.8.8: icmp_seq=5 ttl=117 time=2.36 ms

--- 8.8.8.8 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4006ms
rtt min/avg/max/mdev = 2.133/2.255/2.360/0.091 ms
pod "tmp-shell" deleted

Running in development
If you don't see a command prompt, try pressing enter.

--- 8.8.8.8 ping statistics ---
5 packets transmitted, 0 received, 100% packet loss, time 4083ms

pod "tmp-shell" deleted

[jmiller@euclid: ~/Projects/k8s_manifests/policy/calico] [main|…15] ✔
17:36 $
```

# Uninstall

```shell
make destroy
```
