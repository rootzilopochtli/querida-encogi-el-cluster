# 🤏☸️ Fedora Edge: Querida, encogí el clúster

Bienvenido al escenario de **Edge Computing Local**. Aquí es donde la "Verdad Científica" se pone a prueba en el metal de tu propia laptop. Este proyecto nace de una pregunta fundamental: ¿Realmente necesitamos un clúster masivo en la nube para cada tarea, o estamos usando un tráiler para ir al súper?

> "It's not magic, it's talent and sweat." — Gilfoyle (Silicon Valley).

## 🎭 La Gira de los 4 Actos

Este laboratorio está diseñado como una obra de ingeniería en cuatro actos, eliminando las "cajas negras" y devolviéndote el control sobre cada capa de la infraestructura.

### 📍 Acto 0: Los Cimientos (La VM)
Antes de empezar con la automatización, necesitas un host con RHEL 9 operando correctamente. No importa si tu base es Windows, macOS o Linux, tenemos una guía para ti.
- **Instrucciones de Preparación:** Consulta la guía detallada en el archivo de [preparación de VMs](docs/VM_PREPARATION.md).
    - Si tu base es **Fedora**, clona el repositorio y utiliza el [script de provisionamiento](../scripts/provision_edge_kvm.sh).
    ⚠️ Nota: Deberas tener en tu directorio de trabajo la imagen creada en [developers.redhat.com](https://developers.redhat.com/) con [Image Builder](docs/IMAGE_BUILDER.md).

### 🛠️ Acto 1: Configuración y Orquestación (Ansible)
Aquí es donde aplicamos el "talento y sudor". Utilizaremos un Playbook de Ansible modular para transformar una instalación limpia de RHEL en un nodo de MicroShift. Durante este proceso:
* Automatizaremos el registro en el portal de desarrolladores de Red Hat.
* Configuraremos los repositorios de Fast Datapath.
* Instalaremos y habilitaremos el servicio de MicroShift de forma transparente, sin procesos manuales propensos a errores.
```
$ ansible-playbook microshift_modular_deploy.yml -e "target_env=local local_ip=$IP local_key=$KEY"
```

### 🔍 Acto 2: Verificación de Salud (mTLS)
La confianza se gana con certificados. En este acto, validamos que el plano de control (Control Plane) esté saludable. Configuraremos el intercambio de certificados mTLS entre tu máquina de gestión (host) y el nodo Edge (VM), asegurando que la comunicación sea cifrada y soberana.
```
$ ./check_remote_microshift.sh
```

### 🚀 Acto 3: La Verdad Científica (El despliegue)
El clímax del proyecto. Demostraremos la potencia de la inmutabilidad y la coexistencia de capas ejecutando un Job de **RHEL 10 (Coughlan)** sobre nuestro host de RHEL 9. Es la prueba definitiva de que, en el Edge, el contenedor es el dueño del tiempo y el espacio, permitiéndonos innovar con el software del futuro sobre la estabilidad del presente.
```
$ envsubst < TU_ARCHIVO.yaml | oc apply -f -
```

---

## 🔬 Filosofía del Proyecto
"La prueba de todo conocimiento es el experimento. El experimento es el único juez de la verdad científica". — Richard P. Feynman.

Este proyecto es tu bandera de **Soberanía Operativa**. Al miniaturizar el clúster, recuperas el control total, eliminas el "Vendor Lock-in" de las nubes públicas y garantizas que la tecnología sea una herramienta a tu servicio, y no una renta perpetua.

---

> *Geek by nature, Linux by choice, Fedora of course...*

---
👤 **Alex (@rootzilopochtli)** *Content Architect en Red Hat | Miembro de Fedora Project | Autor de "Fedora Linux System Administration"*
