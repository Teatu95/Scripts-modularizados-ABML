#!/bin/bash
#Definición de Variables (Lleva el tilde en la o?)
DB_USER="root"
DB_PASS="Tcontraa"
DB_NAME="nameee"

REMOTO_USER="usuario_remoto"       #Useer del servidor de respaldo
REMOTO_IP="192.168.1.50"           #IP del servidor de respaldo
REMOTO_DIR="/var/backups/remotos"   #Carpeta destino del servidor remoto

APACHEUBI="/var/www/html" 

#Profe, la verdad no estaba seguro si hacer todo esto variables de entorno
#Se me hace mas facil crear todas las variables aca pero, ¿usted que piensa?

#Verificamos variables de entorno
if [ -z "$DISCO" ] || [ -z "$PUNTO_MONTAJE" ] || [ -z "$MAX_CARPETAS" ]; then
    echo "Error: Falta configurar DISCO, PUNTO_MONTAJE o MAX_CARPETAS en el entorno."
    exit 1
fi

#Montar disco local de respaldos
echo "Montando el disco en $PUNTO_MONTAJE..."
sudo mount "$DISCO" "$PUNTO_MONTAJE"

#Crear carpeta de respaldo local con fecha
FECHA=$(date +"%Y-%m-%d_%H-%M")
NUEVA_CARPETA="$PUNTO_MONTAJE/$FECHA"
mkdir -p "$NUEVA_CARPETA"

#Detener Apache temporalmente
echo "Deteniendo Apache para respaldo consistente de la web..."
sudo systemctl stop apache2

echo "Respaldando archivos del sitio web..."
sudo tar -czvf "$NUEVA_CARPETA/html.backup.tar.gz" -C "$(dirname "$APACHEUBI")" "$(basename "$APACHEUBI")"
#Iniciar Apache nuevamente
echo "Reanudando servicio Apache...."
sudo systemctl start apache2

#Respaldo Local: Dump de la Base de Datos
echo "Realizando dump de la base de datos MySQL.."
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$NUEVA_CARPETA/db_backup.sql"
gzip "$NUEVA_CARPETA/db_backup.sql"

#Mi "Animación" JASJ
opp=0
echo "Guardando respaldos locales..."
if [ "$opp" -ne 3 ]; then
    while [ "$opp" -lt 3 ]; do
        echo "."
        sleep 1
        opp=$((opp + 1))
    done
fi

#Respaldo Remoto, sincronizacion con el servidor remoto vía rsync (Alta Herramienta, la acabo de descubrir)
echo "Enviando copia de seguridad al servidor remoto ($REMOTO_IP)..."
rsync -avz "$NUEVA_CARPETA/" "$REMOTO_USER@$REMOTO_IP:$REMOTO_DIR/$FECHA/"

#Rotación de Respaldos Viejos
CANTIDAD=$(ls -1d "$PUNTO_MONTAJE"/* | grep -v "Scripts" | wc -l)
while [ "$CANTIDAD" -gt "$MAX_CARPETAS" ]; do
    VIEJA=$(ls -td "$PUNTO_MONTAJE"/* | grep -v "Scripts" | tail -n 1)
    echo "Borrando backup viejo: $VIEJA"
    rm -rf "$VIEJA"
    #Volver a contar carpetas
    CANTIDAD=$(ls -1d "$PUNTO_MONTAJE"/* | grep -v "Scripts" | wc -l)
done

#Desmontar el disco local
echo "Desmontando el disco local."
sudo umount "$PUNTO_MONTAJE"
echo "Respaldo local y remoto completado con éxito!"
