#!/bin/bash

# build-and-load.sh

# Esta linha mágica configura o seu shell para usar o daemon do Docker dentro do Minikube.
# Todas as imagens que você construir a partir daqui estarão disponíveis no cluster K8s.
echo ">> Configurando o ambiente Docker para o Minikube"
eval $(minikube -p minikube docker-env)

# Parar em caso de erro
set -e

echo ">> Construindo a imagem da API..."
# Nós damos um nome (tag) para a imagem, por exemplo, "note-api:latest"
# O ponto '.' indica que o Dockerfile está no diretório atual (backend/).
docker build -t note-api:latest -f backend/Dockerfile.api ./backend

echo ">> Construindo a imagem do Frontend..."
docker build -t note-frontend:latest -f frontend/Dockerfile.frontend ./frontend

echo ">> Imagens construídas e carregadas com sucesso no Minikube!"
echo ">> Imagens disponíveis:"
docker images | grep "note-"
