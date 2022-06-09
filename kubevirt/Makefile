NAMESPACE  ?= default
# below are optional until needed..
PUB_SSH_KEY ?= ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDu4qXbvrPPzHEurHD0XL47GHHIln96ct+fcvSZbHMgR root@jmiller01
STORAGE_CLASS_NAME ?= local-path
SECONDARY_NIC ?= ens7
OVS_BRIDGE := ovs-br01
WHEREABOUTS_VLAN_ID := 2504
WHEREABOUTS_NET_RANGE := 10.128.144.0/23
WHEREABOUTS_NET_START := 10.128.144.250
WHEREABOUTS_NET_END := 10.128.144.254
WHEREABOUTS_GATEWAY := 10.128.144.1
POD_CIDR := 10.20.0.0/16

export NAMESPACE STORAGE_CLASS_NAME PUB_SSH_KEY SECONDARY_NIC OVS_BRIDGE WHEREABOUTS_VLAN_ID \
	WHEREABOUTS_NET_RANGE WHEREABOUTS_NET_START WHEREABOUTS_NET_END WHEREABOUTS_GATEWAY \
	POD_CIDR

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

clean:
	rm -f rendered/*

render:
	@echo "Run any of the following.."
	@echo "======================"
	@for source in $$(ls templates/*tmpl); do \
		dest=rendered/$$(basename $$source .tmpl) ; \
		echo "kubectl apply -f $$dest"; \
		envsubst < $$source > $$dest ; \
	done
