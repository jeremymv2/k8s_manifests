# Manage and Install K8s RBAC Policy

This facilitates the creation and management of Roles and RoleBindings for teams and their namespaces.

# Pre-requisites

- make
- kubectl
- kubeconfig for your cluster exported via `KUBECONFIG` environment variable

# Steps

1. Edit the `team-ns-binding.yaml` and adjust the policy accordingly
1. Update the `Makefile` and adjust the `TIGER_TEAM_NAME` and `TIGER_TEAM_NS` variables
1. Ensure all the k8s namespaces have been created.
1. Run `make install_teams` to apply the Roles and RoleBindings
1. As new namespaces are required, add them to the `TIGER_TEAM_NS` list and re-run `make install_teams`
1. Add support for additional teams by customizing and un-commenting lines for `LION_TEAM_NAME`, `LION_TEAM_NS`.

Remove all Roles and RoleBindings via:

```bash
make uninstall_teams
```
