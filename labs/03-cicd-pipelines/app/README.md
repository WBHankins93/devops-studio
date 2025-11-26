# DevOps Studio Sample Application

A simple Node.js Express application used for demonstrating CI/CD pipelines.

## Overview

This application provides:
- Health check endpoint (`/health`)
- Root endpoint (`/`)
- API status endpoint (`/api/status`)

## Local Development

### Prerequisites
- Node.js 18+
- npm

### Setup

```bash
# Install dependencies
npm ci

# Run application
npm start

# Run tests
npm test

# Run unit tests only
npm run test:unit

# Run integration tests only
npm run test:integration
```

### Testing

The application includes:
- Unit tests using Jest
- Integration tests
- Test coverage reporting

## Docker

### Build Image

```bash
docker build -t devops-studio-app:latest .
```

### Run Container

```bash
docker run -p 3000:3000 devops-studio-app:latest
```

### Test Endpoints

```bash
# Health check
curl http://localhost:3000/health

# Root endpoint
curl http://localhost:3000/

# API status
curl http://localhost:3000/api/status
```

## Environment Variables

- `PORT`: Server port (default: 3000)
- `NODE_ENV`: Environment (development, staging, production)
- `APP_VERSION`: Application version

