#!/bin/bash

source ./config.sh

alta_usuario() {
    echo -e "\n--- Alta de Usuario ---"
    read -p "Ingrese el nombre del nuevo usuario: " username

    # Vemos si existe o no el usuario
    if id "$username" &>/dev/null; then
        echo -e "${RED}El usuario '$username' ya existe en el sistema.${NC}"
        log_message "INTENTO_ALTA_FALLIDO: El usuario $username ya existe."
    else
        #Le creamos un directorio si quiere el usuario
        read -p "¿Desea crearle un directorio Home? (s/n): " crear_home
        if [[ "$crear_home" =~ ^[Ss]$ ]]; then
            useradd -m "$username"
        else
            useradd "$username"
        fi

        if [ $? -eq 0 ]; then
            echo -e "${YELLOW}Establezca la contraseña para $username:${NC}"
            passwd "$username"
            echo -e "${GREEN}Usuario '$username' creado con éxito.${NC}"
            log_message "ALTA_USUARIO: Usuario $username creado con éxito."
        else
            echo -e "${RED}Error al crear el usuario.${NC}"
            log_message "ERROR: Falló el comando useradd para el usuario $username."
        fi
    fi
}
baja_usuario() {
    echo -e "\n--- Baja de Usuario ---"
    read -p "Ingrese el nombre del usuario a eliminar: " username

    if ! id "$username" &>/dev/null; then
        echo -e "${RED}El usuario '$username' no existe.${NC}"
        log_message "INTENTO_BAJA_FALLIDO: El usuario $username no existe."
    else
        read -p "¿Desea eliminar también su directorio Home? (s/n): " borrar_home
        if [[ "$borrar_home" =~ ^[Ss]$ ]]; then
            userdel -r "$username"
        else
            userdel "$username"
        fi

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Usuario '$username' eliminado con éxito.${NC}"
            log_message "BAJA_USUARIO: Usuario $username eliminado."
        else
            echo -e "${RED}Error al eliminar el usuario.${NC}"
            log_message "ERROR: Falló el comando userdel para el usuario $username."
        fi
    fi
}
modificacion_usuario() {
    echo -e "\n--- Modificación de Usuario ---"
    read -p "Ingrese el nombre del usuario a modificar: " username

    if ! id "$username" &>/dev/null; then
        echo -e "${RED}El usuario '$username' no existe.${NC}"
        return
    fi

    echo "1. Cambiar UID"
    echo "2. Modificar Shell por defecto"
    echo "3. Cambiar contraseña"
    read -p "Seleccione qué desea modificar [1-3]: " op_mod

    case $op_mod in
        1)
            read -p "Ingrese el nuevo UID: " nuevo_uid
            if usermod -u "$nuevo_uid" "$username"; then
                echo -e "${GREEN}UID modificado.${NC}"
                log_message "MOD_USUARIO: Se cambió el UID de $username a $nuevo_uid."
            else
                log_message "ERROR: Falló cambio de UID para $username."
            fi
            ;;
        2)
            read -p "Ingrese la ruta de la nueva shell (ej: /bin/bash): " nueva_shell
            if usermod -s "$nueva_shell" "$username"; then
                echo -e "${GREEN}Shell modificada.${NC}"
                log_message "MOD_USUARIO: Se cambió la shell de $username a $nueva_shell."
            else
                log_message "ERROR: Falló cambio de shell para $username."
            fi
            ;;
        3)
            passwd "$username"
            log_message "MOD_USUARIO: Se actualizó la contraseña de $username."
            ;;
        *)
            echo -e "${RED}Opción inválida.${NC}"
            ;;
    esac
}
listado_usuario() {
    echo -e "\n--- Listado de Usuarios del Sistema (UID >= 1000) ---"
    echo -e "${YELLOW}USUARIO\t\tUID\t\tHOME${NC}"
    echo "--------------------------------------------------"
    awk -F: '$3 >= 1000 && $3 != 65534 {printf "%-15s %-10s %-20s\n", $1, $3, $6}' /etc/passwd
    log_message "LISTAR_USUARIOS: Se listaron los usuarios del sistema."
}
