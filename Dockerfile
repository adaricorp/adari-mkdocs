# Dockerfile for MkDocs documentation server with all required plugins
# This image is built and published to ghcr.io via GitHub Actions
# The actual documentation content is mounted at runtime by Nomad
#
# Published to: ghcr.io/adaricorp/adari-mkdocs:latest

FROM python:3.11-slim

LABEL org.opencontainers.image.source="https://github.com/adaricorp/adari-mkdocs"
LABEL org.opencontainers.image.description="MkDocs server with Adari documentation plugins"
LABEL org.opencontainers.image.licenses="MIT"

# Set working directory
WORKDIR /docs

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file for docs
COPY requirements.txt /tmp/requirements.txt

# Install Python dependencies (all MkDocs plugins)
RUN pip install --no-cache-dir -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt

# Documentation files, mkdocs.yml, and src/ will be mounted at runtime by Nomad
# This keeps the image lightweight and allows documentation updates without rebuilding

# Expose the port mkdocs will serve on
EXPOSE 8002

# Run mkdocs serve
# Using 0.0.0.0 to allow external access from the container
# Using --dirtyreload for faster rebuilds when content changes
CMD ["mkdocs", "serve", "--dev-addr=0.0.0.0:8002", "--dirtyreload"]

