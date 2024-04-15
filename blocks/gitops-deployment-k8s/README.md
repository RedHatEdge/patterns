# GitOps Application Deployment for Kubernetes Applications
This block is for the deployment of applications deployed to kubernetes-based platforms.

## Information
**Platform:** Red Hat Device Edge with Microshift, Red Hat Openshift
**Scope:** Application deployment, application lifecycle
**Tooling:** Git, Helm, ArgoCD
**Pre-requisite Blocks:** [Kubernetes Core Concepts](../k8s-core-concepts/README.md), [Helm Getting Started](../helm-getting-started/README.md)
**Example Application**: Process Control

## Table of Contents
* [Part 1 - Introduction to GitOps](#part-1---introduction-to-gitops)
* [Part 2 - Creating a Repository](#part-2---creating-a-repository)
* [Part 3 - Creating an Application](#part-3---creating-an-application)
* [Part 4 - Supplying Helm Parameters](#part-4---supplying-helm-parameters)
* [Part 5 - Example Deployment](#part-5---example-deployment)

## Part 1 - Introduction to GitOps
At a high level, gitops refers to using a code repository as a source of truth, and what actions are triggered from via code changes. Since the git repo is just code, typically a continous delivery tool is used to read the repo, apply changes, and track the current sync state.

![GitOps Architecture](https://argo-cd.readthedocs.io/en/stable/assets/argocd_architecture.png)

[Red Hat OpenShift GitOps](https://www.redhat.com/en/technologies/cloud-computing/openshift/gitops), based on [AgroCD](https://argo-cd.readthedocs.io/), is what will be used to demonstrate deploying from a code repository to a cluster. ArgoCD can deploy multiple types of applications from repos, such as Helm charts, straight yaml files, and more.

## Part 2 - Creating a Repository
To get started, we'll create a repository backed by this git repo:
```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: patterns-example
  namespace: openshift-gitops
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://github.com/RedHatEdge/patterns.git
```

A few quick notes:
1. Repos for ArgoCD are created as a `secret` instead of a custom resource.
2. By default, ArgoCD watches the `openshit-gitops` namespace.
3. The `argocd.argoproj.io/secret-type: repository` label is used to identify the secret as a repository.

## Part 3 - Creating an Application
Next, we'll create an application:
```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: process-control
  namespace: openshift-gitops
  labels:
    application: process-control
spec:
  destination:
    name: ""
    namespace: process-control
    server: https://kubernetes.default.svc
  project: default
  source:
    repoURL: https://github.com/RedHatEdge/patterns.git
    targetRevision: HEAD
    path: blocks/k8s-core-concepts/code/k8s
```

Under `.spec`, there are two main things to configure:
### Source
```yaml
source:
  repoURL: https://github.com/RedHatEdge/patterns.git
  targetRevision: HEAD
  path: blocks/k8s-core-concepts/code/k8s
```
This links back to our repository, defines a revision, and optionally a subpath in the repo to use.

### Deployment Destination
```yaml
destination:
  name: process-control
  namespace: process-control
  server: https://kubernetes.default.svc
```
This defines the destination cluster and namespace - here, we're deploying to the local cluster.

## Part 4 - Supplying Helm Parameters
Since Helm templates usually contain a values file with some configurable options, it may be required to supply these values via GitOps.

For our example application's helm chart, the following is found in the `values.yaml` file:
```yaml
---
# "Meta" information about the deployment
instanceAnnotations:
  companyName: "Example_Company_Inc"
  billingAddress: "100_East_Davie_Street"
  billingCity: "Raleigh"
  billingState: "North Carolina"
  billingZipCode: "27601"
  billingCountry: "US"
  deploymentAddress: "1_Main_St_SE"
  deploymentCity: "Minneapolis"
  deploymentState: "Minnesota"
  deploymentZipCode: "55414"
  deploymentCountry: "US"
  serviceProvider: "Managed_Services_Inc"
  
# Technical/resource values for the deployment
uiReplicas: 2
resourceLimitOverrides:
  control:
    cpu: 500m
    memory: 500Mi
```

To override these, we can use the `.spec.source.helm.parameters` field when defining our application:
```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: process-control
  namespace: openshift-gitops
  labels:
    application: process-control
spec:
  destination:
    name: ""
    namespace: process-control
    server: https://kubernetes.default.svc
  project: default
  source:
    repoURL: https://github.com/RedHatEdge/patterns.git
    targetRevision: HEAD
    path: blocks/k8s-core-concepts/code/k8s
    helm:
      parameters:
        instanceAnnotations:
          companyName: "Example_Gitops_Company_Deployment"
          billingAddress: "100_East_Davie_Street"
          billingCity: "Raleigh"
          billingState: "North Carolina"
          billingZipCode: "27601"
          billingCountry: "US"
          deploymentAddress: "30_36_Monument_Street"
          deploymentCity: "London"
          deploymentState: "NA"
          deploymentZipCode: " EC3R_8NB"
          deploymentCountry: "UK"
          serviceProvider: "Managed_GitOps_Services_Inc"
```

These parameters will override the supplied values when deployed.

## Part 5 - Example Deployment
To test using ArgoCD, the examples from this repository can be directly applied to a cluster with OpenShift GitOps installed:
```
oc apply -f code/argocd/
```

# TO-DO: Add screenshot of deployed application