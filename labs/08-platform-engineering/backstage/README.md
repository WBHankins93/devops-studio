# Backstage Developer Portal

Backstage is an open-source platform for building developer portals.

## Overview

Backstage provides:
- Service catalog
- Software templates
- TechDocs (documentation)
- Plugins ecosystem

## Installation

### Prerequisites

- Node.js 18+
- PostgreSQL (for metadata storage)
- Docker (optional, for local development)

### Quick Start

```bash
# Install Backstage CLI
npm install -g @backstage/create-app

# Create new Backstage app
npx @backstage/create-app

# Start Backstage
cd my-backstage-app
yum install sqlite3 -y  # For local development
yarn dev
```

## Integration with Platform

To integrate Backstage with this platform:

1. **Add Service Catalog**: Configure catalog to read from platform
2. **Software Templates**: Create templates for service provisioning
3. **Custom Plugins**: Build plugins for platform APIs
4. **TechDocs**: Host platform documentation

## Configuration

Backstage configuration would go in:
- `app-config.yaml` - Main configuration
- `catalog-info.yaml` - Service definitions

## Note

This is an **optional** component. The platform can work without Backstage using:
- Custom portal
- CLI tools
- Direct API access

See [portal/README.md](../portal/README.md) for other portal options.

