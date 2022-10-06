# ldap 2022
## @dan M06-ASIX

### ldapserver 2022

* **ldap22:editat** servidor ldap con modificación de los usuarios en la base de datos y cambios en la configuración

## 1. Modificación de los usuarios

* Se han añadido nuevos usuarios (modificando el fichero edt-org.ldif) en la base de datos **dc=edt,dc=org** 

* Se ha añadido una nueva ou (organizationalunit) en la base de datos **dc=edt,dc=org**


* Ahora los usuarios se identifican por el uid en vez del cn


* La contraseña de manager ahora está encriptada:


    * Dentro de un container ejecutamos la orden "slappasswd" y encriptamos la contraseña "secret"
    ```
    root@ldap:/opt/docker# slappasswd          
    New password: 
    Re-enter new password: 
    {SSHA}rx59rUZEex37zeEvt5c9Xn1YbSZKls2Z
    ```
    * Seguidamente, copiamos el resultado de la contraseña encriptada ({SSHArx59rUZEex37zeEvt5c9Xn1YbSZKls2Z) y con esta modificamos el fichero de configuración "slapd.conf"

    ```
    database mdb
    suffix "dc=edt,dc=org"
    rootdn "cn=Manager,dc=edt,dc=org"
    rootpw secret                <-- linia a modificar
    directory /var/lib/ldap
    index objectClass eq,pres
    access to * by self write by * read
    ```
    * slapd.conf actualizado:
    
    ```
    database mdb
    suffix "dc=edt,dc=org"
    rootdn "cn=Manager,dc=edt,dc=org"
    rootpw {SSHA}rx59rUZEex37zeEvt5c9Xn1YbSZKls2Z 
    directory /var/lib/ldap
    index objectClass eq,pres
    access to * by self write by * read
    # la contraseña de Manager es secret
    ```


## 2. Configuración

* Para poder configurar la base de datos cn=config en caliente, necesitamos un root para esta base. Asi que modificamos el fichero slapd.conf y añadimos este user:
```
database config
rootdn "cn=Sysadmin,cn=config"
rootpw {SSHA}qJY4iHjsgQQB8y/bRAji6aZXx/zetynF
# el passwd es syskey
```


## 3. Prueba de funcionamiento

* Vemos que alhacer slapcat -n0 en el container, ahora el la base de datos c=config tenemos al user que hemos creado:

```
dn: olcDatabase={0}config,cn=config
objectClass: olcDatabaseConfig
olcDatabase: {0}config
olcAccess: {0}to *  by * none
olcAddContentAcl: TRUE
olcLastMod: TRUE
olcMaxDerefDepth: 15
olcReadOnly: FALSE
olcRootDN: cn=Sysadmin,cn=config
olcRootPW: e1NTSEF9cUpZNGlIanNnUVFCOHkvYlJBamk2YVpYeC96ZXR5bkY=
olcSyncUseSubentry: FALSE
olcMonitoring: FALSE
structuralObjectClass: olcDatabaseConfig
entryUUID: 7594d22e-da01-103c-824e-c57fe223d9bd
creatorsName: cn=config
createTimestamp: 20221006203028Z
entryCSN: 20221006203028.006355Z#000000#000#000000
modifiersName: cn=config
modifyTimestamp: 20221006203028Z
``` 

* Cambiamos la contraseña del user Manager
    * Primero creamos el fichero de modificación mod1.ldif:
        ```
        dn: olcDatabase={1}mdb,cn=config
        changetype: modify
        replace: olcRootPW
        olcRootPW: jupiter
        ```
    * Ejecutamos la orden por medio de sysadmin:
        ```
        ldapmodify -xv -D "cn=Sysadmin,cn=config" -w syskey -f mod1.ldif

        ldap_initialize( <DEFAULT> )
        replace olcRootPW:
	    jupiter
        modifying entry "olcDatabase={1}mdb,cn=config"
        modify complete
        ```

## 4. Container servidor ldap

* Construir la imagen:
```
docker build -t dangomezbernal/ldap22:editat .
```
* Iniciar el container propagando el puerto:
```
docker run --rm --name ldap.edt.org -h ldap.edt.org --network 2hisx -p 389:389 -it dangomezbernal/ldap22:editat
``` 
