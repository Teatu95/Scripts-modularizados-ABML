#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Ejecute como sudo"
  exit 1
fi

echo "=================================================="
echo "          Holap Configurando entorno"
echo "=================================================="
echo ""


echo "Primero, dime los datos para la base de datos:"
read -p "  > Usuario de la BD (DB_USER): " DB_USER
read -sp "  > Contraseña de la BD (DB_PASS): " DB_PASS
echo ""
read -p "  > Nombre de la BD (DB_NAME): " DB_NAME

echo ""
echo "Perfecto. Ahora pasemos a los datos de conexión remota:"
read -p "  > Usuario remoto (REMOTO_USER): " REMOTO_USER
read -p "  > IP o host remoto (REMOTO_IP): " REMOTO_IP
read -p "  > Directorio remoto (REMOTO_DIR): " REMOTO_DIR

APACHEUBI="/var/www/html"
echo ""
echo "Poniendo '$APACHEUBI' como ruta base de Apache por defecto."

read -p "Indica el punto de montaje local (PUNTO_MONTAJE): " PUNTO_MONTAJE
read -p "¿Cuántas carpetas máximas de respaldo quieres conservar? (MAX_CARPETAS): " MAX_CARPETAS

# Validación interactiva del disco
echo ""
echo "Aquí tienes los discos y particiones disponibles en el sistema:"
lsblk -d -o NAME,SIZE,MODEL
echo ""

while true; do
  read -p "Introduce el disco o partición que quieres usar (ejemploo /dev/sdb1): " DISCO
  
  if [ -b "$DISCO" ]; then
    echo "¡Genial! El disco '$DISCO' existe y está listo para usarse."
    break
  else
    echo "Mmm, ese dispositivo no existe o no es válido. Revisa bien e inténtalo de nuevo."
  fi
done

# Verificar y configurar la Base de Datos Mysql
echo ""
echo "Verificando el servicio de Base de Datos..."
if ! command -v mysql &> /dev/null; then
    echo "Ey, parece que MySQL o MariaDB no está instalado localmente. Recuerda instalarlo para que la BD funcione."
else
    echo "Perfecto MySsql está presente. Verificando si la base de datos '$DB_NAME' ya existe..."
    
    read -p "Dame el usuario administrador de MySQL (ej. root): " MYSQL_ROOT_USER
    read -sp "Y su contraseña: " MYSQL_ROOT_PASS
    echo ""

    DB_EXISTS=$(mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" -se "SHOW DATABASES LIKE '$DB_NAME';")

    if [ "$DB_EXISTS" == "$DB_NAME" ]; then
        echo "La base de datos '$DB_NAME' ya existía, así que nos ahorramos crearla."
    else
        echo "La base de datos '$DB_NAME' no existe, así que la creo ahora mismo..."
        mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" -e "CREATE DATABASE \`$DB_NAME\`;"
        echo "¡Listo! Base de datos creada."
    fi

    echo "Configurando los privilegios para el usuario '$DB_USER'..."
    mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
    mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" -e "GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';"
    mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" -e "FLUSH PRIVILEGES;"
    echo "Usuario de base de datos configurado sin problemas."
fi

# Necesito git para descargar los scripts
echo ""
if ! command -v git &> /dev/null; then
    echo "No se encontro Git. Instalando git"
    apt-get update && apt-get install -y git
    echo "¡Git instalado con éxito!"
else
    echo "¡Buenísimo! Git ya está instalado en el sistema."
fi

# Clone en el repositorio
REPO_DIR="/opt/Scripts-modularizados-ABML"
echo ""
if [ -d "$REPO_DIR" ]; then
    echo "El directorio del repositorio ya existe en $REPO_DIR. Actualizando cambios..."
    cd "$REPO_DIR" && git pull
else
    echo "Clonando el repositorio de los scripts..."
    git clone https://github.com/Teatu95/Scripts-modularizados-ABML/ "$REPO_DIR"
fi

# Dar permisos de ejecución
echo "Dándole permisos de ejecución a los scripts..."
if [ -f "$REPO_DIR/Scripts/main.sh" ]; then
    chmod +x "$REPO_DIR/Scripts/main.sh"
fi

if [ -f "$REPO_DIR/Scripts/backup.sh" ]; then
    chmod +x "$REPO_DIR/Scripts/backup.sh"
    BACKUP_SCRIPT_PATH="$REPO_DIR/Scripts/backup.sh"
elif [ -f "$REPO_DIR/Scripts/main.sh" ]; then
    BACKUP_SCRIPT_PATH="$REPO_DIR/Scripts/main.sh"
else
    BACKUP_SCRIPT_PATH="$REPO_DIR/Scripts/backup.sh"
fi
echo "Permisos aplicados correctamente"

#  Crear archivo de entorno (.env.backup)
CONFIG_FILE="$REPO_DIR/.env.backup"
echo "Guardando las variables de entorno en $CONFIG_FILE..."
cat <<EOF > "$CONFIG_FILE"
DB_USER="$DB_USER"
DB_PASS="$DB_PASS"
DB_NAME="$DB_NAME"
REMOTO_USER="$REMOTO_USER"
REMOTO_IP="$REMOTO_IP"
REMOTO_DIR="$REMOTO_DIR"
APACHEUBI="$APACHEUBI"
PUNTO_MONTAJE="$PUNTO_MONTAJE"
MAX_CARPETAS="$MAX_CARPETAS"
DISCO="$DISCO"
EOF
#De aca en adelante es casi todo recomendado por IA, estudie lo que hizo pero igualmente no lo hice
# Configurar la tarea en Cron
echo ""
echo "Programando la tarea automática en Cron para que corra todos los días a las 2:00 AM..."

CRON_JOB="0 2 * * * /bin/bash $BACKUP_SCRIPT_PATH >> /var/log/backup_abml.log 2>&1"

(crontab -l 2>/dev/null | grep -F "$BACKUP_SCRIPT_PATH") && echo "La tarea en cron ya estaba registrada, no hay que duplicarla." || \
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

echo ""
echo "=================================================="
echo "    El entorno tuvo que quedar configurado."
echo "=================================================="
