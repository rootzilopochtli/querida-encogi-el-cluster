#!/bin/bash
###############################################################################
# Autor: Alex (@rootzilopochtli) - Content Architect en Red Hat
# Descripción: Validación de salud y sincronización mTLS local.
###############################################################################

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configura aquí la ruta a tu llave privada local
SSH_KEY="[PATH_A_TU_LLAVE_PRIVADA]/[TU_LLAVE].pem"
SSH_USER="ec2-user"
LOCAL_KUBE_DIR="${HOME}/.kube"

echo -e "${YELLOW}== Paso 1: Limpiando caché local ==${NC}"
if [ -d "$LOCAL_KUBE_DIR" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    mv "$LOCAL_KUBE_DIR" "${LOCAL_KUBE_DIR}_backup_$TIMESTAMP"
fi
mkdir -p "$LOCAL_KUBE_DIR"

read -p "Introduce la IP pública de la instancia de AWS: " INSTANCE_IP

remote_cmd() {
    ssh -i "$SSH_KEY" -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new "$SSH_USER@$INSTANCE_IP" "$1" 2>/dev/null
}

echo -e "\n${GREEN}== Paso 2: Verificando nodo remoto ==${NC}"
OS_VER=$(remote_cmd "grep VERSION_ID /etc/os-release | cut -d'\"' -f2")
[[ $? -ne 0 ]] && { echo -e "${RED}[ERROR] Sin conexión SSH${NC}"; exit 1; }

SERVICE_STATUS=$(remote_cmd "systemctl is-active microshift")
[[ "$SERVICE_STATUS" == "active" ]] && echo -e "[OK] MicroShift Activo"

echo -e "\n${YELLOW}== Paso 3: Configurando mTLS local ==${NC}"
LOCAL_KUBE_CONFIG="$LOCAL_KUBE_DIR/config-aws"

scp -i "$SSH_KEY" "$SSH_USER@$INSTANCE_IP:~/.kube/config" "$LOCAL_KUBE_CONFIG" 2>/dev/null

REMOTE_CA=$(ssh -i "$SSH_KEY" "$SSH_USER@$INSTANCE_IP" "sudo cat /var/lib/microshift/certs/kube-apiserver-external-signer/ca.crt | base64 -w 0")

if [[ -n "$REMOTE_CA" ]]; then
    sed -i "s|https://.*:6443|https://$INSTANCE_IP:6443|g" "$LOCAL_KUBE_CONFIG"
    sed -i "s|certificate-authority-data:.*|certificate-authority-data: $REMOTE_CA|g" "$LOCAL_KUBE_CONFIG"
    echo -e "${GREEN}[OK] Configuración lista. Ejecuta: export KUBECONFIG=$LOCAL_KUBE_CONFIG${NC}"
fi
