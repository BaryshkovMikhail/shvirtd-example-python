#!/bin/bash

# Отправляем GET-запрос на корневой эндпоинт
curl -s http://localhost:8090/

# Проверяем ответ из БД
echo -e "\n\n--- Последние записи из БД ---"
curl -s http://localhost:8090/requests | jq .