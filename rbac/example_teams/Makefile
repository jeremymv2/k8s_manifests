KUBECONFIG ?= default
KUBE_CONTEXT ?= default

DRY_RUN := --dry-run=client -o yaml

# add teams below
# remember multi-lines need a tab to begin the line

TIGER_TEAM_NAME = tiger
TIGER_TEAM_NS = foo \
	bar \
	baz \
	default

# LION_TEAM_NAME = lion
# LION_TEAM_NS = ..

define generate_file
	sed -e 's/{{TEAM}}/$(1)/' team-ns-binding.yaml | kubectl create \
		--context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) \
		--namespace $(2) \
		$(DRY_RUN) -f - > policy/$(1)-$(2).yaml;
endef

install_teams:
	@echo "Generating manifests in policy directory."
	@$(foreach ns,$(TIGER_TEAM_NS),$(call generate_file,$(TIGER_TEAM_NAME),$(ns)))
	# Uncomment below for supporting additional teams
	# @$(foreach ns,$(LION_TEAM_NS),$(call generate_file,$(LION_TEAM_NAME),$(ns)))
	@echo "Applying the RBAC policy.."
	for f in $$(ls -r policy/*yaml); do \
		echo ">> Applying $${f}" ; \
		cat $${f} | kubectl apply \
		--context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) \
		-f - ; done

uninstall_teams:
	@echo "Removing RBAC policy.."
	for f in $$(ls -r policy/*yaml); do \
		echo ">> Deleting $${f}" ; \
		cat $${f} | kubectl delete \
		--context $(KUBE_CONTEXT) \
		--kubeconfig $(KUBECONFIG) \
		-f - ; done
	rm -f policy/*yaml
