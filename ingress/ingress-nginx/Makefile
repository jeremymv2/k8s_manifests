CHART_VERSION := 4.0.17
CHART_NAME := ingress-nginx
NAMESPACE  := $(CHART_NAME)
CHART_REPO := $(CHART_NAME)
RELEASE_NAME := $(CHART_NAME)-$(shell echo $(CHART_VERSION) | sed -e 's/\./\-/g')
REPO_URL := https://kubernetes.github.io/$(CHART_NAME)
KUBE_CONTEXT := default
KUBECONFIG ?= default
HOST_FQDN := demo-ingress.ethzero.cloud

export HOST_FQDN

setup: $(CMCTL)
	@echo "Adding helm repo"
	helm repo add $(CHART_REPO) $(REPO_URL)
	helm repo update

destroy:
	@echo "Deleting release $(RELEASE_NAME) from $(NAMESPACE) with context $(KUBE_CONTEXT) in \
		$(KUBECONFIG)"
	kubectl -n $(NAMESPACE) delete -f $(RELEASE_NAME).yaml --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) || true
	kubectl delete namespace $(NAMESPACE) --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) 
		--force=true || true

apply: setup
	@echo "Installing release $(RELEASE_NAME) into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) \
		in $(KUBECONFIG)"
	helm template $(CHART_NAME) $(CHART_REPO)/$(CHART_NAME) \
		--namespace $(NAMESPACE) \
		--kube-context $(KUBE_CONTEXT) \
		--version $(CHART_VERSION) \
		--values values.yaml > $(RELEASE_NAME).yaml
	kubectl create ns $(NAMESPACE) --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) || true
	kubectl -n $(NAMESPACE) apply -f $(RELEASE_NAME).yaml --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG)

tls:
	kubectl -n $(NAMESPACE) --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		apply -f default-ingress-cert.yaml

clean:
	envsubst < test.yaml | kubectl -n default delete --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) -f - || true

test:
	envsubst < test.yaml | kubectl -n default apply --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) -f -
	#sleep 10
	#curl -vv -s $(HOST_FQDN)
