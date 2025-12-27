FROM python:3.11-slim-bullseye

WORKDIR /MoneyPrinterTurbo
ENV PYTHONPATH="/MoneyPrinterTurbo"

RUN apt-get update && apt-get install -y --no-install-recommends \
    git imagemagick ffmpeg curl gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg \
    && curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list \
    && apt-get update && apt-get install -y caddy && rm -rf /var/lib/apt/lists/*

RUN sed -i '/<policy domain="path" rights="none" pattern="@\*"/d' /etc/ImageMagick-6/policy.xml || true

COPY requirements.txt ./
# Agregar toml para manipular config.toml desde Python
RUN pip install --no-cache-dir -r requirements.txt toml

COPY . .

RUN cat > /etc/caddy/Caddyfile << 'CADDYEOF'
{
    admin off
}

:8000 {
    @api path /docs /docs/* /redoc /redoc/* /openapi.json /api/*
    handle @api {
        reverse_proxy [::1]:8080
    }
    handle {
        reverse_proxy 127.0.0.1:8501
    }
}
CADDYEOF

ENV PORT=8000
EXPOSE 8000

# Cargar variables de entorno y arrancar servicios
CMD ["bash", "-c", "python load_env.py && uvicorn app.asgi:app --host '::' --port 8080 & streamlit run ./webui/Main.py --server.address=0.0.0.0 --server.port=8501 --server.enableCORS=true --browser.gatherUsageStats=false & sleep 5 && caddy run --config /etc/caddy/Caddyfile --adapter caddyfile"]
