# Stage 1: Builder with all build tools
FROM python:3.10-slim as builder

# Install system build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    libpq-dev && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# Stage 2: Runtime image
FROM python:3.10-slim

# Security hardening
RUN groupadd -r appuser && \
    useradd -r -g appuser appuser && \
    mkdir /app && \
    chown appuser:appuser /app

WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy application files (as non-root)
COPY --chown=appuser:appuser . .

# Runtime configuration
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    FLASK_ENV=production

# Health check
HEALTHCHECK --interval=30s --timeout=5s \
    CMD curl -f http://localhost:5000/health || exit 1

# Ports
EXPOSE 5000

# Entrypoint script
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Run as non-root user
USER appuser

ENTRYPOINT ["./entrypoint.sh"]

