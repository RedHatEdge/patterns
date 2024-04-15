# Installing Operators via YAML
This block centers around installing operators through a automatiable method over using the WebUI.

##

## Table of Contents
1. Brief Introduction to Operators
2. YAML-based Operator Installs
3. Deploying Operator-Based Resources
3. Example Operator Deployment

## Part 1 - Brief Introduction to Operators
Operators are extentions to Kubernetes, allowing for custom resource definitions that expand the resources that can be leveraged and managed within a cluster.

Because operators are an extension of the cluster, they can provide additional functionality, such as providing virtual machines as a cluster resource, or provide applications as a custom resource, such as instances of Ansible Controller.

## Part 2 - YAML-Based Operator Installation
Typically, installing an operator involves a few different components: a namespace to install the operator into, an operator group, and a subscription. Not all operators require all three, so be sure to check the operator's documentation.

Let's consider the [cert-manager](https://docs.openshift.com/container-platform/4.15/security/cert_manager_operator/cert-manager-operator-install.html) operator as an example, which requires a namespace, operator group, and subscription.

### Namespace
First, we can configure a namespace, named `cert-manager-operator`:
```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager-operator
```

### Operator Group
An OperatorGroup is used to target appropriate RBAC for an operator to specific namespaces. Not all operators support targeting specific namespaces, however for the `cert-manager` operator, we'll want it to have permissions within its namespace:
```yaml
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: cert-manager-operator
  namespace: cert-manager-operator
spec:
  upgradeStrategy: Default
  targetNamespaces:
    - cert-manager-operator
```

### Subscription
A subscription is an intention to install an operator. It's what triggers the installation of an operator from a catalog source.
```yaml
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-cert-manager-operator
  namespace: cert-manager-operator
spec:
  channel: stable-v1
  installPlanApproval: Automatic
  name: openshift-cert-manager-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: cert-manager-operator.v1.13.0
```

With these resouces configured, the operator will be installed by the cluster.

## Part 3 - Deploying Operator-Based Resources
Since operators are extentions of Kubernetes, deploying resources that they manage is done the same way as any other resource. For example, to deploy a `CertManager`, a resource provided by the `cert-manager` operator, the same format as deploying a `pod` or `service` is used:
```yaml
---
apiVersion: operator.openshift.io/v1alpha1
kind: CertManager
metadata:
  name: cluster
spec:
  logLevel: Normal
  managementState: Managed
  observedConfig: null
  operatorLogLevel: Normal
  unsupportedConfigOverrides: null
  controllerConfig:
    overrideArgs:
      - "--dns01-recursive-nameservers=8.8.8.8:53,1.1.1.1:53"
      - "--dns01-recursive-nameservers-only"
```

Once applied, the operator will take the necessary steps to create the resource as specificed.

> Note:
>
> Be sure to wait for the operator installation to finish before attempting to deploy an operator-managed resource.

## Part 4 - Example Deployment
To test deploying the `cert-manager` operator, apply the resources in the code repo:
```
# Namespace
oc apply -f code/operators/cert-manager/namespace.yaml

# OperatorGroup
oc apply -f code/operators/cert-manager/operatorgroup.yaml

# Subscription
oc apply -f code/operators/cert-manager/subscription.yaml
```

Once the operator installation is complete, a CertManager resource can be created:
```
# CertManager
oc apply -f code/operators/cert-manager/certmanager.yaml
```