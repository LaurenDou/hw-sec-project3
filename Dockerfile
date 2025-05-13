# syntax=docker/dockerfile:1

###############################################################################
# Stage 1: Build go-tpm-tools `attest` binary
###############################################################################
FROM golang:1.23 as go-builder

WORKDIR /src
RUN git clone https://github.com/google/go-tpm-tools.git
WORKDIR /src/go-tpm-tools/cmd/gotpm

# Build the correct CLI binary
RUN go build -o /attest main.go


###############################################################################
# Stage 2: Final FitHealth Flask image
###############################################################################
FROM python:3.10-slim

# ---------- install system dependencies ----------
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    libssl-dev \
    libsqlcipher-dev \
    jq \
    curl \
    ca-certificates \
    gnupg \
    apt-transport-https \
    lsb-release \
    sudo \
    xxd \
 && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
    | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
 && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
 && apt-get update && apt-get install -y google-cloud-sdk \
 && rm -rf /var/lib/apt/lists/*

# ---------- install Python dependencies ----------
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---------- copy source code and built attest binary ----------
COPY app.py .
COPY entrypoint.sh .
COPY --from=go-builder /attest /usr/local/bin/attest
RUN chmod +x /usr/local/bin/attest && chmod +x entrypoint.sh

# ---------- runtime configuration ----------
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
EXPOSE 5000
CMD ["./entrypoint.sh"]
