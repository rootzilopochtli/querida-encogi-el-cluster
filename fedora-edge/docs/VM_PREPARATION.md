# 🖥️ Preparación del Entorno (Acto 0)

Para que **MicroShift** funcione correctamente, tu máquina virtual debe cumplir con requisitos específicos. No es magia, es una configuración técnica precisa para garantizar el éxito del experimento y validar la "Verdad Científica".

## 📋 Requisitos Mínimos de Hardware Virtual
Para este laboratorio, el "Juez de Hardware" requiere que tu instancia cumpla con lo siguiente:

* **Sistema Operativo:** Red Hat Enterprise Linux (RHEL) 9.x (Instalación mínima o Server).
* **CPU:** 2 vCPUs como mínimo.
* **RAM:** 2GB como mínimo, aunque se recomiendan 4GB para una mejor experiencia en el taller.
* **Disco:** 30GB de espacio en disco (100GB si planeas realizar muchas pruebas de imágenes).

---

## 🍎 macOS (Apple Silicon M1/M2/M3/M4 & Intel)
*Colaboración especial de: [Patrick Gomez]([pagomez-cd](https://github.com/pagomez-cd)).*

1. **Identificación de Arquitectura:** Antes de descargar nada, haz clic en el menú Apple (esquina superior izquierda) y selecciona "Acerca de esta Mac".
   * Si en "Chip" aparece Apple M1, M2 o M4, tu arquitectura es **ARM64**.
   * Si aparece Intel, tu arquitectura es **x86_64**.
2. **Descarga de RHEL 9:** Ve al portal de Red Hat Developers y descarga la imagen ISO de RHEL 9 que corresponda a tu arquitectura (ARM o x86).
3. **Instalación del Hipervisor UTM:** Descarga e instala UTM.app, que es la herramienta recomendada para virtualización nativa en macOS.
4. **Configuración de la VM en UTM:**
   * Selecciona la opción de **Virtualizar**.
   * Elige **Linux** como sistema operativo.
   * En la sección de Hardware, asigna al menos **2 CPUs** y **4GB de RAM**.
   * En **Boot ISO Image**, busca y selecciona el archivo ISO de RHEL que descargaste.
   * Define un disco de **30GB** o más.
5. **Instalación de RHEL:** Sigue el proceso de instalación estándar. Define tu contraseña de `root` y crea un usuario personal con privilegios de administrador.
6. **Limpieza Post-Instalación:** Una vez que el sistema reinicie por primera vez, apaga la VM. En el menú principal de UTM, busca la sección de CD/DVD y selecciona **Clear** para desmontar la ISO y evitar que la instalación inicie de nuevo.

---

## 🪟 Windows (VirtualBox)

1. **Software Necesario:** Descarga e instala VirtualBox junto con su Extension Pack.
2. **Configuración de Red (CRÍTICO):** Para que Ansible pueda orquestar la VM desde tu sistema host, debes configurar el adaptador de red en modo **Adaptador Puente (Bridged)**. Esto le asignará a la VM una dirección IP real de tu red local.
3. **Recursos de la VM:** Crea una máquina tipo "Red Hat (64-bit)" con 2 CPUs y 4GB de RAM.
4. **Imagen ISO:** Utiliza la imagen **x86_64** de RHEL 9 para la instalación.

---

## 🐧 Linux (Nativo con KVM/Libvirt)
*Basado en el método de Alex Callejas ([Build a lab quickly](https://www.redhat.com/en/blog/build-lab-quickly))*

Si ya usas Linux, mantén la soberanía usando el hipervisor del kernel.
1. **Herramientas:** `sudo dnf install -y virt-install virt-viewer libvirt`.
2. Asegúrate de que el servicio de gestión de máquinas virtuales esté activo: `sudo systemctl enable --now libvirtd`.
3. **Despliegue por Terminal:**
   ```bash
   virt-install \
     --name microshift-edge \
     --memory 4096 \
     --vcpus 2 \
     --disk size=30 \
     --os-variant rhel9.4 \
     --location /ruta/a/tu/rhel-9.x-x86_64-dvd.iso

4. **Red:** Asegúrate de que la VM esté conectada al puente virtual (bridge) para que tenga salida a internet y sea visible para tu host de gestión.

---

## ⚠️ Tabla de Compatibilidad de Arquitectura

| Si tu computadora tiene... | Debes bajar la ISO de RHEL... | Arquitectura Técnica |
| :--- | :--- | :--- |
| Apple Silicon (M1, M2, M3, M4) | RHEL 9 ARM64 (aarch64) | ARM |
| Procesador Intel o AMD | RHEL 9 x86_64 | x86 |

---

*Geek by nature, Linux by choice, Fedora of course...*

---
👤 **Alex (@rootzilopochtli)** *Content Architect en Red Hat | Miembro de Fedora Project | Autor de "Fedora Linux System Administration"*
