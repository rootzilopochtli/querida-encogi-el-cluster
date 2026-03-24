# 🛠️ Configuración de Recursos Globales de Red Hat

Esta guía detalla los pasos obligatorios para habilitar la suscripción y descarga de componentes necesarios para el proyecto "Querida, encogí el clúster".

## 1. Crear Cuenta en Red Hat Developers
Para obtener acceso a las suscripciones de autodesarrollo (sin costo) y a los binarios de RHEL:
1. Ve a [developers.redhat.com](https://developers.redhat.com/).
2. Regístrate con un correo personal o institucional.
3. Confirma tu cuenta para activar el **Red Hat Developer Subscription for Individuals**.

## 2. Crear el Activation Key (RHSM)
El `activation_key` y el `org_id` son necesarios para que Ansible registre tus nodos automáticamente en el Acto 2.
1. Ingresa al [Portal de Clientes de Red Hat](https://access.redhat.com/management/activation_keys).
2. Haz clic en **Create Activation Key**.
3. Asigna un nombre (ej: `microshift-edge`).
4. Selecciona el **Service Level** como `Self-Support`.
5. **Importante:** Anota tu **Organization ID** y el nombre de la llave para inyectarlos en tu archivo `vars_aws.yml`.

## 3. Obtener el Pull Secret de OpenShift
El Pull Secret permite que el nodo de MicroShift descargue las imágenes de contenedores desde `quay.io`.
1. Ve a [console.redhat.com/openshift/install/pull-secret](https://console.redhat.com/openshift/install/pull-secret).
2. Haz clic en **Download Pull Secret**.
3. Guarda este archivo como `openshift-pull-secret` en la raíz de tu directorio de trabajo (donde reside el playbook).

---
⚠️ **Nota Técnica:** Sin estos tres elementos, el Acto 2 del Playbook fallará al intentar habilitar los repositorios de MicroShift y Fast Datapath.
---
👤 **Alex (@rootzilopochtli)** *Content Architect en Red Hat | Miembro de Fedora Project | Autor de "Fedora Linux System Administration"*
