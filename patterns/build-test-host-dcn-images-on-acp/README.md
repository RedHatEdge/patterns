# Building, Testing, and Hosting Images for DCNs on an ACP or Hub
This pattern outlines a solution for building, testing, and hosting DCN images on an ACP or hub, leveraging core services and built-in functionality. 

As the images that will be deployed to DCNs need to be built, tested, and ultimately hosted for consumption by the DCNs, a platform that can provide tooling and capability to meet the steps required to complete this process is required.

This solution can be deployed centrally onto a hub, optionally using ACPs to mirror or cache the images, or can be deployed to ACPs themselves, depending on requirements.

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
| **Pre-requisite Blocks** | <ul><li>[TODO](../../blocks/todo)</li></ul> |
| **Pre-requisite Patterns** | <ul><li>[Image Mode for Distributed Control Nodes](../image-mode-for-dcns/README.md)</li></ul> |
| **Example Application** | N/A |

## Problem
**Problem Statement:** The images that will be deployed to distributed control nodes, based off [bootable containers](https://developers.redhat.com/articles/2024/09/24/bootc-getting-started-bootable-containers) need to be built, tested, and hosted on a platform that's reachable from the DCNs, and also has the build, test, and host functionality available to drive the process. This build, test, and host process mirrors the processes used for containerized applications today, and since the images are simply bootable containers, there's significant enough overlap that methodologies and tooling can be shared and re-used.

In addition, the number of DCN images may grow as the number of deployed DCNs grows, requiring a platform capable of providing for a large number of images being built, tested, and hosted, without requiring heavy customization to support the required scale.

## Context
This pattern can be applied to environments where DCN images need to be built, tested, and hosted for the DCNs to retrieve during provisioning or update cycles. It relies on core functionality provided by ACPs and hubs, and can be applied to either, or both, as dictated by connectivity, locality, or image customization requirements.

A few key assumptions are made:
- The intended context of the platform aligns to the [Standard HA ACP Architecture](../acp-standardized-architecture-ha/README.md)
- The standard set of [ACP Services](../rh-acp-standard-services/README.md) are available for consumption.
- Physical connections, such as power and networking, have been made to the target hardware
- The upstream network configuration is completed and verified
- The application's required operating systems as available as [templates](../windows-templates-acp-virtualization/README.md) within the ACP's virtualization service.
- The application deployment has been automated and is ready for deployment by the ACP's [IT automation](../rh-acp-standard-services/README.md) service.

Since this pattern can be applied to multiple target platforms, a target of an ACP deployed at a remote site will be used throughout most of the pattern documentation for beveritry.

## Forces
- **Single Service Entrypoint:** This pattern outlines how a single service on an ACP can drive others to accomplish a complex flow without needing to manually interface with other services, instead opting to drive consumption under one umbrella.
- **Modularity:** This pattern's solution can be consumed as a single large flow, or optionally, broken apart, where the individual components are leveraged when needed.
- **Broad Applicability:** This pattern's solution works across different virtual machine operating systems and across applications, as operating system specific and application specific elements are handled transparently by the gitops and it automation services.
- **Reusability:** This pattern's solution can be replicated for many different applications, simply changing out definitions or pointers to automation code bases.
- **Transparency:** By loading both definitions of infrastructure and automation configuration into platform-native assets, all components and steps related to the full deployment process are visible within the deployment location and context.

## Solution
The solution is to leverage the gitops service of an ACP to drive both the deployment of the required infrastructure to support an application, and also configure the IT automation service to connect to and deploy the application via automation.

![Full Flow](./.images/full-flow.png)

In this flow, the infrastructure components, such as virtual machines, k8s services, routes, config maps, etc, are directly deployed by the gitops service, in the same way they would be for fully containerized services. In addition, the configuration of the IT automation service is also initiated by the gitops service, according to the defined automation definition. Then, after the appropriate infrastructure is in place, the IT automation service is initiated, according to the new configuration, to deploy the application to the appropriate infrastructure.

### Deployment Flow
The execution of this process can be broken down into four main logical phases, representing when resources are deployed or services configured.
![Process Flow](./.images/process-flow.png)

#### Phase 1
In phase 1, the base constructs are deployed, such as namespaces, supporting kubernetes resources such as services, secrets, etc. In addition, the confguration for the IT automation service is configured as a k8s resource. This provides visibility into the full list of resources and assets required to fully deploy the desired appliation on the requested infrastructure. In addition, it allows kubernetes-native resources to read in the desired configuration for the IT automation service, and apply it.

#### Phase 2
In phase 2, the infrastructure required to support the application is deployed onto the platform. In the example of this pattern, this includes virtual machines, which also consume other services of the platform, such as network configuration and converged storage.

In addition, the configuration of the IT automation service is executed, by consuming the reviously created definition. This is handled by a one-shot kubernetes job, which communicates directly with the IT automation service.

#### Phase 3
The third phase is compromised of the initiation of the IT automation service. This step happens logically after the infrastructure has been deployed and is available. In this phase, the IT automation service is directed to the newly configured aseets, and begins to execute against the now available infrastructure.

#### Phase 4
The final phase is the IT automation, having been initiated in phase 3, executing the pre-configured tasks to complete the application deployment. This may include tasks such as operating system configuration, downloading files, and ultimately running the application installation.

Once this phase completes, the application should be installed and ready for consumption.

## Resulting Context
The resulting context is the ability to perform end-to-end application deployments of applications that require virtual machines, all from a single service hosted on the platform. The full flow is handled by one service, even though multiple services contribute in reaching the end result of a deployed application.

## Examples
An example of this pattern would be using the solution to install and configure an instance of Active Directory. While AD is usually treated as an infrastructure service, the setup and management procedure mirrors that of other applications, and thus the same tools, technologies, and processes can be leveraged.

### Phase 1
Aligning to the phases above, phase 1 sets up the base constructs that will contain the resources required to run AD. In addition, the base configuration is loaded into the application definition, which are leveraged throughout deployment to achive desired state.

The application definition is loaded and available:
![Application Tile](./.images/application-tile.png)

And the required configuration of the automation service is loaded as part of the application definition:
![Automation Definition](./.images/automation-definition.png)

Before the start of the sync of the application to the target desination, all resources show as OutOfSync, however this changes as synchronization is started:
![Application Pre-Sync](./.images/application-pre-sync.png)

As the sync starts, resources begin to be deployed:
![Sync Started](./.images/sync-started.png)

And k8s-native resources are created. In this example, services have been created:
![k8s Services](./.images/k8s-services.png)

### Phase 2:
In phase 2, the supporting compute infrastructure is brought up, and the IT automation service is configured with the necessary automation to complete the application installation.

On the ACP, the virtual machines are deployed from templates and started:
![Virtual Machines](./.images/virtual-machines.png)

And the virtual machines are started:
![Virtual Machine Start](./.images/virtual-machine-starting.png)

In addition, a k8s-native resource, called a job, configures the IT automation service with the required configurations:
![K8s Jobs](./.images/k8s-jobs.png)

The configuration in-progress:
![Applying Configuration](./.images/applying-configuration.png)

Resources now available in the IT automation service, such as inventories and job templates:
![Controller Inventory](./.images/controller-inventory.png)

![Controller Job Templates](./.images/controller-templates.png)

### Phase 3
In phase 3, continuation of the deployment and configuration is handed off to the IT automation service, which then runs the configuration automation.

Another job is used to used to trigger the automation launch:
![Run Automation Job](./.images/run-automation-job.png)

This job calls out to the IT automation service and waits for the automation to complete:
![Calling IT Automation](./.images/calling-it-automation-service.png)

### Phase 4
Finally, phase 4 is where the IT automation service takes over, and continues the application deployment and configuration until completition.

The automation workflow, created earlier, has been invoked and is running:
![Running Workflow](./.images/running-workflow.png)

Once complete, the appropriate configurations should now be applied and ready:
![Domain Controllers](./.images/domain-controllers.png)

![Areas](./.images/areas.png)

![Ptr Records](./.images/ptr-records.png)

In addition, the application tile now shows synced:
![Application Synced](./.images/application-synced.png)

## Rationale
The Rationale for this pattern is to drive greater consumption and easier on-ramping of consumption of services on the platform, while keeping the interface to consume them more simplistic. Ideally, the entire process from infrastructure deployment to application deployment is automated, and driven through a single interface for easy troubleshooting and simplicity.

## Footnotes

### Version
1.0.0

### Authors
- Josh Swanson (jswanson@redhat.com)