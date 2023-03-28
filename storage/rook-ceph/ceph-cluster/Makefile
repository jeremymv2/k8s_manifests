CHART_NAME := rook-ceph-cluster
NAMESPACE  := rook-ceph
CHART_REPO := rook-release
CHART_VERSION := v1.11.1
CHART_VERSION_SAFE := $(shell echo $(CHART_VERSION) | sed -e 's/\./\-/g')
RELEASE_NAME := $(CHART_NAME)-$(CHART_VERSION_SAFE)
REPO_URL := https://charts.rook.io/release
MONITORING_ENABLED := false
TOOLBOX_ENABLED := true
DASHBOARD_ENABLED := true
DASHBOARD_PORT := 32443
ALLOW_MULTIPLE_MON_PER_NODE := false
MON_COUNT := 3
PUB_AND_CLUSTER_NETWORKS_ENABLED := false
DISABLE_CRASHCOLLECTOR := true
STORAGE_CLASS_NAME_TO_TEST := ceph-block
ENABLE_CEPHFS_SNAPSHOTS := false
ENABLE_RBD_SNAPSHOTS := false

ifeq ($(PUB_AND_CLUSTER_NETWORKS_ENABLED), true)
	NETWORKING := --set "cephClusterSpec.network.connections.provider=host"
else
	NETWORKING :=
endif

include ../../../Makefile

COMMON_ARGS := $(CHART_NAME) $(CHART_REPO)/$(CHART_NAME) \
		--namespace $(NAMESPACE) \
		--kubeconfig $(KUBECONFIG) \
		--kube-context $(KUBE_CONTEXT) \
		--version $(CHART_VERSION) \
		--set "cephClusterSpec.mon.allowMultiplePerNode=$(ALLOW_MULTIPLE_MON_PER_NODE)" \
		--set "cephClusterSpec.mon.count=$(MON_COUNT)" \
		--set "cephClusterSpec.network.connections.provider=host" \
		--set "cephClusterSpec.dashboard.enabled=$(DASHBOARD_ENABLED)" \
		--set "cephClusterSpec.dashboard.port=$(DASHBOARD_PORT)" \
		--set "monitoring.enabled=$(MONITORING_ENABLED)" \
		--set "toolbox.enabled=$(TOOLBOX_ENABLED)" \
		--set "cephClusterSpec.storage.useAllNodes=false" \
		--set "cephClusterSpec.storage.useAllDevices=false" \
		--set "cephClusterSpec.crashCollector.disable=$(DISABLE_CRASHCOLLECTOR)" \
		--set "cephFileSystemVolumeSnapshotClass.enabled=$(ENABLE_CEPHFS_SNAPSHOTS)" \
		--set "cephBlockPoolsVolumeSnapshotClass.enabled=$(ENABLE_RBD_SNAPSHOTS)" \
		$(NETWORKING) \
		--values node_storage.yaml \
		--values values_overrides.yaml

setup: install_helm
	@echo "Adding helm repo"
	helm repo add $(CHART_REPO) $(REPO_URL)
	helm repo update

values:
	@echo "Saving values file as $(RELEASE_NAME)-values.yaml"
	helm show values $(CHART_REPO)/$(CHART_NAME) \
		--version $(CHART_VERSION) > values-$(RELEASE_NAME).yaml

helm_chart_versions:
	helm search repo $(CHART_NAME)

namespace:
	@echo "Creating namespace $(NAMESPACE).."
	kubectl create ns $(NAMESPACE) --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) || true

template:
	@echo "Templating.. saving to $(RELEASE_NAME).yaml"
	helm template $(COMMON_ARGS) > $(RELEASE_NAME).yaml

list:
	helm list --filter $(CHART_NAME) \
		--all-namespaces \
		--kubeconfig $(KUBECONFIG) \
		--kube-context $(KUBE_CONTEXT)
	kubectl --namespace $(NAMESPACE) \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		get pods -l "app=rook-ceph-operator"
	kubectl --namespace $(NAMESPACE) \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		get cephcluster

status:
	kubectl --namespace $(NAMESPACE) \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		exec -it $$(kubectl -n $(NAMESPACE) --kubeconfig $(KUBECONFIG) --context $(KUBE_CONTEXT) get pod -l "app=rook-ceph-tools" \
		-o jsonpath='{.items[0].metadata.name}') -- bash -c 'ceph status; ceph osd tree; ceph osd status'

verify-unique-names:
	@echo "The following Objects are global"
	cat $(RELEASE_NAME).yaml | yq 'select (.metadata.namespace == null) | .kind + " | " + .metadata.name'

uninstall:
	@echo "Uninstalling chart $(CHART_NAME) from $(NAMESPACE) with context $(KUBE_CONTEXT) in \
		$(KUBECONFIG)"
	kubectl --namespace $(NAMESPACE) \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		patch cephcluster rook-ceph \
		--type merge -p '{"spec":{"cleanupPolicy":{"confirmation":"yes-really-destroy-data"}}}'
	helm uninstall $(CHART_NAME) \
		--namespace $(NAMESPACE) \
		--kubeconfig $(KUBECONFIG) \
		--kube-context $(KUBE_CONTEXT)
	@echo "Removing all vestiges.."
	kubectl --namespace $(NAMESPACE) \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		delete cephcluster rook-ceph

install: setup values namespace
	@echo "Installing chart $(CHART_NAME) with version $(CHART_VERSION) into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) \
		in $(KUBECONFIG)"
	helm install $(COMMON_ARGS)

upgrade:
	@echo "Upgrading chart $(CHART_NAME) with version $(CHART_VERSION) into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) \
		in $(KUBECONFIG)"
	helm upgrade $(COMMON_ARGS)

test:
	envsubst < test-pvc.yaml | kubectl apply \
		--context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) \
		-f -
	kubectl --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) wait -n default \
		--for=condition=ready pod/busybox --timeout=120s
	kubectl --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) get pvc

clean-test:
	envsubst < test-pvc.yaml | kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		--force=true -f -
