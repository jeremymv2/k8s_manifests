KUBE_CONTEXT ?= default
KUBECONFIG ?= default

export KUBECONFIG KUBE_CONTEXT

check:
	which kubectl
	which make
	which curl
	which git
	which envsubst
	which jq
	which helm
	which openssl
	@echo "All pre-requisites available!"


install_helm:
	@echo "Installing helm"
	@if [ $$(which helm) ]; then \
		echo "Helm already installed"; \
	else \
		curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash; \
	fi
