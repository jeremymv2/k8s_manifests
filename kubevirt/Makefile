NAMESPACE  := cdi
PUB_SSH_KEY := ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDu4qXbvrPPzHEurHD0XL47GHHIln96ct+fcvSZbHMgR root@jmiller01
STORAGE_CLASS_NAME := nfs-client
VM ?= undef

export NAMESPACE STORAGE_CLASS_NAME PUB_SSH_KEY

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

destroy-containerdisk-demo:
	@echo "Deleting containerdisk demo from namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	envsubst < vmi-ubuntu-containerdisk-emptydisk.yaml | kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -

containerdisk-demo:
	@echo "Deploying containerdisk demo into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	envsubst < vmi-ubuntu-containerdisk-emptydisk.yaml | kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f -

centos-golden-dv:
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
		-f -

centos-cloned:
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
		-f -

ubuntu-golden-dv:
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
		-f -

ubuntu-cloned:
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
		-f -

ubuntu-source-http:
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
		-f -

centos-source-http:
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
