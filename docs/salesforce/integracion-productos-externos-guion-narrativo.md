# Guion narrativo: Cómo construimos la integración de productos externos en LvlUp Wholesale

> Documento pensado para **escucharlo en voz alta** (texto a voz) mientras se hacen otras
> tareas. Lenguaje conversacional, frases cortas, enfocado en el aprendizaje. Cubre la
> **fundación** de la integración: desde la API de Platzi hasta la creación del `Product2`.
> Los pasos posteriores (precio, categoría final en Commerce, imágenes) se construyen
> encima de esta base y quedan fuera del alcance de este guion.

---

## 1. Introducción: qué queríamos lograr

Hola. Vamos a repasar, con calma, lo que hicimos en esta sesión.

La idea era sencilla de decir, pero interesante de construir.

Queríamos simular que algunos productos venían de un fabricante externo. Y que esos productos entraran a nuestra tienda B2B de Salesforce.

Pero no queríamos inventar los datos a mano. Queríamos traerlos de verdad, desde otro sistema, por internet.

O sea: practicar una integración real, de principio a fin.

## 2. Qué significa “integración real” en este caso

Cuando decimos integración real, no hablamos de copiar y pegar datos.

Hablamos de que Salesforce salga a internet, le pida información a otro sistema, reciba una respuesta, y la guarde de forma ordenada.

Eso implica varias cosas. Autenticarse de forma segura. Manejar errores si el otro sistema falla. Y transformar lo que recibimos en algo que Salesforce entienda.

Es el tipo de tarea que harías en un proyecto de verdad.

## 3. Por qué usamos la Platzi Fake Store API

Para practicar, usamos una API educativa y gratuita: la Platzi Fake Store API.

Una API es, simplemente, una puerta por la que un sistema te entrega datos cuando se los pides.

Esta en concreto devuelve productos con la forma típica de un e-commerce. Título, precio, descripción, imágenes y categoría.

Es perfecta para practicar. No cuesta nada, no hay riesgo, y se parece a una integración real.

## 4. Por qué mantuvimos intactos los productos internos

Ya teníamos un catálogo interno con cincuenta y un productos.

Y una regla quedó clara desde el principio: no tocarlos.

Esto es buena práctica. Lo externo y lo interno deben vivir separados. Un experimento no debería poder romper lo que ya funciona.

Así que todo lo nuevo lo marcamos, lo aislamos, y lo tratamos con cuidado.

## 5. Cómo configuramos el Named Credential

Para llamar a Platzi de forma segura, usamos un Named Credential.

Un Named Credential es como una agenda de contactos para sistemas. Guarda a qué dirección llamamos y cómo nos autenticamos.

Lo importante: así no escribimos la dirección ni las claves dentro del código. Si mañana cambia, lo tocas en un solo lugar.

Configuramos la dirección base de la API de Platzi. Y dejamos lista la conexión.

## 6. El problema con External Credential y permisos

Aquí apareció el primer obstáculo real.

En la interfaz nueva de Named Credentials, al ir a configurar la conexión, había un campo llamado External Credential. Y no dejaba seleccionar nada.

¿Por qué? Porque primero hay que crear un External Credential aparte. El Named Credential dice a dónde llamamos. El External Credential dice cómo nos identificamos. Son dos piezas separadas.

Lo creamos. Y entonces saltó un segundo problema: de permisos.

El External Credential usa una identidad interna, llamada principal. Y esa identidad no tenía acceso todavía.

Lo resolvimos asignando el acceso con un Permission Set.

Y de aquí sale un aprendizaje grande: en Salesforce, casi nada funciona por defecto. Casi todo necesita un permiso explícito.

## 7. Cómo validamos el callout con Anonymous Apex

Antes de escribir una sola clase, quisimos probar que la tubería funcionaba.

Para eso usamos Anonymous Apex. Es código que ejecutas suelto, una sola vez, sin guardarlo en ningún lado. Ideal para probar ideas rápido.

Hicimos la llamada a Platzi. Y recibimos un Status doscientos.

Doscientos significa “todo bien”. La conexión funciona.

El aprendizaje: valida la conexión antes de construir encima. Si la base falla, no tiene sentido seguir.

## 8. Qué hace LvlupPlatziProductService

Con la conexión probada, creamos la primera clase: LvlupPlatziProductService.

Esta clase tiene una sola responsabilidad. Hablar con Platzi. Nada más.

Hace la llamada. Pide los primeros diez productos. Y devuelve objetos que Apex entiende.

Le pusimos un límite de tiempo de diez segundos, por si Platzi tarda demasiado. Y si la respuesta no es doscientos, lanza un error controlado, con el código y el detalle.

Tener una clase que solo hace una cosa es clave. Si algo falla con Platzi, sabes exactamente dónde mirar.

## 9. JSON, deserialización, wrappers y casting, en simple

Aquí hay cuatro palabras técnicas. Vamos una por una, fácil.

JSON es un formato de texto para datos. Platzi nos manda texto con esa forma.

Deserializar es convertir ese texto en objetos que el lenguaje puede usar. Pasar de “texto plano” a “cosas con las que trabajar”.

Un wrapper es una clase pequeña que tiene la misma forma que el JSON. Si el JSON trae id, título y precio, el wrapper tiene id, título y precio. Es como un molde que encaja con los datos.

Y casting es decirle al lenguaje: “trata esto como una lista de productos”.

El detalle importante: Platzi devuelve una lista directa de productos. Así que deserializamos a una lista de wrappers. Cada wrapper, un producto.

## 10. Por qué creamos External_Product__c como objeto staging

Ahora una decisión de diseño importante.

No convertimos los datos de Platzi directamente en productos reales. Primero los guardamos en un objeto intermedio, que llamamos External_Product__c.

A esto se le llama staging. Piensa en una bandeja de entrada.

¿Por qué hacerlo así? Porque nos da una zona de seguridad. Podemos revisar los datos, corregirlos, reintentar, sin ensuciar el catálogo real.

Le pusimos un nombre automático, tipo E-P guion cero cero cero cero uno. Así cada registro tiene su identificador propio.

## 11. Qué hace LvlupPlatziProductImporter

La siguiente clase es LvlupPlatziProductImporter.

Su trabajo: tomar lo que devuelve el servicio, y guardarlo en la bandeja de staging.

Mapea cada dato de Platzi a un campo de External_Product__c. El título a un campo, el precio a otro, la descripción a otro, y así.

El servicio trae los datos. El importador los guarda. Cada uno con su rol.

## 12. Qué significa hacer upsert por External_Id__c

Aquí aparece otra palabra clave: upsert.

Upsert es la mezcla de actualizar e insertar. Significa: “si ya existe, actualízalo; si no existe, créalo”.

Para decidir si ya existe, usamos el identificador que viene de Platzi, guardado en el campo External_Id__c.

¿Por qué es tan importante? Porque si importas diez veces el mismo producto, no se duplica. Se actualiza el mismo registro.

A esto se le llama ser idempotente. Repetir la operación no causa desastres.

En integraciones reales, esto es oro. Los procesos se reintentan todo el tiempo, y no quieres mil copias del mismo producto.

## 13. La duda con las imágenes y por qué no se guardan como archivos

En este punto surgió una pregunta natural. ¿Y la imagen del producto?

Investigamos. Y aprendimos algo útil.

Guardar archivos de imagen dentro de Salesforce consume un espacio llamado File Storage. Y en una organización de tipo Developer Edition, ese espacio es muy pequeño.

Así que tomamos una decisión sencilla. No subimos archivos. Guardamos solo la dirección de la imagen, la URL, en un campo del staging.

El trabajo serio de imágenes lo dejamos para más adelante. Por ahora, basta con guardar la referencia.

## 14. Por qué ajustamos el layout de External_Product__c

Aquí vino un obstáculo muy típico, y muy educativo.

Al abrir un registro de External_Product__c, no veía todos los campos en pantalla.

Al principio, para revisar los datos, tuve que usar Salesforce Inspector. Es una extensión del navegador que te muestra los datos crudos, sin pasar por la pantalla bonita.

¿Qué pasaba? Dos cosas. La pantalla por defecto solo mostraba el nombre. Y, además, los campos nuevos no tenían visibilidad automática. A eso se le llama field-level security, o seguridad a nivel de campo.

Ajustamos la pantalla, el layout, para que mostrara todo. Y dimos los permisos de campo.

Y hubo un susto extra. Parecía que seguía roto incluso después de arreglarlo. Pero no era un error. Era la caché del navegador. Cerré sesión, volví a entrar, y ahí estaban los campos.

Lección preciosa: muchos “errores” en Salesforce son, en realidad, permisos o caché.

## 15. Por qué añadimos trazabilidad con Salesforce_Product__c

Cuando un registro externo se convierta en un producto real, queremos poder seguir el hilo.

Para eso añadimos un campo de tipo lookup, llamado Salesforce_Product__c, en el staging.

Un lookup es como un enlace de un registro a otro. Este campo apunta al producto real que se creó.

A esto se le llama trazabilidad. Poder responder: este producto real, ¿de qué registro externo salió?

En una integración seria, esto es fundamental. Si algo sale mal, sabes exactamente qué vino de dónde.

## 16. Qué campos añadimos en Product2 para identificar productos externos

También quisimos que el producto real recordara que vino de fuera.

Para eso añadimos tres campos en el objeto Product2.

Uno: Is_External_Product__c. Una casilla de sí o no. ¿Es externo?

Dos: External_Source__c. De dónde vino. En este caso, Platzi.

Tres: External_Product_Id__c. El identificador original que tenía en Platzi.

Y aquí aparece otro obstáculo que corregimos a tiempo. Tuvimos cuidado de no recrear campos que ya existían. Antes de crear, revisamos lo que ya estaba. Crear un campo duplicado solo trae confusión.

## 17. Qué hace LvlupExternalProductPublisher

Llegamos a la pieza que convierte. LvlupExternalProductPublisher.

Su trabajo: tomar los registros del staging que están listos, y crear el producto real, el Product2.

Mapea el título al nombre. Pasa la descripción. Genera un código de producto, tipo E-X-T guion PLATZI guion veintitrés. Marca el producto como externo. Lo activa.

Y, muy importante, hace dos cosas más. Enlaza la trazabilidad, guardando en el staging el enlace al producto creado. Y marca ese registro de staging como Published, publicado.

Además, usa algo llamado DML parcial. Significa que, si un producto falla, los demás siguen adelante. No se cae todo por culpa de uno solo.

## 18. El flujo completo de la integración

Pongamos todas las piezas en fila, porque así se entiende mejor.

Empezamos en la API de Platzi, que tiene los datos.

El Named Credential dice cómo y a dónde llamar, de forma segura.

El Apex Callout es la llamada en sí, desde Salesforce hacia afuera.

El servicio recibe la respuesta y la deserializa.

Los wrappers son esos datos ya convertidos en objetos tipados.

El importador los guarda en el staging, usando upsert, sin duplicar.

External_Product__c es la bandeja donde quedan los datos externos en crudo.

El publisher toma esos registros y los convierte en productos reales.

Y Product2 es el producto final, con su trazabilidad de vuelta al origen.

Cada pieza, una sola responsabilidad. Esa es la clave del diseño.

Y para ser honestos: esta es la base. Los pasos siguientes, como el precio, la categoría final en Commerce y las imágenes de verdad, se construyen encima de esta fundación. Pero esa es otra etapa.

## 19. Cómo explicar esto en una entrevista técnica

Imagina que te preguntan por esto en una entrevista. Lo dirías más o menos así.

“Construí una integración entrante en Salesforce. Me conecté de forma segura a una API REST externa usando Named Credentials. Hice el callout en Apex, deserialicé el JSON en clases wrapper tipadas, y separé el diseño en capas.”

Y luego das el detalle que demuestra criterio.

“Usé una clase de servicio solo para el HTTP. Un importador que hace upsert idempotente contra un objeto de staging, para no duplicar. Y un publisher que convierte el staging en Product2, manteniendo trazabilidad. Manejé errores controlados, resolví permisos, y mantuve el catálogo existente intacto.”

Eso suena a alguien que entiende integraciones de verdad. No solo código, sino decisiones.

## 20. Cierre y resumen final

Cerremos con lo que aprendimos.

Primero: las integraciones se construyen por capas, y se validan paso a paso. No de golpe.

Segundo: en Salesforce, los permisos son explícitos. Si algo no se ve o no funciona, sospecha de permisos. O de caché.

Tercero: el staging y la idempotencia son tus amigos. Evitan duplicados y te dan una zona segura para corregir.

Cuarto: aislar lo externo protege lo interno. No mezcles lo que estás probando con lo que ya funciona.

Y quinto: nombrar bien y separar responsabilidades hace que todo se entienda. Cada clase con un trabajo. Cada campo con un propósito.

La base de la integración quedó sólida. Datos reales, entrando de forma ordenada, desde Platzi hasta un producto en Salesforce, con su historia bien guardada.

Y desde aquí, lo demás es construir encima. Pero esa fundación ya está lista.

Eso es todo por hoy. Buen trabajo.
