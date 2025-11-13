# Dockerfile for MkDocs documentation server with all required plugins
# This image is built and published to ghcr.io via GitHub Actions
# The actual documentation content is mounted at runtime by Nomad
#
# Published to: ghcr.io/adaricorp/adari-mkdocs:latest

FROM python:3.11-slim

LABEL org.opencontainers.image.source="https://github.com/adaricorp/adari-mkdocs"
LABEL org.opencontainers.image.description="MkDocs server with Adari documentation plugins"
LABEL org.opencontainers.image.licenses="MIT"

# Set environment variables for better Python behavior
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Create a non-root user for security
RUN groupadd -r mkdocs && useradd -r -g mkdocs mkdocs

# Set working directory
WORKDIR /app

# Create expected directory structure and set ownership
RUN mkdir -p /app/docs /app/src && \
    chown -R mkdocs:mkdocs /app

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file for docs
COPY requirements.txt /tmp/requirements.txt

# Upgrade pip and install Python dependencies (all MkDocs plugins)
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r /tmp/requirements.txt && \
    rm /tmp/requirements.txt

# Switch to non-root user
USER mkdocs

# Documentation files, mkdocs.yml, and src/ will be mounted at runtime by Nomad
# This keeps the image lightweight and allows documentation updates without rebuilding

# Expose the port mkdocs will serve on
EXPOSE 8002

# Note: Health checks should be configured in the Nomad job specification,
# not in the Dockerfile, as Nomad doesn't use Docker's HEALTHCHECK instruction.

# Run mkdocs serve
# Using 0.0.0.0 to allow external access from the container
# Using --dirtyreload for faster rebuilds when content changes
CMD ["mkdocs", "serve", "--dev-addr=0.0.0.0:8002", "--dirtyreload"]

