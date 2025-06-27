#!/bin/bash
# Script para instalar y configurar Fail2ban para proteger el puerto SSH 22.

echo "--- Instalando y configurando Fail2ban (El Guardián Automatizado) ---"
echo "Paso 1: Instalando el paquete Fail2ban..."
sudo apt-get update > /dev/null
sudo apt-get install -y fail2ban

echo "Paso 2: Creando una configuración local para SSH..."
JAIL_FILE_PATH="/etc/fail2ban/jail.d/sshd-custom.conf"
cat << EOF | sudo tee $JAIL_FILE_PATH
[sshd]
enabled = true
port    = ssh
maxretry = 3
findtime = 10m
bantime = 1h
EOF
echo "Archivo de configuración creado en $JAIL_FILE_PATH"

echo "Paso 3: Reiniciando Fail2ban para aplicar la nueva configuración..."
sudo systemctl restart fail2ban
sudo systemctl enable fail2ban

echo ""
echo "--- ¡Guardián Instalado y Activo! ---"
echo "Fail2ban está ahora monitoreando el puerto 22."
