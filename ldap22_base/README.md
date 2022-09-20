# ldap 2002
## @dan M06-ASIX

### ldapserver 2022

* **ldap22:base** servidor ldap basico con base de datos edt.org

## 1. Dockerfile

    #ldapserver 2022
    FROM debian:latest
    LABEL author="@dan ASIX-M06"
    LABEL subject="ldapserver 2022"
    RUN apt-get update
    ARG DEBIAN_FRONTEND=noninteractive
    RUN apt-get -y install procps iproute2 tree nmap vim iputils-ping slapd ldap-utils
    RUN mkdir /opt/docker
    WORKDIR /opt/docker
    COPY * /opt/docker/
    RUN chmod +x /opt/docker/startup.sh
    CMD /opt/docker/startup.sh
    EXPOSE 389


* ### FROM debian:latest
```
El sistema operativo y la versión que queremos usar para el container
```

* ### LABEL author="@dan ASIX-M06"
* ### LABEL subject="ldapserver 2022"
```
Las LABEL son etiquetas (opcionales) para dar información sobre el container y el autor
```

* ### RUN apt-get update // ARG DEBIAN_FRONTEND=noninteractive // RUN apt-get -y install procps iproute2 tree nmap vim iputils-ping slapd ldap-utils
```
RUN sirve para ejecutar comandos. En este caso queremos instalar ciertas utilidades basicas para un servidor ldap dentro del container, asi que se hace un apt-get update y un apt-get install. Con ARG DEBIAN_FRONTED=noninteractive evitamos que en la instalación se requiera una interacción de nuestra parte, como por ejemplo confirmar la instalación
```

* ### RUN mkdir /opt/docker
* ### WORKDIR /opt/docker
```
Creamos el directorio /opt/docker dentro del container y hacemos que sea el directorio activo cuando lo iniciemos (realmente el RUN no hace falta porque el WORKDIR a parte de establecer un directorio como el activo, si no existe tal directorio lo crea el mismo)
```

* ### COPY * /opt/docker/
```
Copia el contenido de la carpeta con la que se ha creado el container (donde está el Dockerfile) dentro del container cuando se cree, en el directorio que elijas (en este caso /otp/docker la cual hemos creado en pasos anteriores del propio dockerfile). Es importante destacar la / al final de la ruta a la hora de hacer el COPY *, ya que si no, no funcionará. 
```

* ### RUN chmod +x /opt/docker/startup.sh
```
Hcemos que el fichero startup.sh sea ejecutable
```

* ### CMD /opt/docker/startup.sh
```
Ejecutamos el fichero startup.sh
```

* ### EXPOSE 389
```
Dejamos abierto el puerto del ldap (389)
```

## 2. Startup
```
#! /bin/bash

rm -rf /var/lib/ldap/*
rm -rf /etc/ldap/slapd.d/*
slaptest -f slapd.conf -F /etc/ldap/slapd.d
slapadd -F /etc/ldap/slapd.d -l edt-org.ldif
chown openldap.openldap /etc/ldap/slapd.d/ /var/lib/ldap/
/usr/sbin/slapd -d0
```

* ### rm -rf /var/lib/ldap/*
```
Borramos los datos existentes en /var/lib/slapd.d
```

* ### rm -rf /etc/ldap/slapd.d/*
```
Borramos la configuración existente en /etc/ldap/slapd.d 
```

* ### slaptest -f slapd.conf -F /etc/ldap/slapd.d
```
A partir del fitchero de configuración slapd.conf generar la configuración dinámica
```

* ### slapadd -F /etc/ldap/slapd.d -l edt-org.ldif
```
Hacer la carga de datos inicial masiva 'populate' a bajo nivel (motor parado).
```

* ### chown openldap.openldap /etc/ldap/slapd.d/ /var/lib/ldap/
```
Asignar usuario y grupo openldap.openldap al directorio de configuración i de datos
```

* ### /usr/sbin/slapd -d0
```
Activar el demonio (-d0 es para que haga debug a nivel 0 y se quede en foreground todo el rato)
```

## 3. Container con servidor ldap
* ### Construir la imagen
```
docker build -t dangomezbernal/ldap22:base
```

* ### Iniciar el container
```
docker run --rm --name ldap.edt.org -h ldap.edt.org -it dangomezbernal/ldap22:base
``` 
## 4. Comprobar funcionamiento

```
Desde dentro del container podemos ejecutar ps ax o nmap para ver que todo vaya correctamente
```
```
También podemos probar con ldapsearch (desde dentro y fuera del container) para comprobar que la base de datos funcione
```
* ### Desde dentro
```
ldapsearch -x -LLL -h localhost -b 'dc=edt,dc=org' dn
```
```
dn: dc=edt,dc=org

dn: ou=maquines,dc=edt,dc=org

dn: ou=clients,dc=edt,dc=org

dn: ou=productes,dc=edt,dc=org

dn: ou=usuaris,dc=edt,dc=org

dn: cn=Pau Pou,ou=usuaris,dc=edt,dc=org

dn: cn=Pere Pou,ou=usuaris,dc=edt,dc=org

dn: cn=Anna Pou,ou=usuaris,dc=edt,dc=org

dn: cn=Marta Mas,ou=usuaris,dc=edt,dc=org

dn: cn=Jordi Mas,ou=usuaris,dc=edt,dc=org

dn: cn=Admin System,ou=usuaris,dc=edt,dc=org

```
* ### Desde fuera
```
ldapsearch -x -LLL -h 172.17.0.2 -b 'dc=edt,dc=org' dn
```
```
dn: dc=edt,dc=org

dn: ou=maquines,dc=edt,dc=org

dn: ou=clients,dc=edt,dc=org

dn: ou=productes,dc=edt,dc=org

dn: ou=usuaris,dc=edt,dc=org

dn: cn=Pau Pou,ou=usuaris,dc=edt,dc=org

dn: cn=Pere Pou,ou=usuaris,dc=edt,dc=org

dn: cn=Anna Pou,ou=usuaris,dc=edt,dc=org

dn: cn=Marta Mas,ou=usuaris,dc=edt,dc=org

dn: cn=Jordi Mas,ou=usuaris,dc=edt,dc=org

dn: cn=Admin System,ou=usuaris,dc=edt,dc=org

```