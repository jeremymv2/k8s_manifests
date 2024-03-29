CHART_VERSION := 10.19.5
CHART_NAME := traefik
TRAEFIK_VERSION := 2.6.6
NAMESPACE  := $(CHART_NAME)
CHART_REPO := $(CHART_NAME)
REPO_URL := https://helm.traefik.io/$(CHART_NAME)
TEST_INGRESS_FQDN := demo-ingress.ethzero.cloud

include ../../Makefile

export TEST_INGRESS_FQDN

setup:
	@echo "Adding helm repo"
	helm repo add $(CHART_REPO) $(REPO_URL)
	helm repo update

destroy:
	@echo "Uninstalling chart $(CHART_NAME) from $(NAMESPACE) with context $(KUBE_CONTEXT) in \
		$(KUBECONFIG)"
	helm uninstall $(CHART_NAME) \
		--namespace $(NAMESPACE) \
		--kubeconfig $(KUBECONFIG) \
		--kube-context $(KUBE_CONTEXT)
	kubectl delete namespace $(NAMESPACE) --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG)
		--force=true || true

apply: setup
	@echo "Installing chart $(CHART_NAME) with version $(CHART_VERSION) into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) \
		in $(KUBECONFIG)"
	helm install $(CHART_NAME) $(CHART_REPO)/$(CHART_NAME) \
		--namespace $(NAMESPACE) \
		--create-namespace \
		--kubeconfig $(KUBECONFIG) \
		--kube-context $(KUBE_CONTEXT) \
		--version $(CHART_VERSION) \
		--values values.yaml \
	        --set "image.tag=$(TRAEFIK_VERSION)" --wait

cleanup_test:
	envsubst < test.yaml | kubectl -n default delete --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) -f - || true

get_master_ip:
	@echo "Determining an IP of one of the master nodes"
	$(eval NODE_HOST=$(shell kubectl --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) \
		get nodes -l node-role.kubernetes.io/master= -o \
		jsonpath='{ $$.items[0].status.addresses[?(@.type=="InternalIP")].address }'))

test: get_master_ip
	envsubst < test.yaml | kubectl -n default apply --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) -f -
	for i in {1..5}; do \
		curl -i --connect-timeout 5 \
		--fail \
		--max-time 10 \
		--retry 5 \
		--retry-delay 0 \
		--retry-max-time 40 \
		http://$(NODE_HOST):32080 \
		-H "Host: $(TEST_INGRESS_FQDN)" || true ; \
		sleep 2 ; \
	done

tlstest: get_master_ip
	envsubst < test.yaml | kubectl -n default apply --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) -f -
	for i in {1..5}; do \
		curl -i --silent --connect-timeout 5 \
		--fail \
		--insecure \
		--max-time 10 \
		--retry 5 \
		--retry-delay 0 \
		--retry-max-time 40 \
		https://$(NODE_HOST):32443 \
		-H "Host: $(TEST_INGRESS_FQDN)" || true ; \
		sleep 2 ; \
	done
