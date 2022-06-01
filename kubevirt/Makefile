NAMESPACE  ?= vms
PUB_SSH_KEY ?= ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDu4qXbvrPPzHEurHD0XL47GHHIln96ct+fcvSZbHMgR root@jmiller01
STORAGE_CLASS_NAME ?= local-path
SECONDARY_NIC ?= ens7
OVS_BRIDGE := ovs-br01
WHEREABOUTS_VLAN_ID := 2504
WHEREABOUTS_NET_RANGE := 10.128.144.0/23
WHEREABOUTS_NET_START := 10.128.144.250
WHEREABOUTS_NET_END := 10.128.144.254
WHEREABOUTS_GATEWAY := 10.128.144.1
VM ?= undef

export NAMESPACE STORAGE_CLASS_NAME PUB_SSH_KEY SECONDARY_NIC OVS_BRIDGE WHEREABOUTS_VLAN_ID \
	WHEREABOUTS_NET_RANGE WHEREABOUTS_NET_START WHEREABOUTS_NET_END WHEREABOUTS_GATEWAY

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

clean:
	rm -f rendered/*

setup: namespace

render:
	for source in $$(ls templates/*tmpl); do \
		dest=rendered/$$(basename $$source .tmpl) ; \
		echo "Rendering $$source as $$dest "; \
		envsubst < $$source > $$dest ; \
	done

local-storage:
	kubectl apply -f local-storage-provisioner.yaml \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT)

destroy-local-storage:
	kubectl delete -f local-storage-provisioner.yaml \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) || true

get-console:
ifeq ($(VM),undef)
	@echo "Specify the VM name. ie. \`VM=ubuntu-vm make console\`"
	exit 1
endif
	kubectl virt console $(VM) \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE)

destroy: destroy-namespace
