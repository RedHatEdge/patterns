# Setting Up DNS for an ACP
This block outlines the DNS requirements for running an ACP.

## Information
| Key | Value |
| --- | ---|
| **Platform:** | Red Hat OpenShift |
| **Scope:** | Bootstrapping |
| **Tooling:** | CLI, yaml, Ansible |
| **Pre-requisite Blocks:** | N/A |
| **Pre-requisite Patterns:** | N/A |
| **Example Application**: | N/A |

## Table of Contents
* [Part 0 - Assumptions and Network Layout](#part-0---assumptions-and-network-layout)
* [Part 1 - Outline of Steps](#part-1---outline-of-steps)
* [Part 2 - Structuring Node Information](#part-2---structuring-node-information)
  * [Section 1 - General Information](#section-1---general-information)
  * [Section 2 - Cluster Information](#section-2---cluster-information)
  * [Section 3 - Node Specific Information](#section-3---node-specific-information)
  * [Section 4 - All Node Settings](#section-4---all-node-settings)
* [Part 3 - Templating agent-config.yaml](#part-3---templating-agent-configyaml)
* [Part 4 - Templating install-config.yaml](#part-4---templating-install-configyaml)
* [Part 5 - Creating an Inventory for the Helper Node](#part-5---creating-an-inventory-for-the-helper-node)
* [Part 6 - Creating a Playbook](#part-6---creating-a-playbook)
  * [Section 1 - Play Setup and Vars](#section-1---play-setup-and-vars)
  * [Section 2 - Pre-tasks](#section-2---pre-tasks)
  * [Section 3 - Tasks](#section-3---tasks)
  * [Section 4 - Post-tasks](#section-4---post-tasks)
* [Part 7 - Running the Playbook](#part-7---running-the-playbook)

## Part 0 - Assumptions and Network Layout
This block has a few key assumptions, in an attempt to keep things digestable:
1. Bind will be used to provide DNS in this example, however multiple software stacks can provide DNS.
2. Network configuration has been completed.
3. Static addresses will be used for the cluster links, however DHCP is also an option.

The following example subnets/VLANs will be used:
| VLAN | Subnet | Description |
| --- | ---| --- |
| 2000 | 172.16.0.0/24 | Out of band management interfaces of hardware |
| 2001 | 172.16.1.0/24 | Hyperconverged storage network |
| 2002 | 172.16.2.0/23 | Cluster primary network for ingress, load balanced services, and MetalLB pools |
| 2003 | 172.16.4.0/24 | First dedicated network for bridged virtual machines |
| 2004 | 172.16.5.0/24 | Second dedicated network for bridged virtual machines |
| 2005 | 172.16.6.0/24 | Third dedicated network for bridged virtual machines |

The following network information will be used:
| IP Address | Device | Description |
| --- | --- | --- |
| 172.16.2.1 | Router | Router IP address for subnet |
| 172.16.2.2 | Rendezvous | Rendezvous IP address for bootstrapping cluster, temporary |
| 172.16.2.2 | node0 | node0's cluster IP address |
| 172.16.2.3 | node1 | node1's cluster IP address |
| 172.16.2.4 | node1 | node2's cluster IP address |
| 172.16.2.10 | API | Cluster's API address |
| 172.16.2.11 | Ingress | Cluster's ingress address |
| 10.1.3.106 | DNS | DNS server address

The following cluster information will be used:
```yaml
cluster_info:
  name: example-cluster
  version: stable
  base_domain: your-domain.com
  masters: 3
  workers: 0
  api_ip: 172.16.2.10
  ingress_ip: 172.16.2.11
  host_network_cidr: 172.16.2.0/23
```

The following node information will be used:
```yaml
nodes:
  - name: node0
    cluster_link:
      mac_address: b8:ca:3a:6e:69:40
      ip_address: 172.16.2.2
  - name: node1
    cluster_link:
      mac_address: 24:6e:96:69:56:90
      ip_address: 172.16.2.3
  - name: node2
    cluster_link:
      mac_address: b8:ca:3a:6e:17:d8
      ip_address: 172.16.2.4
```

Topology:
![Topology](./.images/topology.png)

## Part 1 - Outline of DNS Requirements
The DNS requirements for OpenShift are outlined in the [installation docs](https://docs.openshift.com/container-platform/4.15/installing/installing_with_agent_based_installer/preparing-to-install-with-agent-based-installer.html#agent-install-dns-none_preparing-to-install-with-agent-based-installer), and include a set of required resolvable addresses to support the cluster.

For the example cluster, the following is required.
| Component | Record | Record Type | Record Value | Description |
| --- | --- | --- | --- | --- |
| API | api.example-cluster.your-domain.com | A/AAAA | 172.16.2.10 | Forward lookup for cluster API |
| API | 10.2.16.172.in-addr.arpa. | PTR | 10 | Reverse lookup for cluster API |
| Ingress | *.apps.example-cluster.your-domain.com | A/AAAA | 172.16.2.11 | Wildcard forward lookup for ingress |
| node0 | node0.example-cluster.your-domain.com | A/AAAA | 172.16.2.2 | Forward lookup for node0 |
| node0 | 2.2.16.172.in-addr.arpa. | PTR | 2 | Reverse lookup for node 0 |
| node1 | node1.example-cluster.your-domain.com | A/AAAA | 172.16.2.3 | Forward lookup for node1 |
| node1 | 3.2.16.172.in-addr.arpa. | PTR | 3 | Reverse lookup for node 1 |
| node2 | node2.example-cluster.your-domain.com | A/AAAA | 172.16.2.4 | Forward lookup for node2 |
| node2 | 4.2.16.172.in-addr.arpa. | PTR | 4 | Reverse lookup for node 2 |

The rest of this block is focused on using Bind for DNS resolution with the above records loaded. If using another DNS solution, refer to it's documentation for how to create records.

## Part 2 - Create Forward Zone File
The forward zone file contains information about the zone that bind will be the authorative zone for, and what records should exist within that zone, pulled from the table above.

The zone will be the DNS zone of the cluster: `example-cluster.your-domain.com`.

```
$TTL    86400
@	 IN	SOA	dns.example-cluster.your-domain.com. admin.example-cluster.your-domain.com. (
                        ; domain options
                        3       ; Serial
                        604800  ; Refresh
                        86400   ; Retry
                        2419200 ; Expire
                        604800  ; Negative Cache TTL
                        )
; Authoratitive name server as stated above
            IN NS   dns.example-cluster.your-domain.com.
; Resolve dns.example-cluster.your-domain.com to an address
dns IN A 10.1.3.106
; Shortnames used we're "in" the forward zone
node0 IN A 172.16.2.2
node1 IN A 172.16.2.3
node3 IN A 172.16.2.4
api IN A 172.16.2.10
*.apps IN A 172.16.2.11
```

## Part 3 - Create Reverse Zone File
The rerverse zone file contains the reverse lookup records from the table above, and is formatted similiarily to a forward zone file:
```
$TTL    86400
@	IN	SOA	dns.example-cluster.your-domain.com. root.example-cluster.your-domain.com. (
    1997022700        ; serial
    28800             ; refresh
    14400             ; retry
    3600000           ; expire
    86400             ; minimum
)
      IN	    NS      dns.example-cluster.your-domain.com.
;
2     IN      PTR     node0.example-cluster.your-domain.com.
3     IN      PTR     node1.example-cluster.your-domain.com.
4     IN      PTR     node2.example-cluster.your-domain.com.
10    IN      PTR     api.example-cluster.your-domain.com.
```

## Part 4 - Main Configuration and Includes
Two files contain the main configuration information for Bind, with one responsible for base settings, and another for including the zones files from above.

### Section 1 - Main Configuration
This configuration file sets the listening addresses, controls who can query, and starts the include chain:
```
options {
        listen-on port 53 { 0.0.0.0; };
        directory "/var/named";
        recursion yes;
        allow-query { any; };
        allow-recursion { any; };
        forwarders {
                1.1.1.1;
                1.0.0.1;
                8.8.8.8;
                8.8.4.4;
        };
};
include "/etc/named/files.zones";
```

### Section 2 - Including Zone Files
The second file contains paths to the zones files from earlier:
```
// forward
zone "example-cluster.your-domain.com" IN {
        type master;
        file "/etc/named/forward.zone";
        allow-update { none; };
};

// reverse
zone "2.16.172.in-addr.arpa" IN {
        type master;
        file "/etc/named/reverse.zone";
};
```

## Part 5 - Containerized Bind
With the config files crafted, an easy way to deploy and test is to run Bind within a container, and use configmaps to capture and mount the configuration files.

A single kube yaml file can be used, which Podman can read:
```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: dns-configmap
data:
  named.conf: |
    options {
            listen-on port 53 { 0.0.0.0; };
            directory "/var/named";
            recursion yes;
            allow-query { any; };
            allow-recursion { any; };
            forwarders {
                    1.1.1.1;
                    1.0.0.1;
                    8.8.8.8;
                    8.8.4.4;
            };
    };
    include "/etc/named/files.zones";
  files.zones: |
    // forward
    zone "example-cluster.your-domain.com" IN {
            type master;
            file "/etc/named/forward.zone";
            allow-update { none; };
    };

    // reverse
    zone "2.16.172.in-addr.arpa" IN {
            type master;
            file "/etc/named/reverse.zone";
    };
  forward.zone: |
    $TTL    86400
    @	 IN	SOA	dns.example-cluster.your-domain.com. admin.example-cluster.your-domain.com. (
                            ; domain options
                            3       ; Serial
                            604800  ; Refresh
                            86400   ; Retry
                            2419200 ; Expire
                            604800  ; Negative Cache TTL
                            )
    ; Authoratitive name server as stated above
                IN NS   dns.example-cluster.your-domain.com.
    ; Resolve dns.example-cluster.your-domain.com to an address
    dns IN A 10.1.3.106
    ; Shortnames used we're "in" the forward zone
    node0 IN A 172.16.2.2
    node1 IN A 172.16.2.3
    node3 IN A 172.16.2.4
    api IN A 172.16.2.10
    *.apps IN A 172.16.2.11
  reverse.zone: |
    $TTL    86400
    @	IN	SOA	dns.example-cluster.your-domain.com. root.example-cluster.your-domain.com. (
        1997022700        ; serial
        28800             ; refresh
        14400             ; retry
        3600000           ; expire
        86400             ; minimum
    )
          IN	    NS      dns.example-cluster.your-domain.com.
    ;
    2     IN      PTR     node0.example-cluster.your-domain.com.
    3     IN      PTR     node1.example-cluster.your-domain.com.
    4     IN      PTR     node2.example-cluster.your-domain.com.
    10    IN      PTR     api.example-cluster.your-domain.com.
---
apiVersion: v1
kind: Pod
metadata:
  name: dns
spec:
  hostNetwork: true
  containers:
    - name: dns
      image: quay.io/jswanson/dns:1.0.1
      securityContext:
        privileged: true
      ports:
        - containerPort: 53
          name: dns-port
      volumeMounts:
        - name: dns-config-volume
          mountPath: /etc/named
          readOnly: true
  volumes:
    - name: dns-config-volume
      configMap:
        name: dns-configmap
```

In this file, a configmap is created that contains key/value pairs of the name of the config file, then the contents. These will be mounted into /etc/named within the container. Then, a pod is specified to run with the configuration files mounted in.

## Part 6 - Running and Testing
With the appropriate configuration files and kube yaml created, Podman can be used to run the containerized DNS server:
```
podman play kube dns.yaml
```

Once the pod starts, `nslookup` can be used to test resolution of both configured records as well as recursive lookups:
```
> nslookup node0.example-cluster.your-domain.com 10.1.3.106
Server:		10.1.3.106
Address:	10.1.3.106#53

Name:	node0.example-cluster.your-domain.com
Address: 172.16.2.2

> nslookup 172.16.2.2 10.1.3.106
2.2.16.172.in-addr.arpa	name = node0.example-cluster.your-domain.com.

> nslookup test-thing.apps.example-cluster.your-domain.com 10.1.3.106
Server:		10.1.3.106
Address:	10.1.3.106#53

Name:	test-thing.apps.example-cluster.your-domain.com
Address: 172.16.2.11

> nslookup redhat.com 10.1.3.106
Server:		10.1.3.106
Address:	10.1.3.106#53

Non-authoritative answer:
Name:	redhat.com
Address: 52.200.142.250
Name:	redhat.com
Address: 34.235.198.240
