NAMESPACE  := kube-system
CHART_NAME := csi-driver-nfs
CHART_REPO := $(CHART_NAME)
CHART_VERSION := v4.0.0
RELEASE_NAME := $(CHART_NAME)
REPO_URL   := https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
STORAGE_CLASS_NAME := nfs-csi
CONTROLLER_RUN_ON_MASTERS := true
CONTROLLER_REPLICAS := 2
DRIVER_MOUNT_PERMISSIONS := 0777
NFS_SERVER := 10.128.144.128
NFS_PATH   :=  /srv/nfs/kubedata
VOLUME_BINDING_MODE := Immediate
NFS_MOUNT_OPTIONS := rsize=1048576,wsize=1048576,soft,timeo=600,retrans=2,noresvport,_netdev,nofail

export NAMESPACE STORAGE_CLASS_NAME VOLUME_BINDING_MODE NFS_MOUNT_PERMISSIONS \
	CONTROLLER_REPLICAS CONTROLLER_RUN_ON_MASTERS NFS_SERVER NFS_PATH VOLUME_BINDING_MODE \
	NFS_MOUNT_OPTIONS DRIVER_MOUNT_PERMISSIONS

include ../../Makefile

setup: install_helm
	helm repo add $(CHART_REPO) $(REPO_URL)
	helm repo update

destroy:
	@echo "Deleting $(RELEASE_NAME) yaml with version $(CHART_VERSION) from $(CHART_REPO)/$(CHART_NAME) \
		namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f $(RELEASE_NAME).yaml
	kubectl delete \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		secret mount-options

labels:
	for master in $$(kubectl get nodes --selector=node-role.kubernetes.io/master \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		-o jsonpath='{$$.items[*].metadata.name}') ; \
		do echo $$master ; \
		kubectl label --kubeconfig $(KUBECONFIG) --context $(KUBE_CONTEXT) \
		nodes $$master kubernetes.io/role=master || true ; \
	done

#apply: setup labels
apply: labels
	@echo "Templating chart $(RELEASE_NAME) yaml with version $(CHART_VERSION) from $(CHART_REPO)/$(CHART_NAME) \
		into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	helm template $(RELEASE_NAME) $(CHART_REPO)/$(CHART_NAME) \
		--namespace $(NAMESPACE) \
		--version $(CHART_VERSION) \
		--set driver.mountPermissions=$(DRIVER_MOUNT_PERMISSIONS) \
		--set controller.runOnMaster=$(CONTROLLER_RUN_ON_MASTERS) \
		--set controller.replicas=$(CONTROLLER_REPLICAS) \
		> $(RELEASE_NAME).yaml
	@echo "---" >> $(RELEASE_NAME).yaml
	envsubst < storageclass.yaml.tmpl >> $(RELEASE_NAME).yaml
	echo $(NFS_MOUNT_OPTIONS) | tr ',' '\n' | sed -e 's/^/  - /g' >> $(RELEASE_NAME).yaml
	kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f $(RELEASE_NAME).yaml
	kubectl delete secret generic mount-options \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) || true
	kubectl create secret generic mount-options \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		--from-literal mountOptions="$(NFS_MOUNT_OPTIONS)"

test:
	envsubst < test-pvc.yaml | kubectl apply \
		--context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) \
		-n default -f -
	kubectl --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) wait -n default \
		--for=condition=ready pod/busybox --timeout=120s
	kubectl --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) -n default get pvc

clean_test:
	envsubst < test-pvc.yaml | kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-n default --force=true -f -
