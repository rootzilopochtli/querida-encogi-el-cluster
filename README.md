# 🤏☸️ Querida, encogí el clúster (Honey, I shrunk the cluster)

![Banner](./main_banner.png)

> *"Geek by nature, Linux by choice, Fedora of course..."*

Este repositorio es el centro de mando del Proyecto **Querida, encogí el clúster**, diseñado para llevar la potencia de **MicroShift** desde el laboratorio personal hasta la nube pública. Aquí no solo consumimos tecnología; la desarmamos para entender la soberanía del sistema operativo.

## ⚛️ Filosofía: El Factor Feynman
*"El principio de la ciencia, casi la definición, es el siguiente: «La prueba de todo conocimiento es el experimento». El experimento es el único juez de la verdad científica"*.

## 🚀 Estructura del Proyecto (Los 4 Actos)
Para evitar la complejidad de la abstracción, este proyecto se divide en fases lógicas de ejecución que permiten entender el _detrás de cámaras_ de cada despliegue:

* **Acto 0: Cimientos del Edge.** Creación de la VM (KVM) o aprovisionamiento de recursos en la nube [Exclusivo de [Fedora Edge / Local](./fedora-edge)].
```
$ ./provision_edge_kvm.sh
```
* **Acto 1: Orquestación de Infraestructura.** Configuración de la instancia y registro del nodo mediante Ansible.
```
fedora-edge: $ ansible-playbook microshift_modular_deploy.yml -e "target_env=local local_ip=$IP local_key=$KEY"
AWS:         $ ansible-playbook microshift_modular_deploy.yml -e "target_env=aws" -e "@vars_aws.yml"
```
* **Acto 2: El Despliegue Maestro.** Instalación de MicroShift, gestión de mTLS y validación de salud mediante el script `check_remote_microshift.sh`.
```
$ ./check_remote_microshift.sh

# Nota: Te pedirá seleccionar tu llave, el entorno (Local, AWS) y la IP del nodo.
```
* **Acto 3: La Verdad Científica.** Despliegue de aplicaciones y validación de cargas de trabajo futuras (RHEL 10 sobre RHEL 9).
```
$ envsubst < TU_ARCHIVO.yaml | oc apply -f -
```

## 🛠️ Prerrequisitos Globales (Indispensables)
Antes de iniciar cualquier laboratorio (AWS, Local o GCP), es obligatorio completar la configuración de tu ecosistema de Red Hat.

👉 **[Guía de Configuración Global: Cuenta, Keys y Secrets](./docs/SETUP_RESOURCES.md)**

## ☁️ Sabores del Laboratorio

| Plataforma | Estado | Enfoque |
| :--- | :--- | :--- |
| [**Fedora Edge / Local**](./fedora-edge) | ✅ Activo | Soberanía total y Golden Images con Image Builder. |
| [**AWS (Amazon Web Services)**](./AWS) | ✅ Activo | Escalabilidad en la nube de Ohio. |
| [**GCP (Google Cloud Platform)**](./GCP) | 🚧 WIP | Próximamente. |

## ⚠️ Nota sobre Compatibilidad (Legacy Support)

### 🎓 Estudiantes del AWS Student Community Day (TecNM Saltillo)
Si vienes de la plática en Saltillo, ¡bienvenido!.
Para replicar el laboratorio tal cual lo viste en la presentación, te sugerimos:
1.  **Clonar el repositorio** completo.
2.  **Seguir las guías del direcorio [/AWS](./AWS)**, que contienen los archivos `cobra-mai-app.yaml`, el playbook y script de automatización que utilizamos durante la demo.

Para [fedora-edge](./fedora-edge) utiliza la estructura modular en `/ansible`, `/scripts` y `/manifests`.

## 🥑 El Corazón en la Comunidad: Fedora México
La sección [**/fedora-edge**](./fedora-edge) es el punto de encuentro entre la potencia de Kubernetes y la agilidad de la comunidad. Este segmento del proyecto está diseñado específicamente para:

* **Impulsar el uso de MicroShift** dentro del Proyecto Fedora.
* **Servir como base técnica** para workshops, demos y charlas en eventos de la comunidad.
* **Facilitar la transición** de contenedores individuales (Podman) a la orquestación real (Kubernetes) usando la CLI `oc` de forma 100% práctica.

## 🤝 Contribuciones y Uso
Este es un proyecto de uso general. Siéntete libre de:
1. **Hacer un Fork** del proyecto.
2. **Adaptar los archivos** con tu información local (llaves SSH, perfiles de nube, IDs de suscripción).
3. **Enviar un PR** si encuentras una solución a la **[Escena Post-Créditos de AWS](./AWS/AWS_TROUBLESHOOTING_ROUTER.md)** o si quieres añadir soporte para una nueva nube.

---
👤 **Alex (@rootzilopochtli)** *Content Architect en Red Hat | Miembro de Fedora Project | Autor de "Fedora Linux System Administration"*
