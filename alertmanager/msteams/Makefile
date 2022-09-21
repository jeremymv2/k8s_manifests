NAMESPACE  := pf9-monitoring
CHART_NAME := prometheus-msteams
CHART_REPO := $(CHART_NAME)
CHART_VERSION := 1.3.1
APP_VERSION_TAG := v1.5.1
RELEASE_NAME := $(CHART_NAME)-$(shell echo $(CHART_VERSION) | sed -e 's/\./\-/g')
REPO_URL   := https://prometheus-msteams.github.io/prometheus-msteams/
CONNECTOR_NAME := msteams
CONNECTOR_NAME_URL := https://CHANGEME.webhook.office.com/webhookb2/CHANGEME/IncomingWebhook/CHANGEME/CHANGEME

export APP_VERSION_TAG CONNECTOR_NAME CONNECTOR_NAME_URL

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
	envsubst < values.yaml.tmpl > values-$(RELEASE_NAME).yaml
	helm template $(RELEASE_NAME) $(CHART_REPO)/$(CHART_NAME) \
		--namespace $(NAMESPACE) \
		--values values-$(RELEASE_NAME).yaml \
		--version $(CHART_VERSION) \
		> $(RELEASE_NAME).yaml
	kubectl apply \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		-f $(RELEASE_NAME).yaml
	kubectl delete secret alertmanager-sysalert \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE)
	envsubst < prometheus-secret.yaml | kubectl create secret generic alertmanager-sysalert \
		--from-file=alertmanager.yaml=/dev/stdin \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE)
	kubectl delete pod alertmanager-sysalert-0 \
		--kubeconfig $(KUBECONFIG) \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE)

test:
	@echo "Run this command:"
	@echo kubectl port-forward svc/prometheus-msteams 2000:2000 \
		--context $(KUBE_CONTEXT) \
		--namespace $(NAMESPACE) \
		--kubeconfig $(KUBECONFIG)
	@echo
	@echo "Now run this in another terminal"
	@echo curl -X POST -d @prom-alert.json http://localhost:2000/$(CONNECTOR_NAME)
