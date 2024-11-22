# Adding Pre-Built Devices to Existing Environment

The goal of this pattern is to describe the preferable onboarding of devices built with specific purpose into a modern Red Hat Platform environment. 

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
**Problem Statement:** It is common in Industrial Spaces to purchase computer driven hardware devices with a pre-built purpose, anything from a PLC to Flow Meter to a AI vision model on a "box". Even as far as ideas like "PlantPAx in a box" which is a server class equipment with all the necessary virtual machines and infrastructure to run a PlantPAx system. 

However, despite these known quantities, current onboarding capabilities are mostly manual, and not intuitive at all, except in very closed proprietary systems with a single vendor that might have created some semblence of this kind of process. 

This leads to large time consuming efforts, often by the System Integrator to integrate the device into a system, and sometimes without knowning what the original purpose of the device even was. 

These devices/functions are known quanities in the industry, surely there is a better way to added pre-built/function devices to a system with some context of their purpose. 

Security is also a concern any time you bring a device online, a platform that understood the types of things being added to environment should be able to make decisions about whether to allow the device onto the Industrial Automation system, or not. 

## Context
This pattern represents the ideal scenario for pre-function device onboarding and integration into an environment. 

This pattern will describe what kind of information should:
1. The device already provides
2. The type of information the device should provide
3. Security best practice and ideal expectation from the device and platform
4. Most expediciously add and start a device to function within a system. 

## Definitions
Some Definitions to consider:

1. **Device:** throughout this document will refer to a piece of hardware with compute onboard. This compute will have processing power, storage, network capabilties and an operating system of some type, whether common Linux, etc... or a real-time operating system(RTOS) common in devices like PLCs. 


## Forces
1. **Ease of Use:** This pattern describes what will dramatically improve onboarding time and understanding with known devices. 
2. **Flexibility:** While this pattern is heavily opinionated, it is flexible, and can be expanded, changed, or adjusted due to new requirements over time.
3. **Security:** With any onboarding utility, security is a priority to verify the Industrial Automation system isn't compromised. Defining a standard pattern for this procedure will help improve the security posture of an environment. 
4. **Fast:** The function described in this pattern should happen nearly instantly to the human observer. 
5. **User Alerted:** While much of this pattern should and could automatically, there is a need to make the owner of the industrial environment is made aware any new device is added to the industrial platform. 

## Solution
By combining the platform capabilities of Red Hat OpenShift with some additional security focused tooling and opinionated hardware requirements, the following goals can be achieved:
1. New Device awareness by the platform/system. 
2. Ability to use master list/database of known devices to understand their purpose and requirements.
3. Ability to organize and understand different types of devices common in industrial spaces. 
4. Platform can setup communications necessary, once trusted, to the needed locations. 

At a high level, the goal here is to improve the onboarding of known devices. Today's technology, and know-how, both from security vendors and manufactuers, give more than enough information to streamline this process for adding most any type of industrial compute hardware. 

![First phase of onboarding (future pic](./.images/ha-acp.png)

Customer needs or desires a new device and purchases equipment from known industrial compute vendor and brings to environment and plugs into the network.

![Environment Alert (future pic)](./.images/ha-acp-failover.png)

As soon as the device is detected on the network, a series of activities will happen. 

1. Security handshake: Determine if the device is safe to onboard. This could be pre-shared, but than likely it will be a first in "wins" kind of situation. 
2. Setup a secure connection to the brains of the environment to compare device profile (pre-defined or ascertained from commonly known info (custom ASIC or other))
3. Categorize the device being added, such as PLC, AI engine on Industrial Computer (defined more later)
4. Determine level of access granted for device. This could be pre-arranged, or put into a quaranteen till user interaction.
5. Alert user of the type of device, and current state. Request further actions, or disable communications with other equipment. 
6. If determined to be unsafe, sever the network connect and create an alarm while alerting the users. 
7. If determined safe and pre-arranged purpose, give connections and priveledges requirement to be succesful to operate.
8. Where possible, ascertain any pertinent documentation for known device, to further assist user how to most expediate adding the functionality into the system.

** Note: Often the device will not need much interaction with the platform other than to grant it permissions on the network. Otherwise, much of its core functions will be local to the device. 


### Network Connectivity

For the purposes of this pattern, we are dealing with ethernet devices, and ignoring bus protocols or quantum entanglement. Because of this, there are certain functions we can rely on. 

![Typical Industrial Network (future picture)](./.images/node-connectivity.png)

> Note:
>
> Ability to see across sub-domains will be required by the device manager to best be able to onboard devices. The ability to interface with network manager to help facilitate appropriate routes would be ideal. 


![Network Manager Functionality (future picture)](./.images/cluster-connectivity.png)

In this scenario, the Network Manager, of whatever varition, needs access to switch infrastructure, routing tables, etc... as well as ACLs and the like. Including configuration capabilites in some scenarios. 



#### Hardware Characterization
Devices will be recognized by hardware characteristics, some of which will be able to help identify the purpose of the pre-built devices. 

1. Identify type of CPU, GPU, Memory, Storage, Operating System and Network Capabilties
2. Understand the comms needed. Which protocols it is expecting to use, which ports are needed etc... 
3. Understand if the device is meant to be read only, or allows user inputs from environment
4. Understand if compute resources are already accounted for or if any capactity is able to be used by the Industrial automation system (expand capacity). 

    - An example might be something like an AI model on an IPC that only requires 2 cores of 4 core processor, or perhaps there are multiple harddrives availble and only one is being used for the work. 

5. Understand environmental conditions/effects and any concerns.
6. Share firmware information


#### Typical Types of Devices (running list)
Some typical types of devices we might have

1. Simple, fit for purpose devices (instrumentation), typically read only, except for simple parameter changes

    - Flow meters, Temp meters, pressure meters, level meters, simple VFDs, Energy Monitors

2. More complex fit for purpose compute, can be programmed, typically runs sometimes complex programs.

    - PLCs, RTUs, DCS Controllers, Robust VFDs, other drives, Simple touchscreen (Panelviews)

3. Edge Compute platforms, non-server grade

    - IPCs, Touchpanels, Thin Client devices (like ThinManager devices), Laptops, PCs

4. Server Class Hardware

    - Servers, Industrial Data Centers (like Stratus)



#### Management User Interface
To make this operate as seemless as it needs to for OT customers, a simple and effective user interface will be required. Here is a Use case of how this might operate. 

Use Case - Adding Device to System

1. Plant engineer procures new Rotork Flow Meter, the device was bought with the correct communication protocols needed for the system. 
2. Engineer physically brings device to where it will be installed.
3. Device is mechanically installed to read flow of water. 
4. Electrically configured and checked for basic functionality via onboard HIM(Human Interface)
5. Flow Meter plugged into network
6. Management User Interface alerts plant engineer admin that a new device has been added to the network
7. Along with the alert, information about the device is displayed to the user, including: Type of device, which subnet and switch it is currently, any pertinent information about the compute capacity of the device and current state. Includes any questionable security concerns.
8. Management system inquires whether device is safe to add to the system, and any priveledges needed, if any, making recommendations based on the device class. 
9. Updates status to reflect device is now part of the system as needed. 

Along with the interaction described above, some kind of understanding and organization of all the devices should be present in the interface. 

![(future picture)](./eeeeeeeeeeuster-connectivity.png)



### Security and Quarantine of Devices
A core concept of device onboarding is the ability to securely add devices, however in the situations when the device doesn't meet the security requirements a couple things should happen.

1. Engineer alerted that a potential security threat was added to the environment
2. Device should be put into quarantine, no connections available to anything in the system. 
3. Threat will be identified and what level of threat it is considered. The level for alert and quarantine should be set by the users/admin. 
4. User can always override threats, though different levels may require higher credentialed user to approve addition. 


## Resulting Context
Once active, resulting industrial automation system will bring improved onboarding/integration and significantly more secure onboarding procedures.

Some highlights:
- **Secure Onboarding of all devices:** While we didn't discuss open compute platforms, being able to bring pre-defined devices online to a plant in a secure manner, regardless of type, will be a massive improvement.
- **Ease of Operations:** Current onboarding of new devices is cumbersome and manual in most situations, except propreitary. An open, standard way to bring online new devices regardless of manufactuer or OS, will majorly simplify integration and improve timeliness. 
- **Self-Management:** The ability to allow the system to self manage and even automate some deployments (perhaps at startup) will improve integration.
- **Scalability:** The management system should be able to improve the total understanding of the size and scale of any Industrial system.
- **Consistency:** Creating an established onboarding procedure will improve the overall experience and standardize the approach. 



## Examples
![Pics to come](./.images/acp-with-workloads.png)

In this example....

### Security Onboarding
This set of functions...

### User Interface
This...

### Network provisioning
This

## Rationale
The main rationale for this is simplifaction of device integration in a modern secure manner.


## Footnotes

### Version
1.0.0

### Authors
- Tim Mirth (tmirth@redhat.com)