NAMESPACE  := kube-system
CHART_NAME := nfs-subdir-external-provisioner
CHART_REPO := $(CHART_NAME)
CHART_VERSION := v4.0.16
APP_VERSION_TAG := v4.0.2
RELEASE_NAME := $(CHART_NAME)
REPO_URL   := https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner
NFS_SERVER := 10.128.144.128
NFS_PATH   :=  /srv/nfs/kubedata
STORAGE_CLASS_NAME := nfs-client
ARCHIVE_ON_DELETE_BOOL := false
ACCESS_MODE := ReadWriteMany
NFS_MOUNT_OPTIONS := rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev,nofail
VOLUME_BINDING_MODE := WaitForFirstConsumer

export NAMESPACE STORAGE_CLASS_NAME NFS_MOUNT_OPTIONS

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

apply: setup
	@echo "Templating chart $(RELEASE_NAME) yaml with version $(CHART_VERSION) from $(CHART_REPO)/$(CHART_NAME) \
		into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	helm template $(RELEASE_NAME) $(CHART_REPO)/$(CHART_NAME) \
		--namespace $(NAMESPACE) \
		--version $(CHART_VERSION) \
		--set image.tag=$(APP_VERSION_TAG) \
		--set nfs.server=$(NFS_SERVER) \
    		--set nfs.path=$(NFS_PATH) \
		--set nfs.mountOptions="{$(NFS_MOUNT_OPTIONS)}" \
    		--set storageClass.name=$(STORAGE_CLASS_NAME) \
    		--set storageClass.archiveOnDelete=$(ARCHIVE_ON_DELETE_BOOL) \
    		--set storageClass.accessModes=$(ACCESS_MODE) \
		> $(RELEASE_NAME).yaml
	sed -i.bak -e "s/\(reclaimPolicy: .*\)/\1\nvolumeBindingMode: WaitForFirstConsumer/" $(RELEASE_NAME).yaml
	rm $(RELEASE_NAME).yaml.bak
	kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f $(RELEASE_NAME).yaml

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
