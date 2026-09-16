#!/bin/bash

# Esta piola esto vistea profe, en vez de un poner un source de una primer verificas que exista
if [ -f "./config.sh" ]; then
    source ./config.sh
else
    echo "Error: No se encontró config.sh"
    exit 1
fi

# Esto que tengo en el config por si no ejecutas con el root
check_root

# Funcion para elegir un servicio,
select_service() {
    echo -e "\n${YELLOW}Servicios disponibles:${NC} ssh | apache2 | mysql | rsync"
    echo -n "Escribí el nombre del servicio a administrar: "
    read SERVICIO
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
            # Configuración de red, no tengo la menor idea de que poner, supongo que apagar prenderlo, capaz cambiar la ip
            ;;
        7)
            # Cargar backup no se hacerlo tengo que buscar, igual es la primera version, creo que es presentable
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
