FROM python:3.10-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV SQLCIPHER_KEY=default_static_key_1234567890abcdef

# Install OS dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libsqlcipher-dev gcc && \
    rm -rf /var/lib/apt/lists/*

# Set work directory
WORKDIR /app

# Copy application files
COPY app.py ./
COPY entrypoint.sh ./   
COPY requirements.txt ./  

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Make entrypoint executable
RUN chmod +x /app/entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
