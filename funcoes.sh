#!/usr/bin/env bash

# Valida se a variavel IP do server ZB se á nula.
valida_null(){

COUNT=3

while [ $COUNT -gt 0 ]
do
    read -p "IP do Server: " ZB_SERVER
    sleep 1

    COUNT=$((COUNT - 1))
    if [ -z "$ZB_SERVER" ]
    then
      echo ""
      echo -e "\e[31m#######################################\e[0m"
      echo -e "\e[31mO IP do server Zabbix nao foi definido!\e[0m"
      echo -e "\e[31m#######################################\e[0m"
      echo ""
      sleep 1
    elif [ `valida_ip $ZB_SERVER` -eq "0" ]
    then
      echo ""
      echo -e "\e[31m#######################################\e[0m"
      echo -e "\e[31m  O IP do server Zabbix nao e VALIDO \e[0m"
      echo -e "\e[31m#######################################\e[0m"
      echo ""
      sleep 1
    else
    	echo "FIM..."
	break
    fi
done
if [ $COUNT -le 0  ]
then 
    echo "NAO FOI POSSIVEL SEGUIR, TENTE NOVAMENTE!"
    exit 0
fi
}

# Valida se o IP é valido
valida_ip(){

if expr "$ZB_SERVER" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
  echo 1
else
  echo 0
  exit 0
fi
}

check_install_agent(){
    # Checa se o zabbix já existe
    ZABBIX_CHECK=$(yum list installed | grep zabbix | awk '{ print $1 }')

    if [ -z "$ZABBIX_CHECK" ]
    then
        echo 0
    else
        echo 1
    fi
}

install_zabbix_agent(){

# repositorio
rpm -i zabbix-agent-3.0.28-1.el6.x86_64.rpm

# Checa se o Conf Agentd existe!
DIR='/etc/zabbix'

if [ -d "$DIR" ]; then
echo "Installing config files in ${DIR}..."
echo "#Confs Agent Zabbix
Server=$ZB_SERVER
Hostname=$HOST_NAME
StartAgents=3
Timeout=3
ListenPort=10050
AllowRoot=1
DebugLevel=3
LogFile=/etc/zabbix/zabbix_agentd.log
LogFileSize=1
LogRemoteCommands=1
EnableRemoteCommands=1
PidFile=/tmp/zabbix_agentd.pid
Include=/etc/zabbix/zabbix_agentd.d/*.conf" > $DIR/zabbix_agentd.conf
else
###  Control will jump here if $DIR does NOT exists ###
echo -e "\e[31m##########################################\e[0m"
echo -e "\e[31mError: ${DIR} not found. Can not continue.\e[0m"
echo -e "\e[31m##########################################\e[0m"
exit 1
fi
# Sudoers
echo "Defaults:zabbix !requiretty
Cmnd_Alias ZABBIX_CMD = /usr/sbin/asterisk
zabbix   ALL = (other_user)  NOPASSWD: ALL
zabbix   ALL = (root)        NOPASSWD: ZABBIX_CMD" >> /etc/sudoers
echo ""
# restart
service zabbix-agent restart
# Start Onboot
chkconfig --level 12345 zabbix-agent on
# Allow ports zabbix iptables
iptables -I INPUT -s 192.168.9.0/24 -p tcp -m tcp --dport 10050 -m comment --comment "ALLOW 10050 ZABBIX" -j ACCEPT
iptables -I INPUT -s 192.168.9.0/24 -p tcp -m tcp --dport 10051 -m comment --comment "ALLOW 10051 ZABBIX" -j ACCEPT
}
