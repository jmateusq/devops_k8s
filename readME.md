# Aplicação de Notas Codificadas em Kubernetes com Helm

Este projeto demonstra o processo completo de conteinerização e orquestração de uma aplicação web de três camadas (Frontend, API, Banco de Dados) utilizando Docker, Kubernetes e Helm. O objetivo é transformar um ambiente `docker-compose` em uma implantação robusta e automatizada em um cluster Kubernetes local.

## Tabela de Conteúdos
- [Arquitetura da Aplicação](#arquitetura-da-aplicação)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Pré-requisitos](#pré-requisitos)
- [Guia de Instalação Rápida](#guia-de-instalação-rápida)
  - [Passo 1: Clonar o Repositório](#passo-1-clonar-o-repositório)
  - [Passo 2: Configurar o Ambiente e Construir as Imagens](#passo-2-configurar-o-ambiente-e-construir-as-imagens)
  - [Passo 3: Instalar a Aplicação com Helm](#passo-3-instalar-a-aplicação-com-helm)
  - [Passo 4: Configurar o Acesso Local](#passo-4-configurar-o-acesso-local)
  - [Passo 5: Acessar a Aplicação](#passo-5-acessar-a-aplicação)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Detalhes dos Artefatos Kubernetes](#detalhes-dos-artefatos-kubernetes)
- [Comandos Úteis do Helm](#comandos-úteis-do-helm)
- [Autor](#autor)

## Arquitetura da Aplicação

A aplicação é composta por três serviços principais que são orquestrados pelo Kubernetes:

1.  **Frontend**: Um servidor **Nginx** que serve uma interface de usuário estática (HTML/JavaScript).
2.  **API (Backend)**: Uma aplicação **Node.js/Express** que fornece uma API RESTful para as operações de notas.
3.  **Banco de Dados**: Uma instância do **MongoDB** para persistência dos dados.

O tráfego externo é gerenciado por um **Ingress Controller**, que roteia as requisições para os serviços apropriados com base no caminho da URL.

```
[ Navegador do Usuário ]
        |
        v
[ Ingress (k8s.local) ]
        |
        |--- (Rota: /) ---> [ Frontend Service ] -> [ Frontend Pod (Nginx) ]
        |
        |--- (Rota: /api)--> [ API Service ] ------> [ API Pod (Node.js) ]
                                                            |
                                                            v
                                                    [ MongoDB Service ] -> [ MongoDB Pod ]
```

## Tecnologias Utilizadas

- **Frontend**: HTML, JavaScript, Nginx
- **Backend**: Node.js, Express.js
- **Banco de Dados**: MongoDB
- **Conteinerização**: Docker
- **Orquestração**: Kubernetes (Minikube)
- **Gerenciamento de Pacotes**: Helm
- **Automação**: Shell Script

## Pré-requisitos

Garanta que as seguintes ferramentas estejam instaladas e funcionando em seu sistema:

- [Docker](https://www.docker.com/get-started)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Helm](https://helm.sh/docs/intro/install/)

## Guia de Instalação Rápida

Siga os passos abaixo para ter a aplicação rodando em seu ambiente local.

### Passo 1: Clonar o Repositório
```sh
git clone https://github.com/jmateusq/devops_k8s.git
cd devops_k8s/
```

### Passo 2: Configurar o Ambiente e Construir as Imagens
Este projeto inclui um script que automatiza a preparação do ambiente. Ele irá iniciar o Minikube, habilitar o addon de Ingress e construir as imagens Docker necessárias.

Primeiro, dê permissão de execução ao script:
```sh
chmod u+x build-and-load.sh
```

Agora, execute-o:
```sh
./build-and-load.sh
```

### Passo 3: Instalar a Aplicação com Helm
Com o ambiente pronto, utilize o Helm para instalar a aplicação no seu cluster Kubernetes. O nome `meu-release` é um exemplo.
```sh
helm install meu-release ./crypto-chart
```

### Passo 4: Configurar o Acesso Local
Para que seu navegador possa encontrar a aplicação em `http://k8s.local`, é necessário mapear o endereço IP do cluster a este nome de host.

**a. Obtenha o IP do Ingress:**
Execute o comando e anote o endereço na coluna `ADDRESS`.
```sh
kubectl get ingress
```

**b. Edite seu arquivo de hosts:**
Este passo requer permissão de administrador. O arquivo está em:
- **Linux/macOS:** `/etc/hosts`
- **Windows:** `C:\Windows\System32\drivers\etc\hosts`

Adicione a seguinte linha no final do arquivo, substituindo `<IP_DO_INGRESS>` pelo endereço que você anotou:
```
<IP_DO_INGRESS>  k8s.local
```
Exemplo:
```
192.168.49.2  k8s.local
```

### Passo 5: Acessar a Aplicação
Após salvar o arquivo de hosts, a configuração está completa. Abra seu navegador e acesse:

**`http://k8s.local`**

## Estrutura do Projeto

```
.
├── backend/                # Código-fonte e Dockerfile da API Node.js
├── frontend/               # Arquivos estáticos (HTML/JS) e configuração do Nginx
├── crypto-chart/           # Helm Chart para a implantação no Kubernetes
│   ├── templates/          # Manifestos Kubernetes (Deployment, Service, Ingress, etc.)
│   └── values.yaml         # Configurações personalizáveis do Chart
├── build-and-load.sh       # Script de automação para preparar o ambiente
└── README.md               # Este arquivo de documentação
```

## Detalhes dos Artefatos Kubernetes

- **Deployment**: Utilizado para gerenciar os pods *stateless* da API e do Frontend.
- **StatefulSet**: Utilizado para gerenciar o pod *stateful* do MongoDB, garantindo armazenamento e identidade de rede persistentes.
- **Service**: Cria um ponto de acesso de rede interno e estável (DNS) para cada componente, permitindo a comunicação entre eles.
- **PersistentVolumeClaim (PVC)**: Solicita armazenamento persistente para o MongoDB.
- **Ingress**: Gerencia o acesso HTTP externo, roteando o tráfego de `k8s.local` para os serviços corretos.

## Comandos Úteis do Helm

- **Verificar erros no chart:** `helm lint ./crypto-chart`
- **Ver o YAML que será gerado (dry-run):** `helm template meu-release ./crypto-chart`
- **Atualizar a aplicação após uma mudança:** `helm upgrade meu-release ./crypto-chart`
- **Reverter para uma versão anterior:** `helm rollback meu-release <NÚMERO_DA_REVISÃO>`
- **Desinstalar a aplicação:** `helm uninstall meu-release`

## Autor

José Mateus Freitas Queiroz - 811840

```