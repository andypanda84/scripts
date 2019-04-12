#!/bin/bash
correo=usuario@dominio
USER="root"
PASSWORD="XXXXXX"
mysql=/usr/bin/mysql
mysqldump=/usr/bin/mysqldump
origen=/var/lib/mysql/
DIA=`date +"%d/%m/%Y"`
HORA=`date +"%H:%M"`
actual=/usr/bin/pwd
destino=/backup

#Tiene base de datos mysql para respaldar?
base=SI

#Nombre de la base de datos a respladar. En el caso de querer respaldar todas ponga la palabra "todo"
nombrebase=todo

#Sync de Base de Datos
syncbase()
{
        if nombrebase=="todo"
        then
                {
		cd $origen
                TABLES=`$mysql  -u $USER --password=$PASSWORD --execute="SHOW DATABASES;" |awk '{print($1)}' |grep -v "Database" |grep -v "information_schema"|grep -v "performance_schema"`
                        for table in $TABLES; do
                                echo "Respaldando la base $table..." # >> /tmp/respaldosbase
                                file=$table-backup_`date +"%Y-%m-%d"`.sql
                                $mysqldump -u $USER --password=$PASSWORD $table > $file
                                echo "Comprimiendo la base..."
                                tar -cvzf $file.tgz $file
                                rm -Rf *.sql
                                du -sh *.tgz > /tmp/respaldosbase
                        done


  }
        else
                       mysqldump --opt --password=Passworddelabase --user=root $nombrebase > $origen/$line.sql
        fi
}

#Sync de datos
syncdata()
{
cd $origen
mv -v *.tgz $destino #>> /tmp/respaldosbase
echo " " >> /tmp/respaldosbase
cd $destino
echo "Respaldos realizado en:" >> /tmp/respaldosbase
df -h|sed -n 1p >> /tmp/respaldosbase
df -h|sed -n 9p >> /tmp/respaldosbase

echo "######################################################################" >> /tmp/rsync_file
echo "#Verificar que la carpeta en donde se realiza el respaldo es /backup #" >> /tmp/rsync_file
echo "######################################################################" >> /tmp/rsync_file
}

#Envio de notificacion
reporte()
{
echo "######################################################################" >> /tmp/rsync_file
echo "#                         Proceso Concluido                          #" >> /tmp/rsync_file
echo "######################################################################" >> /tmp/rsync_file
echo "## TAMAÑO ########### NOMBRE DE BASE #################################" >> /tmp/rsync_file
echo "                                                                      " >> /tmp/rsync_file
cat /tmp/respaldosbase|grep -v borrado >> /tmp/rsync_file
echo "El respaldo a concluido en el 100%" | mail -s "Respaldo Diario de "$HOSTNAME"" $correo < /tmp/rsync_file
rm -f /tmp/respaldosbase
rm -f /tmp/rsync_file
}

 if base=="SI"
  then
      {
          syncbase
          syncdata
          reporte
      }
  else
           reporte
  fi
