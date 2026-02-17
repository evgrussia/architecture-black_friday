# sharding-repl-cache

Проект с MongoDB: шардирование, репликация (по 3 реплики на шард) и **кеширование** запросов в Redis. Приложение кеширует ответы эндпоинта `/<collection_name>/users` в Redis; повторные запросы выполняются за &lt;100 мс.

## Как запустить

### 1. Запуск сервисов MongoDB (config server и шарды)

```shell
docker compose up -d configsrv shard1-1 shard1-2 shard1-3 shard2-1 shard2-2 shard2-3
```

Подождите 10–15 секунд.

### 2. Инициализация config server

**Linux/macOS (bash):**
```shell
./scripts/init-configsrv.sh
```

**Windows (PowerShell):**
```powershell
Get-Content scripts\init-configsrv.js -Raw | docker compose exec -T configsrv mongosh --port 27019 --quiet
```

### 3. Настройка репликации для каждого шарда

**Linux/macOS:**
```shell
./scripts/init-shard1.sh
./scripts/init-shard2.sh
```

**Windows (PowerShell):**
```powershell
Get-Content scripts\init-shard1.js -Raw | docker compose exec -T shard1-1 mongosh --port 27018 --quiet
Get-Content scripts\init-shard2.js -Raw | docker compose exec -T shard2-1 mongosh --port 27018 --quiet
```

Подождите 10–15 секунд.

### 4. Запуск mongos, Redis и приложения

```shell
docker compose up -d mongos redis pymongo_api
```

Подождите несколько секунд. Приложение подключается к mongos и к Redis (переменная окружения `REDIS_URL: "redis://redis:6379"`).

### 5. Регистрация шардов и включение шардирования

**Linux/macOS:** `./scripts/init-mongos.sh`  
**Windows:** `Get-Content scripts\init-mongos.js -Raw | docker compose exec -T mongos mongosh --port 27017 --quiet`

### 6. Наполнение базы данными

**Linux/macOS:** `./scripts/mongo-init.sh`  
**Windows:** `Get-Content scripts\mongo-init.js -Raw | docker compose exec -T mongos mongosh --port 27017 --quiet`

**Примечание.** Скрипты `.sh` используют JS-файлы из папки `scripts/`. На Windows можно также запустить все шаги инициализации одной командой из корня проекта: `.\scripts\init-all.ps1` (после шага 1 — запуска контейнеров). Если имена контейнеров конфликтуют с другим проектом (mongo-sharding-repl), остановите его: `docker stop configsrv shard1-1 ... ; docker rm ...`

## Одной командой (после первого запуска)

```shell
docker compose up -d
```

## Как проверить

- **Локально:** http://localhost:8080  
- **На ВМ:** http://\<IP виртуальной машины\>:8080  

В ответе главной страницы (JSON):

- общее количество документов в базе (≥ 1000);
- количество документов в каждом шарде (`shard_documents_count`);
- количество реплик по каждому шарду (`replicas_count`);
- **cache_enabled: true** — кеширование включено.

### Проверка кеширования

Кеширование включено для эндпоинта **`/<collection_name>/users`** (например, `/helloDoc/users`).

1. Первый запрос к `GET /helloDoc/users` может занять больше времени (обращение к MongoDB).
2. Второй и последующие запросы к тому же URL отдаются из Redis и должны выполняться **менее чем за 100 мс**.

Проверка с замером времени (PowerShell):

```powershell
Measure-Command { Invoke-WebRequest -Uri "http://localhost:8080/helloDoc/users" -UseBasicParsing | Out-Null }
```

Повторите запрос несколько раз: первый раз — дольше, следующие — значительно быстрее (&lt;100 мс).

В Linux/macOS:

```shell
curl -w "%{time_total}s\n" -o /dev/null -s http://localhost:8080/helloDoc/users
```

## Состав кластера

| Сервис      | Назначение |
|-------------|------------|
| configsrv   | Config server (replica set), порт 27019 |
| shard1-1 … shard1-3 | Replica set rs1 (шард 1), порт 27018 |
| shard2-1 … shard2-3 | Replica set rs2 (шард 2), порт 27018 |
| mongos      | Роутер запросов, порт 27017 |
| **redis**   | Кеш запросов приложения, порт 6379 |
| pymongo_api | Приложение (подключено к mongos и redis) |

БД: `somedb`, коллекция: `helloDoc`. Кеш: Redis, переменная окружения `REDIS_URL: "redis://redis:6379"`.
