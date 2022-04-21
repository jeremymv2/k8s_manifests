CHART_VERSION := 4.0.17
CHART_NAME := ingress-nginx
NAMESPACE  := $(CHART_NAME)
CHART_REPO := $(CHART_NAME)
RELEASE_NAME := $(CHART_NAME)-$(shell echo $(CHART_VERSION) | sed -e 's/\./\-/g')
REPO_URL := https://kubernetes.github.io/$(CHART_NAME)
TEST_INGRESS_FQDN := demo-ingress.ethzero.cloud
TLS_KEY := tls.key
TLS_CRT := tls.crt

include ../../Makefile

export TEST_INGRESS_FQDN

%.key:
	umask 77 ; \
		openssl genrsa 2048 > $@

$(TLS_CRT): $(TLS_KEY)
	openssl req -x509 -sha256 -nodes -days 1825 -new -key $^ \
		-out $@ -subj "/CN=nginxsvc/O=nginxsvc"

setup:
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

tls: $(TLS_CRT)
	kubectl create ns $(NAMESPACE) --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) || true
	kubectl -n $(NAMESPACE) --context $(KUBE_CONTEXT) --kubeconfig $(KUBECONFIG) \
		create secret tls default-ingress-tls --key $(TLS_KEY) --cert $(TLS_CRT) || true

apply: setup tls
	@echo "Installing release $(RELEASE_NAME) into namespace $(NAMESPACE) with context $(KUBE_CONTEXT) \
		in $(KUBECONFIG)"
	helm template $(CHART_NAME) $(CHART_REPO)/$(CHART_NAME) \
		--namespace $(NAMESPACE) \
		--kube-context $(KUBE_CONTEXT) \
		--version $(CHART_VERSION) \
		--values values.yaml > $(RELEASE_NAME).yaml
	kubectl -n $(NAMESPACE) apply -f $(RELEASE_NAME).yaml --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG)

cleanup_test:
	envsubst < test.yaml | kubectl -n default delete --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) -f - || true

test:
	envsubst < test.yaml | kubectl -n default apply --context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) -f -
	curl -i --silent --connect-timeout 5 \
		--fail \
		--retry-all-errors \
		--max-time 10 \
		--retry 5 \
		--retry-delay 0 \
		--retry-max-time 40 \
		http://$(TEST_INGRESS_FQDN)
