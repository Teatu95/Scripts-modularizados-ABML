#!/bin/bash

#colores para una interfaz mas colorida
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

#Funcion para verificar si se ejecuta el script como root
check_root() {
        if [ "$EUID" -ne 0 ]; then
                echo -e "${RED}Error: Este script debe ser ejecutado como root (Utilice sudo)${NC}"
                exit 1
        fi
}



#Log qye hay que probar aun

LOG_FILE="/var/log/abml_usuarios.log"
log_message(){
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [Usuario: $USER]= $1" >> "$LOG_FILE"
}
