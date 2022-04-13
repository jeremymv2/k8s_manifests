RELEASE_NAME  := csi-driver-nfs
NAMESPACE  := kube-system
CHART_NAME := csi-driver-nfs
CHART_REPO := csi-driver-nfs
CHART_VERSION := v3.1.0
NFS_SUBDIR_PROVISIONER_IMAGE := v4.0.2
REPO_URL   := https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
NFS_SERVER := 10.128.145.176
NFS_PATH   := /var/nfsshare
PROVISIONER_NAME := k8s.ethzero.cloud/nfs
KUBE_CONTEXT := default
KUBECONFIG ?= default

export NFS_SERVER NFS_PATH PROVISIONER_NAME NFS_SUBDIR_PROVISIONER_IMAGE

setup:
	helm repo add $(CHART_REPO) $(REPO_URL)
	helm repo update

destroy:
	@echo "Deleting chart $(RELEASE_NAME) yaml with version $(CHART_VERSION) from $(CHART_REPO)/$(CHART_NAME) \
		namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	kubectl delete --kubeconfig $(KUBECONFIG) -n $(NAMESPACE) -f 01_$(RELEASE_NAME).yaml --context $(KUBE_CONTEXT)
	envsubst < 02_nfs-auto-provisioner.yaml | kubectl delete --kubeconfig $(KUBECONFIG) --context $(KUBE_CONTEXT) -n $(NAMESPACE) -f -

labels:
	for master in $$(kubectl get nodes --selector=node-role.kubernetes.io/master -o jsonpath='{$$.items[*].metadata.name}') ; \
		do echo $$master ; \
		kubectl label --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
			nodes $$master kubernetes.io/role=master || true ; \
	done

apply: setup labels
	@echo "Installing chart $(RELEASE_NAME) yaml with version $(CHART_VERSION) from $(CHART_REPO)/$(CHART_NAME) \
		into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	helm template -n $(NAMESPACE) $(RELEASE_NAME) $(CHART_REPO)/$(CHART_NAME) \
		--version $(CHART_VERSION) \
		--values values.yaml > 01_$(RELEASE_NAME).yaml
	kubectl apply -n $(NAMESPACE) -f 01_$(RELEASE_NAME).yaml --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG)
	envsubst < 02_nfs-auto-provisioner.yaml | kubectl apply --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) -n $(NAMESPACE) -f -

test:
	envsubst < test-pvc.yaml | kubectl apply --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-n default -f -
	kubectl --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) wait -n default \
		--for=condition=ready pod/busybox --timeout=120s
	kubectl --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) -n default get pvc

clean:
	envsubst < test-pvc.yaml | kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-n default --force=true -f -
