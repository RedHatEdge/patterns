# Running Existing Workloads on an ACP
This pattern showcases running existing workloads, specifically applications relying heavily on virtualization, on an ACP.

As ACPs are next-generation platforms, their functionality and provided services are capable of running modern workloads, however full functionality for existing workloads is provided via the ACP's core services.

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
| **Platform(s)** | TBD |
| **Scope** | TBD |
| **Tooling** | TBD |
| **Pre-requisite Blocks** | TBD |
| **Example Application** | TBD |

## Problem
**Problem Statement:** While next generation workloads are being introducted by vendors in the industrial control space, organizations will not adopt them immediately, instead running their existing set of workloads on top of the appropriate platform to support business operations.

To support ongoing operations powered by existing workloads, as well as provide full support for next-generation workloads all on a single platform, ACPs must provide consumable services to support existing workloads, and allow for topologies and configurations that mimic existing platforms.

## Context
This pattern focuses on running existing applications, predominately virtualized, on an ACP, and how the platform provides consumable services to support the workloads.

This use case can be considered "table-stakes", as existing mission-critical workloads must continue to function identically as they do currently on a new platform, as they do currently on an existing platform.

This pattern will highlight how various services of an ACP are consumed to provide a like for like experience for these workloads.

The following services will be highlighted:
| Service | Description | Usage in this Pattern |
| --- | --- | --- |
| Virtualization | Provides virtual machines and lifecycle functionality across different guest operating systems | Provides compute blocks, in the form of virtual machines, for running existing applications |
| Network Configuration | Configures and manages network connectivity of the platform | Replicates existing network connectivity patterns on existing platforms to an ACP |
| Storage | Provides consumable storage in multiple formats and topologies | Provides storage for running existing workloads, supporting their persistent data needs |
| IT Automation | Provides a task-orentated idempotent automation framework for managing application lifecycles | Automates and orchestrates existing workload lifecycle operations, such as installation and upgrading |
| Declarative State Configuration | Provides a simplified interface to describe infrastructure requirements with constant enforcement | Allows for simple description of the required infrastructure, which is then deployed and enforced on the ACP |

### TO DO BELOW

## Forces
1. **Ease of Use:** This pattern represents a platform that's ready "out of the box", with customizations applied automatically at or immediately after installation, so the platform is ready for many different types of workloads.
2. **Flexibility:** While this pattern is heavily opinionated, it is flexible, and can be expanded, changed, or adjusted due to new requirements over time.
3. **Consistency:** ACPs should be treated as cattle, being deployed in a consistent fashion across many sides, allowing for a consistent deployment target across site boundries.
4. **Compact:** The ACP's control functionality and services are located on a single node, allowing for a smaller overall footprint.
5. **Limited Supporting Resources:** Edge sites are typically constrained on power and cooling, while the workloads still require a platform capable of providing consistent core services. The platform should fit within these power and cooling constraints.

## Solution
By combining the platform capabilities of Red Hat OpenShift with some additional tooling and opinionated hardware requirements, the following goals can be achieved:
1. A compact, converged control/worker node on a single physical system
2. Dynamic local storage, presenting local disks as one consumable resource
3. Ability to run virtual machine based workloads alongside containerized workloads on one platform
4. Platform configured for local autonomy and resiliency

At a high level, a non highly-available ACP contains a single physical node, acting as both control plane and worker, connected to a networking stack:

![Non-HA ACP](./.images/non-ha-acp.png)

All control plane functionality is run on the single physical node, alongside the standard services and deployed workloads

***Note: add justification for this

### Network Connectivity

There are two main channels of communication for non highly-available ACPs: control plane/containerized workloads and virtual machine traffic. It's not required to separate these across NICs, but doing so can improve throughput and provide more flexibility when running virtualized workloads.

![Node Connectivity](./.images/node-connectivity.png)

> Note:
>
> VLAN numbers are examples.

In this diagram, each of the communication channels are matched to a dedicated physical connection tied back to the appropriate network infrastructure. Generally, the faster the link speed, the more throughput for workloads, however 1Gbps links are generally acceptable.

A remote management link is also connected if available on the hardware platform, however this is not required.

It is highly recommended to separate the vaious communication channels across subnet/VLANs, as to provide proper network segmentation for the various types of traffic.

Since the platform is not highly-available, the loss of a node will cause the loss of all workloads on the platform, however, they'll be recovered when the node is brought back online.

For example, if a node fails:

![Node Failure](./.images/node-loss.png)

Then, when the node is recovered:

![Node Recovered](./.images/node-recovered.png)

#### Control Plane and Containerized Workload Traffic
The control plane and containerized workload traffic is any traffic using OpenShift's default ingress capabilities, along with the internal networking concepts provided by the cluster. As almost all containerized workloads leverage these concepts, application traffic will flow over this link. In addition, node to node communication for control plane traffic will also leverage this link.

Non-bridged virtual machine traffic will also use this link.

#### Bridged Virtual Machine Traffic
Using a network bridge for virtual machines provides the same connectivity model as what other virtualization platforms provide: the VMs appear as endpoints on the network, with their own MAC addess and IP address, and can be communicated with directly. This provides operational consistency with existing setups, however it also bypasses the kubernetes-native networking stack, removing some of the provided segmentation and traffic control functionality. In this configuration, network segmentation and traffic isolation responsibility is offloaded to a firewall.

Multiple VLANs/subnets are possible, using VLAN interfaces on top of a bridge interface, or by scaling up the number of bridge interfaces if needed.

### Dynamic Local Storage
As opposed to the highly-available architecture with converged storage, a non highly-available architecture provides storage in a similar way, however with the limitation of only having a single node.

Similar to the converged storage storage, the dynamic local storage service takes over control of the data disks in the node, and presents them as one consumable pool that workloads can utilize. In fact, except for workloads with multi-access or object storage requirements, deployment and operation will be identical between highly-available and non highly-available platforms.

The number of physical devices required depends on throughput and IOPS requirements for workloads, however 7 physical devices will used as an example here.

Within each node, a device is dedicated to being the boot/sysroot device, then the other devices are consumed to provide dynamic local storage:

![Node Storage](./.images/node-storage.png)

Storage can also be configured for redundancy through mirroring and striping, depending on requirements.

#### Mirroring

Mirroring allows for data to be written to multiple drives, protecting against individual drive failures:

![Node Storage Mirroring](./.images/node-storage-mirroring.png)

In the event of a drive failure, data remains available:

![Node Storage Mirroring Failure](./.images/node-storage-mirrored-failure.png)

Once the drive is replaced, data can be reconstructed from the mirror:

![Node Storage Mirroring Reconstruction](./.images/node-storage-mirroring-reconstruction.png)

#### Striping

Striping allows for data to be spread across drives, providing a balance between performance and redundancy:

![Node Storage Striping](./.images/node-storage-striped.png)

In the event of a drive failure, the data is still available via drives on other nodes, and will continue to be served:
![Node Storage Striping Failure](./.images/node-storage-striped-failure.png)

Once the drive is replaced, data will be reconstructed from other drives.

![Node Storage Striping Reconstruction](./.images/node-storage-striped-reconstruction.png)

## Resulting Context
Once deployed, a non highly-available advanced computing platform provides the functionality to run multiple types of workloads on the same common platform. 

Some highlights:
- **Platform Consolidation:** With a software-based platform providing capabilities around running many different types of workloads, a single platform on a single node can be used to consolidate workloads from many differnet platforms.
- **Ease of Operations:** With only a single platform deployed, operators need to only learn one technology stack, and interface with one management interface for running workloads or for platform maintenance.
- **Self-Management:** The platform provides management of workloads as part of the platform, automatically initiating failover and recovery actions when required. These are performed without manual intervention.
- **Scalability:** As power and cooling allow for more compute, the ACP automatically consumes and presents these additional resources for workloads to consume.
- **Consistency:** As one platform is used across multiple deployment sites, workloads can easily be deployed and scaled, and training resources can be reused at each deployment location.
- **Security:** By default, an ACP comes with a high level of pre-configured, preventing the deployment of insecure workloads, and providing some segmentation between users and workloads. These are configurable, allowing for far more control and restrictions on workloads as needed.

## Examples
![ACP with Workloads](./.images/acp-with-workloads.png)

In this example, three core categories of workloads are running on a converged platform, leveragng the same hardware footprint and platform, despite being different types of workloads with different requirements.

These workloads are examples, however they are representitive of workloads found on ACPs.

Ultimately, these workloads all share base requirements of connectivity, storage, and a platform to orchestrate them, however how those resources are consumed is different per workload. The ACP is responsible for providing these common resources, and faciliting their consumption.

### Control Plane Functionality
This set of functions are related to the operation of the platform and how the underlying hardware is both abstracted and presented, as well as managed over time by the platform.

This functionality is related to the ongoing availablity and capabilities of the platform, and is all self-managed, self-deployed, and simply consumed by workloads or operators.

### Manufacturing Execution System - Containerized
This workload provides the core set of functions of an MES: monitoring, tracking, documenting, and controlling the production of products at a single or many sites.

In this example, the application has been containerized, leveraging native k8s functionality provided by the ACP. Since this is a "next generation" workload with requirements around running containerized workloads, the core operating concepts of the ACP, based on k8s, are heavily utilized.

### Distributed Control System - Virtualized
This workload is representitive of a supervisory system atop industrial equipment and devices, and is a more traditional workload with requirements to match.

This application is broken up into a components, however those components are deployed on top of virtual machines, which consume resources of the ACP.

## Rationale
The two main rationalizations for a modern compute platform, such as an ACP are:
1. Running Existing Applications that Power the Business
2. Providing for Next-Generation Workloads without Replatforming

A modern approach to computing, such as an ACP as outlined above, provide for both of these points without requiring the replacement of the platform when new applications are deployed.

While there's value in running the workloads found today, applications are being modernized by internal teams, by vendors, etc, and providing a consistent, capable platform allows for any type of workload to recieve the same benefits as others, regardless of the individual differences in application type, deployment method, or operating method.

## Footnotes

### Version
1.0.0

### Authors
- Hendrik van Niekerk (hvanniek@redhat.com)
- Josh Swanson (jswanson@redhat.com)