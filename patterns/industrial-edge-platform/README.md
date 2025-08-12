# Industrial Edge Platform Overview
This pattern outlines a solution for next generation compute platforms operating at industrial sites, such as manufacturing plants, oil refineries, and other locations. It encompases small form-factor devices up through small-scale "datacenter-like" environments, providing consistent, easily managed, and future-lookng functionality for any workloads running at these sites today.

The overall goal of this pattern is to provide the ability to run existing and next generation workloads across the industrial edge (or similar) environment, with the freedom to adapt and extend the functionality over time to support new requirements.

This pattern's solution can be considered a "meta-pattern", outlining a high-level vision, with links to other architectural patterns that are more detailed around individual elements.

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
| **Platform(s)** | <ul><li>Advanced Compute Platform</li><li>Distributed Control Nodes</li></ul> |
| **Scope** | <ul><li>Installation</li><li>Operation</li></ul> |
| **Tooling** | <ul><li>Red Hat Advanced Cluster Management (Optional)</li><li>Red Hat Ansible Automation Platform (Optional)</li></ul> |
| **Pre-requisite Blocks** | N/A |
| **Pre-requisite Patterns** | N/A |
| **Example Application** | N/A |

## Problem
**Problem Statement:** The modern industrial environment,while primarily focused on individual processes and flows that ultimately create products or assemblies, now requires more than just hardware PLCs and basic I/O functionality. Higher level operations, such as distributed control systems, manufacturing execution systems, supervisory control and data acquisition systems, and other critical applications require "IT-like" compute be available at the site.

These compute environments often being operational challenges and introduce additional burden on the site, given their lack, consistency, automation, and general day-to-day requirements, introducing undue cost and risk to the site's core production functions.

In addition, the inflexibility of these existing platforms prevents the deployment of newer workloads provided by vendors and developed in-house, limiting the ability of the business to gain insight into existing processes and work towards improving them. Also the ability to deploy new functionality to the site prevents new revenue streams or additional functionality from being realized.

## Context
This pattern can be applied anytime compute is required for mission-critical applications that need to be run outside of a core data center or cloud environment, with focus on industrial sites and the core workloads that enable site operations.

The overall goal is to lower the management burden associated with the adoption and operation of IT functionality, providing a stable and consistent compute experience while allowing for the adoption of next generation workloads and functionality without needing to replace the core platform. This pattern provides a broad look at the driving factors that drive this industrual edge platform approach, and will provide links to other patterns that give more depth about individual elements of the platform itself.

A few key assumptions are made:
- The intended use of the platform is to provide compute and hardware abstraction functionality for key workloads across a broad array of hardware
- Deployment will happen in a highly distributed fashion, with both commonality and site-specific customizations
- Workoads will range from existing/legacy to modernized to deterministic, bringing many different requirements for the platform to fulfill


## Forces
- **Resilience:** This pattern's solution should allow for the same installation and operational experience for the platform and workloads, regardless of the connected or disconnected state.
- **Security:** This pattern's solution should allow for ACPs to be operated in highly protected, highly trusted environments where external connectivity is considered too much of a risk to the platform.
- **Consistency:** This pattern's solution should be repeatable across sites with similar constraints and requirements, allowing for a large number of sites to run similiar platform installations where appropriate.
- **Customization:** This pattern's solution should allow for customization across deployment hardware footprints, according to power, cooling, and budgetary constraints relative to the desired workloads for that platform.
- **Observability:**
- **Managability:**

### HERE ###

## Solution
The solution is two fold: content mirroring and platform configuration are combined to provide the solution for operating an ACP in a fully disconnected state.

For review, the default ACP architecture involves the platform being able to reach out to publically accessable content sources to download during initial installation, the addition of additional features and functionality, and during workload deployment:
![Connected ACP](./.images/connected-acp.png)

The two sections below walk through the components of this solution, while the [Examples](#examples) section showcases the solution in action in a few different situations.

> Note:
>
> For simplicity, not all ACP features and services are shown in the following diagrams.

> Note:
>
> The content mirroring tool used throughout this pattern is the same tooling as what's used for the [caching platform update content on an ACP](../caching-platform-updates-on-an-acp/README.md) solution.

### Platform Content Mirroring
For disconnected ACPs, all content required by the platform, standard services, and workloads must be mirrored and be made available to the disconnected platfom. This content is mirrored to a location that is reachable by the disconnected platform, either co-located at the destination deployment site, or available through an internal network.

The content mirroring tooling takes a configuration that outlines desired platform version, functionality, and optionally, additional content to be mirrored, and downloads it from the publically available content sources. The downloaed content can be stored in a content registry directly, or optionally, written to persistent storage for transportation to a destination.

![Content Mirroring Tool](./.images/content-mirroring-tool.png)

Refer to the [Examples](#examples) section of this pattern for a few example use cases.

### Platform Configuration
By default, ACPs are configured to pull their content from publically accessable sources on the internet, which works well for datacenter and cloud deployments, but does not support disconnected environments, or even all edge deployments where connectivity is limited. To support retrieving platform and workload content from alternate sources, the platform can be configured to retrieve content from mirrored or internally available sources, instead of reaching out to the default sources on the internet.

This configuration's behavior is transparent to the workload and to the operator of the platform. When content is required, the platform will automatically redirect the request to the configured internal location, without needing specific configuration at the feature or workload level.

![Redirected Content Download](./.images/redirected-content-download.png)

**Pros:**
- Provides full platform functionality when fully disconnected
- Transparent to end users and operators of the platform

**Cons:**
- Requires knowledge of the desired platform version and standard services
- Requires available persistent storage to store the content
- Requires an internally reachable content registry for the platform to pull the content from

## Resulting Context
The resulting context is the ability to deploy ACPs, standard services, and workloads when external connectivity is not available, while maintaining consistency with the functionality provided by a "connected" ACP. The end user experience, features and functionality, and operational experience are all consistent across connected and disconnected platforms, and across deployment methodologies.

The content mirroring portion of this pattern's solution can be automated and scaled, allowing for many platforms to be run across a large number of deployment locations or targets, all consuming the same set of mirrored content (or optionally, the same content across many mirrors), driving consistency and operational efficiency.

In addition, the platform configuration can be deployed at scale using a hub, or through automation at deployment time. In addition, it can be applied to already-installed platforms as a day-2 operation, through any standard tooling that's used to manage ACPs.

This also allows for ACPs to be run outside of the traditional "plant datacenter" or edge location, instead allowing for platform deployment and operation on mobile platforms, high security sites, or other locations that do not have, or do not provide, external connectivity to internal resources.

## Examples
The [Solution](#solution) section of this pattern highlights the core components required to enact the solution. In this section, three scenarios will be outlined that leverage that solution:

1. Mirroring content to an internally reachable location
2. Managing Disconnected ACPs from a Hub
3. Transporting content via "sneakernet" to fully disconnected locations

### Mirroring Content to an Internally Reachable Location
Some industrial sites operate in a "mostly disconnected" mode, meaning that connectivity back to internal/corporate resources is allowed, but connectivity to the internet is not.

For the purposes of this pattern, this use case can be considered disconnected, and a content mirror can be run centrally for ACPs at sites to pull content from.

![Central Content Source](./.images/centralized-content-source.png)

This approach leverages the disconnected methodology, and provides all the benefits of full platform functionality, version consistency, and operational consistency without needing to allow the deployed ACPs to pull content from the internet directly.

### Managing Disconnected ACPs from a Hub
Building on the previous example, if connectivity back to a central location is allowed, then ACPs at remote sites can be managed using a [hub](../rh-hub-standard-services/README.md). This allows for [highly-automated ACP installs](../automated-acp-install-from-hub/README.md), along with deployment of applications and policies at scale from a central management location.

![Centralized Management with Centrailized Content Source](./.images/hub-management-with-centralized-content-source.png)

In this use case, the ACP configuration to leverage an internal content source for workloads and platform content is simply a configuration item that can be applied from the hub in a broad or targeted approach.

### Transporting Content via "Sneakernet" to Fully Disconnected Locations
For fully disconnected sites that have no outside connectivity, the content mirroring tool can be used to download the required content to persistent storage that can be physically transported to the site, then leveraged again to load the content from storage to a content repository on-site that the ACP can reach.

![Content Over Sneakernet](./.images/content-over-sneakernet.png)

This allows for operation at sites that have no connectivity, at all, outside of the site itself.

## Rationale
The rationale for this pattern is to address wanting ACPs deployed to sites that operate in a disconnected manner, while retaining full feature parity with ACPs that are deployed in connected or semi-connected environments. This allows for the platform's features and functionality to be consumed in even more operational environments without significant drift from the standard platform deployment configuration.

Since consistency is key when operating edge sites at scale, the ability to leverage a common platform, regardless of the connectivity model at each site, helps to scale the capabilities of the organization, while still remaining flexible enough to support the needs of an individual site.

## Footnotes

### Version
1.0.0

### Authors
- Josh Swanson (jswanson@redhat.com)