#!/bin/bash
# Proyecto: Querida, encogí el clúster
# Paso 0.5: Verificación de Cimientos (Hardware Virtual)

echo "--- [ Verificando el Juez de la Verdad Científica: Hardware ] ---"

# 1. Verificar CPUs (Mínimo 2)
CPUS=$(grep -c ^processor /proc/cpuinfo)
if [ "$CPUS" -lt 2 ]; then
    echo "❌ ERROR: Necesitas al menos 2 vCPUs. Tienes: $CPUS"
else
    echo "✅ CPUs: $CPUS (OK)"
fi

# 2. Verificar RAM (Mínimo 2GB, Recomendado 4GB+)
TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
if [ "$TOTAL_RAM" -lt 2 ]; then
    echo "❌ ERROR: Necesitas al menos 2GB de RAM. Tienes: ${TOTAL_RAM}GB"
else
    echo "✅ RAM: ${TOTAL_RAM}GB (OK)"
fi

# 3. Verificar Espacio en Disco (Mínimo 20GB libres en /)
DISK_FREE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$DISK_FREE" -lt 20 ]; then
    echo "⚠️ ADVERTENCIA: Tienes menos de 20GB libres. Podrías tener problemas de almacenamiento."
else
    echo "✅ Disco: ${DISK_FREE}GB libres (OK)"
fi

echo "------------------------------------------------------------"
