Este repositorio contiene una guía detallada y un conjunto de scripts para demostrar cómo implementar un sistema de defensa activo utilizando Fail2ban en un servidor Ubuntu desplegado en Azure.El objetivo es transformar un servidor con una configuración SSH estándar en un sistema que detecta y bloquea automáticamente los intentos de ataque de fuerza bruta, una de las amenazas más comunes en internet.📋 Tabla de Contenido🎯 Objetivo del Laboratorio🛠️ Requisitos Previos📂 Contenido del Repositorio🚀 Guía de Ejecución Paso a PasoFase 1: Despliegue del EntornoFase 2: Instalación del Guardián (Fail2ban)Fase 3: Simulación del Ataque de Fuerza BrutaFase 4: Verificación del BloqueoFase Final: Limpieza de Recursos📜 Código Completo de los Scripts🎯 Objetivo del LaboratorioEste laboratorio está diseñado para que los profesionales de TI y ciberseguridad puedan:Comprender el concepto de un Sistema de Prevención de Intrusiones (IPS) a nivel de host.Instalar y configurar Fail2ban de forma profesional para proteger el servicio SSH.Simular un ataque de fuerza bruta para probar la efectividad de la defensa.Verificar y gestionar las reglas y los bloqueos (baneos) de Fail2ban en tiempo real.🛠️ Requisitos PreviosAntes de comenzar, asegúrate de tener lo siguiente en tu máquina local (ej. WSL):HerramientaComando de Verificación / InstalaciónPropósitoAzure CLIaz versionPara interactuar con tu suscripción de Azure.Cliente SSHssh -VPara conectarse a la máquina virtual.jqsudo apt install jqPara procesar la salida JSON de Azure CLI.Nota Importante: Debes haber iniciado sesión en Azure CLI antes de ejecutar los scripts. Usa el comando az login.📂 Contenido del RepositorioScriptDescripción📜 create_vm.shDespliega la VM Ubuntu 24.04 estándar en Azure.🔍 verify_vm.shVerifica el estado y obtiene los detalles (IP pública) de la VM.🛡️ instalar_guardian.sh(Se ejecuta en la VM) Instala y configura Fail2ban para proteger SSH.💥 simular_ataque.sh(Se ejecuta localmente) Lanza un ataque simulado contra la VM.🧹 delete_resources.shElimina todos los recursos de Azure y espera a que el proceso finalice.🚀 Guía de Ejecución Paso a PasoFase 1: Despliegue del Entorno de LaboratorioUbicación: Tu terminal local (WSL gmt@MSI).Crear la VM: Ejecuta el script para desplegar el servidor Ubuntu en Azure. Este creará un grupo de recursos nuevo y único para este laboratorio: rg-fail2ban-lab../create_vm.sh
Verificar y Obtener IP: Una vez que termine, ejecuta el script de verificación para obtener la dirección IP pública. Anota esta IP../verify_vm.sh
Fase 2: Instalación del Guardián (Fail2ban)Ubicación: DENTRO de la VM de Azure.Conéctate a la VM: Usa la IP del paso anterior.ssh gmt@<TU_IP_PÚBLICA>
Usa la contraseña Password1234!.Sube el script de instalación: Abre una segunda terminal local y usa scp para enviar el script a la VM.scp ./instalar_guardian.sh gmt@<TU_IP_PÚBLICA>:~/
Instala Fail2ban: Vuelve a la terminal donde estás conectado a la VM y ejecuta el script.# Dentro de la VM (gmt@vm-gmt-ubuntu)
chmod +x instalar_guardian.sh
sudo ./instalar_guardian.sh
Verifica el estado inicial: Comprueba que Fail2ban está activo y vigilando.# Dentro de la VM
sudo fail2ban-client status sshd
En este punto, la lista de IPs baneadas debería estar vacía.Fase 3: Simulación del Ataque de Fuerza BrutaUbicación: Tu terminal local (WSL gmt@MSI).Prepara el script de ataque: Asegúrate de que el script simular_ataque.sh tenga permisos de ejecución.chmod +x simular_ataque.sh
Lanza el ataque: Ejecuta el script pasándole la IP de tu VM como argumento../simular_ataque.sh <TU_IP_PÚBLICA>
Verás en tu terminal cómo se realizan 5 intentos de conexión fallidos. Los primeros deberían fallar por contraseña, y los últimos deberían ser rechazados directamente por el firewall.Fase 4: Verificación del Bloqueo en Tiempo RealUbicación: DENTRO de la VM de Azure.Comprueba el estado de nuevo: En tu sesión SSH con la VM, vuelve a ejecutar el comando de estado.sudo fail2ban-client status sshd
Resultado Esperado: ¡Ahora verás tu propia IP pública en la "Banned IP list"! Has demostrado que el guardián detectó y bloqueó al atacante.Intenta conectar de nuevo (opcional): Si abres otra terminal local e intentas conectarte (ssh gmt@<TU_IP_PÚBLICA>), la conexión será rechazada con un error de Connection timed out o Connection refused, probando que el bloqueo es efectivo.Fase Final: Limpieza del EntornoUbicación: Tu terminal local (WSL gmt@MSI).Cuando hayas terminado el laboratorio, ejecuta este script para eliminar todos los recursos de Azure y evitar costos. El script esperará a que el proceso termine antes de devolverte el prompt../delete_resources.sh
📜 Código Completo de los Scriptscreate_vm.sh#!/bin/bash
RESOURCE_GROUP_NAME="rg-fail2ban-lab"
VM_NAME="vm-fail2ban-target"
LOCATION="eastus"
ADMIN_USERNAME="gmt"
ADMIN_PASSWORD="Password1234!"
UBUNTU_IMAGE="Ubuntu2404"
TAG_ENVIRONMENT="SecurityLab"
TAG_PROJECT="Fail2banDemo"
TAG_OWNER="gmt"
echo "=================================================="
echo "Iniciando el despliegue de la VM para el laboratorio de Fail2ban..."
echo "=================================================="
if ! az account show > /dev/null 2>&1; then
    echo "ERROR: No has iniciado sesión en Azure CLI."
    exit 1
fi
echo "Creando el Grupo de Recursos '$RESOURCE_GROUP_NAME'..."
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION --tags environment="$TAG_ENVIRONMENT" project="$TAG_PROJECT" owner="$TAG_OWNER"
echo "Creando la Máquina Virtual '$VM_NAME'..."
az vm create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $VM_NAME \
    --image $UBUNTU_IMAGE \
    --size "Standard_B1s" \
    --admin-username $ADMIN_USERNAME \
    --admin-password $ADMIN_PASSWORD \
    --nsg-rule SSH
if [ $? -ne 0 ]; then
    echo "ERROR: Falló la creación de la Máquina Virtual."
    exit 1
fi
echo ""
echo "¡Despliegue completado! Ejecuta ./verify_vm.sh para obtener los detalles."
verify_vm.sh#!/bin/bash
RESOURCE_GROUP_NAME="rg-fail2ban-lab"
VM_NAME="vm-fail2ban-target"
echo "=================================================="
echo "Verificando los detalles de la VM '$VM_NAME'..."
echo "=================================================="
if ! az account show > /dev/null 2>&1; then
    echo "ERROR: No has iniciado sesión en Azure CLI."
    exit 1
fi
VM_DETAILS=$(az vm show --resource-group $RESOURCE_GROUP_NAME --name $VM_NAME --show-details --query "{name:name, powerState:powerState, publicIp:publicIps}" -o json)
if [ -z "$VM_DETAILS" ]; then
    echo "ERROR: No se pudo encontrar la VM '$VM_NAME'."
    exit 1
fi
PUBLIC_IP=$(echo $VM_DETAILS | jq -r .publicIp)
echo "Detalles de la VM:"
echo "--------------------------------------------------"
echo "  Nombre de la VM:      $VM_NAME"
echo "  IP Pública:           $PUBLIC_IP"
echo "--------------------------------------------------"
echo ""
if [ -n "$PUBLIC_IP" ] && [ "$PUBLIC_IP" != "null" ]; then
    echo "Puedes conectarte a la VM usando el siguiente comando:"
    echo "ssh gmt@$PUBLIC_IP"
fi
echo "=================================================="
instalar_guardian.sh#!/bin/bash
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
simular_ataque.sh#!/bin/bash
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
delete_resources.sh#!/bin/bash
RESOURCE_GROUP_NAME="rg-fail2ban-lab"
echo "=================================================="
echo "¡ADVERTENCIA! Estás a punto de eliminar el grupo de recursos '$RESOURCE_GROUP_NAME'."
echo "=================================================="
read -p "¿Estás seguro de que quieres continuar? (escribe 'si' para confirmar): " CONFIRMATION
if [ "$CONFIRMATION" != "si" ]; then
    echo "Operación cancelada."
    exit 0
fi
echo ""
echo "Iniciando la eliminación del grupo de recursos..."
az group delete --name $RESOURCE_GROUP_NAME --yes
if [ $? -ne 0 ]; then
    echo "ERROR: Ocurrió un error durante la eliminación."
else
    echo ""
    echo "=================================================="
    echo "¡Grupo de recursos eliminado exitosamente!"
    echo "=================================================="
    echo "Esperando 20 segundos para la propagación de la eliminación en Azure..."
    sleep 20
fi
