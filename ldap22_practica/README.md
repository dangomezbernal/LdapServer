# ldap 2022
## @dan M06-ASIX

### ldapserver 2022

* **ldap22:practica**

## 1.Iniciar Container

* container base de datos practica
```
docker build -t dangomezbernal/ldap22:practica .
```
```
docker run --rm --name ldap.edt.org -h ldap.edt.org --network 2hisx -p 389:389 -d danzzzo/ldap22_server:practica
```

* container phpldapadmin
```
docker run --rm --name phpldapadmin.edt.org -h phpldapadmin.edt.org --network 2hisx -p 80:80 -d danzzzo/ldap22_server:phpl
```

## 2.Cambios

* slapd.conf
	* quitar esquemas que no hacen falta
	```
	/etc/ldap/schema/corba.schema
	/etc/ldap/schema/duaconf.schema
	/etc/ldap/schema/dyngroup.schema
	/etc/ldap/schema/java.schema
	/etc/ldap/schema/misc.schema
	/etc/ldap/schema/openldap.schema
	/etc/ldap/schema/ppolicy.schema
	/etc/ldap/schema/collective.schema
	```
	* añadir el nuevo esquema a utilizar
	```
	/opt/docker/arkham.schema
	```

* arkham.schema
	Nuevo esquem a utilizar. Contiene dos objectClass nuevas: **x-ArkhamAsylum (STRUCTURAL)** y **x-interno (AUXILIARY)**

	Ambas objectClass derivan de TOP

	Atributos de **x-ArkhamAsylum**:	
	* Obligatorios
		```
		x-CID			#Codigo de identificación de todo lo que está dentro del asilo
		x-sector		#Area del asilo
		```
	* Opcionales
		```
		x-visitas		#Boolean que indica si en una zona se pueden recebir visitas 
		```
	Atributos de x-interno:
	* Obligatorios:
		```
		x-nombre		#Nombre del interno
		x-informe		#Información extra del interno
		x-foto			#Foto del interno
		```
	* Opcionales
		```
		x-alias			#Apodo del interno
		```
