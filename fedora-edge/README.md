# 🤏☸️ Fedora Edge: Querida, encogí el clúster

Bienvenido al escenario de **Edge Computing Local**. Aquí es donde la "Verdad Científica" se pone a prueba en el metal de tu propia laptop. Este proyecto nace de una pregunta fundamental: ¿Realmente necesitamos un clúster masivo en la nube para cada tarea, o estamos usando un tráiler para ir al súper?

> "It's not magic, it's talent and sweat." — Gilfoyle (Silicon Valley).

## 🎭 La Gira de los 4 Actos

Este laboratorio está diseñado como una obra de ingeniería en cuatro actos, eliminando las "cajas negras" y devolviéndote el control sobre cada capa de la infraestructura.

### 📍 Acto 0: Los Cimientos (La VM)
Antes de empezar con la automatización, necesitas un host con RHEL 9 operando correctamente. No importa si tu base es Windows, macOS o Linux, tenemos una guía para ti.
* **Instrucciones de Preparación:** Consulta la guía detallada en el archivo de [preparación de VMs](docs/VM_PREPARATION.md).

### ✅ Acto 0.5: El Juez de Hardware
No confíes, verifica. Una vez que tu VM esté encendida y tengas acceso a ella, el primer paso es confirmar que los recursos asignados son suficientes para soportar la carga de MicroShift. Ejecutaremos un [script](scripts/check_requirements.sh) de validación que funcionará como un "smoke test" para tu CPU, RAM y almacenamiento.

### 🛠️ Acto 1: Configuración y Orquestación (Ansible)
Aquí es donde aplicamos el "talento y sudor". Utilizaremos un Playbook de Ansible modular para transformar una instalación limpia de RHEL en un nodo de MicroShift. Durante este proceso:
* Automatizaremos el registro en el portal de desarrolladores de Red Hat.
* Configuraremos los repositorios de Fast Datapath.
* Instalaremos y habilitaremos el servicio de MicroShift de forma transparente, sin procesos manuales propensos a errores.

### 🔍 Acto 2: Verificación de Salud (mTLS)
La confianza se gana con certificados. En este acto, validamos que el plano de control (Control Plane) esté saludable. Configuraremos el intercambio de certificados mTLS entre tu máquina de gestión (host) y el nodo Edge (VM), asegurando que la comunicación sea cifrada y soberana.

### 🚀 Acto 3: La Verdad Científica (El despliegue)
El clímax del proyecto. Demostraremos la potencia de la inmutabilidad y la coexistencia de capas ejecutando un Job de **RHEL 10 (Coughlan)** sobre nuestro host de RHEL 9. Es la prueba definitiva de que, en el Edge, el contenedor es el dueño del tiempo y el espacio, permitiéndonos innovar con el software del futuro sobre la estabilidad del presente.

---

## 🔬 Filosofía del Proyecto
"La prueba de todo conocimiento es el experimento. El experimento es el único juez de la verdad científica". — Richard P. Feynman.

Este proyecto es tu bandera de **Soberanía Operativa**. Al miniaturizar el clúster, recuperas el control total, eliminas el "Vendor Lock-in" de las nubes públicas y garantizas que la tecnología sea una herramienta a tu servicio, y no una renta perpetua.

### 🎓 Estudiantes del AWS Student Community Day (TecNM Saltillo)
Si vienes de la plática en Saltillo, ¡bienvenido!.
Para replicar el laboratorio tal cual lo viste en la presentación, te sugerimos:
1.  **Clonar el repositorio** completo.
2.  **Seguir las guías del direcorio [/AWS](../AWS)**, que contienen los archivos `cobra-mai-app.yaml` y el playbook y script de automatización que utilizamos durante la demo.

---
**Geek by nature, Linux by choice, Fedora of course...**
---
👤 **Alex (@rootzilopochtli)** *Content Architect en Red Hat | Miembro de Fedora Project | Autor de "Fedora Linux System Administration"*
