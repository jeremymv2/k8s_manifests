DRY_RUN := --dry-run=client -o yaml

# add teams below
# remember multi-lines need a tab to begin the line

TEAM_NAME = devteam
TEAM_NS = airflow \
	postgres \
	datalake

define generate_file
	kubectl create ns $(2) $(DRY_RUN) | kubectl apply -f - ; \
		sed -e 's/{{TEAM}}/$(1)/' team-ns-binding.yaml | kubectl create --namespace $(2) $(DRY_RUN) -f - > policy/$(1)-$(2).yaml;
endef

install_teams:
	@echo "Creating namespaces and generating manifests in policy directory."
	@$(foreach ns,$(TEAM_NS),$(call generate_file,$(TEAM_NAME),$(ns)))
	@echo "Applying k8s policy.."
	kubectl apply -f policy/

uninstall_teams:
	@echo "Removing k8s policy.."
	kubectl delete -f policy/
	rm -f policy/*yaml
