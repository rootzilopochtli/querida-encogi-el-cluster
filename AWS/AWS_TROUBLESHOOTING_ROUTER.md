# 🕳️ El Agujero del Conejo: Troubleshooting del Ingress

Este documento detalla la autopsia técnica realizada al **Router de MicroShift** durante el laboratorio. Es una guía de referencia para entender cómo validar las capas de red en Kubernetes cuando la abstracción falla y debemos bajar al metal de RHEL.

## 🎭 Contexto: La Ambición contra el Metal

El plan original para el laboratorio era simple y espectacular: no solo queríamos hablar del EDGE, queríamos que la audiencia lo *tocara*. 

Diseñamos una aplicación web personalizada utilizando el manifiesto `cobra-mai-app.yaml` (un servidor Apache corriendo sobre Fedora), decorado con el branding de la comunidad y un mensaje de bienvenida. La idea era que cada asistente pudiera sacar su teléfono, escanear un código QR o ingresar a una URL dinámica basada en el servicio **nip.io** y ver, en tiempo real, su petición siendo procesada por un clúster de Kubernetes "encogido" en una instancia de AWS.

Desplegamos el Namespace, el ConfigMap con el HTML, el Deployment y el Service. Todo parecía perfecto en la terminal:
- El estado de los Pods indicaba **Running**.
    - `oc get pods` → Running ✅
- El objeto Route aparecía con el estado **Admitted**.
    - `oc get routes` → Admitted ✅
- Los logs del pod mostraban al servidor web listo para recibir tráfico.

Sin embargo, al intentar el primer "apretón de manos" desde el navegador del teléfono, la respuesta fue un frío y seco: **Connection Refused**. 

Fieles a la máxima de que _el experimento es el único juez de la verdad_, decidimos no ocultar el fallo. En lugar de eso, convertimos el error en una oportunidad pedagógica, transformando la sesión en una cacería técnica para entender por qué, cuando el software dice "estoy listo", el metal a veces dice "por aquí no pasas".

---

## El Problema: El "Portero" no abre la puerta

Tras confirmar que la infraestructura estaba arriba, observamos un comportamiento contradictorio: 
```
$ oc apply -f cobra-mai-app.yaml
namespace/lab-namespace created
configmap/web-content created
deployment.apps/cobra-mai-web created
service/cobra-mai-web created
route.route.openshift.io/cobra-mai-web created
$ oc get pods -n lab-namespace
NAME                            READY   STATUS    RESTARTS   AGE
cobra-mai-web-d844d56b4-jft6c   1/1     Running   0          6s
$ ssh -i ~/.ssh/[LLAVE_SSH].pem ec2-user@[INSTANCE_IP] "sudo ss -tulpn | grep :80"
$ 
$ ssh -i ~/.ssh/[LLAVE_SSH].pem ec2-user@[INSTANCE_IP] "sudo ss -tulpn"
Netid State  Recv-Q Send-Q Local Address:Port  Peer Address:PortProcess                                     
udp   UNCONN 0      0          127.0.0.1:323        0.0.0.0:*    users:(("chronyd",pid=712,fd=5))           
udp   UNCONN 0      0            0.0.0.0:5353       0.0.0.0:*    users:(("microshift",pid=12443,fd=112))    
udp   UNCONN 0      0            0.0.0.0:5353       0.0.0.0:*    users:(("microshift",pid=12443,fd=108))    
udp   UNCONN 0      0              [::1]:323           [::]:*    users:(("chronyd",pid=712,fd=6))           
udp   UNCONN 0      0               [::]:5353          [::]:*    users:(("microshift",pid=12443,fd=111))    
udp   UNCONN 0      0               [::]:5353          [::]:*    users:(("microshift",pid=12443,fd=110))    
tcp   LISTEN 0      4096    172.31.3.208:2381       0.0.0.0:*    users:(("microshift-etcd",pid=12453,fd=10))
tcp   LISTEN 0      128          0.0.0.0:22         0.0.0.0:*    users:(("sshd",pid=1083,fd=3))             
tcp   LISTEN 0      4096       127.0.0.1:10248      0.0.0.0:*    users:(("microshift",pid=12443,fd=138))    
tcp   LISTEN 0      4096       127.0.0.1:43377      0.0.0.0:*    users:(("crio",pid=12419,fd=11))           
tcp   LISTEN 0      4096               *:31192            *:*    users:(("ovnkube",pid=13667,fd=10))        
tcp   LISTEN 0      4096               *:2380             *:*    users:(("microshift-etcd",pid=12453,fd=3)) 
tcp   LISTEN 0      4096               *:2379             *:*    users:(("microshift-etcd",pid=12453,fd=6)) 
tcp   LISTEN 0      4096               *:6443             *:*    users:(("microshift",pid=12443,fd=7))      
tcp   LISTEN 0      4096               *:8445             *:*    users:(("microshift",pid=12443,fd=113))    
tcp   LISTEN 0      4096               *:30808            *:*    users:(("ovnkube",pid=13667,fd=12))        
tcp   LISTEN 0      4096               *:2112             *:*    users:(("microshift",pid=12443,fd=118))    
tcp   LISTEN 0      128             [::]:22            [::]:*    users:(("sshd",pid=1083,fd=4))             
tcp   LISTEN 0      4096               *:10259            *:*    users:(("microshift",pid=12443,fd=80))     
tcp   LISTEN 0      4096               *:10257            *:*    users:(("microshift",pid=12443,fd=79))     
tcp   LISTEN 0      4096               *:10250            *:*    users:(("microshift",pid=12443,fd=131))    
tcp   LISTEN 0      4096               *:32609            *:*    users:(("ovnkube",pid=13667,fd=11))   
$ oc get svc -n lab-namespace
NAME            TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
cobra-mai-web   ClusterIP   10.43.9.7    <none>        80/TCP    4m5s
$ oc get endpoints -n lab-namespace
NAME            ENDPOINTS        AGE
cobra-mai-web   10.42.0.7:8080   87s
$ oc get routes -n lab-namespace
NAME            HOST                                                     ADMITTED   SERVICE         TLS
cobra-mai-web   cobra-mai-web-lab-namespace.apps.[INSTANCE_IP]].nip.io   True       cobra-mai-web  
```

Kubernetes nos informaba que la ruta de entrada estaba admitida, pero no había respuesta en el puerto 80 del host. Iniciamos el descenso por las capas de la "cebolla" de Kubernetes.

> [**NOTA**]
> Debido a las políticas de seguridad de MicroShift, primero relajamos el namespace:
> ```
> $ oc label namespace lab-namespace pod-security.kubernetes.io/enforce=privileged
> ```
---

## Nivel 1: Validación de la Red Interna (East-West)

Siguiendo el método de aislamiento, primero validamos que el corazón del sistema estuviera latiendo. Para esto, lanzamos un pod de herramientas de red (**network-tools**) con una imagen de Fedora directamente en el clúster para realizar pruebas de "bisturí".
```
$ oc run network-tools -n lab-namespace --image=quay.io/fedora/fedora:40

# Verificamos la creación del pod
$ oc get pods -n lab-namespace

# Accedemos al pod
$ oc exec -it network-tools -n lab-namespace -- /bin/bash
```

### Pruebas de conectividad interna
Una vez dentro del pod de diagnóstico, realizamos las siguientes validaciones:
* **Conexión al Pod:** Una petición directa a la dirección IP interna del pod de la aplicación respondió exitosamente (HTTP 200 OK).
    * Prueba al Pod: `curl -I [POD_IP]:8080` → Resultado: **200 OK**.
* **Conexión al Service:** Una petición a la IP del ClusterIP (la abstracción que balancea el tráfico) también fue exitosa.
    * Prueba al Service: `curl -I [SERVICE_IP]:80` → Resultado: **200 OK**.
* **Resolución DNS:** El servicio CoreDNS interno resolvió el nombre de la aplicación correctamente.
    * Prueba DNS: curl -I `http://web-server:80` → Resultado: **200 OK**.

**Veredicto del Nivel 1:** El CNI (la red interna) y el DNS están impecables. El tráfico fluye perfectamente dentro del clúster. El problema no es la aplicación, es el puente hacia el exterior.

---

## Nivel 2: Validación del Host (North-South)

Si "adentro" todo funciona pero "afuera" no, el problema es el punto de contacto. Bajamos al metal de **Red Hat Enterprise Linux 9**.

### ¿Quién escucha en el puerto 80?
Utilizamos herramientas del sistema operativo en el host de AWS para verificar si el proceso de MicroShift (o su componente de HAProxy interno) había reclamado el puerto físico 80.
```
$ sudo ss -tulpn | grep :80
```
**Resultado:** El puerto estaba vacío. No había ningún proceso realizando un enlace (bind) al puerto físico.

### Inspección del Portero (Router)
Analizamos los logs del pod encargado de la exposición del tráfico. Curiosamente, el router informaba que su propia comprobación de salud era exitosa. Esto nos reveló una gran lección: el software puede creer que está funcionando correctamente dentro de su contenedor, pero estar completamente aislado de la red física del host.
```
$ oc logs -n openshift-ingress [NOMBRE_DEL_POD_ROUTER]
I0310 21:53:03.867933       1 template.go:561 "msg"="starting router" "logger"="router" "version"="majorFromGit: \nminorFromGit: \ncommitFromGit: b231c65b5c06c1f74590ca8e77caecc6213beb6a\nversionFromGit: 4.0.0-607-gb231c65b\ngitTreeState: clean\nbuildDate: 2026-01-12T19:02:18Z\n"
I0310 21:53:03.868255       1 merged_client_builder.go:121 Using in-cluster configuration
I0310 21:53:03.868331       1 merged_client_builder.go:163 Using in-cluster namespace
I0310 21:53:03.868363       1 envvar.go:172 "Feature gate default state" feature="ClientsAllowCBOR" enabled=false
...
I0310 21:53:03.869604       1 metrics.go:169 "msg"="router health and metrics port listening" "address"="0.0.0.0:1936" "logger"="metrics"
I0310 21:53:03.869643       1 merged_client_builder.go:121 Using in-cluster configuration
...
I0310 21:53:03.871114       1 router.go:214 "msg"="creating a new template router" "logger"="template" "writeDir"="/var/lib/haproxy"
I0310 21:53:03.871138       1 router.go:298 "msg"="router will coalesce reloads within an interval of each other" "interval"="5s" "logger"="template"
I0310 21:53:03.871371       1 router.go:368 "msg"="watching for changes" "logger"="template" "path"="/etc/pki/tls/private"
I0310 21:53:03.871392       1 router.go:283 "msg"="router is including routes in all namespaces" "logger"="router"
I0310 21:53:03.871498       1 reflector.go:358 "Starting reflector" type="*v1.Service" resyncPeriod="30m0s" reflector="github.com/openshift/router/pkg/router/template/service_lookup.go:33"
...
I0310 21:53:03.972039       1 router_controller.go:54 "msg"="running router controller" "logger"="controller"
...
I0310 21:53:05.022412       1 plugin.go:187 "msg"="processing subset" "index"=0 "logger"="template" "subset"={"addresses":[{"ip":"10.42.0.5","targetRef":{"kind":"Pod","namespace":"openshift-ingress","name":"router-default-f95c69f54-8p48s","uid":"ce7bcc81-a536-4a31-ac3c-78fe4f04e710"}}],"ports":[{"name":"http","port":80,"protocol":"TCP"},{"name":"https","port":443,"protocol":"TCP"}]}
...
I0310 21:54:31.260214       1 router_controller.go:269 "msg"="processing route" "event"="MODIFIED" "logger"="controller" "route"={"metadata":{"name":"cobra-mai-web","namespace":"cobra-mai-lab","uid":"830a65f1-364b-4f46-901c-24cc93b78a0f","resourceVersion":"851","generation":1,"creationTimestamp":"2026-03-10T21:54:31Z","annotations":{"kubectl.kubernetes.io/last-applied-configuration":"{\"apiVersion\":\"route.openshift.io/v1\",\"kind\":\"Route\",\"metadata\":{\"annotations\":{},\"name\":\"cobra-mai-web\",\"namespace\":\"cobra-mai-lab\"},\"spec\":{\"host\":\"cobra-mai-web-cobra-mai-lab.apps.3.144.117.204.nip.io\",\"port\":{\"targetPort\":80},\"to\":{\"kind\":\"Service\",\"name\":\"cobra-mai-web\"}}}\n"},"managedFields":[{"manager":"kubectl-client-side-apply","operation":"Update","apiVersion":"route.openshift.io/v1","time":"2026-03-10T21:54:31Z","fieldsType":"FieldsV1","fieldsV1":{"f:metadata":{"f:annotations":{".":{},"f:kubectl.kubernetes.io/last-applied-configuration":{}}},"f:spec":{".":{},"f:host":{},"f:port":{".":{},"f:targetPort":{}},"f:to":{".":{},"f:kind":{},"f:name":{},"f:weight":{}},"f:wildcardPolicy":{}}}},{"manager":"openshift-router","operation":"Update","apiVersion":"route.openshift.io/v1","time":"2026-03-10T21:54:31Z","fieldsType":"FieldsV1","fieldsV1":{"f:status":{".":{},"f:ingress":{}}},"subresource":"status"}]},"spec":{"host":"cobra-mai-web-cobra-mai-lab.apps.3.144.117.204.nip.io","to":{"kind":"Service","name":"cobra-mai-web","weight":100},"port":{"targetPort":80},"wildcardPolicy":"None"},"status":{"ingress":[{"host":"cobra-mai-web-cobra-mai-lab.apps.3.144.117.204.nip.io","routerName":"default","conditions":[{"type":"Admitted","status":"True","lastTransitionTime":"2026-03-10T21:54:31Z"}],"wildcardPolicy":"None","routerCanonicalHostname":"router-default.apps.example.com"}]}}
I0310 21:54:31.260245       1 status.go:202 "msg"="route status matches expected values, update not required" ...
I0310 22:01:15.009341       1 probehttp.go:107 "msg"="probe succeeded" "Status"="200 OK" "StatusCode"=200 "logger"="metrics_probehttp" "url"="http://localhost:80/_______internal_router_healthz"
...
go:124" type="*v1.Route" err="Get \"https://10.43.0.1:443/apis/route.openshift.io/v1/routes?allowWatchBookmarks=true&resourceVersion=1146&timeout=7m49s&timeoutSeconds=469&watch=true\": dial tcp 10.43.0.1:443: connect: connection refused"
...
I0310 22:11:31.834622       1 probehttp.go:107 "msg"="probe succeeded" "Status"="200 OK" "StatusCode"=200 "logger"="metrics_probehttp" "url"="http://localhost:80/_______internal_router_healthz"
...
I0310 22:26:03.930370       1 probehttp.go:107 "msg"="probe succeeded" "Status"="200 OK" "StatusCode"=200 "logger"="metrics_probehttp" "url"="http://localhost:80/_______internal_router_healthz"
```

---

## Nivel 3: El Muro de SELinux y Privilegios

En un entorno de grado empresarial como RHEL, la seguridad es un factor determinante.

* **Hipótesis:** El contenedor del Router no contaba con los permisos necesarios para realizar un enlace en un puerto privilegiado (menores al 1024) en el modo de red del host (**HostNetwork**).
* **Experimento:** Cambiamos las políticas de SELinux a modo permisivo de forma temporal y habilitamos booleanos de red específicos para permitir conexiones de servicios web.
```
$ ssh -i ~/.ssh/[LLAVE_SSH].pem ec2-user@[INSTANCE_IP] "sudo setsebool -P httpd_can_network_connect 1"
$ ssh -i ~/.ssh/[LLAVE_SSH].pem ec2-user@[INSTANCE_IP] "sudo setenforce 0"
$ ssh -i ~/.ssh/[LLAVE_SSH].pem ec2-user@[INSTANCE_IP] "sudo getenforce"
Permissive
```
* **Estado actual:** El puerto 80 se mantuvo en rebeldía, sugiriendo que la restricción podría residir en la configuración profunda del binario de MicroShift o en las reglas de seguridad de la infraestructura de red de la nube.

---

## Conclusión: Solución en Progreso 🚧

Este episodio es la prueba de que **Kubernetes es Linux**. No basta con que el archivo de configuración sea gramaticalmente correcto; la orquestación debe garantizar que el proceso sea capaz de interactuar con los recursos del sistema operativo anfitrión.

Este caso de estudio permanece abierto para futuras investigaciones, recordándonos que en el EDGE, el conocimiento profundo de los sistemas operativos es tan valioso como el dominio de las APIs de la nube.

*"La prueba de todo conocimiento es el experimento"*. Seguimos aprendiendo.

---
👤 **Alex (@rootzilopochtli)** *Content Architect en Red Hat | Autor de "Fedora Linux System Administration"*