# syntax=docker/dockerfile:1
###############################################################################
# FitHealth API – Flask + SQLCipher build
###############################################################################

FROM python:3.10-slim

# ---------- system dependencies ----------
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
 && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
      | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
 && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg \
      | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
 && apt-get update && apt-get install -y google-cloud-sdk \
 && rm -rf /var/lib/apt/lists/*

# Intel Trust Authority (ITA) CLI – single binary, signed by Intel.
# Installs to /usr/local/bin/trustauthority-cli
RUN curl -sL https://raw.githubusercontent.com/intel/trustauthority-client-for-go/main/release/install-tdx-cli.sh \
      | bash -

RUN mkdir -p /etc/trustauthority-cli \
 && printf '%s\n' \
     '{' \
     '  "trustauthority_api_url": "https://api.trustauthority.intel.com",' \
     '  "trustauthority_api_key": "FAKE_OR_TEST_API_KEY",' \
     '  "trustauthority_url": "https://portal.trustauthority.intel.com"' \
     '}' \
     > /etc/trustauthority-cli/config.json

# Google Secret Manager Python client (avoid bash-curl-jq in prod path)
RUN pip install --no-cache-dir google-cloud-secret-manager~=2.19


# Runtime linker can find libsqlcipher
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

# ---------- app setup ----------
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# ---------- runtime ----------
EXPOSE 5000
CMD ["./entrypoint.sh"]
