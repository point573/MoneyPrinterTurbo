# Use an official Python runtime as a parent image
FROM python:3.11-slim-bullseye

WORKDIR /MoneyPrinterTurbo
ENV PYTHONPATH="/MoneyPrinterTurbo"

# Install system dependencies (usando mirrors oficiales para Railway)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    imagemagick \
    ffmpeg \
    curl \
    debian-keyring \
    debian-archive-keyring \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# Install Caddy
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list \
    && apt-get update \
    && apt-get install -y caddy \
    && rm -rf /var/lib/apt/lists/*

# Fix security policy for ImageMagick
RUN sed -i '/<policy domain="path" rights="none" pattern="@\*"/d' /etc/ImageMagick-6/policy.xml || true

# Copy requirements first for cache
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy codebase
COPY . .

# Create Caddyfile
RUN echo ':${PORT} {\n\
    reverse_proxy /docs localhost:8080\n\
    reverse_proxy /redoc localhost:8080\n\
    reverse_proxy /openapi.json localhost:8080\n\
    reverse_proxy /api/* localhost:8080\n\
    reverse_proxy localhost:8501\n\
}' > /etc/caddy/Caddyfile

# Expose default port
EXPOSE 8501

# Start script: FastAPI + Streamlit + Caddy
CMD bash -c "\
    python main.py & \
    streamlit run ./webui/Main.py \
        --server.address=0.0.0.0 \
        --server.port=8501 \
        --server.enableCORS=true \
        --browser.gatherUsageStats=false & \
    caddy run --config /etc/caddy/Caddyfile --adapter caddyfile"
