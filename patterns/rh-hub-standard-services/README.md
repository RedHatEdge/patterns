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
**Problem Statement:** As multiple ACPs are deployed to geographically diverse sites, a central management concept is required to properly manage the platforms at scale. This central location is responsible for key functions such as update content standardization, application deployment, compliance and drift, image vulnerability scanning, app deployment delegation, and provisioning.

These core offerings represent the required functionality to operate ACPs at scale.

## Context
This pattern represents the Red Hat provided services used to run ACPs in large quantites, with a focus on having a central place to develop and deploy from. In this context, the ACPs are considered "deployment targets" that are given responsibility for managing their own workloads, while the hub is responsible for delegating that functionality as well as higher level functions.

This pattern is limited to the services and offerings shipped and supported by Red Hat.

In addition, it assumes that enough infrastructure resources [CPU, memory, disk] are available to support the installation and operation of these resources, in the form of an OpenShift cluster. This cluster does not need to be an ACP, it could be a cluster in a cloud.

This pattern also assumes some level of network connectivity is available between the hub and the ACPs. This connection does not need to be presistent or highly performant.

## Forces
1. **Central Management Point:** This pattern focuses on creating a centralized management point that can be leveraged to manage a large number of ACPs that are geographically distributed.
3. **Security Shift-Left:** As much as possible, proper security scanning and baselining should be handled centrally, then enforced across the fleet. The compute intensive work of scanning many images and application code bases should be done outside of the compute-constratined ACPs, then deployed.
2. **Consistency:** Consistency is key for any edge computing deployment, as scale makes management and operations challenging. Enforcement and reconsiliation are required to keep platforms healthy and operating as expected.
4. **Scalability:** This pattern represents a way to scale from a single site to thousands, with potential to scale even higher. This also encompasses scaling the capabilities of the centralized development and support organizations.
5. **Responsibility Delegation:** To enable local autonomy, as workloads are defined for ACPs, the definition of the workloads should be centrally pushed, however the responsibility of the starting and watching that work should fall to the ACPs, in case of hub maintenance or connectivity interruptions.

## Solution
A hub leverages a few key services to provide centralized management:

| Service | Red Hat Product/Functionality | Description |
| --- | --- | --- |
| Declarative State Management | [Red Hat OpenShift GitOps](https://www.redhat.com/en/technologies/cloud-computing/openshift/gitops) | Provides declarative management of platforms and applications, using git as the source of truth |
| Centralized Cluster Management | [Red Hat Advanced Cluster Management for Kubernetes](https://www.redhat.com/en/technologies/management/advanced-cluster-management) | Management, visibility, deployment, and lifecycle functionality provided from a central control plane |
| Security, Compliance and Vulnerability | [Red Hat Advanced Cluster Security for Kubernetes](https://www.redhat.com/en/technologies/cloud-computing/openshift/advanced-cluster-security-kubernetes) | Provides compliance policy enforcement using industry standards, vulnerability scanning, policy violation actions, and centralized visibility |
| Image Storage and Scanning | [Red Hat Quay](https://www.redhat.com/en/technologies/cloud-computing/quay) | Provides a highly-available controlled image registry with built in image vulnerability scanning and full RBAC |
| IT Automation | [Red Hat Ansible Automation Platform](https://www.redhat.com/en/technologies/management/ansible) | Provides IT-level idempotent automation for managing networks, bare metal systems, and more |

These services and how they are leveraged are explained below.

### Declarative State Management
A common concept for application deployment and management is using a declarative approach and relying on tooling to translate that into reality.

In the same way, from a central hub, two key concepts are declared: what the ACPs themselves are, and what workloads should be run on them.

At runtime, a third concept is handled through the same process: identifying vulnerabilities and risks of the platform, and then changing the definition to remediate.

#### Declaring and Managing ACPs
To build platforms, the definition of their base configuration is loaded into a central respository, then declarative state management tooling leverages the appropriate supporting tooling to build and manage the platform. This happens from a central location to distributed locations.
![Define and Build ACP](./.images/define-acp-build.png)

In the event that there are additional configuration changes needed, additional IT automation tooling can be leveraged to enable remote building, connect installation media, and reconfigure networks to allow the process to work as desired.
![Define and Build ACP with AAP](./.images/define-acp-build-with-aap.png)

#### Declaring Workloads and Delegating Responsibility
Similar to declaring a cluster in code, workloads are also described as code. The difference is how the application is defined at the hub level: the intention is to declare what the ACPs should be responsible for running instead of the workloads themselves.

As the first step, thw workloads are defined and committed to a repository. After the workloads are defined, a definition of the workloads is created, which encompasses what these workloads are, and where they can be deployed from.
![App and App Definition](./.images/app-and-app-def.png)

Once a the target deployment platform has been built, or is ready, the hub pushes the workload definitions to the target. This is the "handoff" of responsibility to the target: it now becomes responsible for deploying and managing the workload, which begins once it knows what workloads it is responsible for.
![Hub to ACP](./.images/hub-to-acp.png)

Once complete, the connection from the hub to the target ACP could be broken, as the target is now locally responsible for the stated workloads.

### Centralized Cluster Management
To enable solution scaling, a centralized control plane is used to visualize distributed platforms and optionally, push changes out in bulk. This approach favors usability over speed: the distributed platforms will recieve the updates and apply them the next time connectivity is available. If connectivity is always available, then the changes are applied immediately.

Distributed platforms can also be group logically to allow for changes to be applied in bulk.
![Hub to ACP Interaction](./.images/hub-to-acp-interaction.png)

### Policy Definition and Enforcement
A centralized approach to policy definition and enforcement is also part of the overarching set of standard services for running highly distributed platforms. These policies are defined and loaded centrally, and then evaluated against the highly distributed platforms.
![Centralized Policies](./.images/central-policies.png)

The loaded policies generally contain explanation details, scope, criteria, and enforcement behaviors, and are centrally evaluated and acted on.

### Vulnerability and Policy Visualization
The central control plane provides functionality around scanning and visualizing the active vulnerabilities of both workloads and deployment configurations on the distributed platforms. This information is consolidated for easy consumption.
![ACS Interacts](./.images/acs-interacts.png)

The important part of this is that both vulnerabilities in the application code and images are scanned for, as well as the permissions assigned at deployment time. Both of these pieces are required for properly securing applications. The intention is to shift as much of the responsibility for remediating vulnerabilities and policy enforcement to a centralized location where development is happening, rather than out at the distributed platforms.

An example look at the vulnerability dashboard.
![ACS Vulnerability Dashboard](./.images/acs-vulnerability-dashboard.png)

### Risk Ranking
To better represent the potential risk of vulnerabilities and policy violations, the central management platform providles pre-weighted rankings of various issues, and then ranks them according to those rankings. The intention is to provide a for a opinionated flow to addressing vulnerabilities and policy violations.

![Risk Ranking](./.images/risk-ranking.png)

This capability provides a more comprehensive view into the operational status and security posture of platforms deployed at scale.

### Runtime Process Discovery
As part of a centralized security approach, the executed application processes are also scanned and evaluated. This provides insight into the inner workings of the deployed applications, allowing for proper identification of undesired activites within the applications themselves, along with the ability to enforce and block deployment.

For example, if two workloads are deployed to a remote platform, one that is allowed by policy, and another that is not, they will both be scanned and evaluated:
![Scan Processes](./.images/scan-processes.png)

Then, based on policy which includes enforcement actions, the good workload is allowed to continue. For the "bad" workload, alerts or incidents can be raised, or more direct action, such as eviction, can be taken.
![Enforce Processes](./.images/enforce-processes.png)

An example loook at process discovery:
![ACS Process Discovery](./.images/acs-process-discovery.png)

### Network Visualization and Policies
Another capability of the centralized management platform is the ability to visualize and, if desired, apply policies to the networking layer of the target platform. Capturing network flows provides a deeper understanding of the deployed applications and how their various components interact.
![Network Flow Gathering](./.images/flow-gathering.png)

This representation of flows can be used for both East-West as well as North-South traffic flows, provising a holistic look at traffic within and around the distributed platforms.
![Traffic Flows Graph](./.images/traffic-flows-graph.png)

### Compliance
Compliance standards have been established that provide secure operating models for applications and for platforms, and to be fully aligned with a standard, must be validated at both of those layers.

This central management platform provides the capability to assign various standards to a platform, enforce it, and then scan for drift.
![Compliance Enforcement and Reporting](./.images/compliance-enforcement-reporting.png)

The selected standards/profiles and the compliance of the distributed platforms are represented visually, centrally, for actions to be taken off of if desired.
![Compliance Dashboard](./.images/compliance-dashboard.png)

### Image Storing and Scanning
Part of ensuring proper flow of application content to the distributed platforms is keeping the content centrally managed. This allows for strong RBAC around what content can be consumed where. In addition, application images can be centrally scanned for vulnerabilities, layer by layer, leveraging the more readily available compute resources of the central management plane.
![Image Storage and Scanning](./.images/image-storage-and-scanning.png)

An example of an image, scanned layer by layer:
![Scanned Image](./.images/scanned-image.png)

### IT Automation
For additional capabilities, IT automation is added to the set of standard services. This functionality allows for interation with assets around the central management plane and the distributed platforms for provisioning and management functionality. Assets such as cloud resources, firewalls, switches, and more can be brought under central management, or their management can be delegated to the distributed platforms as needed.

As stated above, this functionality could be used to build platforms:
![Define and Build ACP with AAP](./.images/define-acp-build-with-aap.png)

It also can be used for additional workflows or ongoing management if the need arises.

## Resulting Context
The resulting context of a fully deployed set of centralized management services is the ability to securely scan, deploy, and enforce workloads and policies against a large number of target deployment platforms.

As the number of target platforms increases, the impacts of onboarding and operating the new platforms is minimized, as the contenxt, process, and capabilities are already build and ready to scale.

## Examples

### Onboarding a New Site
Onboarding new sites becomes simple by consuming the available services running centrally:
![Onboard New Site](./.images/define-acp-build-with-aap.png)

For example, a new site could be onboarded with the following process, assuming the platform definition was already created:
| Step | Consumed Service | Description |
| --- | --- | --- |
| 1. Load Context into Central Management Plane | <ul><li>Declarative State Management</li><li>Centralized Cluster Management</li></ul> | Cluster definition is loaded into central management plane in preparation for install and first check-in |
| 2. Generate Installation Media | <ul><li>Centralized Cluster Management</li></ul> | Customized installation media is created and made available for platform install |
| 3. Configure Site Firewall and Networking | <ul><li>IT Automation</li></ul> | Site networking stack is configured to allow access to and support installed platform | 
| 4. Mount/Boot Installation Media | <ul><li>IT Automation</li></ul> | Out-of-band management of target hardware is leveraged to perform bootstrapping |
| 5. Monitor Installtion Progress | <ul><li>IT Automation</li><li>Centralized Cluster Management</li></ul> | Logs and status are occasionally checked as the platform progresses towards readiness |
| 6. Apply Security Baseline | <ul><li>Security, Compliance and Vulnerability</li></ul> | Foundational security and compliance settings are enforced |
| 7. [ACP Standad Services](../rh-hub-standard-services/README.md) Deployed | <ul><li>Centralized Cluster Management</li><li>Declarative State Management</li></ul> | The core set of platform services are deployed and configured |
| 8. Deploy Workloads | <ul><li>Centralized Cluster Management</li><li>Declarative State Management</li></ul> | Workload definitions are loaded onto the platform, and it begins deploying the workloads |

Once this process is complete, the new platform is configured and productive.

## Rationale
The main rationale for deploying a set of services centrally are:
1. Allowing for high scaling without requiring linear scaling of supporting resources.
2. Consuming resources intelligently where they're more abundant, while keeping the deployment targets as agile as possible.

## Footnotes

### Version
1.0.0

### Authors
- Josh Swanson (jswanson@redhat.com)