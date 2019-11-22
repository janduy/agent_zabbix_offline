#!/bin/bash
# Janduy Euclides <jsilva@astpbx.info>
#
# Versão: 1.0
#
# Info: Script Desenvolvido para Instalacao do agent do Zabbix em servidores
# sem conexao com a internet.

# Importando funções
source $(pwd)/funcoes.sh

if [ `check_install_agent` -ne 1 ]
then
    echo ""
    echo -e "\e[31m################################\e[0m"
    echo -e "\e[31mNao existe zabbix instalado!\e[0m"
    echo -e "\e[31m################################\e[0m"
    echo ""
else
    echo ""
    echo -e "\e[32m#############################\e[0m"
    echo -e "\e[32mO Zabbix ja esta instalado!\e[0m"
    echo -e "\e[32m#############################\e[0m"
    echo ""
    exit 0
fi
valida_null

# Definindo o nome do HOSTNAME do Agent
echo -e "\e[31m=====================================================================\e[0m"
echo -e "\e[31m  Defina o nome deste host para ser identificado no Zabbix Server.\n Lembrando que o valor nao pode ser NULO!\e[0m"
echo -e "\e[31m=====================================================================\e[0m"
read -p "NOME DO HOST(ZABBIX_AGENTE): " ZB_NAME_AGENT
HOST_NAME=$(echo "$ZB_NAME_AGENT" | tr '[:lower:]' '[:upper:]')

if [ -z $HOST_NAME ]
then
    echo "O nome nao foi definido, tente novamente!"
else
    echo "INICIANDO A INSTALACAO DO ZABBIX"
    install_zabbix_agent
fi
