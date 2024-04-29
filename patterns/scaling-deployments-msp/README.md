# Scaling Deployments as a Managed Service Provider
This pattern gives an opinionated look at scaling up deployment capabilities using gitops tooling from the perspective of a managed service provider.

## Problem
**Problem Statement:** When acting as a managed service provider, it can often be challenging to install and run many deployments of an application at scale for customers.

## Abstract
| Key | Value |
| --- | --- |
| **Platform(s)** | <ul><li>Red Hat Device Edge with Microshift</li><li>Red Hat Openshift</li></ul> |
| **Scope** | Application deployment |
| **Tooling** | <ul><li>Red Hat OpenShift GitOps</li></ul> |
| **Pre-requisite Blocks** | <ul><li>[Kubernetes Core Concepts](../../blocks/k8s-core-concepts/README.md)</li><li>[Scaling GitOps Deployment](../scaling-gitops-deployment-k8s/README.md)</li><li>[Helm Getting Started](../helm-getting-started/README.md)</li><li>[GitOps Deployments](../gitops-deployment-k8s/README.md)</li><li>[App of Apps](../../blocks/app-of-apps/README.md)</li></ul>
| **Example Application** | Process Control |

**Resolution:** Using modern tooling and processes, the main goals of this pattern are:
1. Increase the number of instances for customers that can be managed
2. Increase the consistency between deployments
3. Allow for customizations between deployments relative to customer requirements
4. Leverage code and code reviews as the "source of truth" for deployments

## Context
This pattern can be applied where a high number of deployments, usually for external entities such as customers, are being managed from a central location, and deployed to a single target. Current deployment processes are typically manually initiated or completely manual, and deployments have drifted or become inconsistent over time.

## Forces
1. **Scalability:** This pattern allows for easy scalability by adding or removing deployments as needed, up to a nearly limitless number of deployments across customers.
2. **Modularity:** Each deployment can be individually managed or adjusted using the same core  reduces complexity.
3. **Customization:** MSPs can customize the set of applications based on the specific needs of their customers, providing a tailored solution.
4. **Maintenance:** Day 2+ operations are all handled through the same automation path, and can include updates/upgrades, automatic rollbacks, and more.
5. **Resource Efficiency:** Since tooling and technology are responsible for the deployments, time and soft dollar expenses are saved.
6. **Isolation:** This pattern allows for isolation down to the individual deployment level, allowing for proper boundries around customers and deployments, and even multiple deployments within customers.
7. **Flexibility:** MSPs can easily onboard new customers, retire old customers, and contextualize/customize where required through one process.

## Solution
![MSP Process](./.images/msp-process.png)







## Resulting Context


## Example








# OLD, IGNORE



## Limitations
- This patterns assumes one deployment target, and one common namespace for all deployments within a customer - this is, however customizable.

## Processes
Four example processes are showcased in this pattern:
1. [Onboarding New Customer and Deploying Software](#onboarding-new-customer-and-deploying-software)
2. [Adding Deployment to Existing Customer](#adding-deployment-to-existing-customer)
3. [Removing Deployment from Existing Customer](#removing-deployment-from-existing-customer)
4. [Removing Customer Completely](#removing-customer-completely)

### Onboarding New Customer and Deploying Software
For this example, the onboarding and initial deployment process will exist as so:
![Example Onboarding with Deployment Process](./.images/onboard-new-customer-with-deployment.drawio.png)

This can be mapped to the various stakeholders and technologies:
![Mapping to Stakeholders and Technology](./.images/onboard-new-customer-with-deployment-map.png)

Resulting in the following process at the technology level:
![Technical Rollout of New Customer and Deployment](./.images/onboard-new-customer-with-deployment-technical.drawio.png)

# TO-DO
### Adding Deployment to Existing Customer

### Removing Deployment from Existing Customer

### Removing Customer Completely

