# Workload Data Protection on an ACP
This block outlines how to install and configure a data protection service to provide application-aware backup and restore for workloads running on an ACP. Examples, currently, are specific to Trilio as the backup provider software.

## Information
| Key | Value |
| --- | ---|
| **Platform:** | Red Hat OpenShift |
| **Scope:** | Data Protection |
| **Tooling:** | CLI, yaml, GitOps |
| **Pre-requisite Blocks:** | <ul><li>[Installing Operators via Yaml](../installing-operators-yaml/README.md)</li><li>[GitOps Cluster Config](../gitops-cluster-config-rbac/README.md)</li></ul> |
| **Pre-requisite Patterns:** | <ul><li>[ACP Standard Services](../../patterns/rh-acp-standard-services/README.md)</li></ul> |
| **Example Application**: | N/A |

## Table of Contents
* [Part 0 - Assumptions and Prerequisites](#part-0---assumptions-and-prerequisites)
* [Part 1 - Installing the Data Protection Operator](#part-1---installing-the-data-protection-operator)
* [Part 2 - Creating the Manager Instance](#part-2---creating-the-manager-instance)
* [Part 3 - Configuring a Backup Target](#part-3---configuring-a-backup-target)
* [Part 4 - Defining Protection Policies](#part-4---defining-protection-policies)
* [Part 5 - Creating Consistency Hooks](#part-5---creating-consistency-hooks)
* [Part 6 - Creating Protection Plans](#part-6---creating-protection-plans)
* [Part 7 - Executing Backups and Restores](#part-7---executing-backups-and-restores)
* [Part 8 - Managing Protection via GitOps](#part-8---managing-protection-via-gitops)

## Part 0 - Assumptions and Prerequisites
This block has a few key assumptions, in an attempt to keep things digestable:
1. A target platform is installed and reachable.
2. The platform has a CSI driver installed that supports the VolumeSnapshot capability. The `VolumeSnapshot`, `VolumeSnapshotContent`, and `VolumeSnapshotClass` CRDs must be registered on the cluster.
3. An S3-compatible object store or NFS share is available and reachable from the platform to serve as a backup target.
4. The certified operators catalog is available on the platform (connected or mirrored).

The CSI VolumeSnapshot capability is a prerequisite for volume-level backups. This capability is provided by various storage services — for example, the converged storage service (ODF) or other CSI-compliant storage drivers. The specific storage service does not matter, as long as the VolumeSnapshot CRDs are registered and a VolumeSnapshotClass exists.

To verify the prerequisites are met:
```bash
# Check for VolumeSnapshot CRDs
oc get crd volumesnapshots.snapshot.storage.k8s.io
oc get crd volumesnapshotcontents.snapshot.storage.k8s.io
oc get crd volumesnapshotclasses.snapshot.storage.k8s.io

# Check for at least one VolumeSnapshotClass
oc get volumesnapshotclass
```

## Part 1 - Installing the Data Protection Operator
The data protection service is provided by the Trilio for Kubernetes operator, available through the certified operators catalog. The installation follows the standard operator installation pattern: a Namespace, OperatorGroup, and Subscription are created.

### Namespace
```yaml
---
apiVersion: v1
kind: Namespace
metadata:
  name: trilio-system
  labels:
    openshift.io/cluster-monitoring: "true"
```

### Operator Group
```yaml
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: trilio-system-operatorgroup
  namespace: trilio-system
spec:
  targetNamespaces:
    - trilio-system
```

### Subscription
```yaml
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: k8s-triliovault
  namespace: trilio-system
spec:
  name: k8s-triliovault
  channel: lts-4.0
  source: certified-operators
  sourceNamespace: openshift-marketplace
  installPlanApproval: Automatic
```

After applying these resources, the operator will be installed by OLM. The operator pod should reach a `Running` state in the `trilio-system` namespace:
```bash
oc get pods -n trilio-system
```

The operator registers 12 CRDs under the `triliovault.trilio.io` API group, which are used to configure and manage all aspects of data protection.

## Part 2 - Creating the Manager Instance
Once the operator is installed and the CRDs are registered, a `TrilioVaultManager` instance is created. This is the central configuration resource that instructs the operator to deploy all required controllers and services.

```yaml
---
apiVersion: triliovault.trilio.io/v1
kind: TrilioVaultManager
metadata:
  name: triliovault-manager
  namespace: trilio-system
  labels:
    triliovault.trilio.io/instance: triliovault-manager
spec:
  trilioVaultAppVersion: 4.0.0
  applicationScope: Cluster
  ingressConfig:
    ingressClass: openshift-default
  componentConfiguration:
    ingress-controller:
      enabled: true
```

Key configuration options:
| Field | Description |
| --- | --- |
| `applicationScope` | `Cluster` allows cluster-wide protection plans. `Namespaced` restricts to per-namespace only. |
| `ingressConfig` | Configures the management console route. |
| `componentConfiguration` | Enables or disables optional components like the ingress controller. |

After applying, the operator will deploy the full set of controllers. This takes a few minutes. Verify all pods are running:
```bash
oc get pods -n trilio-system
```

The following controllers should be present and running:
- Target controller
- BackupPlan controller
- Backup controller
- Snapshot controller
- Restore controller
- Webhook server
- Ingress controller (if enabled)
- Web console and backend
- Metrics exporter

## Part 3 - Configuring a Backup Target
A backup target defines where backup data is stored. The data protection service supports two target types: S3-compatible object stores and NFS shares.

### S3-Compatible Object Store
First, create a secret containing the S3 credentials:
```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: s3-backup-credentials
  namespace: trilio-system
type: Opaque
stringData:
  accessKey: "<your-access-key>"
  secretKey: "<your-secret-key>"
```

Then, create the target resource:
```yaml
---
apiVersion: triliovault.trilio.io/v1
kind: Target
metadata:
  name: s3-backup-target
  namespace: trilio-system
spec:
  type: ObjectStore
  vendor: Other
  objectStoreCredentials:
    url: "https://s3.example.com"
    bucketName: "acp-backups"
    region: "us-east-1"
    credentialSecret:
      name: s3-backup-credentials
      namespace: trilio-system
  thresholdCapacity: 1000Gi
```

### NFS Share
```yaml
---
apiVersion: triliovault.trilio.io/v1
kind: Target
metadata:
  name: nfs-backup-target
  namespace: trilio-system
spec:
  type: NFS
  nfsCredentials:
    nfsExport: "nfs-server.example.com:/exports/backups"
    nfsOptions: "nolock,nfsvers=4.1"
```

After applying, the target controller will validate the target. Check the status:
```bash
oc get target -n trilio-system
```

The target should show as `Available` once validation passes. If it shows an error, verify the credentials, network connectivity, and bucket/share configuration.

## Part 4 - Defining Protection Policies
Protection policies define the schedule and retention rules for backups. Policies are referenced by protection plans.

### Daily Backup with 7-Day Retention
```yaml
---
apiVersion: triliovault.trilio.io/v1
kind: Policy
metadata:
  name: daily-7day-retention
  namespace: trilio-system
spec:
  type: Schedule
  scheduleConfig:
    schedule:
      - "0 2 * * *"
  cleanupConfig:
    backupDays: 7
```

### Weekly Backup with 30-Day Retention
```yaml
---
apiVersion: triliovault.trilio.io/v1
kind: Policy
metadata:
  name: weekly-30day-retention
  namespace: trilio-system
spec:
  type: Schedule
  scheduleConfig:
    schedule:
      - "0 3 * * 0"
  cleanupConfig:
    backupDays: 30
```

The schedule follows standard cron syntax. Multiple schedules can be defined in the `schedule` list if needed. The `cleanupConfig` defines how long completed backups are retained before the retention job removes them.

## Part 5 - Creating Consistency Hooks
For stateful workloads such as databases, consistency hooks run commands inside application containers before and after a backup to ensure a consistent snapshot. Hooks are optional, but recommended for any workload with write-ahead logs or in-memory state.

### MySQL Consistency Hook
```yaml
---
apiVersion: triliovault.trilio.io/v1
kind: Hook
metadata:
  name: mysql-consistency
  namespace: my-application
spec:
  pre:
    - podSelector:
        matchLabels:
          app: database
          tier: mysql
      container: mysql
      command:
        - /bin/bash
        - -c
        - "mysqldump --all-databases --single-transaction --flush-logs > /tmp/pre-backup.sql"
  post:
    - podSelector:
        matchLabels:
          app: database
          tier: mysql
      container: mysql
      command:
        - /bin/bash
        - -c
        - "rm -f /tmp/pre-backup.sql"
```

### PostgreSQL Consistency Hook
```yaml
---
apiVersion: triliovault.trilio.io/v1
kind: Hook
metadata:
  name: postgres-consistency
  namespace: my-application
spec:
  pre:
    - podSelector:
        matchLabels:
          app: database
          tier: postgres
      container: postgres
      command:
        - /bin/bash
        - -c
        - "pg_dumpall -U postgres > /tmp/pre-backup.sql && psql -U postgres -c 'SELECT pg_start_backup($$triliovault$$, true);'"
  post:
    - podSelector:
        matchLabels:
          app: database
          tier: postgres
      container: postgres
      command:
        - /bin/bash
        - -c
        - "psql -U postgres -c \"SELECT pg_stop_backup();\" && rm -f /tmp/pre-backup.sql"
```

Hooks are namespace-scoped and referenced by protection plans in the same namespace.

## Part 6 - Creating Protection Plans
Protection plans define what to protect. They reference a backup target, a schedule policy, and optionally a consistency hook. Workloads are selected by label, Helm release, or operator.

### Namespace-Scoped Protection Plan
This plan protects all resources in a namespace that match a specific label:
```yaml
---
apiVersion: triliovault.trilio.io/v1
kind: BackupPlan
metadata:
  name: my-app-backup-plan
  namespace: my-application
spec:
  backupConfig:
    target:
      name: s3-backup-target
      namespace: trilio-system
    schedulePolicy:
      fullBackupPolicy:
        name: daily-7day-retention
        namespace: trilio-system
    backupPlanComponent:
      customSelector:
        labelSelector:
          - matchLabels:
              app.kubernetes.io/part-of: my-application
    hookConfig:
      mode: Sequential
      hooks:
        - hook:
            name: mysql-consistency
    backupPlanFlags:
      skipImageBackup: false
```

### Cluster-Scoped Protection Plan
For protecting workloads across multiple namespaces, a `ClusterBackupPlan` is used. This requires the manager to be running in `Cluster` application scope:
```yaml
---
apiVersion: triliovault.trilio.io/v1
kind: ClusterBackupPlan
metadata:
  name: production-vms-backup
spec:
  backupConfig:
    target:
      name: s3-backup-target
      namespace: trilio-system
    schedulePolicy:
      fullBackupPolicy:
        name: weekly-30day-retention
        namespace: trilio-system
    backupPlanComponent:
      customSelector:
        labelSelector:
          - matchLabels:
              workload-type: virtual-machine
              environment: production
    backupPlanFlags:
      skipImageBackup: false
```

This plan discovers and protects all virtual machines matching the specified labels, regardless of which namespace they run in.

After creating a protection plan, verify its status:
```bash
# Namespace-scoped
oc get backupplan -n my-application

# Cluster-scoped
oc get clusterbackupplan
```

## Part 7 - Executing Backups and Restores

### Triggering a Manual Backup
While protection plans with schedule policies will execute automatically, a backup can also be triggered manually:
```yaml
---
apiVersion: triliovault.trilio.io/v1
kind: Backup
metadata:
  name: my-app-manual-backup
  namespace: my-application
spec:
  type: Full
  backupPlan:
    name: my-app-backup-plan
    namespace: my-application
```

Monitor the backup status:
```bash
oc get backup -n my-application -w
```

The backup progresses through several phases: `InProgress` → `Available`. A failed backup will show a `Failed` status with detail in the backup resource's status field.

### Restoring from a Backup
To restore a workload from a backup, create a restore resource:
```yaml
---
apiVersion: triliovault.trilio.io/v1
kind: Restore
metadata:
  name: my-app-restore
  namespace: my-application
spec:
  source:
    type: Backup
    backup:
      name: my-app-manual-backup
      namespace: my-application
  restoreNamespace: my-application
```

The restore can target the original namespace, a different namespace (by changing `restoreNamespace`), or a different cluster entirely, as long as the backup target is accessible from that cluster.

Monitor the restore:
```bash
oc get restore -n my-application -w
```

### Restoring from a Cluster-Scoped Backup
```yaml
---
apiVersion: triliovault.trilio.io/v1
kind: ClusterRestore
metadata:
  name: production-vms-restore
spec:
  source:
    type: ClusterBackup
    clusterBackup:
      name: production-vms-backup-20260910
```

## Part 8 - Managing Protection via GitOps
All of the resources defined in this block — targets, policies, hooks, protection plans — are standard Kubernetes custom resources. They can be stored in a code repository and managed via the gitops service, keeping protection configuration in sync with application deployments.

An example ArgoCD Application that manages a full set of protection resources:
```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app-data-protection
  namespace: openshift-gitops
  labels:
    application: my-app-data-protection
spec:
  destination:
    name: ""
    server: https://kubernetes.default.svc
  project: default
  source:
    repoURL: https://github.com/example/acp-workload-protection.git
    targetRevision: HEAD
    path: my-application/protection
  syncPolicy:
    automated:
      prune: false
      selfHeal: true
```

The repository structure for the protection configuration:
```
my-application/protection/
├── target.yaml          # Backup target definition
├── policy.yaml          # Schedule and retention policy
├── hook.yaml            # Consistency hooks (if applicable)
└── backupplan.yaml      # Protection plan
```

This allows protection configuration to be reviewed, versioned, and applied alongside application changes.
