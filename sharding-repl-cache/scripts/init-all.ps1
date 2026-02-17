# Инициализация кластера sharding-repl-cache (PowerShell)
# Запускать из корня проекта: .\scripts\init-all.ps1

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "1. Инициализация config server..."
Get-Content "$ScriptDir\init-configsrv.js" -Raw | docker compose exec -T configsrv mongosh --port 27019 --quiet

Write-Host "2. Инициализация shard1 (rs1)..."
Get-Content "$ScriptDir\init-shard1.js" -Raw | docker compose exec -T shard1-1 mongosh --port 27018 --quiet

Write-Host "3. Инициализация shard2 (rs2)..."
Get-Content "$ScriptDir\init-shard2.js" -Raw | docker compose exec -T shard2-1 mongosh --port 27018 --quiet

Write-Host "Ожидание 12 сек (replica set election)..."
Start-Sleep -Seconds 12

Write-Host "4. Запуск mongos, redis, pymongo_api..."
docker compose up -d mongos redis pymongo_api
Start-Sleep -Seconds 5

Write-Host "5. Регистрация шардов и включение шардирования..."
Get-Content "$ScriptDir\init-mongos.js" -Raw | docker compose exec -T mongos mongosh --port 27017 --quiet

Write-Host "6. Наполнение базы данными (1000 документов)..."
Get-Content "$ScriptDir\mongo-init.js" -Raw | docker compose exec -T mongos mongosh --port 27017 --quiet

Write-Host "Готово. Проверка: http://localhost:8080"
