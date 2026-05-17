# Coolify 部署说明

## 项目判断

MediaCrawler 是 Python 3.11 项目，WebUI 静态文件已经放在 `api/webui`，后端入口是 `api.main:app`，对外端口是 `8080`。

Coolify 推荐使用本仓库新增的 `Dockerfile` 部署，不建议直接用 Nixpacks。原因是项目依赖 Playwright/Chromium、Node.js、中文字体和浏览器运行参数，Dockerfile 更可控。

## Coolify 创建应用

1. 在 Coolify 新建 `Application`，选择 Git 仓库。
2. Build Pack 选择 `Dockerfile`。
3. Dockerfile 路径填写 `Dockerfile`。
4. 端口填写 `8080`。
5. Healthcheck 路径填写 `/api/health`。
6. 添加持久化卷：
   - `/app/data`
   - `/app/browser-data`
   - `/app/database`

## 必填环境变量

复制 `.env.coolify.example` 中的基础变量到 Coolify 的 Environment Variables。最关键的是：

```env
PORT=8080
SAVE_DATA_PATH=/app/data
USER_DATA_DIR=/app/browser-data/%s_user_data_dir
HEADLESS=true
CDP_HEADLESS=true
ENABLE_CDP_MODE=false
CDP_CONNECT_EXISTING=false
FORCE_HEADLESS=true
SAVE_DATA_OPTION=jsonl
MAX_CONCURRENCY_NUM=1
```

## 环境检测失败：JavaScript runtime

如果 WebUI 环境检测里看到 `RuntimeUnavailableError: Could not find an available JavaScript runtime.`，说明正在运行的镜像缺少 Node.js。请确认已经部署包含本 Dockerfile 的最新镜像，并在 Coolify 中执行一次重新构建，而不是仅重启旧容器。

## 登录方式建议

容器里没有可见桌面，推荐优先使用 `cookie` 登录方式，在 WebUI 中粘贴 Cookie。

如果必须扫码登录，建议先在本机运行项目完成登录并保存浏览器状态，再考虑把对应浏览器数据目录迁移到 `/app/browser-data`。不过这类爬虫平台风控变化较多，Coolify 里使用 Cookie 通常更实际。

## 本机 Docker 验证

```bash
docker compose -f docker-compose.coolify.yml up --build
```

启动后访问：

```text
http://localhost:8080
```

健康检查：

```text
http://localhost:8080/api/health
```

## 使用数据库

默认 `SAVE_DATA_OPTION=jsonl`，数据保存到 `/app/data`。如果想用数据库：

- MySQL：Coolify 添加 MySQL 服务，设置 `MYSQL_DB_HOST` 为服务名，比如 `mysql`，并在 WebUI 中选择 `db`。
- PostgreSQL：设置 `POSTGRES_DB_HOST` 为服务名，比如 `postgres`，命令行模式可使用 `postgres` 保存项。
- MongoDB：设置 `MONGODB_HOST` 为服务名，比如 `mongodb`，并选择 `mongodb` 保存项。

首次使用关系型数据库前，需要进入容器执行初始化：

```bash
uv run python main.py --init_db sqlite
uv run python main.py --init_db mysql
uv run python main.py --init_db postgres
```
