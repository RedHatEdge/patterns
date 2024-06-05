# Hub for ACPs Standard Services
This pattern gives a technical look at the core services run on a hub for managing ACPs.

## Table of Contents
* [Abstract](#abstract)
* [Problem](#problem)
* [Context](#context)
* [Forces](#forces)
* [Solution](#solution)
* [Resulting Content](#resulting-context)
* [Examples](#examples)
* [Rationale](#rationale)

## Abstract
| Key | Value |
| --- | --- |
| **Platform(s)** | Red Hat OpenShift |
| **Scope** | Platform Capabilities |
| **Tooling** | <ul><li>Red Hat OpenShift GitOps</li></ul> |
| **Pre-requisite Blocks** | TBD |
| **Pre-requisite Patterns** | <ul><li>[Highly Available ACP Standard Architecture](../acp-standardized-architecture-ha/README.md)</li><li>[Red Hat ACP Standard Services](../rh-acp-standard-services/README.md)</li></ul> |
| **Example Application** | N/A |

## Problem
**Problem Statement:** As multiple ACPs are deployed to 

***HERE***

## Context
This pattern represents the Red Hat provided core services that run on top of a standard ACP. It is focused on providing these core services for workloads running on the ACP itself, along with limited support for extension beyond the platform itself.

This pattern is limited to the services provided by Red Hat, either as foundational components of the platform, or run on top of the platform, allowing for capabilities beyond the platform itself.

This pattern also assumes an ACP has been established and is available, aligned to the requirements called out in the [ACP Standard Architecture](../acp-standardized-architecture-ha/README.md) pattern.

In addition, it assumes that the underlying ACP has enough resources [CPU, memory, disk] to support the installation and operation of these resources.

## Forces
1. **Ease of Use:** This pattern attempts to provide easily consumed resources as part of a holistic solution, rather than individual product functionality.
3. **Opinionated:** These services should be installed according to best practices, and leveraged in a consistent, somewhat pre-determined manner. This is done to lower the barrier to entry, and accelerate consumption of the platform.
2. **Extensibility:** While the selection and deployment of these services are opinionated, they can be easily adjusted, changed, integrated, or extended to support use cases and workflows not necessarily covered in this pattern.

## Solution
An ACP should come "out of the box" with a set of consumable services for running workloads of all types and for automating assets near and around the ACP, as needed.

The main services, provided by Red Hat, are as follows:
| Service | Red Hat Product/Functionality | Description |
| --- | --- | --- |
| Certificate Management | [cert-manager Operator](https://www.redhat.com/en/blog/the-cert-manager-operator-is-now-generally-available-in-openshift) | Provides automatic certificate management for platform and service certificates, integrates with ACME certificate providers. |
| Converged Storage | [Red Hat OpenShift Data Foundation](https://www.redhat.com/en/technologies/cloud-computing/openshift-data-foundation) | Translates physical devices into consumable storage at the platform level across multiple storage types |
| Virtualization | [Red Hat OpenShift Virtualization](https://www.redhat.com/en/technologies/cloud-computing/openshift/virtualization) | Provides virtualization capabilities across the platform for multiple types of guests and workloads |
| Network Interface Management | [Kubernetes NMState Operator](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.15/html/networking/kubernetes-nmstate) | Provides declarative configuration of network interfaces to support workloads such as storage, virtualization, and general workloads |
| IT Automation | [Red Hat Ansible Automation Platform](https://www.redhat.com/en/technologies/management/ansible) | Provides IT-level idempotent automation of workloads, networks, and more, both on the platform and outside of it |
| Declarative State Management | [Red Hat OpenShift GitOps](https://www.redhat.com/en/technologies/cloud-computing/openshift/gitops) | Provides declarative management of the platform's core services and workloads, delegating responsiblity to the platform itself |

These services provide the core set of functionality for running and operating an ACP, along with capabilities beyond the platform itself as desired. They are all shipped and supported by Red Hat.

To provide this solution, services are installed in an opinionated and ordered manner, as some rely on the others.

### Phase 0
Phase 0 is focused on enabling the platform to begin managing itself, as well as loading in the definitions of those services so the platform can install and configure them.
![Phase 0](./.images/phase0.png)

This phase is fairly static, as the initial responsiblities are simply being established.

### Phase 1
Phase 1 is focused on setting up storage, networking, and certificate management based on the definitions loaded in phase 0.
![Phase 1](./.images/phase1.png)

After installation and configuration, key services are now provided and managed:
![Phase 1 Post-Install](./.images/phase1-post-install.png)

These services provide the foundation for the "higher level" services installed in the next phase, as those services will consume them.

### Phase 2
Finally, the higher level services are installed, which consume the "lower level" services. These services are virtualization and IT automation, which rely on storage and networking provided in phase 1.
![Phase 2](./.images/phase2.png)


## Resulting Context
Once all services are deployed and configured, a core set of services are available for consumption. The ease of installation is handled at deployment time, resulting in the correct sequence and service availability.

The platform is now ready to run multiple workloads in a converged state.

## Examples
Two main examples will be considered in this pattern: deployment and management of workloads of a virtualized workload, and automation of network infrastructure outside of the platform.

### Deployment and Management of a Virtualized Workload
In this example, a virtualized workload is deployed on the platform which requires post-installation automation, as well as ongoing maintenance. The platform should be responsible for managing this workload.

#### Day -1
Before deployment on day 0, the definitions and context of the application are loaded into the declarative state management tooling, along with the appropriate automation definitions. In this example, the definitions will be loaded by an actor, however this could be automated.
![Day -1](./.images/day-1.png)

#### Day 0
On day 0, deployment is initiated, and the corresponding assets are created by the responsible services. The virtual machine, which consumes network configuration and storage, is created by OCP Virtualization, and the supporting automation playbooks and job templates are created via Ansible Automation Platform:
![Day 0](./.images/day0.png)

#### Day 1+
After the initial deployment, the operational pattern stabilizes for the lifecycle of the workload. OCP Virtualization keeps managing the virtual machine, while continued automation runs via Ansible Automation Platform ensure the workload is installed within the virtual machine, updated, and overall healthy.
![Day 1+](./.images/day1+.png)

Changes could be introducted into the available automation to undertake new workflows, such as reconfiguration of the application, if desired.

### Automation of Network Infrastructure
A second example would be leveraging the IT automation capabilities to manage a resource outside of the platform, such as network switches and firewalls.

In much the same flow as above, this example will be broken up over a few different "days" for clarity.

#### Day -1
Before beginning to automate, desired state and configurations are loaded by an actor:
![Day -1](./.images/day-1.png)

#### Day 0
With the definitions loaded, the assets specificed are created by consuming Ansible Automation Platform capabilities:
![Network Automation Day 0](./.images/network-automation-day0.png)

#### Day 1+
Now, for initial configuration and ongoing enforcement, the IT Automation service (Ansible) consumes the created automation assets, and is capable of both configuration and enforcement against devices in the network stack:
![Network Automation Day1+](./.images/network-automation-day1+.png)


## Rationale
The main rationale for deploying these core services are:
1. Ease of use for running multiple types of workloads
2. Extensibility through and beyond the platform as needed

As applications often have many requirements and many supporting processes, it's important to provide a high amount of functionality at the platform level, that can be configured and consumed to support workloads as they are onboarded to the platform.

In addition, as infrastucture becomes more complex, providing the capability to manage and automate removes complexity and error, and provides a more robust experience.

## Footnotes

### Version
1.0.0

### Authors
- Josh Swanson (jswanson@redhat.com)