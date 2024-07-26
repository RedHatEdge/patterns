# Virtualization on an ACP
This pattern gives a technical look at how virtual machines are created and managed on an ACP via consumption of the virtualization and gitops services.

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
| **Scope** | Virtualization |
| **Tooling** | <ul><li>Red Hat OpenShift GitOps</li></ul> |
| **Pre-requisite Blocks** | <ul><li>[Example ACP Networking](../../blocks/example-network-config/README.md)</li><li>[ACP Network Configuration](../../blocks/acp-network-configuration/)</li><li>[Creating Bridged Networks on an ACP](../../blocks/acp-bridge-networks/README.md)</li></ul> |
| **Pre-requisite Patterns** | <ul><li>[ACP Standard Architecture](../acp-standardized-architecture-ha/README.md)</li><li>[ACP Standard Services](../rh-acp-standard-services/README.md)</li></ul> |
| **Example Application** | N/A |

## Problem
**Problem Statement:** ACPs are designed to handle multiple types of workloads concurrently while maintaining management and operations consistency. Virtual machines, a specific type of workload provided by the virtualization service, should have the same deployment and management flow as other types of workloads, such as containerized workloads. Ideally, virtual machines should also use the same tooling for the initial deployment and management.

## Context
This pattern can be applied to ACPs where virtual machines are required to run workloads, and the ACP has been setup and configured according the the [Standard HA ACP Architecture](../acp-standardized-architecture-ha/README.md). In addition, the standard set of [ACP Services](../rh-acp-standard-services/README.md) have been deployed and are ready to be consumed. GitOps tooling will be used to deploy the virtual machines, and can be used to update/change them over their lifecycle.

A few key assumptions are made:
- The intended context of the platform aligns to the [Standard HA ACP Architecture](../acp-standardized-architecture-ha/README.md)
- The standard set of [ACP Services](../rh-acp-standard-services/README.md) are available for consumption.
- Physical connections, such as power and networking, have been made to the target hardware
- The upstream network configuration is completed and verified

## Forces
- **Management Tooling Consolidation:** This pattern is focused on leveraging common tooling to manage the deployment and lifecycle of virtual machines, identically to how other workloads are deployed and managed on an ACP.
- **Extensibility:** The solution outlined in this pattern focuses on the initial deployment of a virtual machine, along with how to make adjustments during normal operation, however additional hooks/steps can be added with ease.
- **Broad Applicability:** This pattern's solution works for almost all types of virtual machine, regardless of required compute resources, network connections, or operating system.

## Solution
The solution for this pattern involves consuming the virtualization and gitops services to deploy and manage virtual machines. This is accomplished by defining the desired virtual machines and their configurations, then leveraging GitOps tooling to run the deployment, and optionally, make changes over time.

The virtual machine definitions are stored as code, and automatically tracked and deployed by GitOps tooling. This allows for a clear audit trail and ease of management without needing another management tool specifically for virtual machines.

Typically, the virtual machine definitions include information such as requested resources (CPU/memory), desired operating system, and any additional configuration details as needed.

![Define Virtual Machine](./.images/define-vm.png)

To deploy and manage virtual machines in a declarative method, the gitops service of the platform is leveraged. It reads in the virtual machine definitions, then consumes the virtualization service to instantiate and manage virtual machines.

![Deploy Virtual Machine](./.images/deploy-vm.png)

The virtual machines consume various services from the platform, depending on their configuration. For example, a virtual machine bridged onto the network that leverages converged storage would consume those respective services to operate.

![Running Virtual Machine](./.images/running-vm.png)

The provided services are scalable, allowing for as many virtual machines as the underlying compute hardware provides, using all the same flow and technologies.

![Full Flow](./.images/full-flow.png)

## Resulting Context
The resulting context is the ability to deploy and manage virtual machines at scale on ACPs. These virtual machines can be of multiple operating systems, resource requirements, and more, all contained within a defintion stored as code, and acted on in a declarative fashion. The platform's core services and core functionality ensure the virtual machines are scheduled and running automatically. In addition, the provided services such as converged storage and network configuration allow for persistent storage and advanced connectivity models.

### WIP BELOW ###

## Examples

## Rationale

## Footnotes

### Version
1.0.0

### Authors
- Josh Swanson (jswanson@redhat.com)