# Developer Portal

The developer portal is the central hub for developers to interact with the platform.

## Overview

The portal provides:
- Service catalog browsing
- One-click provisioning
- Resource management
- Documentation access
- Metrics and monitoring

## Portal Options

### Option 1: Backstage (Recommended)

Backstage is an open-source platform for building developer portals.

**Setup**: See [backstage/README.md](../backstage/README.md) for Backstage setup.

### Option 2: Custom Portal

Build a custom portal using:
- React/Next.js for frontend
- Platform APIs for backend
- Tailwind CSS for styling

### Option 3: Port

Port is a commercial platform engineering solution.

## Configuration

Portal configuration files go in `config/`:
- `app-config.yaml` - Application configuration
- `catalog-info.yaml` - Service catalog definitions
- `theme.yaml` - Portal theme configuration

## Quick Start

For a simple portal setup:

```bash
# Using Backstage
cd backstage
npm install
npm start

# Or custom portal
cd portal
npm install
npm run dev
```

## Features

- **Service Catalog**: Browse and provision services
- **Resource Management**: View and manage resources
- **Documentation**: Access platform documentation
- **Metrics**: View platform and service metrics
- **Cost Tracking**: Monitor costs per service

