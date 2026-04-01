# MicroShift en AWS ☁️

Este directorio contiene los manifiestos y scripts para desplegar un nodo compacto de MicroShift en AWS Ohio (`us-east-2`).

## 🛠️ Contenido
* `full_microshift_automated.yml`: Playbook de Ansible para provisión total.
* `check_remote_microshift.sh`: Script de validación mTLS.
* `cobra-mai-job.yaml`: Experimento de procesamiento (RHEL 10 sobre RHEL 9).
* `cobra-mai-app.yaml`: Despliegue de aplicación web demo.
* [`AWS_WALKTHROUGH.md`](./AWS_WALKTHROUGH.md): **Guía detallada paso a paso (Troubleshooting y manual).**

## 🚀 Despliegue Rápido
1. Configura tu perfil local de AWS CLI.
2. Personaliza las variables en `full_microshift_automated.yml` (Llaves, perfiles, etc.).
3. Ejecuta: `ansible-playbook full_microshift_automated.yml`.
4. Sincroniza tu clúster: `./check_remote_microshift.sh`.

---
👤 **Alex (@rootzilopochtli)** *Content Architect en Red Hat | Miembro de Fedora Project | Autor de "Fedora Linux System Administration"*
