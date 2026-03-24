#!/bin/bash
# set -x
###############################################################################
# Autor: Alex Callejas (@rootzilopochtli)
# Propósito: Aprovisionamiento seguro para el Fedora-Edge en KVM.
# Motto: "Geek by nature, Linux by choice, Fedora of course..."
###############################################################################

# --- Configuración Estática ---
TARGET_IMG="edge.qcow2"
KVM_DIR="/var/lib/libvirt/images"
VM_NAME="edge"
HOSTNAME="edge.lab"

# --- Variables de Usuario ---
LAB_USER="edge-user"  # Identidad local para el Fedora-Edge Lab
PASSWORD="redhat"

echo "🚀 Iniciando el detector de recursos para el Cloud Local..."

# 1. Validar existencia y estado de la VM
if sudo virsh dominfo "$VM_NAME" >/dev/null 2>&1; then
    VM_STATE=$(sudo virsh domstate "$VM_NAME")
    echo "❌ ERROR: Ya existe una máquina virtual llamada '$VM_NAME' (Estado: $VM_STATE)."

    if [ "$VM_STATE" == "running" ]; then
        echo "💡 La VM está encendida. Para eliminarla:"
        echo "   sudo virsh destroy $VM_NAME && sudo virsh undefine $VM_NAME"
    else
        echo "💡 La VM está apagada. Para eliminarla:"
        echo "   sudo virsh undefine $VM_NAME"
    fi
    exit 1
fi

# 2. Validar existencia del disco en el pool de KVM
if [ -f "$KVM_DIR/$TARGET_IMG" ]; then
    echo "❌ ERROR: El archivo de disco '$KVM_DIR/$TARGET_IMG' ya existe."
    echo "💡 Para eliminarlo manualmente:"
    echo "   sudo rm $KVM_DIR/$TARGET_IMG"
    exit 1
fi

# 3. Validar Golden Image local y documentación
QCOW2_COUNT=$(ls ../*.qcow2 2>/dev/null | wc -l)
if [ "$QCOW2_COUNT" -eq 0 ]; then
    echo "--------------------------------------------------------------------------"
    echo "❌ ERROR: No se encontró ninguna imagen .qcow2 en este directorio."
    echo "📖 INSTRUCCIONES: Remítase a la documentación del repositorio para"
    echo "   obtener las instrucciones de cómo crear su Golden Image."
    echo "--------------------------------------------------------------------------"
    exit 1
fi

# 4. Selección de Recursos (Imagen y Llave SSH)
echo "Imágenes disponibles:"
ls -1 ../*.qcow2
read -p "👉 Ingresa el nombre de tu 'Golden Image': " ORIGINAL_IMG
if [ ! -f "$ORIGINAL_IMG" ]; then echo "❌ Archivo no encontrado."; exit 1; fi

if [ -f "$TARGET_IMG" ]; then
    echo "⚠️  ADVERTENCIA: Ya existe '$TARGET_IMG' localmente. Bórralo para continuar."
    exit 1
fi

echo "------------------------------------------"
echo "🔍 Buscando llaves públicas SSH (.pub)..."
MAPFILE_KEYS=()
while IFS= read -r line; do MAPFILE_KEYS+=("$line"); done < <(ls ../*.pub *.pub ~/.ssh/*.pub 2>/dev/null)

if [ ${#MAPFILE_KEYS[@]} -eq 0 ]; then echo "❌ ERROR: No hay llaves .pub."; exit 1; fi

echo "Selecciona la llave SSH para inyectar:"
select SELECTED_KEY in "${MAPFILE_KEYS[@]}"; do
    if [ -n "$SELECTED_KEY" ]; then
        SSH_PUB_KEY="$SELECTED_KEY"
        break
    else
        echo "Opción no válida."
    fi
done

echo "------------------------------------------"
echo "✅ Validaciones completas. Iniciando personalización..."

# --- Ejecución del Flujo de Trabajo ---
cp "$ORIGINAL_IMG" "$TARGET_IMG"

echo "🔧 Creando usuario administrativo '$LAB_USER' y asegurando el entorno..."

virt-customize -a "$TARGET_IMG" \
    --hostname "$HOSTNAME" \
    --root-password password:$PASSWORD \
    --run-command "useradd -m -G wheel $LAB_USER" \
    --password $LAB_USER:password:$PASSWORD \
    --run-command "echo '$LAB_USER ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/$LAB_USER" \
    --ssh-inject "$LAB_USER:file:$SSH_PUB_KEY" \
    --run-command "sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config" \
    --uninstall cloud-init \
    --selinux-relabel

sudo mv "$TARGET_IMG" "$KVM_DIR/"

sudo virt-install \
    --name "$VM_NAME" \
    --memory 8196 \
    --vcpus 2 \
    --disk "$KVM_DIR/$TARGET_IMG" \
    --import \
    --osinfo rhel9.0 \
    --noautoconsole

#echo "🏗️  VM '$VM_NAME' lanzada. Obteniendo IP en 5 segundos..."
#sleep 5
#sudo virsh domifaddr "$VM_NAME"

# --- Obtención de IP con Polling Loop ---
echo -n "🏗️  VM '$VM_NAME' lanzada. Esperando IP (DHCP)"
MAX_RETRIES=30
COUNT=0
VM_IP=""

while [ $COUNT -lt $MAX_RETRIES ]; do
    VM_IP=$(sudo virsh domifaddr "$VM_NAME" | grep ipv4 | awk '{print $4}' | cut -d/ -f1)

    if [ -n "$VM_IP" ]; then
        echo -e "\n✅ IP detectada: $VM_IP"
        break
    fi

    echo -n "."
    sleep 2
    ((COUNT++))
done

if [ -z "$VM_IP" ]; then
    echo -e "\n❌ ERROR: No se pudo obtener la IP automáticamente tras 60s."
    echo "💡 Verifique el estado con: sudo virsh domifaddr $VM_NAME"
else
    # Extraemos la ruta de la llave privada (quitando .pub)
    PRIVATE_KEY="${SSH_PUB_KEY%.pub}"

    echo "--------------------------------------------------------------------------"
    echo "🚀 Listo para el siguiente paso."
    echo ""
    echo "1. Conexión manual para validar:"
    echo "   ssh -i $PRIVATE_KEY $LAB_USER@$VM_IP"
    echo ""
    echo "2. Desplegar MicroShift con Ansible:"
    echo "   ansible-playbook microshift_modular_deploy.yml -e \"target_env=local local_ip=$VM_IP local_key=$PRIVATE_KEY\""
    echo "--------------------------------------------------------------------------"
fi
