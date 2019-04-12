#!/bin/bash
usuario=usuario_ssh
ip=ip_server_notify
puerto=puerto_ssh
IP_gateway=ip_server_internet
IP_server_mariadb=ip_server_mariadb

while :
do
	function checkport {
	if nc -v -w10 $1 $2 <<< '' &> /dev/null
	then
		echo "$(date +"%d%b%Y %T") [+] Port $1/$2 is open"
	else
		echo "El servicio: "$3." Esta detenido $(date +"%d%b%Y %T")" > /tmp/telegram_msg_caption.txt
		scp -p $puerto /tmp/telegram_msg_caption.txt $usuario@$ip:/tmp/telegram_msg_caption.txt
		ssh -p $puerto $usuario@$ip 'sh scripts/telegrambot.sh'
	fi
	}

	function checkping {
	if [ "'ping -c 1 $1'" ]
	then
		echo "$(date +"%d%b%Y %T") [+] Host $1 is up"
	else
		echo "El Host: "$3." Es inalcanzable $(date +"%d%b%Y %T")" > /tmp/telegram_msg_caption.txt|sh /root/scripts/telegrambot.sh
	fi
	}

	checkping '$IP_gateway' 23 "GW Internet"
	checkport '$IP_server_mariabd' 3306 "nombre del servidore - Puerto 3306"
	exit 0
done
