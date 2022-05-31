NAMESPACE  ?= virtualmachines
PUB_SSH_KEY ?= ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDu4qXbvrPPzHEurHD0XL47GHHIln96ct+fcvSZbHMgR root@jmiller01
STORAGE_CLASS_NAME ?= local-path
SECONDARY_NIC ?= ens7
OVS_BRIDGE := ovs-br01
WHEREABOUTS_VLAN_ID := 2504
WHEREABOUTS_NET_RANGE := 10.128.144.0/23
WHEREABOUTS_NET_START := 10.128.144.250
WHEREABOUTS_NET_END := 10.128.144.254
VM ?= undef

export NAMESPACE STORAGE_CLASS_NAME PUB_SSH_KEY SECONDARY_NIC OVS_BRIDGE WHEREABOUTS_VLAN_ID \
	WHEREABOUTS_NET_RANGE WHEREABOUTS_NET_START WHEREABOUTS_NET_END

include ../Makefile

install-crew:
	bash -c ./install_krew.sh

check-krew:
	@echo "Checking if krew and virt plugin are installed"
	@echo "https://krew.sigs.k8s.io/docs/user-guide/setup/install/"
	kubectl krew

install-krew-virt: check-krew
	kubectl krew update
	kubectl krew install virt

namespace:
	envsubst < namespace.yaml
	envsubst < namespace.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		-f -

destroy-namespace:
	envsubst < namespace.yaml | kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		-f -

setup: namespace

containerdisk-demo-ubuntu: setup
	@echo "Deploying containerdisk demo into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	@echo "======= MANIFEST ======="
	envsubst < vmi-ubuntu-containerdisk-emptydisk.yaml
	@echo "======= KUBECTL ======="
	envsubst < vmi-ubuntu-containerdisk-emptydisk.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -

destroy-containerdisk-demo-ubuntu:
	@echo "Deleting containerdisk demo from namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	envsubst < vmi-ubuntu-containerdisk-emptydisk.yaml | kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f - || true

quickstart-demo: containerdisk-demo-ubuntu

containerdisk-demo-ubuntu-join-cluster: setup
	@echo "Deploying containerdisk demo into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	@echo "======= MANIFEST ======="
	envsubst < vmi-ubuntu-containerdisk-emptydisk-join-cluster.yaml
	@echo "======= KUBECTL ======="
	envsubst < vmi-ubuntu-containerdisk-emptydisk-join-cluster.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -

destroy-containerdisk-demo-ubuntu-join-cluster:
	@echo "Deleting containerdisk demo from namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	envsubst < vmi-ubuntu-containerdisk-emptydisk-join-cluster.yaml | kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f - || true

quickstart-demo-join-cluster: containerdisk-demo-ubuntu-join-cluster

destroy-quickstart-demo: destroy-containerdisk-demo-ubuntu destroy-containerdisk-demo-ubuntu-join-cluster

containerdisk-demo-fedora:
	@echo "Deploying containerdisk demo into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	envsubst < vmi-fedora-containerdisk-emptydisk.yaml
	envsubst < vmi-fedora-containerdisk-emptydisk.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -

destroy-containerdisk-demo-fedora:
	@echo "Deleting containerdisk demo from namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	envsubst < vmi-fedora-containerdisk-emptydisk.yaml | kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f - || true

containerdisk-demo-fedora-ovs:
	@echo "Deploying containerdisk demo into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	@echo "======= MANIFEST ======="
	envsubst < vmi-fedora-containerdisk-emptydisk-ovs.yaml
	@echo "======= KUBECTL ======="
	envsubst < vmi-fedora-containerdisk-emptydisk-ovs.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -

destroy-containerdisk-demo-fedora-ovs:
	@echo "Deleting containerdisk demo from namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	envsubst < vmi-fedora-containerdisk-emptydisk-ovs.yaml | kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f - || true

containerdisk-demo-ubuntu-ovs:
	@echo "Deploying containerdisk demo into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	@echo "======= MANIFEST ======="
	envsubst < vmi-ubuntu-containerdisk-emptydisk-ovs.yaml
	@echo "======= KUBECTL ======="
	envsubst < vmi-ubuntu-containerdisk-emptydisk-ovs.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -

destroy-containerdisk-demo-ubuntu-ovs:
	@echo "Deleting containerdisk demo from namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	envsubst < vmi-ubuntu-containerdisk-emptydisk-ovs.yaml | kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f - || true

centos-golden-dv:
	envsubst < centos-golden-dv.yaml
	envsubst < centos-golden-dv.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -

destroy-centos-golden-dv:
	envsubst < centos-golden-dv.yaml | kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f - || true

centos-cloned:
	envsubst < centos-cloned.yaml
	envsubst < centos-cloned.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -

destroy-centos-cloned:
	envsubst < centos-cloned.yaml | kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f - || true

ubuntu-golden-dv:
	envsubst < ubuntu-golden-dv.yaml
	envsubst < ubuntu-golden-dv.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -

destroy-ubuntu-golden-dv:
	envsubst < ubuntu-golden-dv.yaml | kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f - || true

ubuntu-cloned:
	envsubst < ubuntu-cloned.yaml
	envsubst < ubuntu-cloned.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -

destroy-ubuntu-cloned:
	envsubst < ubuntu-cloned.yaml | kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f - || true

ubuntu-source-http:
	envsubst < vm-ubuntu-http.yaml
	envsubst < vm-ubuntu-http.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -

destroy-ubuntu-source-http:
	envsubst < vm-ubuntu-http.yaml | kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f - || true

centos-source-http:
	envsubst < vm-centos-http.yaml
	envsubst < vm-centos-http.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -

destroy-centos-source-http:
	envsubst < vm-centos-http.yaml | kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f - || true

local-storage:
	kubectl apply -f local-storage-provisioner.yaml \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT)

destroy-local-storage:
	kubectl delete -f local-storage-provisioner.yaml \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) || true

hostnetwork:
	@echo "======= MANIFEST ======="
	envsubst < networkplugins.yaml
	envsubst < networkplugins.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -
	sleep 10
	@echo "======= MANIFEST ======="
	envsubst < hostnetwork.yaml
	envsubst < hostnetwork.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -
	@echo "======= MANIFEST ======="
	envsubst < networkattachmentdef.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -

destroy-hostnetwork:
	kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f networkplugins.yaml
	envsubst < hostnetwork.yaml | kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -

watch:
	watch kubectl get \
		pv,pvc,datavolume,virtualmachine,virtualmachineinstance,pods \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE)

get-console:
ifeq ($(VM),undef)
	@echo "Specify the VM name. ie. \`VM=ubuntu-vm make console\`"
	exit 1
endif
	kubectl virt console $(VM) \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE)

destroy:
	$(MAKE) destroy-containerdisk-demo-ubuntu destroy-centos-golden-dv destroy-centos-cloned \
		destroy-ubuntu-golden-dv destroy-ubuntu-cloned destroy-ubuntu-source-http \
		destroy-centos-source-http destroy-local-storage \
		destroy-containerdisk-demo-fedora destroy-quickstart-demo
