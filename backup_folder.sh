correo=usuario@dominio
origen=/var/www/html/
actual=$(/usr/bin/pwd)
destino=/backup/

#Tiene carpetas para respaldar?
folders=SI

#Nombre de la carpeta a respladar. En el caso de querer respaldar todas ponga la palabra "todo"
files=todo

#Comprimido de Carpetas
synccarpetas()
{
        if files=="todo"
        then
                {
                cd $origen
                CARPETAS=`ls -l |awk '{print($9)}'`
                        for table in $CARPETAS; do
                                echo "Respaldando la carpeta $table" #>> /tmp/respaldofolder
                                file=$table
                                echo "Comprimiendo archivos $file..."
                                tar -czf backup_`date +"%Y-%m-%d"`_$file.tgz $file
                        done
}
        else
                       tar -czf backup_`date +"%Y-%m-%d"`_$file.tgz $file
        fi
}

#Sync de datos
syncdata()
{
	cd $origen
	mv -v *.tgz $destino #>> /tmp/respaldofolder
	echo " " >> /tmp/respaldofolder
}

#Envio de notificacion por mail
reporte()
{
	cd $destino
		echo "                                                                      " >> /tmp/respaldofolder
		echo "Respaldos realizado en: $destino						       		                 " >> /tmp/respaldofolder
	du -sh backup_`date +"%Y-%m-%d"`*.tgz > /tmp/respaldofolder
		echo "                                                                      " >> /tmp/respaldofolder
	df -h|sed -n 1p >> /tmp/respaldofolder
	df -h|sed -n 10p >> /tmp/respaldofolder
		echo "######################################################################" >> /tmp/rsync_file
		echo "#                         Proceso Concluido                          #" >> /tmp/rsync_file
		echo "######################################################################" >> /tmp/rsync_file
	cat /tmp/respaldofolder|grep -v borrado >> /tmp/rsync_file
		echo "######################################################################" >> /tmp/rsync_file
		echo "#Verificar que la carpeta en donde se realiza el respaldo es /backup #" >> /tmp/rsync_file
		echo "######################################################################" >> /tmp/rsync_file
		echo "El respaldo a concluido en el 100%" | mail -s "Respaldo Diario de "$HOSTNAME"" $correo < /tmp/rsync_file
	rm -f /tmp/respaldofolder
	rm -f /tmp/rsync_file
}

 if folders=="SI"
  then
      {
        synccarpetas
        syncdata
        reporte
      }
  else
		syncdata
		reporte
  fi
