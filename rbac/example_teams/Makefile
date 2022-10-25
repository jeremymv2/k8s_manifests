KUBECONFIG ?= default
KUBE_CONTEXT ?= default

DRY_RUN := --dry-run=client -o yaml

# add teams below
# remember multi-lines need a tab to begin the line

TEAM_NAME = devteam
TEAM_NS = foo \
	bar \
	baz \
	default

define generate_file
	sed -e 's/{{TEAM}}/$(1)/' team-ns-binding.yaml | kubectl create \
		--context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) \
		--namespace $(2) \
		$(DRY_RUN) -f - > policy/$(1)-$(2).yaml;
endef

install_teams:
	@echo "Generating manifests in policy directory."
	@$(foreach ns,$(TEAM_NS),$(call generate_file,$(TEAM_NAME),$(ns)))
	@echo "Applying the new policy.."
	for f in $$(ls -r policy/*yaml); do \
		echo ">> Applying $${f}" ; \
		cat $${f} | kubectl apply \
		--context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) \
		-f - ; done

uninstall_teams:
	@echo "Removing k8s policy.."
	for f in $$(ls -r policy/*yaml); do \
		echo ">> Deleting $${f}" ; \
		cat $${f} | kubectl delete \
		--context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) \
		-f - ; done
	rm -f policy/*yaml
