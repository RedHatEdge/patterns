# Self-Healing Distributed Control Nodes
This pattern outlines how to leverage distributed control nodes running Red Hat Device Edge to automatically reloate workloads in the event of a device failure. This behavior is described as self-healing, as the DCNs form an autonomus cluster capable of scheduling and coordination when needed.

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
| **Pre-requisite Blocks** | <ul><li>[Example ACP Networking](../../blocks/example-network-config/README.md)</li><li>[ACP Network Configuration](../../blocks/acp-network-configuration/)</li><li>[Creating Bridged Networks on an ACP](../../blocks/acp-bridge-networks/README.md)</li><li>[Creating Virtual Machines via Code](../../blocks/virtual-machines-as-code/README.md)</li><li>[Importing Installer ISOs](../../blocks/importing-installer-isos/README.md)</li><li>[Enabling Tekton Virtual Machine Tasks](../../blocks/enabling-tekton-vm-tasks/README.md)</li><li>[Creating Virtual Machine Tempaltes and Cluster Preferences](../../blocks/ocp-virt-templates-and-preferences/README.md)</li></ul> |
| **Pre-requisite Patterns** | <ul><li>[ACP Standard Architecture](../acp-standardized-architecture-ha/README.md)</li><li>[ACP Standard Services](../rh-acp-standard-services/README.md)</li><li>[Creating and Hosting RHDE Images](../creating-hosting-rhde-images/README.md)</ul> |
| **Example Application** | N/A |

## Problem
**Problem Statement:** When DCNs are tasked with running mission critical workloads, their failure can lead to service interruption, loss of functionality, and ultimately, loss of revenue. Ideally, DCNs should be able to automatically relocate and recover workloads in the event of a node failure. This functionality should exist for any workload on a DCN, assuming it is relocatable, and should happen without manual intervention.

## Context
This pattern can be applied to DCNs that are running RHDE and have the clustering components installed in their image, and have network communication established between the desired DCNs. In addition, the workloads to be relocated or recovered have been deployed to each DCN and validated to be working.

A few key assumptions are made:
- The workload(s) to be reloated are not locked to a specific DCN within the cluster, or dependent on a physical connection provided by a single DCN
- The DCNs have the clustering components installed as part of their base image
- The DCNs can communicate with each other over a network, or over multiple networks

## Forces
- **Availability:** This pattern's solution is primarily focused on workload availability, ensuring that downtime is minimized as much as possible.
- **Customizability:** The pattern's solution works for multiple types of workloads, such as bare-metal and containerized, and more. In addition, specific behaviors, such as co-location of workloads, are configurable.
- **Flexibility:** The created cluster should be able to be grown or shrunk as needed, without interrupting existing workloads or existing cluster members.
- **Autonomy:** Once configured and started, the cluster should perform all recovery and relocatable actions without needing manual intervention.

## Solution
The solution for this pattern is to leverage pacemaker clustering across DCNs running RHDE, where the workloads to monitor and relocate and configured within the cluster, and any additional recovery or co-location constraints have also been configured.

![Pipeline Overview](./.images/pipeline-overview.png)

Once the cluster is es

### Pipeline Overview


## Resulting Context
The resulting context is the ability to specify image requirements or definitions, and have the platform automically handle the process to create and host those images. Image composition and hosting should happen without manual intervention, and be easily repeated and customized, removing any management burden associated with the process.

## Examples

### Creating a kernel-rt/Deterministic Image
### Creating an HMI Image
### Creating an Updated Image

## Rationale
The rationale for this pattern is to have a completely automated way to create and host RHDE images, such that device provisioning and management is far more easily adopted over having to manually maintain infrastructure to serve the same purpose. Simple image defintiions should be fed into this automated process, with the expected output being consumable images.

## Footnotes

### Version
1.0.0

### Authors
- Josh Swanson (jswanson@redhat.com)