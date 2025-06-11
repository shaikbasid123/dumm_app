#!/bin/sh
set -e

# Run database migrations (if needed)
# flask db upgrade

# Start Gunicorn
exec gunicorn \
    --bind 0.0.0.0:5000 \
    --workers 4 \
    --threads 2 \
    --worker-class gthread \
    --log-level info \
    --timeout 120 \
    --access-logfile - \
    --error-logfile - \
    "app:create_app()"