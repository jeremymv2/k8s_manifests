RELEASE_NAME  := csi-driver-vsphere
CSI_VERSION := v2.5.1
K8S_MAJOR_VERSION := v1.21
NAMESPACE  := vmware-system-csi
KUBE_CONTEXT := default
KUBECONFIG ?= default
CSI_VSPHERE_CONF := csi-vsphere.conf
CONTROLLER_MANAGER_YAML := vsphere-cloud-controller-manager.yaml

$(CSI_VSPHERE_CONF):
	@echo "You must first create $(CSI_VSPHERE_CONF) from the $(CSI_VSPHERE_CONF).example file!"
	@exit 1

$(CONTROLLER_MANAGER_YAML):
	@echo "You must first create $(CONTROLLER_MANAGER_YAML) from the $(CONTROLLER_MANAGER_YAML).example file!"
	@exit 1

setup:
	curl -o $(CONTROLLER_MANAGER_YAML).example \
		-L https://raw.githubusercontent.com/kubernetes/cloud-provider-vsphere/master/releases/$(K8S_MAJOR_VERSION)/vsphere-cloud-controller-manager.yaml

destroy:
	@echo "Deleting $(RELEASE_NAME) with version $(CSI_VERSION) from \
		namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) --namespace $(NAMESPACE) \
		secret vsphere-config-secret
	kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/$(CSI_VERSION)/manifests/vanilla/vsphere-csi-driver.yaml
	kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-f storage-class.yaml
	kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/$(CSI_VERSION)/manifests/vanilla/namespace.yaml


cloud-provider-vsphere: setup $(CONTROLLER_MANAGER_YAML)
	for node in $$(kubectl get nodes -o jsonpath='{$$.items[*].metadata.name}') ; \
		do echo $$node ; \
		kubectl taint nodes $$node node.cloudprovider.kubernetes.io/uninitialized=true:NoSchedule || true ; \
	done
	kubectl apply --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-f $(CONTROLLER_MANAGER_YAML)

apply: $(CSI_VSPHERE_CONF) cloud-provider-vsphere
	@echo "Installing $(RELEASE_NAME) version $(CHART_VERSION) into \
		namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	kubectl apply --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/$(CSI_VERSION)/manifests/vanilla/namespace.yaml
	kubectl create --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) --namespace $(NAMESPACE) \
		secret generic vsphere-config-secret --from-file=csi-vsphere.conf
	kubectl apply --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/$(CSI_VERSION)/manifests/vanilla/vsphere-csi-driver.yaml
	kubectl apply --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-f storage-class.yaml
	kubectl get --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) --namespace $(NAMESPACE) \
		deployment vsphere-csi-controller
	kubectl get --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) --namespace $(NAMESPACE) \
		daemonsets vsphere-csi-node
	kubectl describe --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) --namespace $(NAMESPACE) \
		csidrivers
	kubectl get --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) --namespace $(NAMESPACE) \
		CSINode

test:
	kubectl apply --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) -n default \
		-f test-pvc.yaml
	kubectl --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) wait -n default \
		--for=condition=ready pod/busybox --timeout=120s
	kubectl --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) -n default get pvc

clean:
	kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) -n default --force=true \
		-f test-pvc.yaml
