#!/bin/bash

# 1. Очистка предыдущих запусков
echo "Очистка старых контейнеров и сетей..."
docker compose -f proxy.yaml down --remove-orphans 2>/dev/null || true
docker rm -f mysql-dev webapp 2>/dev/null || true

# 2. Удаляем сеть backend, если существует
docker network rm backend 2>/dev/null || true

# 3. Создаем новую сеть backend с подсетью 172.20.0.0/24
echo "Создание сети backend..."
docker network create --subnet=172.20.0.0/24 backend

# 4. Запуск MySQL в Docker
echo "Запуск MySQL..."
docker run -d \
  --name mysql-dev \
  --network backend \
  --ip 172.20.0.10 \
  -e MYSQL_ROOT_PASSWORD=YtReWq4321 \
  -e MYSQL_DATABASE=virtd \
  -e MYSQL_USER=app \
  -e MYSQL_PASSWORD=QwErTy1234 \
  mysql:8.0

# 5. Сборка и запуск Python-приложения
echo "Сборка и запуск FastAPI приложения..."
docker build -f Dockerfile.python -t my-fastapi .

docker run -d \
  --name webapp \
  --network backend \
  --ip 172.20.0.5 \
  -e DB_HOST=172.20.0.10 \
  -e DB_USER=app \
  -e DB_PASSWORD=QwErTy1234 \
  -e DB_NAME=virtd \
  my-fastapi

# 6. Запуск reverse-proxy и ingress-proxy из proxy.yaml
echo "Запуск прокси..."
docker compose -f proxy.yaml up -d

# 7. Вывод информации
echo ""
echo "✅ Сервисы запущены:"
echo "- MySQL: 172.20.0.10:3306"
echo "- WebApp: 172.20.0.5:5000"
echo "- Reverse Proxy: localhost:8080"
echo "- Ingress Proxy: localhost:8090"

echo ""
echo "💡 Проверьте работу:"
echo "curl http://localhost:8090"