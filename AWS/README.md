# MicroShift en AWS ☁️

Este directorio contiene los manifiestos y scripts para desplegar un nodo compacto de MicroShift en AWS Ohio (`us-east-2`).

## 🛠️ Contenido
* `full_microshift_automated.yml`: Playbook de Ansible para provisión total.
* `check_remote_microshift.sh`: Script de validación mTLS.
* `cobra-mai-job.yaml`: Experimento de carga de trabajo RHEL 10.
* [`AWS_WALKTHROUGH.md`](./AWS_WALKTHROUGH.md): **Diario de ingeniería (Paso a paso detallado).**

## 🚀 Despliegue Rápido
1. Configura tu perfil AWS (`alex`).
2. Ejecuta: `ansible-playbook full_microshift_automated.yml`.
3. Valida: `./check_remote_microshift.sh`.
