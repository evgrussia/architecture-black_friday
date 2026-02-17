# Проектная работа 4 спринта — «Мобильный мир»

Репозиторий содержит решение задач по отказоустойчивости, шардированию, репликации и кешированию MongoDB для онлайн-магазина.

## Что в репозитории

- **mongo-sharding** — задание 2: шардирование MongoDB (2 шарда).
- **mongo-sharding-repl** — задание 3: шардирование + репликация (по 3 реплики на шард).
- **sharding-repl-cache** — **финальный стенд для проверки**: задание 2 + 3 + 4 (шардирование, репликация, Redis-кеш). Используется образ приложения `kazhem/pymongo_api:1.0.0`.
- **task1-final.drawio** — итоговая схема архитектуры (задания 1, 5, 6): шардирование, репликация, кеш, API Gateway, Consul, CDN.

## Как поднять стенд (для ревьюера)

Для проверки используется директория **sharding-repl-cache**. В ней разворачиваются приложение (образ `kazhem/pymongo_api:1.0.0`), Redis и MongoDB с шардированием и репликацией.

### Требования

- Docker и Docker Compose.
- На Windows — PowerShell (или Git Bash для скриптов `.sh`).

### Шаги запуска

Перейдите в директорию проекта:

```bash
cd sharding-repl-cache
```

Подробная инструкция по шагам инициализации, проверке кеша и вариантам для Windows — в файле **sharding-repl-cache/README.md**.

**1. Запуск контейнеров MongoDB (config server и шарды):**

```bash
docker compose up -d configsrv shard1-1 shard1-2 shard1-3 shard2-1 shard2-2 shard2-3
```

Подождите 10–15 секунд.

**2. Инициализация config server:**

Linux/macOS:
```bash
./scripts/init-configsrv.sh
```

Windows (PowerShell):
```powershell
Get-Content scripts\init-configsrv.js -Raw | docker compose exec -T configsrv mongosh --port 27019 --quiet
```

**3. Инициализация replica set для каждого шарда:**

Linux/macOS:
```bash
./scripts/init-shard1.sh
./scripts/init-shard2.sh
```

Windows (PowerShell):
```powershell
Get-Content scripts\init-shard1.js -Raw | docker compose exec -T shard1-1 mongosh --port 27018 --quiet
Get-Content scripts\init-shard2.js -Raw | docker compose exec -T shard2-1 mongosh --port 27018 --quiet
```

Подождите 10–15 секунд.

**4. Запуск mongos, Redis и приложения:**

```bash
docker compose up -d mongos redis pymongo_api
```

Подождите 5–10 секунд.

**5. Регистрация шардов и включение шардирования:**

Linux/macOS:
```bash
./scripts/init-mongos.sh
```

Windows:
```powershell
Get-Content scripts\init-mongos.js -Raw | docker compose exec -T mongos mongosh --port 27017 --quiet
```

**6. Наполнение базы данными (1000 документов):**

Linux/macOS:
```bash
./scripts/mongo-init.sh
```

Windows:
```powershell
Get-Content scripts\mongo-init.js -Raw | docker compose exec -T mongos mongosh --port 27017 --quiet
```

### Проверка статуса сервисов

```bash
docker compose ps
```

Все сервисы (configsrv, shard1-1, shard1-2, shard1-3, shard2-1, shard2-2, shard2-3, mongos, redis, pymongo_api) должны быть в состоянии `Up`.

### Проверка приложения

- Локально: откройте в браузере **http://localhost:8080**
- На ВМ: **http://\<IP виртуальной машины\>:8080**

На главной странице приложение возвращает **JSON** с:

- информацией о MongoDB: тип топологии (`Sharded`), база `somedb`, коллекции, шарды;
- **статусом использования кеша** (`cache_enabled`: true при подключённом Redis).

Документация API (Swagger): http://localhost:8080/docs (или с IP ВМ).

### Повторный запуск (после первого успешного поднятия)

Если контейнеры и тома уже созданы и инициализация выполнялась:

```bash
cd sharding-repl-cache
docker compose up -d
```

Данные сохраняются в томах Docker.

## Итоговая схема

Файл **task1-final.drawio** — итоговая архитектурная схема по заданиям 1, 5 и 6:

- Шардирование и репликация MongoDB
- Кеширование (Redis)
- API Gateway и Consul (Service Discovery)
- CDN в нескольких регионах

Схему можно открыть в [draw.io](https://app.diagrams.net/) или в VS Code с расширением Draw.io.

## Образ приложения

В **sharding-repl-cache** используется образ **kazhem/pymongo_api:1.0.0** (указан в `compose.yaml`).
