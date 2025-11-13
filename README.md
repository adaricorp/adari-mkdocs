# Adari MkDocs Container Image

This repository builds and publishes a container image for serving MkDocs
documentation with all required plugins for Adari documentation.

## Overview

The image is designed to be used with Adari instances. It contains all
MkDocs plugins but **not** the actual documentation content, which is mounted at
runtime from the host filesystem.

**Published Image**: `ghcr.io/adaricorp/adari-mkdocs:latest`

## What's Included

This container image includes:

- Python 3.11
- MkDocs with Material theme
- All plugins needed for Adari documentation:
  - Material theme
  - Mermaid diagrams
  - Markmap visualizations
  - mkdocstrings (Python API docs)
  - PDF export
  - PlantUML diagrams
  - And more (see `requirements.txt`)

### Running Standalone

```bash
# Run with mounted documentation
podman run -d \
  -p 8002:8002 \
  -v /path/to/docs:/app/docs:ro \
  -v /path/to/mkdocs.yml:/app/mkdocs.yml:ro \
  -v /path/to/src:/app/src:ro \
  ghcr.io/adaricorp/adari-mkdocs:latest
```

## Building Locally

```bash
# Build the image
docker build -t adari-mkdocs:local .

# Or with Podman
podman build -t adari-mkdocs:local .

# Test it
docker run -p 8002:8002 -v ./test-docs:/app/docs:ro adari-mkdocs:local
```

### Expected Volume Mounts

The image expects these directories to be mounted at runtime:

- `/app/docs` - Documentation source files
- `/app/mkdocs.yml` - MkDocs configuration
- `/app/src` - Python source code (for API documentation via mkdocstrings)

### User and Permissions

The container runs as a non-root user (`mkdocs`, UID/GID 999) for security. **No user override is needed** in Nomad or Podman configurations - the Dockerfile's `USER` instruction is automatically respected.


## Development

### Testing Changes Locally

```bash
# Build local version
docker build -t adari-mkdocs:test .

# Run with test documentation
docker run -p 8002:8002 \
  -v $(pwd)/test-docs:/app/docs:ro \
  adari-mkdocs:test

# Access at http://localhost:8002
```

