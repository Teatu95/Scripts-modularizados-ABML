#!/bin/bash

if [ -z "$DISCO" ] || [ -z "$PUNTO_MONTAJE" ] || [ -z "$MAX_CARPETAS" ]; then
        echo "Error: Falta configurar DISCO, PUNTO_MONTAJE o MAX_CARPETAS en el entorno."
        exit 1
fi

#Montamos el disco
echo "Montando el disco en $PUNTO_MONTAJE..."
sudo mount "$DISCO" "$PUNTO_MONTAJE"

#Creamos carpetas con la fecha para que quede ma profecional :3
FECHA=$(date +"%Y-%m-%d_%H-%M")
NUEVA_CARPETA="$PUNTO_MONTAJE/$FECHA"
mkdir -p "$NUEVA_CARPETA"

#------------------------------------------------------------
#Deteniendo apache
APACHEUBI="/var/www/html"
sudo systemctl stop apache2
sudo  tar -czvf "$NUEVA_CARPETA/html.backup.tar.gz" -C "$(dirname "$APACHEUBI")" "$(basename "$APACHEUBI")"











#------------------------------------------------------------
opp=0
echo "Guardando."
if [ "$opp" -ne 3 ]; then
        while [ "$opp" -lt 3 ]; do
                echo "."
                sleep 1
                opp=$((opp + 1))
        done
fi

#Borra carpetas viejas
#ls -1d hace que se muestren en una sola columna y el  / del final  hace que solo muestren carpetas, el wc -l cuenta las lineas y las devuelve
CANTIDAD=$(ls -1d "$PUNTO_MONTAJE"/* | grep -v "Scripts" | wc -l)

#Mientras la cantidad de carpetas sea mayor que el limte se va a ejecutar esto
#ls -td las ordena de la nueva a mas vieja y el tail -n 1 agarra las ultimas de la lista
while [ "$CANTIDAD" -gt "$MAX_CARPETAS" ];do
        VIEJA=$(ls -td "$PUNTO_MONTAJE"/* | tail -n 1)
        echo "Borrando backup viejo: $VIEJA"
        rm -rf "$VIEJA"

        #Se vuelven a contar las carpetas
        CANTIDAD=$(ls -ld "$PUNTO_MONTAJE"/* | wc -l)
done

#Desmonta el disco
echo "Desmontando el disco."
sudo umount "$PUNTO_MONTAJE"
