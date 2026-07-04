#!/bin/bash


#aca tenemos todas las funciones de  los grupos :D
#no es dificil usar este formato, me hace acordar
#bastante a las clases de java y la heredacion de variables

source ./config.sh

alta_grupo() {
        echo -e "\n--- ALTA DE GRUPO ---"
        read -p "Ingrese el nombre del grupo: " grupo

        if getent group "$grupo" &>/dev/null; then
                echo -e "${RED}Error: El grupo '$grupo' ya existe.${NC}"
                return
        fi

        groupadd "$grupo"
        if [ $? -eq 0 ]; then
                echo -e "${GREEN}Grupo '$grupo' creado con éxito.${NC}"
                log_message "Alta de grupo: $grupo"
        else
                echo -e "${RED}Error al crear el grupo${NC}"
        fi
}
baja_grupo() {
        echo -e "\n--- BAJA DE GRUPO ---"
        read -p "Ingrese el nombre de un grupo para eliminar: " grupo

        if ! getent group "$grupo" &>/dev/null; then
                echo -e "${RED}Error: El grupo '$grupo' no existe.${NC}"
                return
        fi

        groupdel "$grupo"
        if [ $? -eq 0 ]; then
                echo -e "${GREEN}Grupo '$grupo' eliminado con exito.${NC}"
                log_message "Baja de grupo: $grupo"
        else
                echo -e "${RED}Error al eliminar el grupo (puede ser el grupo primero de un usuario)${NC})"
        fi
}
modificacion_grupo() {
    echo -e "\n--- Modificación de Grupo ---"
    read -p "Ingrese el nombre del grupo a modificar: " groupname

    if ! getent group "$groupname" &>/dev/null; then
        echo -e "${RED}El grupo '$groupname' no existe.${NC}"
        return
    fi

    echo "1. Añadir usuario al grupo"
    echo "2. Eliminar usuario del grupo"
    echo "3. Cambiar nombre del grupo"
    read -p "Seleccione una opción [1-3]: " op_gmod
    case $op_gmod in
        1)
            read -p "Nombre del usuario a añadir: " usermod_name
            if id "$usermod_name" &>/dev/null; then
                if usermod -aG "$groupname" "$usermod_name"; then
                    echo -e "${GREEN}Usuario añadido al grupo.${NC}"
                    log_message "MOD_GRUPO: Usuario $usermod_name añadido al grupo $groupname."
                fi
            else
                echo -e "${RED}El usuario no existe.${NC}"
            fi
            ;;
        2)
            read -p "Nombre del usuario a remover: " usermod_name
            if id "$usermod_name" &>/dev/null; then
                if gpasswd -d "$usermod_name" "$groupname"; then
                    echo -e "${GREEN}Usuario removido del grupo.${NC}"
                    log_message "MOD_GRUPO: Usuario $usermod_name removido del grupo $groupname."
                fi
            else
                echo -e "${RED}El usuario no existe.${NC}"
            fi
            ;;
        3)
            read -p "Nuevo nombre para el grupo: " nuevo_nombre
            if groupmod -n "$nuevo_nombre" "$groupname"; then
                echo -e "${GREEN}Nombre cambiado a '$nuevo_nombre'.${NC}"
                log_message "MOD_GRUPO: Se cambió el nombre del grupo $groupname a $nuevo_nombre."
            fi
            ;;
        *)
            echo -e "${RED}Opción inválida.${NC}"
            ;;
    esac
}


listado_grupo() {
    echo -e "\n--- Listado de Grupos del Sistema (GID >= 1000) ---"
    echo -e "${YELLOW}GRUPO\t\tGID\t\tMIEMBROS${NC}"
    echo "--------------------------------------------------"
    awk -F: '$3 >= 1000 && $3 != 65534 {printf "%-15s %-10s %-20s\n", $1, $3, $4}' /etc/group
    log_message "LISTAR_GRUPOS: Se listaron los grupos del sistema."
}
