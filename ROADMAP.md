# Roadmap
This is a rough roadmap for this repository, calling out blocks and patterns that will be developed and added.

To request content be added to this repo, [open an issue](https://github.com/RedHatEdge/patterns/issues/new/choose).

## Planned Patterns
| Name | Description | Assignee |
| --- | --- | --- |
| SR-IOV for Virtual Machines | High performant networking configuration for virtualized workloads | Josh |
| Exposing Services on a Virtual Machine via MetalLB | Using MetalLB to expose services on a virtual machine | Josh |
| Exposing Services on a Virtual Machine via Load Balancer | Using load balancing to expose a service on a virtual machine | Josh |
| Exposing Services on a Virtual Machine via NodePort | Using a nodeport service to expose a service on a virtual machine | Josh |
| Virtual Machine Connectivity Comparison | Compare connectivity models for virtual machines and their services | Josh |
| Sizing Guide | Sizing an ACP Based on Amount of IO | Josh |
| Offline ACP Install | Install an ACP without internet connection from bootstrap | Josh |
| Bootstrap Setup | Setup bootstrap to serve OCP content for install and standard services install | Josh |
| Creating and Hosting RHDE Images on an ACP | How a Red Hat Device Image can be created and hosted using an ACP's core services | Josh |

## Planned Blocks
| Name | Description | Supports Pattern | Assignee |
| --- | --- | --- | --- |
| Configuring SR-IOV on an ACP | How to install/configure SR-IOV for NICs | SR-IOV for Virtual Machines | Josh |
| Attaching VMs to a Bridged Network | How to add a network interface to a bridge | Virtualization on an ACP | Josh |
| Running Pipelines via CLI | How to initiate a pipeline run from the CLI (or other tooling) | Creating Windows Virtual Machine Templates for Virtualization on an ACP | Josh |
| Configuring a Platform to Update from a Mirrored Source | Configure OCP ICSPs to use a mirror | [Caching Update Content on an ACP](./patterns/caching-platform-updates-on-an-acp/README.md) | Josh |