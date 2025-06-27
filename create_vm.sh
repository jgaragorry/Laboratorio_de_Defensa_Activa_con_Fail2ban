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