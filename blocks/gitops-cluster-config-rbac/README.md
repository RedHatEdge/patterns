# GitOps Cluster Configuration Permissions
This block gives an example of giving OpenShift GitOps cluster admin permissions for managing more than just applications.

## Information
**Platform:** Red Hat Device Edge with Microshift, Red Hat Openshift
**Scope:** Application deployment
**Tooling:** Red Hat OpenShift GitOps
**Pre-requisite Patterns:** [Kubernetes Core Concepts](../k8s-core-concepts/README.md)
**Example Application**: N/A

## Table of Contents
* [Part 1 - Creating a ClusterRoleBinding](#part-1---creating-a-clusterrolebinding)
* [Part 2 - Applying the ClusterRoleBinding](#part-2---applying-the-clusterrolebinding)

## Part 1 - Creating a ClusterRoleBinding
To properly give Red Hat OpenShift GitOps permissions to manage things at the cluster level, the various service accounts must be given cluster admin privileges. This is done through a cluster role binding:
```yaml
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: openshift-gitops-admin
subjects:
  - kind: ServiceAccount
    name: gitops-service-cluster
    namespace: openshift-gitops
  - kind: ServiceAccount
    name: openshift-gitops-applicationset-controller
    namespace: openshift-gitops
  - kind: ServiceAccount
    name: openshift-gitops-argocd-application-controller
    namespace: openshift-gitops
  - kind: ServiceAccount
    name: openshift-gitops-argocd-dex-server
    namespace: openshift-gitops
  - kind: ServiceAccount
    name: openshift-gitops-argocd-grafana
    namespace: openshift-gitops
  - kind: ServiceAccount
    name: openshift-gitops-argocd-redis
    namespace: openshift-gitops
  - kind: ServiceAccount
    name: openshift-gitops-argocd-redis-ha
    namespace: openshift-gitops
  - kind: ServiceAccount
    name: openshift-gitops-argocd-server
    namespace: openshift-gitops
  - kind: ServiceAccount
    name: openshift-gitops-operator-controller-manager
    namespace: openshift-operators
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
```

## Part 2 - Applying the ClusterRoleBinding
To test deploying from this repository, the following can be used:
```
oc apply -f code/clusterrolebinding.yaml
```

> Note:
>
> Ensure you have cluster admin privileges before attempting to create or modify the cluster role binding.