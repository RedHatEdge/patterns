# Multi-Site VM Infrastructure — Repeatable Patterns

This folder captures the architectural and operational patterns distilled from this reference implementation. Each pattern is self-contained, cross-referenced to the relevant ADRs, and written to be reusable beyond the specific Rockwell / FactoryTalk context where they were first validated.

## Why patterns?

This project assembled a complex stack — OpenShift Virtualization, ODF/Ceph, Tekton, Ansible Automation Platform, cert-manager, Multus CNI, Windows Server, and Rockwell FactoryTalk — and validated it at scale through repeated deployment cycles. The patterns here document *what works*, *why it works*, and *how to apply it* without having to rediscover every hard lesson.

## Pattern Index

| # | Pattern | Core Technology | Status |
|---|---------|----------------|--------|
| [01](01-platform-foundation.md) | Platform Foundation: OpenShift Virtualization vs VMware | OCP, KubeVirt, ODF | Validated v1.0.0 |
| [02](02-vm-lifecycle.md) | VM Lifecycle: From ISO to Running Workload | CDI, Tekton, CSI Snapshots | Validated v1.2.0 |
| [03](03-ot-network-isolation.md) | OT Network Isolation: Layer-2 PLC Connectivity | Multus CNI, NMState, cnv-bridge | Validated v1.5.0 |
| [04](04-tekton-vm-pipelines.md) | Tekton Pipelines for VM Lifecycle | Tekton, KubeVirt Tasks, RBAC | Validated v1.2.0 |
| [05](05-rockwell-factorytalk-deployment.md) | Rockwell FactoryTalk Deployment | FTSP, FT View SE, msiexec, TCG | Validated v1.8.0 |
| [06](06-multi-vm-site-architecture.md) | Multi-VM Site Architecture & Orchestration | AAP, Tekton hybrid, boot tiers | Validated v1.8.0 |
| [07](07-gitops-secrets-compliance.md) | GitOps, Secrets, and Compliance | ESO, Vault, cert-manager, licensing | Partially validated |
| [08](08-generalizing-to-non-rockwell.md) | Generalizing to Non-Rockwell OT Workloads | Pattern extraction | Reference |

## How to read these patterns

Each pattern document follows this structure:

1. **Problem statement** — what real operational problem this solves
2. **Architecture diagram** — Mermaid block/sequence diagram of the approach
3. **Key decisions** — the ADR-backed choices that define the pattern
4. **Step-by-step workflow** — concrete implementation steps
5. **Known failure modes** — hard-won lessons from the deployment cycles
6. **Generalization** — how the pattern extends beyond Rockwell

## Cross-references

All patterns link back to the ADRs in [docs/adrs/](../docs/adrs/) which are the authoritative source of truth for every architectural decision.

The [CLAUDE.md](../CLAUDE.md) at repo root contains a table of all validated failure patterns encountered during deployment — essential reading before implementing any of these patterns.
