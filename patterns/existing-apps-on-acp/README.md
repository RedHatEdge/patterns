# Preparing to Run Existing Workloads on an ACP
This pattern prepares an ACP for running existing workloads found on current-generation platforms at industrial locations.

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
An ACP provides a consistent, unified platform for next generation containerized workloads, as well as existing workloads that rely heavily on existing platform functionality, such as virtualizaiton.

To support ongoing business operations, an ACP can be configured to mirror the functionality of existing platforms to support existing workloads, while keeping the forward focus for next generation workloads.

This use case can be considered "table-stakes", as existing mission-critical workloads must continue to function identically as they do currently on a new platform, as they do currently on an existing platform. This allows for a simplified migration story, and allows for modernization over time.

This pattern will highlight how various services of an ACP are consumed to provide a like for like experience for these workloads.

The following services will be highlighted:
| Service | Description | Usage in this Pattern |
| --- | --- | --- |
| Virtualization | Provides virtual machines and lifecycle functionality across different guest operating systems | Provides compute blocks, in the form of virtual machines, for running existing applications |
| Network Configuration | Configures and manages network connectivity of the platform | Replicates existing network connectivity patterns on existing platforms to an ACP |
| Storage | Provides consumable storage in multiple formats and topologies | Provides storage for running existing workloads, supporting their persistent data needs |
| IT Automation | Provides a task-orentated idempotent automation framework for managing application lifecycles | Automates and orchestrates existing workload lifecycle operations, such as installation and upgrading |
| Declarative State Configuration | Provides a simplified interface to describe infrastructure requirements with constant enforcement | Allows for simple description of the required infrastructure, which is then deployed and enforced on the ACP |

## Forces
1. **Mirroring Existing Functionality:** This pattern provides identical functionality with existing platforms for virtual workloads, allowing for identical functionality when running on an ACP.
2. **ACP Value-Add:** This pattern calls out the functionality provided by an ACP that is above and beyond what an existing platform provides, specific to running existing workloads.
3. **Hyperconverged Approach:** Mirroring existing platforms, an ACP should consume a small number of systems and present unified, consumable pools of storage and compute to support workloads.
4. **Limited Supporting Resources:** An ACP should not require much/any intervention from non-techical on-site resources, instead handling as many functions as possible autonomously.

## Solution
The solution is to both deploy an ACP according to the published standard architectures and consume the offered services to achieve the desired result.

To highlight the function of each service in this solution, an existing software stack will be used as an example: an MES stack, which uses 3 Windows-based systems: a database, a core execution system, and a web frontend system.
![MES Application](./.images/mes-application.png)

Today, this application lives on a virtualization platform that is also hosting other virtualized application:
![Virtualization Platform with Applications](./.images/virt-platform-with-apps.png)

If this virtualization platform is hyperconverged, then the underlying hardware is often abstracted into consumable pools and presented for consumption by hosted virtualized workloads by platform services:
![Hyperconverged Platform](./.images/hyperconverged-platform.png)

Often, connectivity for the virtual machines follows a "directly connected" model, where physical connections of the underlying hardware, and virtual connections from the virtual machines to the platform are combined to create logical connections between the virtual machines and the networking stack. This allows the virtual machines and their applications to appear directly connected to the network, even if multiple virtual machines on the platform are sharing a single physical link:
![Direct Connected Virtual Machines](./.images/direct-connected-virtual-machines.png)

An ACP can provide the same functionality, and provide more services that improve operational efficiency, streamline lifecycle management, and run applications that are containerized as opposed to just virtualized applications.

### Declarative State Management Service

### Virtualization Service

### Network Configuration Service

### Storage Service

### IT Automation Service

## Resulting Context

## Examples

## Rationale

## Footnotes

### Version
1.0.0

### Authors
- Josh Swanson (jswanson@redhat.com)