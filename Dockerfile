FROM python:3.11-slim-bullseye

WORKDIR /MoneyPrinterTurbo
ENV PYTHONPATH="/MoneyPrinterTurbo"

RUN apt-get update && apt-get install -y --no-install-recommends \
    git imagemagick ffmpeg curl gnupg \
    && rm -rf /var/lib/apt/lists/*

# Caddy
RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list \
    && apt-get update && apt-get install -y caddy && rm -rf /var/lib/apt/lists/*

RUN sed -i '/<policy domain="path" rights="none" pattern="@\*"/d' /etc/ImageMagick-6/policy.xml || true

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Caddyfile usando @matcher y handle (SIN stripear path)
RUN cat > /etc/caddy/Caddyfile << 'CADDYEOF'
:{$PORT} {
    @api path /docs /docs/* /redoc /redoc/* /openapi.json /api/*
    handle @api {
        reverse_proxy 127.0.0.1:8080
    }
    handle {
        reverse_proxy 127.0.0.1:8501
    }
}
CADDYEOF

EXPOSE 8501

CMD ["bash", "-c", "python main.py & streamlit run ./webui/Main.py --server.address=0.0.0.0 --server.port=8501 --server.enableCORS=true --browser.gatherUsageStats=false & sleep 3 && caddy run --config /etc/caddy/Caddyfile --adapter caddyfile"]
