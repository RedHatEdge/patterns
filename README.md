# Edge Architecture Patterns
This repo is a collection of blocks and patterns that can be used for communicating concepts, code, and ideas around operating edge landscapes.

## Blocks
[Blocks](./blocks/) are consumable topics intended to be used to highlight a specific concept or idea in a consumable way. They should be limited in scope, as to be easily understood on their own.

## Available Blocks
| Name | Description | Status |
| ---- | ----------- | ------ |
| [Kubernetes Core Concepts](./blocks/k8s-core-concepts/README.md) | A brief introduction to kubernetes concepts | :white_check_mark: |
| [Getting Started with Helm](./blocks/helm-getting-started/README.md) | A brief introduction to Helm | :white_check_mark: |
| [GitOps Deployment to Kubernetes](./blocks/gitops-deployment-k8s/README.md) | Getting started with GitOps | :white_check_mark: |
| [GitOps Cluster Configuration Permissions](./blocks/gitops-cluster-config-rbac/README.md) | Giving OpenShift GitOps cluster-level permissions | :white_check_mark: |
| [App of Apps Pattern](./blocks/app-of-apps/README.md) | Defining and using the app-of-apps pattern | :white_check_mark: |

## Patterns
[Patterns](./patterns/) are blocks that have been assembled to create something more akin to a full architecture or deployment. They use one to many blocks, and highlight how individual concepts are integrated together.

## Available Patterns
| Name | Description | Status |
| ---- | ----------- | ------ |
| [Scaling Deployments as a Managed Service Provider](./patterns/scaling-deployments-msp/README.md) | How to manage application deployments at scale for end customers | :grey_question: Under Review |
| [Standardized Highly Available Computing Platform Architecture](./patterns/acp-standardized-architecture-ha/README.md) | The standard deployment architecture for highly-available ACPs | :grey_question: Under Review |
