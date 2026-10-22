# Comandos de Floci: guía de uso general

**Floci** es un programa que imita a AWS (la nube de Amazon) dentro de su laptop. Responde en `http://localhost:4566` y habla el mismo idioma que AWS, así que el código que escriba contra Floci es el mismo que luego apuntaría a AWS real.

**Para qué sirve en el trabajo:** simular desarrollos en AWS (colas, tablas, almacenamiento de archivos, notificaciones, funciones) sin abrir una cuenta, sin pagar y sin permisos corporativos. Sirve para probar una idea, correr pruebas automáticas de un desarrollo antes de subirlo y ensayar cómo se comporta un diseño. **No reemplaza a AWS:** prueba el comportamiento, no el rendimiento ni los costos reales.

Los comandos se escriben en una **consola** (Terminal en Mac/Linux, PowerShell en Windows). Para los de Python, la consola debe tener el entorno activo (se ve `(.venv)` al inicio de la línea) y estar dentro de la carpeta `CLASE`.

---

## 1. Levantar y bajar Floci

Floci corre dentro de un contenedor de Docker llamado `floci-clase4`. **Docker Desktop debe estar abierto.**

| Qué quiero | Comando |
| --- | --- |
| **Levantarlo (la forma normal)** | Ejecutar el archivo **2-INICIAR-LA-CLASE** de su carpeta |
| Bajarlo (apagarlo, conserva el contenedor) | `docker stop floci-clase4` |
| Volver a levantarlo | `docker start floci-clase4` |
| Reiniciarlo | `docker restart floci-clase4` |
| Eliminar el contenedor | `docker rm -f floci-clase4` |
| Eliminar todo lo del curso | Ejecutar **5-ELIMINAR-FLOCI** |

**Importante:** por defecto Floci guarda sus datos **en memoria**. Si lo baja y lo vuelve a levantar, las colas, tablas y archivos creados se pierden. Por eso, después de reiniciarlo, ejecute `python tools/floci_preparar.py` para volver a crear lo del taller.

**Levantarlo a mano, sin los archivos del paquete** (útil para sus propios proyectos):

```
docker run -d --name mi-floci -p 4566:4566 floci/floci:2.2.0
```

`2.2.0` es la versión que usa la clase. Con `:latest` obtiene la más reciente, que puede comportarse distinto. Si el puerto 4566 ya está ocupado por otro contenedor, use otro puerto, por ejemplo `-p 4567:4566`, y apunte su código a `http://localhost:4567`.

**Levantarlo conservando los datos** (según la documentación de Floci; no se probó en la clase):

```
docker run -d --name mi-floci -p 4566:4566 -e FLOCI_STORAGE_MODE=persistent -e FLOCI_STORAGE_PERSISTENT_PATH=/data -v floci-datos:/data floci/floci:2.2.0
```

Algunos servicios (por ejemplo Lambda) necesitan además que Floci pueda usar Docker. Eso se logra agregando `-v /var/run/docker.sock:/var/run/docker.sock`. No lo necesita para colas, tablas, archivos ni notificaciones.

---

## 2. Probar que está vivo

| Qué quiero | Comando |
| --- | --- |
| Ver si el contenedor está encendido | `docker ps --filter name=floci-clase4` |
| ¿Responde? (debe imprimir `200`) | `curl -s -o /dev/null -w "%{http_code}" http://localhost:4566/` |
| Prueba corta de humo (cola y tabla) | `python tools/probar_emulador.py` (debe terminar con «LISTO») |
| Ver los últimos mensajes de Floci | `docker logs --tail 30 floci-clase4` |
| Seguir los mensajes en vivo (salir con Ctrl+C) | `docker logs -f floci-clase4` |
| Ver cuánta memoria y CPU usa | `docker stats floci-clase4 --no-stream` |
| Ver todos los contenedores, incluso apagados | `docker ps -a` |

En Windows, `curl` en PowerShell se comporta distinto; use `curl.exe -s -o NUL -w "%{http_code}" http://localhost:4566/`.

**Consola web** (una pantalla para ver lo que hay en Floci): `http://localhost:4500`. Se abre con **3-ABRIR-CONSOLA-WEB** y se apaga con **4-LIMPIAR-DESPUES-DE-LA-CLASE**.

---

## 3. Datos de conexión

Floci no valida usuarios reales, pero las herramientas de AWS exigen algo. Use siempre estos:

| Dato | Valor |
| --- | --- |
| Dirección (endpoint) | `http://localhost:4566` |
| Región | `us-east-1` |
| Usuario / clave | `test` / `test` |

En el taller además se usan estos nombres: cola `seguimiento-eventos`, cola de fallidos `seguimiento-eventos-dlq`, tabla `seguimiento`.

---

## 4. Qué servicios ofrece

Según su documentación, Floci simula, entre muchos otros: **S3** (archivos), **SQS** (colas), **SNS** (notificaciones), **DynamoDB** (tablas), **Lambda** (funciones), IAM, KMS, Secrets Manager, EventBridge, Step Functions, API Gateway, Cognito, CloudWatch, RDS y más. No todos tienen la misma madurez: pruebe cada uno antes de apoyar un diseño en él.

En la clase usamos solo **SQS** y **DynamoDB**.

---

## 5. Recetas por servicio (Python, sin instalar nada más)

Estos comandos usan lo que ya trae su carpeta. Cópielos completos, en una sola línea. Cambie los nombres de ejemplo (`demo-clase`, `demo-cola`…) por los suyos.

### Archivos (S3)

| Qué quiero | Comando |
| --- | --- |
| Crear un «bucket» (carpeta raíz) | `python -c "from separado import aws; aws.cliente('s3').create_bucket(Bucket='demo-clase'); print('creado')"` |
| Ver los buckets | `python -c "from separado import aws; print([b['Name'] for b in aws.cliente('s3').list_buckets()['Buckets']])"` |
| Subir un texto | `python -c "from separado import aws; aws.cliente('s3').put_object(Bucket='demo-clase', Key='hola.txt', Body=b'hola desde Floci'); print('subido')"` |
| Ver qué archivos hay | `python -c "from separado import aws; print([o['Key'] for o in aws.cliente('s3').list_objects_v2(Bucket='demo-clase').get('Contents', [])])"` |
| Leer un archivo | `python -c "from separado import aws; print(aws.cliente('s3').get_object(Bucket='demo-clase', Key='hola.txt')['Body'].read().decode())"` |
| Borrar el archivo y el bucket | `python -c "from separado import aws; s=aws.cliente('s3'); s.delete_object(Bucket='demo-clase', Key='hola.txt'); s.delete_bucket(Bucket='demo-clase'); print('borrado')"` |

### Colas (SQS)

| Qué quiero | Comando |
| --- | --- |
| Crear una cola | `python -c "from separado import aws; print(aws.cliente('sqs').create_queue(QueueName='demo-cola')['QueueUrl'])"` |
| Ver las colas | `python -c "from separado import aws; print(aws.cliente('sqs').list_queues().get('QueueUrls', 'ninguna'))"` |
| Enviar un mensaje | `python -c "from separado import aws; aws.cliente('sqs').send_message(QueueUrl=aws.url_cola('demo-cola'), MessageBody='mensaje de prueba'); print('enviado')"` |
| Cuántos mensajes esperan | `python -c "from separado import aws; print(aws.cliente('sqs').get_queue_attributes(QueueUrl=aws.url_cola('demo-cola'), AttributeNames=['ApproximateNumberOfMessages'])['Attributes'])"` |
| Recibir mensajes | `python -c "from separado import aws; r=aws.cliente('sqs').receive_message(QueueUrl=aws.url_cola('demo-cola'), WaitTimeSeconds=1).get('Messages', []); print([m['Body'] for m in r])"` |
| Vaciar la cola | `python -c "from separado import aws; aws.cliente('sqs').purge_queue(QueueUrl=aws.url_cola('demo-cola')); print('vacía')"` |
| Borrar la cola | `python -c "from separado import aws; aws.cliente('sqs').delete_queue(QueueUrl=aws.url_cola('demo-cola')); print('borrada')"` |

Un mensaje recibido **no desaparece** de la cola: queda oculto unos segundos y vuelve a aparecer si nadie lo confirma. Así protege SQS contra mensajes perdidos. El trabajador del taller lo borra al terminar de procesarlo.

### Tablas (DynamoDB)

| Qué quiero | Comando |
| --- | --- |
| Crear una tabla | `python -c "from separado import aws; aws.cliente('dynamodb').create_table(TableName='demo-tabla', KeySchema=[{'AttributeName':'id','KeyType':'HASH'}], AttributeDefinitions=[{'AttributeName':'id','AttributeType':'S'}], BillingMode='PAY_PER_REQUEST'); print('creada')"` |
| Ver las tablas | `python -c "from separado import aws; print(aws.cliente('dynamodb').list_tables()['TableNames'])"` |
| Guardar un registro | `python -c "from separado import aws; aws.recurso_dynamodb().Table('demo-tabla').put_item(Item={'id':'1','nombre':'Ana'}); print('guardado')"` |
| Leer un registro | `python -c "from separado import aws; print(aws.recurso_dynamodb().Table('demo-tabla').get_item(Key={'id':'1'})['Item'])"` |
| Ver todo lo guardado | `python -c "from separado import aws; print(aws.recurso_dynamodb().Table('demo-tabla').scan()['Items'])"` |
| Borrar la tabla | `python -c "from separado import aws; aws.cliente('dynamodb').delete_table(TableName='demo-tabla'); print('borrada')"` |

### Notificaciones (SNS)

| Qué quiero | Comando |
| --- | --- |
| Crear un tema | `python -c "from separado import aws; print(aws.cliente('sns').create_topic(Name='demo-tema')['TopicArn'])"` |
| Ver los temas | `python -c "from separado import aws; print([x['TopicArn'] for x in aws.cliente('sns').list_topics()['Topics']])"` |

Un tema avisa a quienes se suscriben a él (una cola, una función…). Es el patrón «uno avisa, muchos escuchan».

### Los del taller

| Qué quiero | Comando |
| --- | --- |
| Crear (o recrear) cola, cola de fallidos y tabla del seguimiento | `python tools/floci_preparar.py` |
| Borrarlas y crearlas de cero | `python tools/floci_preparar.py --reiniciar` |
| Cuántos mensajes fallaron | `python -c "from separado import aws; print(aws.cliente('sqs').get_queue_attributes(QueueUrl=aws.url_cola(aws.COLA_ERRORES), AttributeNames=['ApproximateNumberOfMessages'])['Attributes'])"` |
| Ver el historial que guardó el trabajador | `python -c "from separado import aws; [print(i) for i in aws.recurso_dynamodb().Table(aws.TABLA).scan()['Items']]"` |
| Levantar el trabajador (en otra consola) | `python -m separado.trabajador` (se apaga con Ctrl+C) |
| Correr la demo en modo separado | Mac/Linux: `SEGUIMIENTO_MODO=separado python -m horizonte.demo` · Windows PowerShell: `$env:SEGUIMIENTO_MODO="separado"; python -m horizonte.demo` |

---

## 6. Con la línea de comandos de AWS (opcional)

La herramienta `aws` (AWS CLI) **no viene en el paquete** y no la necesita para la clase. Si la instala, se usa igual que con AWS real agregando `--endpoint-url`:

```
aws --endpoint-url http://localhost:4566 s3 mb s3://demo-clase
aws --endpoint-url http://localhost:4566 s3 ls
aws --endpoint-url http://localhost:4566 sqs create-queue --queue-name demo-cola
aws --endpoint-url http://localhost:4566 sqs list-queues
aws --endpoint-url http://localhost:4566 dynamodb list-tables
```

Para no repetir `--endpoint-url` en cada comando, defina estas variables una vez por consola:

| Sistema | Cómo definirlas |
| --- | --- |
| Mac / Linux | `export AWS_ENDPOINT_URL=http://localhost:4566 AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test AWS_DEFAULT_REGION=us-east-1` |
| Windows (PowerShell) | `$env:AWS_ENDPOINT_URL="http://localhost:4566"; $env:AWS_ACCESS_KEY_ID="test"; $env:AWS_SECRET_ACCESS_KEY="test"; $env:AWS_DEFAULT_REGION="us-east-1"` |

Esa es la utilidad de un emulador: su código lee esas variables. Cuando las apunte a una cuenta real de AWS, **el mismo código funciona sin cambios**.

---

## 7. Cómo probar su propio código contra Floci

1. Levante Floci (sección 1) y confirme que responde (sección 2).
2. En su código, cree el cliente indicando la dirección de Floci. En Python:

```python
import boto3
sqs = boto3.client("sqs", endpoint_url="http://localhost:4566", region_name="us-east-1",
                   aws_access_key_id="test", aws_secret_access_key="test")
```

3. Cree los recursos que su código espera (cola, tabla, bucket) **antes** de correrlo. El taller lo hace con `tools/floci_preparar.py`.
4. Corra su código y mire el resultado con las recetas de la sección 5.
5. Al terminar, baje Floci (sección 1). Como guarda en memoria, la próxima vez parte limpio.

---

## 8. Si algo no responde

| Síntoma | Qué hacer |
| --- | --- |
| «Connection refused» o «No pude hablar con el emulador» | Docker Desktop cerrado o Floci apagado. Abra Docker y ejecute **2-INICIAR-LA-CLASE**. |
| `docker: command not found` o «Cannot connect to the Docker daemon» | Docker no está instalado o no está abierto. Ábralo y espere a que diga que está en ejecución. |
| La cola, tabla o bucket «no existe» | Floci se reinició y perdió los datos. Vuelva a crearlos (`python tools/floci_preparar.py` para los del taller). |
| El historial sale vacío | El trabajador está apagado: `python -m separado.trabajador`. Es consistencia eventual, no un error. |
| «Port is already allocated» | El puerto 4566 lo usa otro contenedor. Véalo con `docker ps` y apáguelo, o use otro puerto (sección 1). |
| Después de la pausa Floci ya no responde | Ejecute de nuevo **2-INICIAR-LA-CLASE**. |
| Floci responde lento | Revise que Docker tenga memoria suficiente (Docker Desktop, Configuración, Recursos) y cierre contenedores que no use. |
| Quiero empezar de cero | `docker rm -f floci-clase4`, luego **2-INICIAR-LA-CLASE** y `python tools/floci_preparar.py`. |
