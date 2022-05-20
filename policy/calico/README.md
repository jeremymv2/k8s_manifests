# Installs Calico GlobalNetworkPolicy

This is an example Calico GlobalNetworkPolicy that disallows any egress traffic to 8.8.8.8/32 for any
PODs in the development namespace.

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
Pinging 8.8.4.4 - should work from both namespaces
==================================================
for ns in production development; do \
        echo "Running in ${ns} namespace" ; \
        kubectl run tmp-shell \
                        --restart=Never --rm -i --tty \
                        --image nicolaka/netshoot -n ${ns} \
                        --context default \
                        --kubeconfig /home/jmiller/Downloads/calico-k8s.yaml \
                        -- bash -c "ping -v -c 5 8.8.4.4 || true" ; \
        echo ; \
done
Running in production namespace
If you don't see a command prompt, try pressing enter.
64 bytes from 8.8.4.4: icmp_seq=3 ttl=117 time=2.47 ms
64 bytes from 8.8.4.4: icmp_seq=4 ttl=117 time=2.56 ms
64 bytes from 8.8.4.4: icmp_seq=5 ttl=117 time=2.22 ms

--- 8.8.4.4 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4005ms
rtt min/avg/max/mdev = 2.223/2.384/2.560/0.119 ms
pod "tmp-shell" deleted

Running in development namespace
If you don't see a command prompt, try pressing enter.
64 bytes from 8.8.4.4: icmp_seq=3 ttl=117 time=2.32 ms
64 bytes from 8.8.4.4: icmp_seq=4 ttl=117 time=2.50 ms
64 bytes from 8.8.4.4: icmp_seq=5 ttl=117 time=2.11 ms

--- 8.8.4.4 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4006ms
rtt min/avg/max/mdev = 2.105/2.441/2.858/0.247 ms
pod "tmp-shell" deleted

Pinging 8.8.8.8 - should work ONLY from production namespace
============================================================
for ns in production development; do \
        echo "Running in ${ns} namespace" ; \
        kubectl run tmp-shell \
                        --restart=Never --rm -i --tty \
                        --image nicolaka/netshoot -n ${ns} \
                        --context default \
                        --kubeconfig /home/jmiller/Downloads/calico-k8s.yaml \
                        -- bash -c "ping -v -c 5 8.8.8.8 || true" ; \
        echo ; \
done
Running in production namespace
If you don't see a command prompt, try pressing enter.
64 bytes from 8.8.8.8: icmp_seq=3 ttl=117 time=2.30 ms
64 bytes from 8.8.8.8: icmp_seq=4 ttl=117 time=2.12 ms
64 bytes from 8.8.8.8: icmp_seq=5 ttl=117 time=2.26 ms

--- 8.8.8.8 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4006ms
rtt min/avg/max/mdev = 2.124/2.328/2.696/0.193 ms
pod "tmp-shell" deleted

Running in development namespace
If you don't see a command prompt, try pressing enter.

--- 8.8.8.8 ping statistics ---
5 packets transmitted, 0 received, 100% packet loss, time 4085ms

pod "tmp-shell" deleted
```

# Uninstall

```shell
make destroy
```
