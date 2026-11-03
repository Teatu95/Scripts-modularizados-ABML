#!/bin/bash

if [ -f "./config.sh" ]; then
    source ./config.sh
else
    echo "Error: No se encontró config.sh"
    exit 1
fi

if [ -f "./backup.sh" ]; then
    source ./backup.sh
else
    echo "Error: No se encontró backup.sh"
    exit 1
fi
check_root

# --- FUNCIONES ---

select_service() {
    echo -e "\n${YELLOW}Servicios disponibles:${NC} ssh | apache2 | mysql | rsync"
    echo -n "Escribí el nombre del servicio a administrar: "
    read SERVICIO
}

restaurar_ultimo_backup() {
    echo "================================================"
    echo "    Iniciando proceso de restauracion de datos."
    echo "================================================="

    # Buscar el backup
    if ! mountpoint -q "$PUNTO_MONTAJE"; then
        echo "Montando el disco en $PUNTO_MONTAJE"
        sudo mount "$DISCO" "$PUNTO_MONTAJE" || { echo "No se pudo montar el disco."; return 1; }
    fi    
    
    echo "Identificando la copia de seguridad más reciente...."
    local ultimo_backup
    ultimo_backup=$(ls -td "$PUNTO_MONTAJE"/* 2>/dev/null | grep -v "Scripts" | head -n 1)
    
    if [ -z "$ultimo_backup" ]; then
        echo "No se encontraron backups en $PUNTO_MONTAJE."
        sudo umount "$PUNTO_MONTAJE" 2>/dev/null
        return 1
    fi
    echo "Último respaldo detectado en: $ultimo_backup"

    # Apache
    echo "Deteniendo Apache temporalmente..."
    sudo systemctl stop apache2
    if [ -f "$ultimo_backup/html.backup.tar.gz" ]; then
        echo "Restaurando el directorio web..."
        sudo rm -rf "${APACHEUBI:?}/*"
        sudo tar -xzf "$ultimo_backup/html.backup.tar.gz" -C "$(dirname "$APACHEUBI")"
        echo "Archivos web restaurados con éxito."
    else
        echo "[ADVERTENCIA] No se localizó html.backup.tar.gz en el respaldo."
    fi
    echo "Reanudando servicio Apache..."
    sudo systemctl start apache2

    if [ -f "$ultimo_backup/db_backup.sql.gz" ]; then
        echo "Procesando base de datos..."
        
        cp "$ultimo_backup/db_backup.sql.gz" /tmp/
        gunzip -f /tmp/db_backup.sql.gz

        echo "Borrando la base de datos anterior. "
        mysql -u "$DB_USER" -p"$DB_PASS" -e "DROP DATABASE IF EXISTS $DB_NAME; CREATE DATABASE $DB_NAME;"

        echo "Cargando datos del archivo sql"
        mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < /tmp/db_backup.sql
        
        if [ $? -eq 0 ]; then
            echo "Base de datos restaurada."
        else
            echo "Hubo un problema al importar el archivo SQL."
        fi
        rm -f /tmp/db_backup.sql
    else
        echo "No se encontró el archivo de base de datos db_backup.sql.gz"
    fi

    echo "Desmontando disco"
    sudo umount "$PUNTO_MONTAJE"
    echo "========================="
    echo " Restauración completa.."
    echo "========================="
}

while true; do
    echo -e "\n${YELLOW}=== Menú de Servicios (Ubuntu Server) ===${NC}"
    echo "1) Encender servicio"
    echo "2) Apagar servicio"
    echo "3) Reiniciar servicio"
    echo "4) Habilitar servicio (enable)"
    echo "5) Inhabilitar servicio (disable)"
    echo "6) Configuración de red"
    echo "7) Cargar backup"
    echo "8) Salir"
    echo -n "Seleccioná una opción: "
    read opcion

    case $opcion in
        1)
            select_service
            systemctl start $SERVICIO
            echo -e "${GREEN}Servicio $SERVICIO encendido.${NC}"
            log_message "Servicio $SERVICIO encendido"
            ;;
        2)
            select_service
            systemctl stop $SERVICIO
            echo -e "${RED}Servicio $SERVICIO apagado.${NC}"
            log_message "Servicio $SERVICIO apagado"
            ;;
        3)
            select_service
            systemctl restart $SERVICIO
            echo -e "${YELLOW}Servicio $SERVICIO reiniciado.${NC}"
            log_message "Servicio $SERVICIO reiniciado"
            ;;
        4)
            select_service
            systemctl enable $SERVICIO
            echo -e "${GREEN}Servicio $SERVICIO habilitado.${NC}"
            log_message "Servicio $SERVICIO habilitado"
            ;;
        5)
            select_service
            systemctl disable $SERVICIO
            echo -e "${YELLOW}Servicio $SERVICIO inhabilitado.${NC}"
            log_message "Servicio $SERVICIO inhabilitado"
            ;;
        6)
            echo "1) Mostrar ip"
            echo "2) Reiniciar NetworkManager"
            echo "3) Volver al menú principal"
            echo -n "Ingrese opcion: "
            read redopcion
            case $redopcion in
                1) ip -br a ;;
                2) systemctl restart NetworkManager ;;
                3) echo "Volviendo..." ;;
                *) echo -e "Opcion invalida." ;;
            esac
            ;;
        7)
            restaurar_ultimo_backup
            ;;
        8)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo -e "${RED}Opción no válida.${NC}"
            ;;
    esac
done
