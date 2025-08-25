#!/bin/bash
echo "Atualizando sistema..."
sudo apt-get update -y && sudo apt-get upgrade -y
echo "Instalando dependências essenciais..."
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
echo "Instalando Flutter via snap..."
sudo snap install flutter --classic
echo "Verificando versão do Flutter..."
flutter --version
echo "Configuração concluída!"./