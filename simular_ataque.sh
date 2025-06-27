#!/bin/bash
# Script para simular un ataque de fuerza bruta a SSH

TARGET_IP="$1"
TARGET_PORT="22"
TARGET_USER="fakeuser"
ATTEMPTS=5

if [ -z "$TARGET_IP" ]; then
    echo "Error: Debes proporcionar la dirección IP de la VM como primer argumento."
    echo "Uso: ./simular_ataque.sh <IP_DE_LA_VM>"
    exit 1
fi

echo "--- Iniciando Simulación de Ataque a $TARGET_IP:$TARGET_PORT ---"
echo "Intentaremos conectarnos $ATTEMPTS veces con un usuario inválido."
echo "--------------------------------------------------------"

for i in $(seq 1 $ATTEMPTS)
do
    echo -n "Intento #$i: "
    ssh -o BatchMode=yes -o ConnectTimeout=5 -o LogLevel=QUIET -p $TARGET_PORT ${TARGET_USER}@${TARGET_IP} &> /dev/null
    
    if [ $? -eq 255 ]; then
        echo "Conexión fallida/rechazada (¡Esperado!)"
    else
        echo "¡Conexión exitosa! El ataque no funcionó como se esperaba."
    fi
    sleep 1
done

echo "--------------------------------------------------------"
echo "Simulación completada."
echo "Verifica el estado de Fail2ban en la VM. Deberías ver tu IP baneada."
