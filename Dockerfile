FROM mcr.microsoft.com/playwright/python:v1.45.0-jammy

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    UV_PYTHON=3.11 \
    UV_LINK_MODE=copy \
    PORT=8080 \
    HOST=0.0.0.0 \
    SAVE_DATA_PATH=/app/data \
    USER_DATA_DIR=/app/browser-data/%s_user_data_dir \
    HEADLESS=true \
    CDP_HEADLESS=true \
    ENABLE_CDP_MODE=false \
    CDP_CONNECT_EXISTING=false \
    FORCE_HEADLESS=true

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        fonts-noto-cjk \
        fonts-wqy-zenhei \
        nodejs \
        tini \
    && rm -rf /var/lib/apt/lists/* \
    && python -m pip install --no-cache-dir uv==0.5.11

COPY pyproject.toml uv.lock README.md .python-version ./
RUN uv sync --frozen --no-install-project

COPY . .
RUN uv sync --frozen

RUN mkdir -p /app/data /app/browser-data /app/database

EXPOSE 8080

ENTRYPOINT ["tini", "--"]
CMD ["sh", "-c", "uv run uvicorn api.main:app --host ${HOST:-0.0.0.0} --port ${PORT:-8080}"]
