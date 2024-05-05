# Scaling Deployments as a Managed Service Provider
This pattern gives an opinionated look at scaling up deployment capabilities using gitops tooling from the perspective of a managed service provider.

## Abstract
| Key | Value |
| --- | --- |
| **Platform(s)** | <ul><li>Red Hat Device Edge with Microshift</li><li>Red Hat Openshift</li></ul> |
| **Scope** | Application deployment |
| **Tooling** | <ul><li>Red Hat OpenShift GitOps</li></ul> |
| **Pre-requisite Blocks** | <ul><li>[Kubernetes Core Concepts](../../blocks/k8s-core-concepts/README.md)</li><li>[Scaling GitOps Deployment](../scaling-gitops-deployment-k8s/README.md)</li><li>[Helm Getting Started](../helm-getting-started/README.md)</li><li>[GitOps Deployments](../gitops-deployment-k8s/README.md)</li><li>[App of Apps](../../blocks/app-of-apps/README.md)</li></ul>
| **Example Application** | Process Control |

## Problem
**Problem Statement:** When acting as a managed service provider, it can often be challenging to install and run many deployments of an application at scale for customers.

**Resolution:** Using modern tooling and processes, the main goals of this pattern are:
1. Increase the number of instances for customers that can be managed
2. Increase the consistency between deployments
3. Allow for customizations between deployments relative to customer requirements
4. Leverage code and code reviews as the "source of truth" for deployments

## Context
This pattern can be applied where a high number of deployments, usually for external entities such as customers, are being managed from a central location, and deployed to a single target. Current deployment processes are typically manually initiated or completely manual, and deployments have drifted or become inconsistent over time.

## Forces
1. **Scalability:** This pattern allows for easy scalability by adding or removing deployments as needed, up to a nearly limitless number of deployments across customers.
2. **Modularity:** Each deployment can be individually managed or adjusted using the same core  reduces complexity.
3. **Customization:** MSPs can customize the set of applications based on the specific needs of their customers, providing a tailored solution.
4. **Maintenance:** Day 2+ operations are all handled through the same automation path, and can include updates/upgrades, automatic rollbacks, and more.
5. **Resource Efficiency:** Since tooling and technology are responsible for the deployments, time and soft dollar expenses are saved.
6. **Isolation:** This pattern allows for isolation down to the individual deployment level, allowing for proper boundries around customers and deployments, and even multiple deployments within customers.
7. **Flexibility:** MSPs can easily onboard new customers, retire old customers, and contextualize/customize where required through one process.

## Solution
This pattern leverages two main elements to achieve a solution:
- Using code as the source of truth for deployments
- Using GitOps tooling and practices to manage and enforce deployments

An example implimentation:
![MSP Process](./.images/msp-process.png)

Here, a new customer deployment has been identified, added to the code repository, approved for deployment, and is rolled out completely via tooling and automation, and does not require manual intervention.

To achieve this, a few conditions must be met:
- Deployments and their customizations can be captured as code
- A valid code repository exists, with proper controls, to contain deployments
- Proper wiring of tooling to the code repo has been configured

For details on the above, see the prerequisite blocks in the [Abstract](#abstract) setion.

Once the tooling and source of truth are properly configured, all individuals reposonsible for creating, updating, and deleting deployments now adopt the code-focused approach, as opposed to manual processes that are not code driven.

This pattern can scale across multiple types of deployments, such as different applications, different deployment targets, and more, with proper customization.


## Resulting Context
Once deployed, all management of deployments, from initial roll-out to updates to deletion, are completely handled through an automated process that uses code as the source of truth.

Some highlights:
- **Simplified Application Management:** The app-of-apps pattern allows MSPs to manage multiple applications using a single Git repository. This simplifies the management process, as all configuration and deployment information is stored in one central location.
- **Enhanced Collaboration:** GitOps encourages collaboration among teams by providing a centralized repository for managing applications. This helps improve communication, as all team members can easily access and contribute to the repository.
- **Version Control:** Git provides robust version control capabilities, allowing MSPs to track changes made to applications over time. This ensures that they can easily roll back to previous versions if needed, reducing the risk of errors or downtime.
- **Automation:** GitOps promotes the use of automation for application deployment and management. By leveraging tools like GitLab CI/CD or Argo CD, MSPs can automate the deployment process, reducing manual intervention and the risk of human error.
- **Scalability:** The app-of-apps pattern is highly scalable, allowing MSPs to easily add or remove applications as needed. This scalability ensures that MSPs can quickly adapt to changing customer requirements without significant overhead.
- **Consistency:** With the app-of-apps pattern, MSPs can ensure consistency across applications by defining common configurations and deployment processes. This helps maintain a standardized environment, reducing the risk of configuration drift.
- **Security:** GitOps promotes security best practices by enforcing code reviews, access controls, and audit logs. This helps ensure that applications are deployed securely, reducing the risk of security breaches.


## Examples
In all examples, the same overall setup and process is used:
![MSP Process](./.images/msp-process.png)

### Adding a New Customer Deployment
When a new deployment is desired, the following process is used:
1. The production code repo is cloned
2. A new branch is created from the production branch
3. The new deployment is added to the new branch
4. A pull request is opened to merge changes to the production branch

### Updating an Existing Deployment

### Deleting a Customer Deployment



Rationale
An explanation/justification of the pattern as a whole, or of individual components within it, indicating how the pattern actually works, and why - how it resolves the forces to achieve the desired goals and objectives, and why this is "good". The Solution element of a pattern describes the external structure and behavior of the solution: the Rationale provides insight into its internal workings.