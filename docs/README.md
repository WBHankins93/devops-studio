# Documentation

This directory contains all documentation for the DevOps Studio platform.

## Structure

### Main Documentation (Root Level)

These are the primary guides that users should read:

- **[prerequisites.md](./prerequisites.md)** ⚠️ **REQUIRED** - System requirements, tool installation, AWS setup
- **[learning-paths.md](./learning-paths.md)** ⭐ **HIGHLY RECOMMENDED** - Career-focused learning paths
- **[getting-started.md](./getting-started.md)** - Step-by-step setup instructions
- **[makefile-guide.md](./makefile-guide.md)** - Understanding and using Makefiles in labs
- **[troubleshooting.md](./troubleshooting.md)** - Common issues and solutions
- **[cost-management.md](./cost-management.md)** - Cost optimization strategies

### Architecture Decision Records (ADRs)

The `architecture-decisions/` folder contains Architecture Decision Records (ADRs) that document important design decisions made during the development of this platform.

**What are ADRs?**
ADRs are a way to document important architectural decisions, the context in which they were made, and the consequences. This helps future maintainers understand why certain choices were made.

**Current ADRs:**
- [001-terraform-structure.md](./architecture-decisions/001-terraform-structure.md) - Terraform module structure and organization
- [002-kubernetes-platform.md](./architecture-decisions/002-kubernetes-platform.md) - Kubernetes platform design decisions
- [003-monitoring-strategy.md](./architecture-decisions/003-monitoring-strategy.md) - Monitoring and observability strategy

**ADR Format:**
Each ADR follows a standard format:
- **Status**: Proposed, Accepted, Deprecated, Superseded
- **Context**: Why this decision is needed
- **Decision**: What was decided
- **Consequences**: Positive and negative outcomes

## Documentation Best Practices

### For Contributors

When adding new documentation:

1. **Main Guides**: Add to root level if it's a primary user-facing guide
2. **ADRs**: Add to `architecture-decisions/` folder with numbered format (XXX-title.md)
3. **Lab-Specific Docs**: Keep in the lab's directory (e.g., `labs/01-terraform-foundations/README.md`)
4. **Reference Material**: Consider if it belongs in a subfolder or root

### For Users

**First Time?** Start here:
1. Read [prerequisites.md](./prerequisites.md)
2. Review [learning-paths.md](./learning-paths.md)
3. Follow [getting-started.md](./getting-started.md)

**Having Issues?** Check [troubleshooting.md](./troubleshooting.md)

**Want to Understand Design?** Browse [architecture-decisions/](./architecture-decisions/)

## Why This Structure?

- **Flat for Main Docs**: Easy to find and link to from README
- **Nested for ADRs**: Standard pattern for architecture documentation
- **Simple Navigation**: Clear separation between user guides and technical decisions
- **Scalable**: Easy to add new docs without creating unnecessary nesting

