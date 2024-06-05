# Standardized Highly Available Computing Platform Architecture
This pattern gives a technical look at a highly available, hyper-converged style advanced computing platform on three nodes.

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
| **Pre-requisite Patterns** | <ul><li>[ACP Standard Architecture](../acp-standardized-architecture-ha/README.md)</li></ul> |
| **Example Application** | N/A |

## Problem
**Problem Statement:** Industrial sites require platforms that are capable of running various types of workloads, being responsible for the scheduling of those workloads, and providing a core set of services to be consumed for supporting those workloads and external assets, if desired.

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

To provide this solution, services are installed in an opinionated and ordered manner, as some rely on the others:

![HA ACP](./.images/ha-acp.png)

All control plane functionality is run in a highly available deployment across the nodes. Workloads that are highly available will be spread across the nodes as well.

In the event of a failure of a node or of networking to that node, the lost workloads and control plane functions are automatically rescheduled:

![HA ACP Failover](./.images/ha-acp-failover.png)

This recovery action is performed automatically by the platform, regardless of the type of workload: pods, virtual machines, etc.

***Note: add justification for this

### Network Connectivity

There are three main channels of communication for highly available ACPs: control plane/containerized workloads, bridged virtual machines, and storage. It's recommended to separate these communication channels onto dedicated links for the best performance.

![Node Connectivity](./.images/node-connectivity.png)

> Note:
>
> VLAN numbers are examples.

In this diagram, each of the communication channels are matched to a dedicated physical connection tied back to the appropriate network infrastructure. The required link speed for storage is 10Gbps/minimum. In addition, the other communication channels's links are recommended to be 10Gbps+, depending on workloads.

A remote management link is also connected if available on the hardware platform, however this is not required.

It is highly recommended to separate the vaious communication channels across subnet/VLANs, as to provide proper network segmentation for the various types of traffic.

![Cluster Connectivity](./.images/cluster-connectivity.png)

In a highly available setup, the failure of a single link or loss of a node will not impact functionality of the control plane.

For example, if a link fails:

![Link Failure](./.images/link-failure.png)

Or, if a node fails:

![Node Failure](./.images/node-failure.png)

#### Control Plane and Containerized Workload Traffic
The control plane and containerized workload traffic is any traffic using OpenShift's default ingress capabilities, along with the internal networking concepts provided by the cluster. As almost all containerized workloads leverage these concepts, application traffic will flow over this link. In addition, node to node communication for control plane traffic will also leverage this link.

Non-bridged virtual machine traffic will also use this link.

#### Storage Traffic
The storage traffic is for nodes in the cluster to replicate data being moved to and from the storage layer. Workloads do not access the storage layer on this link, instead, it is used to keep the storage system "in sync", and keeps rebalancing traffic from overwhelming other forms of traffic.

The storage traffic can be treated as "internal only", meaning the only devices in that subnet/VLAN are the node's storage links. A gateway is not required.

#### Bridged Virtual Machine Traffic
Using a network bridge for virtual machines provides the same connectivity model as what other virtualization platforms provide: the VMs appear as endpoints on the network, with their own MAC addess and IP address, and can be communicated with directly. This provides operational consistency with existing setups, however it alos bypasses the kubernetes-native networking stack, removing some of the provided segmentation and traffic control functionality. In this configuration, network segmentation and traffic isolation responsibility is offloaded to a firewall.

Multiple VLANs/subnets are possible, using VLAN interfaces on top of a bridge interface, or by scaling up the number of bridge interfaces if needed.

### HCI-style Storage Cluster
A core concept of hyper-converged infrastructure is taking available devices, such as storage devices, available on the nodes and presenting them as one consistent layer for consumption by workloads. OpenShift Data Foundation works according to this mantra as well: taking physical storage devices and presenting them as consumable storage for workloads, in a few different storage classes.

The number of physical devices required depends on throughput and IOPS requirements for workloads, however 7 physical devices will used as an example here.

Within each node, a device is dedicated to being the boot/sysroot device, then the other devices are managed by ODF:

![Node Disk Layout](./.images/node-storage.png)

Within the storage cluster, the failure domain for the storage layer is set to "node", so that an entire node can be lost without data being lost as well.

In highly protected situations, the number of copies of data can be set to 3, meaning that each node would have a copy of the data, for mamimum data durability in the event of failure.

In the event of a drive failure, the data is still available via drives on other nodes, and will continue to be served:
![Drive Failure](./.images/drive-failure.png)

Once the drive is replaced, data will be replicated from other nodes/drives.

In the event of a node failure, data will continue to be read/written, as the failure domain is set to a node:
![Storage Node Failure](./.images/storage-node-failure.png)

Upon recovery, data will be rebalanced and available copies will be restored.

## Resulting Context
Once deployed, a highly available advanced computing platform provides the functionality to run multiple types of workloads on the same common platform. 

Some highlights:
- **Platform Consolidation:** With a software-based platform providing capabilities around running many different types of workloads, a single platform on a single hardware stack can be used to consolidate workloads from many differnet platforms.
- **Ease of Operations:** With only a single platform deployed, operators need to only learn one technology stack, and interface with one management interface for running workloads or for platform maintenance.
- **Self-Management:** OpenShift provides management of workloads as part of the platform, automatically initiating failover and recovery actions when required. These are performed without manual intervention.
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
- Josh Swanson (jswanson@redhat.com)