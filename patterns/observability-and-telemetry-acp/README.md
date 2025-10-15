# Observability and Telemetry on an ACP
This pattern outlines a solution for observability and telemetry on an ACP, and for DCNs (and related devices) within the same network boundry as an ACP. It can be used as part of a enterprise-wide observability and telemtry approach, however this pattern will focus on the ACP and "lower" layers within a single site.

ACPs provide a level of observability and telemetry out-of-the-box, with the main focus being to track the health and performance of the platform itself. This can be extended to additional workloads running on the platform for deeper visibility and better efficiency when troubleshooting.

In addition, ACPs can provide [OpenTelemetry](https://opentelemetry.io/) aligned functionality for workloads on the platform, as well as workloads or devices running external to the platform, but are reachable by the platform.

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
| **Platform(s)** | Advanced Compute Platform |
| **Scope** | Installation |
| **Tooling** | <ul><li>Red Hat Advanced Cluster Management</li></ul> |
| **Pre-requisite Blocks** | N/A |
| **Pre-requisite Patterns** | <ul><li>[ACP Standardized Architecture - Highly Available](../acp-standardized-architecture-ha/README.md)</li><li>[ACP Standardized Architecture - Non-Highly Available](../acp-standardized-architecture-non-ha/README.md)</li></ul> |
| **Example Application** | N/A |

## Problem
**Problem Statement:** ACPs provide a full suite of hosting and automation capabilities to support many different types of workloads, however a key element to proper operation of a platform or system is visibility into the performance, metrics, and logs of the components of the system. In addition, metrics, logs, and traces are often generated non-standard formats, making them hard to visualize and correlate.

ACPs should be able to provide the functionality to ingest, normalize, transform, store, and visualize key information about the platform itself, along with workloads hosted on the platform. In addition, the platform should be able to scrape or ingest metrics, logs, and traces from other elements of a system, such as DCNs or their applications, assuming there is sufficient network connectivity. 

## Context
This pattern is best applied when there is a need for visibilty into the performance of a system, when an ACP is hosting some or all of the required components. This pattern's soluction provides deeper insights into overall performance, and can help with troubleshooting, right-sizing, and other operational tasks, which often require a holistic view of a system and the components.

This pattern focues on the "infrastructure" pieces provided by an ACP. Metrics, logs, and traces are often functions of  operating systems, platforms, and applications, with an ACP acting as the centralized place to collect, store, and visualize these metrics. Optionally, normalizations, filtering, and other common operations for incoming metrics, logs, and traces can be handled by the ACP, offloading the requirement from smaller, less resource-heavy devices and platforms.

A few key assumptions are made:
- The intended context of the platform aligns to the [Standard HA ACP Architecture](../acp-standardized-architecture-ha/README.md), the [Standard Non-HA ACP Architecture](../acp-standardized-architecture-non-ha/README.md), or any valid ACP architecture as needed.
- The standard set of [ACP Services](../rh-acp-standard-services/README.md) are available for consumption.
- Connectivity from the various devices and applications to/from the ACP is available when external sources of information is desired.

Observability and telemetry are often sprawling and complicated topics. This pattern will provide an opinionated look, using some base examples, however the functionality outlined here is highly extensable. This pattern is not intended to capture every possible scenario, instead, it provides the foundational base from which a proper system-level view can be built.

## Forces
- **Highly Automated:** This pattern outlines how an ACP installs and manages the various components and pieces required to build a full obersability and telemetry stack, with all elements managed by the ACP itself.
- **Simplicity:** This pattern's solution is designed to allow for non-IT personnel to state the need for various components within a full observability and telemetry stack, and allow for the platform to install and manage those components without needing to understand the full install/lifecycle process.
- **Scalablility:** This pattern's solution allows for a large amount of information to be ingested and processed by the platform, and even for it to be deployed in a highly-available state, according to requirements.
- **Customization:** This pattern's solution allows for full customization of the various components within a obersvability and telemetry stack, allowing for the ingestion, storage, and visualization of metrics, logs, and traces, with full customization of the ingestion and visualization processes.

## Solution
The solution is to leverage two of an ACP's core services to provide a full stack solution:

| Service | Description |
| --- | --- |
| Telemetry | Provides functionality around gathering, modifying, curating, and forwarding metrics, logs, and more for storage and visualization, aligned to the [OpenTelemetry framework](https://opentelemetry.io/) |
| Observability | Provides the ability to deploy platform-managed monitoring and visualizaton stacks used to automatically capture, store, and visualize system information |

These two core services have some overlapping functionality, but in this solution are used in conjunction with each other to provide a holistic approach to building an obervability and monitoring stack.

When leveraged together, these services compliment each other, allowing for metrics, logs, and traces from within the platform, and from external to the platform, to be collected, aggregrated, normalized, stored, and visualized.

The Telemetry service is aligned to the OpenTelemetry standard, and allows for centralized aggregration and standardization of information from the various components of a system.
![OTEL Infograpgic](https://opentelemetry.io/img/otel-diagram.svg)

In this example, the OTel Collector and Observability Frontends/APIs are hosted and managed by the ACP.

The Observability service provides the storage and visualization services to allow for ingestion of the normalized data from the telemetry service, allowing for system-wide visualization and drill-down functionality when needed. In addition, it can automatically gather metrics, logs, and other information from workloads running on the platform automatically, which provides easy-to-consume functionality when deploying workloads to an ACP.

The [Examples](#examples) section will outline a few common scenarios that leverage these standard ACP services.

## Examples
This section of this pattern will focus on two key use cases for the solution of this pattern:
- Observability of workloads running on the ACP
- Combining observability and telemetry for workloads both on the ACP and external to the ACP

HERE

### Observability of Workloads Running on the ACP
The observability service provides 

![Network Based Boot](./.images/network-based-boot.png)

In this example, the generated installation media for networking booting is downloaded to a web server at the site. Then, the hosts are network booted, where network services inform the hosts that the installation media is available for download from the web server. The hosts retrieve the installation media over the network, boot, then continue on with the rest of the process like normal.

Optionally, this can be fully automated using IT automation tooling to configure the site's web server and network services.

### Installation onto an underlying platform
In certain situations, ACPs can be virtualized on top of other platforms that provide virtualization. The hub's central management platform features a set of pre-built integrations for virtualization and compute providers, which allows to hub to simply consume the virtualization platform and create an ACP without needing additional support, or without needing to generate installation media.

![Virtualized ACP Install](./.images/virtualized-acp-install.png)

In this example, the site has a virtualization platform that the hub's central management service has an existing integration for. This allows for a "direct" installation of the ACP by the hub, without any additional input. This provides a similiarily heavily automated experience when building ACPs at remote sites.

### Leveraging declarative tooling to scale ACP operating environment and ACP definition deployment
Finally, another example is using declarative tooling and GitOps to define clusters at scale, and ensure they're consistent and managed on the hub, which in turn ensures consistency as the ACPs are deployed to remote sites.

![Declarative Process](./.images/declarative-process.png)

This allow for significant scaling of this solution over manually defining each site or ACP at every site, reducing the burden on the centralized management team when deploying ACPs to a large number of sites.

In addition, templating functionality of the declarative state management service could be used to build a large number of ACP operating environment definitions and ACP definitions without needing to manually define them individually.

## Rationale
The rationale for this pattern is to address the need for repeatable and automated deployment of ACPs at a large number of edge sites without needing a large centralized team. This pattern's solution leverages functionality of a service provided by a centralized application, the hub's central management service, to accomplish this. This approach also leads to greater consistency at scale, helping to eliminate support and troubleshooting burdens when building and operating ACPs.

## Footnotes

### Version
1.0.0

### Authors
- Josh Swanson (jswanson@redhat.com)