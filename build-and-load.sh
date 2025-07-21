#!/bin/bash

# Script para configurar o ambiente Minikube e construir as imagens locais.
# Ele unifica os passos de inicialização do cluster, habilitação do Ingress e build das imagens.

# Encerra o script imediatamente se um comando falhar.
set -e

# --- Passo 1: Verificando e/ou iniciando o Minikube (Equivalente ao Passo 2 do README) ---
echo "--- Verificando o status do Minikube... ---"

# Usamos 'grep -q' para verificar silenciosamente se a saída contém "minikube: Running"
if minikube status | grep -q "minikube: Running"; then
    echo "✅  Minikube já está em execução."
else
    echo "🚀  Minikube não está rodando. Iniciando agora..."
    minikube start --cpus=4 --memory=4g
    echo "✅  Minikube iniciado com sucesso."
fi

echo "" # Adiciona uma linha em branco para melhor legibilidade

# --- Passo 2: Verificando e/ou habilitando o addon Ingress (Equivalente ao Passo 3 do README) ---
echo "--- Verificando o status do addon Ingress... ---"

# Verificamos se 'ingress' aparece como 'enabled' na lista de addons
if minikube addons list | grep 'ingress' | grep -q 'enabled'; then
    echo "✅  O addon Ingress já está habilitado."
else
    echo "🔌  Habilitando o addon Ingress..."
    minikube addons enable ingress
    echo "✅  Addon Ingress habilitado com sucesso."
fi

echo ""

# --- Passo 3: Construindo e carregando as imagens no Minikube (Equivalente ao Passo 4 do README) ---
echo "--- Construindo as imagens Docker e carregando no Minikube... ---"

# Esta linha mágica configura o seu shell para usar o daemon do Docker dentro do Minikube.
echo "   - Apontando o terminal para o Docker do Minikube..."
eval $(minikube -p minikube docker-env)

# Construindo a imagem do backend
echo "   - Construindo a imagem da API (note-api:latest)..."
docker build -t note-api:latest -f backend/Dockerfile.api ./backend

# Construindo a imagem do frontend
echo "   - Construindo a imagem do Frontend (note-frontend:latest)..."
docker build -t note-frontend:latest -f frontend/Dockerfile.frontend ./frontend

echo "✅  Imagens construídas e carregadas com sucesso!"

echo ""
echo "--------------------------------------------------------"
echo "🎉 Ambiente pronto! Próximos passos:"
echo "1. Instale a aplicação com Helm: helm install meu-release ./crypto-chart"
echo "2. Configure seu arquivo de hosts (se ainda não o fez)."
echo "3. Acesse http://k8s.local no seu navegador."
echo "--------------------------------------------------------"