CHART_NAME := rook-ceph
NAMESPACE  := $(CHART_NAME)
CHART_REPO := rook-release
CHART_VERSION := v1.11.1
CHART_VERSION_SAFE := $(shell echo $(CHART_VERSION) | sed -e 's/\./\-/g')
RELEASE_NAME := $(CHART_NAME)-$(CHART_VERSION_SAFE)
REPO_URL   := https://charts.rook.io/release
MONITORING_ENABLED := false
LOG_LEVEL := INFO
ENABLE_RBD_CSI := true
ENABLE_CEPHFS_CSI := true
ENABLE_CRDS := true
ENABLE_PUBLIC_AND_CLUSTER_NETWORKS := false
# if above is true set the following two networks
CEPH_PUBLIC_NETWORK := 10.10.10.0/24
CEPH_CLUSTER_NETWORK := 10.10.20.0/24

include ../../../Makefile
export CEPH_PUBLIC_NETWORK CEPH_CLUSTER_NETWORK

COMMON_ARGS := $(CHART_NAME) $(CHART_REPO)/$(CHART_NAME) \
		--namespace $(NAMESPACE) \
		--kubeconfig $(KUBECONFIG) \
		--kube-context $(KUBE_CONTEXT) \
		--version $(CHART_VERSION) \
		--set "crds.enabled=$(ENABLE_CRDS)" \
		--set "monitoring.enabled=$(MONITORING_ENABLED)" \
		--set "logLevel=$(LOG_LEVEL)" \
		--set "enableRbdDriver=$(ENABLE_RBD_CSI)" \
		--set "enableCephfsDriver=$(ENABLE_CEPHFS_CSI)" \
		--values values_overrides.yaml

setup: install_helm
	@echo "Adding helm repo"
	helm repo add $(CHART_REPO) $(REPO_URL)
	helm repo update

values:
	@echo "Saving values file as values-$(RELEASE_NAME).yaml"
	helm show values $(CHART_REPO)/$(CHART_NAME) \
		--version $(CHART_VERSION) > values-$(RELEASE_NAME).yaml

crds:
	@echo "Saving crd file as crds-$(RELEASE_NAME).yaml"
	helm show crds $(CHART_REPO)/$(CHART_NAME) \
		--version $(CHART_VERSION) > crds-$(RELEASE_NAME).yaml

helm_chart_versions:
	helm search repo $(CHART_NAME)

labels:
	for master in $$(kubectl get nodes --selector=node-role.kubernetes.io/master \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		-o jsonpath='{$$.items[*].metadata.name}') ; \
		do echo $$master ; \
		kubectl label --kubeconfig $(KUBECONFIG) --context $(KUBE_CONTEXT) \
		nodes $$master role=ceph-operator-node || true ; \
	done
	for worker in $$(kubectl get nodes --selector=node-role.kubernetes.io/worker \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		-o jsonpath='{$$.items[*].metadata.name}') ; \
		do echo $$worker ; \
		kubectl label --kubeconfig $(KUBECONFIG) --context $(KUBE_CONTEXT) \
		nodes $$worker role=ceph-storage-node || true ; \
	done

namespace:
	@echo "Creating namespace $(NAMESPACE) with context $(KUBE_CONTEXT) \
		in $(KUBECONFIG)"
	kubectl create ns $(NAMESPACE) --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) || true

configmap: namespace
ifeq ($(ENABLE_PUBLIC_AND_CLUSTER_NETWORKS), true)
	@echo "Applying configMap into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) \
		in $(KUBECONFIG)"
	envsubst < rook-config-override.yaml.tmpl
	envsubst < rook-config-override.yaml.tmpl | kubectl apply \
		--namespace $(NAMESPACE) \
		--context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) -f -
endif

template:
	@echo "Templating.. saving to $(RELEASE_NAME).yaml"
	helm template $(COMMON_ARGS) > $(RELEASE_NAME).yaml

verify-unique-names:
	@echo "The following Objects are global"
	cat $(RELEASE_NAME).yaml | yq 'select (.metadata.namespace == null) | .kind + " | " + .metadata.name'

destroy-crds:
	@echo "Removing all CRDs"
	for cr in $$(kubectl --kubeconfig $(KUBECONFIG) --context $(KUBE_CONTEXT) get crd | \
		grep ceph.rook.io | awk '{print $$1}') ; \
		do kubectl --kubeconfig $(KUBECONFIG) --context $(KUBE_CONTEXT) delete crd $$cr ; \
	done
	kubectl --kubeconfig $(KUBECONFIG) --context $(KUBE_CONTEXT) delete crd objectbuckets.objectbucket.io
	kubectl --kubeconfig $(KUBECONFIG) --context $(KUBE_CONTEXT) delete crd objectbucketclaims.objectbucket.io

uninstall:
	@echo "Uninstalling chart $(CHART_NAME) from $(NAMESPACE) with context $(KUBE_CONTEXT) in \
		$(KUBECONFIG)"
	helm uninstall $(CHART_NAME) \
		--namespace $(NAMESPACE) \
		--kubeconfig $(KUBECONFIG) \
		--kube-context $(KUBE_CONTEXT)
	kubectl delete namespace $(NAMESPACE) --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG)
		--force=true || true

install: setup values labels configmap
	@echo "Installing chart $(CHART_NAME) with version $(CHART_VERSION) into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) \
		in $(KUBECONFIG)"
	helm install $(COMMON_ARGS)

upgrade:
	@echo "Upgrading chart $(CHART_NAME) with version $(CHART_VERSION) into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) \
		in $(KUBECONFIG)"
	helm upgrade $(COMMON_ARGS)

list:
	helm list --filter $(CHART_NAME) \
		--all-namespaces \
		--kubeconfig $(KUBECONFIG) \
		--kube-context $(KUBE_CONTEXT)
	kubectl --namespace $(NAMESPACE) \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		get pods -l "app=rook-ceph-operator" -o wide
