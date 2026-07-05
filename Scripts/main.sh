#!/bin/bash

source ./config.sh
source ./functions_user.sh
source ./functions_group.sh


check_root


echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}   SISTEMA DE GESTION DE USUARIOS Y GRUPOS     ${NC}"
echo -e "${GREEN}=============================================${NC}"

while true; do
        echo -e "\n¿Què desea administrar?"
        echo "1. Usuarios"
        echo "2. Grupos"
        echo "3. Salir"
        read -p "Seleccione una opciòn [1-3]" operacion_principal

        case $operacion_principal in
                1)
                        while true; do
                                echo -e "\n-- MENÙ DE USUARIOS"
                                echo "1. Alta de Usuario"
                                echo "2. Baja de Usuario"
                                echo "3. Modificaciòn de Usuario"
                                echo "4. Listar Usuarios"
                                echo "5. Volver al menù principal"
                                read -p "Opcion [1-5]" op_user
                                case $op_user in
                                        1) alta_usuario ;;
                                        2) baja_usuario ;;
                                        3) modificacion_usuario ;;
                                        4) listado_usuario ;;
                                        5) break ;;
                                        *) echo -e "${RED}Opciòn invalida${NC}" ;;
                                esac
                        done
                        ;;
                2)
                        while true; do
                                echo -e "\n-- MENÛ DE GRUPOS --"
                                echo "1. Alta de Grupo"
                                echo "2. Baja de Grupo"
                                echo "3. Modificaciòn de Grupo"
                                echo "4. Listar Grupos"
                                echo "5. Volver al menù principal"
                                read -p "Opciòn [1-5]" op_group
                                case $op_group in
                                        1) alta_grupo ;;
                                        2) baja_grupo ;;
                                        3) modificacion_grupo ;;
                                        4) listado_grupo ;;
                                        5) break ;;
                                        *) echo -e "${RED}Opciòn incalida ${NC}" ;;
                                esac
                        done
                        ;;
                3)
                        echo -e "${GREEN}Saliendo del sistema. Chau${NC}"
                        exit 0
                        ;;
                *)
 						echo -e "${RED}Opciòn incorrecta${NC}"
                        ;;
                esac
done
