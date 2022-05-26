NAMESPACE  := cdi
PUB_SSH_KEY := ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICSkMgT4PfvnL88E53bNt8RxnXRiiFeXyZGnQbw/E36K root@jmiller662503
STORAGE_CLASS_NAME := local-path
SECONDARY_NIC := ens7
VM ?= undef

export NAMESPACE STORAGE_CLASS_NAME PUB_SSH_KEY SECONDARY_NIC

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

containerdisk-demo-ubuntu:
	@echo "Deploying containerdisk demo into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	envsubst < vmi-ubuntu-containerdisk-emptydisk.yaml
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
		--context $(KUBE_CONTEXT)

hostnetwork:
	cat networkplugins.yaml
	kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace luigi-system \
		-f networkplugins.yaml
	sleep 10
	envsubst < hostnetwork.yaml
	envsubst < hostnetwork.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace luigi-system \
		-f -

destroy-hostnetwork:
	kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace luigi-system \
		-f networkplugins.yaml
	envsubst < hostnetwork.yaml | kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace luigi-system \
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

destroy-all:
	$(MAKE) destroy-containerdisk-demo-ubuntu destroy-centos-golden-dv destroy-centos-cloned \
		destroy-ubuntu-golden-dv destroy-ubuntu-cloned destroy-ubuntu-source-http \
		destroy-centos-source-http destroy-local-storage destroy-hostnetwork destroy-containerdisk-demo-fedora
