# Manage and Install K8s RBAC Policy

This facilitates the creation and management of Roles and RoleBindings for teams and their namespaces.

# Pre-requisites

- make
- kubectl
- kubeconfig for your cluster either at `~/.kube/config` or exported via `KUBECONFIG` environment variable

# Steps

1. Edit the `team-ns-binding.yaml` and adjust the policy accordingly
1. Update the `Makefile` and adjust the `TEAM_NAME` and `TEAM_NS` variables
1. Run `make install_teams` to create the namespaces and apply the Roles and RoleBindings
