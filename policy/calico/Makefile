KUBE_CONTEXT := default
KUBECONFIG ?= default
CALICOCFG = calicoctl.cfg
CALICOCTL = calicoctl

export KUBECONFIG KUBE_CONTEXT

$(CALICOCTL):
	curl -L https://github.com/projectcalico/calico/releases/download/v3.23.1/calicoctl-linux-amd64 -o calicoctl
	chmod +x calicoctl

%.cfg:
	envsubst < calicoctl.cfg.tmpl > $@

destroy: $(CALICOCFG)
	kubectl delete -f namespaces.yaml \
		--context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG)
	./calicoctl delete --filename policy.yaml \
		--allow-version-mismatch \
		--config $^

apply: $(CALICOCTL) $(CALICOCFG)
	kubectl apply -f namespaces.yaml \
		--context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG)
	./calicoctl apply --filename policy.yaml \
		--allow-version-mismatch \
		--config $(CALICOCFG)

test:
	@echo "Pinging 8.8.4.4 - should work from both namespaces"
	@echo "=================================================="
	for ns in production development; do \
		echo "Running in $${ns} namespace" ; \
		kubectl run tmp-shell \
        		--restart=Never --rm -i --tty \
        		--image nicolaka/netshoot -n $${ns} \
        		--context $(KUBE_CONTEXT) \
        		--kubeconfig $(KUBECONFIG) \
        		-- bash -c "ping -v -c 5 8.8.4.4 || true" ; \
		echo ; \
	done
	@echo "Pinging 8.8.8.8 - should work ONLY from production namespace"
	@echo "============================================================"
	for ns in production development; do \
		echo "Running in $${ns} namespace" ; \
		kubectl run tmp-shell \
        		--restart=Never --rm -i --tty \
        		--image nicolaka/netshoot -n $${ns} \
        		--context $(KUBE_CONTEXT) \
        		--kubeconfig $(KUBECONFIG) \
        		-- bash -c "ping -v -c 5 8.8.8.8 || true" ; \
		echo ; \
	done
