RELEASE_NAME  := csi-driver-vsphere
CSI_VERSION := v2.5.1
NAMESPACE  := vmware-system-csi
KUBE_CONTEXT := default
KUBECONFIG ?= default

csi-vsphere.conf:
	@echo "You must first create csi-vsphere.conf from csi-vsphere.conf.example"

destroy:
	@echo "Deleting $(RELEASE_NAME) with version $(CSI_VERSION) into \
		namespace $(NAMESPACE) with context $(KUBE_CONTEXT) from $(KUBECONFIG)"
	kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) --namespace $(NAMESPACE) \
		secret vsphere-config-secret
	kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/$(CSI_VERSION)/manifests/vanilla/vsphere-csi-driver.yaml
	kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-f storage-class.yaml
	kubectl delete --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		-f https://raw.githubusercontent.com/kubernetes-sigs/vsphere-csi-driver/$(CSI_VERSION)/manifests/vanilla/namespace.yaml

apply: csi-vsphere.conf
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
