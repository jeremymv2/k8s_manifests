RELEASE_NAME  := csi-driver-vsphere
CSI_VERSION := v2.5.1
NAMESPACE  := vmware-system-csi
KUBE_CONTEXT := default
KUBECONFIG ?= default
CSI_VSPHERE_CONF := csi-vsphere.conf
CONTROLLER_MANAGER_YAML := vsphere-cloud-controller-manager.yaml
VSPHERE_ENVVARS = .vcenter_config
VCENTER_USER ?= YOUR_VCENTER_USER
VCENTER_PASSWORD ?= YOUR_VCENTER_PASSWORD
VCENTER_NAME := YOUR_VCENTER_NAME
VCENTER_IP := YOUR_VCENTER_IP
DATACENTER_NAME := YOUR_DATACENTER_NAME

export VCENTER_USER VCENTER_PASSWORD

destroy:
	@echo "Deleting $(RELEASE_NAME) with version $(CSI_VERSION) from \
		namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) --namespace $(NAMESPACE) \
		secret vsphere-config-secret || true
	kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/$(CSI_VERSION)/manifests/vanilla/vsphere-csi-driver.yaml || true
	kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-f storage-class.yaml || true
	kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/$(CSI_VERSION)/manifests/vanilla/namespace.yaml || true
	envsubst < $(CONTROLLER_MANAGER_YAML) | kubectl delete --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) -f - || true
	for node in $$(kubectl get nodes -o jsonpath='{$$.items[*].metadata.name}') ; \
		do echo $$node ; \
		kubectl taint --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
			nodes $$node node.cloudprovider.kubernetes.io/uninitialized=true:NoSchedule- || true ; \
	done

envvars:
ifeq ($(VCENTER_USER),YOUR_VCENTER_USER)
	@echo "VCENTER_USER is not set! Please set in $(VSPHERE_ENVVARS) then run: source $(VSPHERE_ENVVARS)"
	exit 1
endif

cloud-provider-vsphere: envvars
	for node in $$(kubectl get nodes -o jsonpath='{$$.items[*].metadata.name}') ; \
		do echo $$node ; \
		kubectl taint --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
			nodes $$node node.cloudprovider.kubernetes.io/uninitialized=true:NoSchedule || true ; \
	done
	envsubst < $(CONTROLLER_MANAGER_YAML) | kubectl apply --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) -f -

apply: cloud-provider-vsphere
	@echo "Installing $(RELEASE_NAME) version $(CHART_VERSION) into \
		namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	kubectl apply --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/$(CSI_VERSION)/manifests/vanilla/namespace.yaml
	envsubst $(CSI_VSPHERE_CONF) | kubectl create --context $(KUBE_CONTEXT) --kubeconfig \
		$(KUBECONFIG) --namespace $(NAMESPACE) secret generic vsphere-config-secret \
		--from-file=$(CSI_VSPHERE_CONF)=/dev/stdin
	kubectl apply --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/$(CSI_VERSION)/manifests/vanilla/vsphere-csi-driver.yaml
	kubectl apply --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-f storage-class.yaml

validate:
	kubectl get --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) --namespace $(NAMESPACE) \
		nodes -o wide --show-labels
	@echo "=================================================="
	kubectl get --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) --namespace $(NAMESPACE) \
		deployment vsphere-csi-controller
	@echo "=================================================="
	kubectl get --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) --namespace $(NAMESPACE) \
		daemonsets vsphere-csi-node
	@echo "=================================================="
	kubectl describe --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) --namespace $(NAMESPACE) \
		csidrivers
	@echo "=================================================="
	kubectl get --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) --namespace $(NAMESPACE) \
		CSINode

test:
	kubectl apply --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) -n default \
		-f test-pvc.yaml
	kubectl --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) wait -n default \
		--for=condition=ready pod/busybox --timeout=120s
	kubectl --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) -n default describe pvc pvc1

cleanup_test:
	kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) -n default --force=true \
		-f test-pvc.yaml
