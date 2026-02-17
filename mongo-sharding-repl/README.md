# mongo-sharding-repl

Проект с MongoDB: шардирование и **репликация** — у каждого шарда по три узла (replica set). Состав: config server, два шарда (rs1 и rs2) по 3 реплики, mongos и приложение.

## Как запустить

### 1. Запуск сервисов MongoDB (config server и шарды)

Сначала поднимаются config server и все узлы шардов. Mongos не стартует, пока config server не инициализирован как replica set.

```shell
docker compose up -d configsrv shard1-1 shard1-2 shard1-3 shard2-1 shard2-2 shard2-3
```

Подождите 10–15 секунд.

### 2. Инициализация config server

```shell
./scripts/init-configsrv.sh
```

### 3. Настройка репликации для каждого шарда

Каждый шард — это replica set из **трёх** узлов. Инициализация выполняется на первом узле каждого шарда (shard1-1 и shard2-1), в конфиге указываются все три члена replica set.

**Replica set rs1 (шард 1):**

```shell
./scripts/init-shard1.sh
```

Скрипт выполняет на контейнере `shard1-1` команду `rs.initiate()` с тремя участниками: `shard1-1:27018`, `shard1-2:27018`, `shard1-3:27018`.

**Replica set rs2 (шард 2):**

```shell
./scripts/init-shard2.sh
```

Скрипт выполняет на контейнере `shard2-1` команду `rs.initiate()` с тремя участниками: `shard2-1:27018`, `shard2-2:27018`, `shard2-3:27018`.

Подождите 10–15 секунд после инициализации шардов (выбор primary в каждом replica set).

### 4. Запуск mongos и приложения

```shell
docker compose up -d mongos pymongo_api
```

Подождите несколько секунд.

### 5. Регистрация шардов и включение шардирования

В кластер добавляются оба шарда (каждый задаётся строкой подключения к replica set из трёх узлов), включается шардирование для БД `somedb` и коллекции `helloDoc`:

```shell
./scripts/init-mongos.sh
```

### 6. Наполнение базы данными

```shell
./scripts/mongo-init.sh
```

В БД `somedb`, коллекция `helloDoc` будет вставлено 1000 документов.

## Одной командой (после первого запуска)

Если кластер уже поднимался и инициализация выполнялась:

```shell
docker compose up -d
```

## Как проверить

- **Локально:** http://localhost:8080  
- **На ВМ:** http://\<IP виртуальной машины\>:8080  

В ответе приложения (JSON) должны быть:

- общее количество документов в базе (≥ 1000);
- количество документов в каждом шарде (`shard_documents_count`);
- **количество реплик** по каждому шарду (`replicas_count`: по 3 для rs1 и rs2).

## Состав кластера

| Сервис     | Назначение |
|------------|------------|
| configsrv  | Config server (replica set), порт 27019 |
| shard1-1, shard1-2, shard1-3 | Replica set rs1 (шард 1), порт 27018 |
| shard2-1, shard2-2, shard2-3 | Replica set rs2 (шард 2), порт 27018 |
| mongos     | Роутер запросов, порт 27017 |
| pymongo_api| Приложение, подключается к mongos |

БД: `somedb`, коллекция: `helloDoc`.

## Шаги настройки репликации (кратко)

1. Запустить контейнеры узлов шардов (шаг 1 выше).
2. Инициализировать replica set **rs1** на первом узле шарда 1: `./scripts/init-shard1.sh` — в конфиге три члена: shard1-1, shard1-2, shard1-3.
3. Инициализировать replica set **rs2** на первом узле шарда 2: `./scripts/init-shard2.sh` — в конфиге три члена: shard2-1, shard2-2, shard2-3.
4. Дальнейшие шаги (mongos, addShard, наполнение данными) выполняются по разделам выше.

Автоматизация: все команды инициализации выполняются скриптами в `scripts/`; при необходимости те же команды можно выполнить вручную через `docker compose exec -T <service-name> mongosh --port <port> --quiet <<EOF ... EOF`.
