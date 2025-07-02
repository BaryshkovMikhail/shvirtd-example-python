#!/bin/bash

# Очистка старых данных
echo "Очистка старых контейнеров и сетей..."
docker compose -f proxy.yaml down --remove-orphans 2>/dev/null || true
docker rm -f mysql-dev webapp 2>/dev/null || true

# Удаляем старую сеть, если существует
docker network rm backend 2>/dev/null || true

# Создаем новую сеть
echo "Создание сети backend..."
docker network create --subnet=172.20.0.0/24 backend

# Запуск MySQL с автоматической инициализацией
echo "Запуск MySQL..."
docker run -d \
  --name mysql-dev \
  --network backend \
  --ip 172.20.0.10 \
  -e MYSQL_ROOT_PASSWORD=YtReWq4321 \
  -e MYSQL_DATABASE=virtd \
  -e MYSQL_USER=app \
  -e MYSQL_PASSWORD=QwErTy1234 \
  -v $(pwd)/mysql/initdb.d:/docker-entrypoint-initdb.d \
  mysql:8.0

# Ждём, пока MySQL запустится
echo "Ожидание запуска MySQL..."
sleep 10

# Сборка и запуск FastAPI приложения
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

# Запуск прокси
echo "Запуск reverse-proxy и ingress-proxy..."
docker compose -f proxy.yaml up -d

# Информация о запуске
echo ""
echo "✅ Сервисы запущены:"
echo "- MySQL: 172.20.0.10:3306"
echo "- WebApp: 172.20.0.5:5000"
echo "- Reverse Proxy: localhost:8080"
echo "- Ingress Proxy: localhost:8090"

echo ""
echo "💡 Проверьте работу:"
echo "curl http://localhost:8090"