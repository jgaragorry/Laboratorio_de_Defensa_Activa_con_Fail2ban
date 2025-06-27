<div align="center">
  <img src="https://placehold.co/600x200/1e293b/ffffff?text=Laboratorio+de+Defensa+Activa+con+Fail2ban" alt="Banner del Laboratorio de Defensa Activa con Fail2ban">
</div>

<h1 align="center">Laboratorio Práctico: Defensa Activa contra Fuerza Bruta con Fail2ban</h1>

Este repositorio contiene una guía detallada y un conjunto de scripts para demostrar cómo implementar un sistema de defensa activo utilizando **Fail2ban** en un servidor Ubuntu desplegado en Azure.

El objetivo es transformar un servidor con una configuración SSH estándar en un sistema que detecta y bloquea automáticamente los intentos de ataque de fuerza bruta, una de las amenazas más comunes en internet.

---

## 📋 Tabla de Contenido

- [🎯 **Objetivo del Laboratorio**](#-objetivo-del-laboratorio)
- [🛠️ **Requisitos Previos**](#-requisitos-previos)
- [📂 **Contenido del Repositorio**](#-contenido-del-repositorio)
- [🚀 **Guía de Ejecución Paso a Paso**](#-guía-de-ejecución-paso-a-paso)
  - [Fase 1: Despliegue del Entorno](#fase-1-despliegue-del-entorno-de-laboratorio)
  - [Fase 2: Instalación del Guardián (Fail2ban)](#fase-2-instalación-del-guardián-fail2ban)
  - [Fase 3: Simulación del Ataque de Fuerza Bruta](#fase-3-simulación-del-ataque-de-fuerza-bruta)
  - [Fase 4: Verificación del Bloqueo](#fase-4-verificación-del-bloqueo-en-tiempo-real)
  - [Fase Final: Limpieza de Recursos](#fase-final-limpieza-del-entorno)
- [📜 **Código Completo de los Scripts**](#-código-completo-de-los-scripts)

---

## 🎯 Objetivo del Laboratorio

Este laboratorio está diseñado para que los profesionales de TI y ciberseguridad puedan:

- **Comprender** el concepto de un Sistema de Prevención de Intrusiones (IPS) a nivel de host.
- **Instalar y configurar** Fail2ban de forma profesional para proteger el servicio SSH.
- **Simular** un ataque de fuerza bruta para probar la efectividad de la defensa.
- **Verificar y gestionar** las reglas y los bloqueos (baneos) de Fail2ban en tiempo real.

---

## 🛠️ Requisitos Previos

Antes de comenzar, asegúrate de tener lo siguiente en tu máquina local (ej. WSL):

| Herramienta | Comando de Verificación / Instalación | Propósito |
| :--- | :--- | :--- |
| **Azure CLI** | `az version` | Para interactuar con tu suscripción de Azure. |
| **Cliente SSH** | `ssh -V` | Para conectarse a la máquina virtual. |
| **`jq`** | `sudo apt install jq` | Para procesar la salida JSON de Azure CLI. |

> **Nota Importante:** Debes haber iniciado sesión en Azure CLI antes de ejecutar los scripts. Usa el comando `az login`.

---

## 📂 Contenido del Repositorio

| Script | Descripción |
| :--- | :--- |
| 📜 `create_vm.sh` | Despliega la VM Ubuntu 24.04 estándar en Azure. |
| 🔍 `verify_vm.sh` | Verifica el estado y obtiene los detalles (IP pública) de la VM. |
| 🛡️ `instalar_guardian.sh` | **(Se ejecuta en la VM)** Instala y configura Fail2ban para proteger SSH. |
| 💥 `simular_ataque.sh` | **(Se ejecuta localmente)** Lanza un ataque simulado contra la VM. |
| 🧹 `delete_resources.sh` | Elimina todos los recursos de Azure y espera a que el proceso finalice. |

---

## 🚀 Guía de Ejecución Paso a Paso

### **Fase 1: Despliegue del Entorno de Laboratorio**

**Ubicación:** Tu terminal local (WSL `gmt@MSI`).

1.  **Crear la VM:** Ejecuta el script para desplegar el servidor Ubuntu en Azure. Este creará un grupo de recursos nuevo y único para este laboratorio: `rg-fail2ban-lab`.
    ```bash
    ./create_vm.sh
    ```
2.  **Verificar y Obtener IP:** Una vez que termine, ejecuta el script de verificación para obtener la dirección IP pública. **Anota esta IP**.
    ```bash
    ./verify_vm.sh
    ```

### **Fase 2: Instalación del Guardián (Fail2ban)**

**Ubicación:** DENTRO de la VM de Azure.

1.  **Conéctate a la VM:** Usa la IP del paso anterior.
    ```bash
    ssh gmt@<TU_IP_PÚBLICA>
    ```
    *Usa la contraseña `Password1234!`.*

2.  **Sube el script de instalación:** Abre una **segunda terminal local** y usa `scp` para enviar el script a la VM.
    ```bash
    scp ./instalar_guardian.sh gmt@<TU_IP_PÚBLICA>:~/
    ```
3.  **Instala Fail2ban:** Vuelve a la terminal donde estás conectado a la VM y ejecuta el script.
    ```bash
    # Dentro de la VM (gmt@vm-gmt-ubuntu)
    chmod +x instalar_guardian.sh
    sudo ./instalar_guardian.sh
    ```
4.  **Verifica el estado inicial:** Comprueba que Fail2ban está activo y vigilando.
    ```bash
    # Dentro de la VM
    sudo fail2ban-client status sshd
    ```
    *En este punto, la lista de IPs baneadas debería estar vacía.*

### **Fase 3: Simulación del Ataque de Fuerza Bruta**

**Ubicación:** Tu terminal local (WSL `gmt@MSI`).

1.  **Prepara el script de ataque:** Asegúrate de que el script `simular_ataque.sh` tenga permisos de ejecución.
    ```bash
    chmod +x simular_ataque.sh
    ```
2.  **Lanza el ataque:** Ejecuta el script pasándole la IP de tu VM como argumento.
    ```bash
    ./simular_ataque.sh <TU_IP_PÚBLICA>
    ```
    *Verás en tu terminal cómo se realizan 5 intentos de conexión fallidos. Los primeros deberían fallar por contraseña, y los últimos deberían ser rechazados directamente por el firewall.*

### **Fase 4: Verificación del Bloqueo en Tiempo Real**

**Ubicación:** DENTRO de la VM de Azure.

1.  **Comprueba el estado de nuevo:** En tu sesión SSH con la VM, vuelve a ejecutar el comando de estado.
    ```bash
    sudo fail2ban-client status sshd
    ```
    > **Resultado Esperado:** ¡Ahora verás tu propia IP pública en la "Banned IP list"! Has demostrado que el guardián detectó y bloqueó al atacante.

2.  **Intenta conectar de nuevo (opcional):** Si abres otra terminal local e intentas conectarte (`ssh gmt@<TU_IP_PÚBLICA>`), la conexión será rechazada con un error de `Connection timed out` o `Connection refused`, probando que el bloqueo es efectivo.

### **Fase Final: Limpieza del Entorno**

**Ubicación:** Tu terminal local (WSL `gmt@MSI`).

1.  Cuando hayas terminado el laboratorio, ejecuta este script para eliminar todos los recursos de Azure y evitar costos. El script esperará a que el proceso termine antes de devolverte el prompt.
    ```bash
    ./delete_resources.sh
    ```

---

## 📜 Código Completo de los Scripts

### `create_vm.sh`
```bash
#!/bin/bash
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
```

### `verify_vm.sh`
```bash
#!/bin/bash
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
```

### `instalar_guardian.sh`
```bash
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
```

### `simular_ataque.sh`
```bash
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
```

### `delete_resources.sh`
```bash
#!/bin/bash
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
