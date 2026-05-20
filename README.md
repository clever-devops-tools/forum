<div align="center">
  <img src="./assets/header.png" alt="Fullstack App Forum Workshop - Búsqueda de Personas" width="100%" />

</div>

<h1 align="center">Fullstack App Forum Workshop - Búsqueda de Personas</h1>

<p align="center">
  <a href="https://github.com/features/copilot"><img src="https://img.shields.io/badge/GitHub_Copilot-000000?style=for-the-badge&amp;logo=githubcopilot&amp;logoColor=white" alt="GitHub Copilot" /></a>
  <a href="https://quarkus.io/"><img src="https://img.shields.io/badge/Quarkus-4695EB?style=for-the-badge&amp;logo=quarkus&amp;logoColor=white" alt="Quarkus" /></a>
  <a href="https://spring.io/projects/spring-boot"><img src="https://img.shields.io/badge/Spring_Boot-6DB33F?style=for-the-badge&amp;logo=springboot&amp;logoColor=white" alt="Spring Boot" /></a>
  <a href="https://angular.dev/"><img src="https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&amp;logo=angular&amp;logoColor=white" alt="Angular" /></a>
  <a href="https://www.postgresql.org/"><img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&amp;logo=postgresql&amp;logoColor=white" alt="PostgreSQL" /></a>
  <a href="https://www.docker.com/"><img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&amp;logo=docker&amp;logoColor=white" alt="Docker" /></a>
</p>

---

## 🌟 Resumen (Overview)

En este workshop vas a **construir paso a paso una aplicación fullstack de búsqueda de personas** usando GitHub Copilot como apoyo directo durante la implementación. La solución queda separada en tres capas:

- **Frontend** en Angular para capturar la búsqueda y mostrar resultados.
- **BFF** en Spring Boot para adaptar y transformar la respuesta del backend.
- **API** en Quarkus para exponer endpoints REST sobre el dominio `Persona`.

> [!IMPORTANTE]
> Este documento está pensado para una dinámica **hands-on**. Aquí nos enfocamos únicamente en **crear la aplicación fullstack**. La preparación del ambiente local, prerrequisitos e infraestructura ya deben estar resueltos antes de comenzar esta actividad.

> Para más información sobre las herramientas utilizadas, consulta la documentación oficial:
>
> - [GitHub Copilot](https://docs.github.com/en/copilot)
> - [Quarkus](https://quarkus.io/guides/)
> - [Spring Boot](https://spring.io/projects/spring-boot/)
> - [Angular](https://angular.dev/)

---

## 📋 Tabla de Contenidos

1. [🚀 Primeros Pasos](#-primeros-pasos)
2. [🧩 Paso 1. Estructura base de la app](#-paso-1-estructura-base-de-la-app)
3. [🔷 Paso 2. Crear la API con Quarkus](#-paso-2-crear-la-api-con-quarkus)
4. [🟩 Paso 3. Crear el BFF con Spring Boot](#-paso-3-crear-el-bff-con-spring-boot)
5. [🔶 Paso 4. Crear el frontend con Angular](#-paso-4-crear-el-frontend-con-angular)
6. [✅ Paso 5. Integrar y validar la app](#-paso-5-integrar-y-validar-la-app)
7. [🎓 Tópicos Avanzados](#-tópicos-avanzados)
8. [💡 Prompts sugeridos](#-prompts-sugeridos)

---

## 🚀 Primeros Pasos

En esta actividad vas a trabajar directamente sobre el código de la solución. La idea es que avances por capas, ejecutes prompts concretos y construyas la aplicación pieza por pieza con ayuda de Copilot.

### Runtimes y Frameworks Utilizados

- **Java 21** con **Quarkus 3.8.x**
- **Java 21** con **Spring Boot 3.3.x**
- **Angular 18** con **TypeScript 5.x**
- **GitHub Copilot** en Visual Studio Code

### Requisitos Previos

- Repositorio abierto en VS Code.
- GitHub Copilot habilitado en el editor.
- Terminal integrada disponible.
- Servicios de soporte ya preparados previamente por el facilitador.

### Contexto Funcional de la App

Al terminar esta actividad, la app debe permitir:

1. Buscar una persona por tipo y número de identificación.
2. Mostrar los datos retornados por la API en una vista amigable.
3. Desacoplar frontend y backend mediante una capa BFF.

---

### 1. Clonar el repositorio

Clona el repositorio público desde Bitbucket para obtener la base del proyecto en tu máquina local.

```bash
git clone https://forumclever-admin@bitbucket.org/forumclever/fullstackapp.git
cd fullstackapp
```

### 2. Crear una nueva rama para el desarrollo

Antes de comenzar, crea una nueva rama en tu repositorio para trabajar en el desarrollo de la aplicación. Esto asegura que los cambios realizados estén aislados del resto del proyecto.

```bash
git checkout -b mi1nombre-mi1apellido
```

---

## 🧩 Paso 1. Estructura base de la app

Arranquemos por lo básico: dejar lista la estructura del proyecto para separar claramente las tres capas de la solución.

### Prompt sugerido para Copilot Chat

```text
Estoy construyendo una aplicación fullstack de búsqueda de personas con Quarkus, Spring Boot y Angular.
Quiero que me ayudes a generar código consistente entre las tres capas, manteniendo nombres claros, manejo de errores y una buena experiencia de usuario.

Necesito crear en una nueva carpeta con el nombre de mi rama, una aplicación fullstack para búsqueda de personas con tres capas:
- api: backend REST en Quarkus (Java)
- middle: BFF en Spring Boot (Java)
- frontend: SPA en Angular

Ayúdame a definir la estructura base de carpetas y los archivos principales que debería crear en cada capa.
```

### Resultado esperado

- Carpeta `api` para la API REST.
- Carpeta `middle` para el BFF.
- Carpeta `frontend` para la SPA.

Si Copilot te propone carpetas o archivos adicionales, revísalos y quédate solo con lo que aporte al objetivo del workshop.

### Comando sugerido

```powershell
mkdir api, middle, frontend
```

---

## 🔷 Paso 2. Crear la API con Quarkus

Ahora vas a construir la capa backend. El objetivo es dejar una API REST simple, clara y usable desde el BFF.

### 1. Crear el proyecto Quarkus

**Prompt sugerido:**

```text
Debo Crear el proyecto Quarkus LOCALMENTE en mi carpeta api, para ello debo ejecutar el siguiente comando:

mvn io.quarkus.platform:quarkus-maven-plugin:3.8.1:create `
  -DprojectGroupId=com.forum.workshop `
  -DprojectArtifactId=forum-api `
  -DprojectVersion=1.0.0 `
  -Dextensions="resteasy-reactive-jackson,hibernate-orm-panache,jdbc-postgresql"
```

### 2. Crear la entidad `Persona`

**Prompt sugerido:**

```text
Crea una entidad JPA llamada Persona para Quarkus usando Panache.

Debe:
- mapear la tabla personas
- extender PanacheEntity
- incluir los campos idTipo, idValor, nombres, apellidos, fechaNacimiento, email y telefono
- incluir un método helper getFullName()
- usar LocalDate para fechaNacimiento
```

Pega el prompt en Copilot Chat, revisa la propuesta y ajusta nombres o imports si hace falta antes de aceptar.

### 3. Crear el recurso REST `PersonaResource`

**Prompt sugerido:**

```text
Crea un controlador REST JAX-RS llamado PersonaResource para Quarkus con estos endpoints:

1. GET /api/personas/search?idTipo=DNI&idValor=12345678
2. GET /api/personas
3. GET /api/personas/{id}
4. POST /api/personas
5. PUT /api/personas/{id}
6. DELETE /api/personas/{id}
7. GET /api/personas/health

Usa PanacheEntity para consultas y agrega @Transactional en POST, PUT y DELETE.
```

En este punto, la meta no es solo “generar código”, sino entender cómo Copilot arma un recurso REST completo a partir de una especificación bien escrita.

### 4. Configurar la aplicación

**Prompt sugerido:**

```text
Ayúdame a crear el archivo application.properties para una aplicación Quarkus que:
- expone la API en el puerto 8080
- usa PostgreSQL
- habilita CORS
- habilita logs en nivel INFO
```

Mantén esta configuración mínima. En esta guía no estamos cubriendo infraestructura ni despliegue, solo la creación de la aplicación.

### 5. Compilar la API

Cuando termines de generar las clases base, compila para validar que la capa backend quedó consistente.

**Prompt sugerido:**

```text
Necesito compilar las clases bases para validar que la capa backend quedó consistente con el siguiente comando en la carpeta api:
mvn clean package
```

### Resultado esperado

- Proyecto Quarkus compilando correctamente.
- Clase `Persona` creada.
- Recurso `PersonaResource` con endpoints CRUD y health.
- Configuración base de la API lista.

---

## 🟩 Paso 3. Crear el BFF con Spring Boot

Con la API ya modelada, ahora toca crear la capa intermedia. Este BFF será el puente entre Angular y Quarkus.

### 1. Crear el backend intermedio, Inicializar el proyecto Spring Boot

**Prompt sugerido:**

```text
Crea un proyecto Spring Boot 3.3.x (Java 21) para la carpeta middle.

Debe incluir:
- endpoint GET /health
- endpoint GET /middle/personas?idTipo=&idValor=
- endpoint GET /middle/personas/{id}
- POST/PUT/DELETE para /middle/personas
- cliente HTTP a Quarkus con timeout configurable
- transformación de datos: idTipo->idType, idValor->idValue, telefono->phone, fechaNacimiento->birthDate
- manejo de errores 400, 404 y 503
```

### 2. Corrobora la Configuración

**Prompt sugerido:**

```text
Corrobora y duvuelve la configuración en el archivo "application.properties", el mismo debe tener estas y otras configuraciones extras si es necesario:

server.port=3000
quarkus.api.url=${QUARKUS_API_URL:http://localhost:8080}
quarkus.api.timeout-ms=${API_TIMEOUT:5000}
```

### 4. Ejecutar el middle

**Prompt sugerido:**

```text
Ejecuta el middle, para corroborar su funcionamiento con el siguiente comando en la carpeta indicada:

mvn spring-boot:run
```

### Resultado esperado

- Servicio Spring Boot respondiendo en `http://localhost:3000/health`.
- Endpoint `/middle/personas` funcionando como BFF hacia Quarkus.
- Respuesta transformada a camelCase para Angular.

---

## 🔶 Paso 4. Crear el frontend con Angular

Llegó el momento de construir la capa visible para el usuario. Aquí vas a conectar la experiencia completa de búsqueda con Angular.

### 1. Crear el proyecto Angular

**Prompt sugerido:**

```text
Genera la base del frontend con Angular standalone con el siguiente comando en la carpeta frontend:

npx @angular/cli@18 new . --skip-git --standalone --style=scss
```

### 2. Crear el servicio `PersonaService`

**Prompt sugerido:**

```text
Crea un servicio Angular llamado PersonaService que:
- use HttpClient
- consuma http://localhost:3000/middle/personas
- tenga un método buscarPersona(idTipo, idValor)
- defina una interfaz Persona con id, fullName, idType, idValue, email, phone y birthDate
```

La intención es que el frontend consuma un modelo limpio y consistente, sin conocer detalles internos del backend original.

### 3. Crear componente de búsqueda

**Prompt sugerido:**

```text
Crea un componente Angular standalone llamado SearchFormComponent que:
- tenga un select para tipo de identificación con DNI, RUT y Pasaporte
- tenga un input para el número de identificación
- tenga botones Buscar y Limpiar
- emita eventos search y clear
- use FormsModule y ngModel
```

Piensa este componente como la entrada principal de la experiencia hands-on: es lo primero que el usuario toca y lo primero que vas a poder demostrar.

### 4. Crear componente de detalle

**Prompt sugerido:**

```text
Crea un componente Angular standalone llamado PersonaDetailComponent que:
- reciba una persona como @Input()
- muestre los datos en formato amigable
- muestre un mensaje cuando no haya resultados
- calcule la edad desde la fecha de nacimiento
```

Aquí conviene pedirle a Copilot una vista simple pero clara, fácil de leer en una demo en vivo.

### 5. Armar el componente principal

**Prompt sugerido:**

```text
Crea el AppComponent de Angular para esta aplicación de búsqueda de personas.

Debe:
- usar SearchFormComponent y PersonaDetailComponent
- manejar estados persona, loading, error y searched
- llamar a PersonaService cuando el usuario busque
- mostrar spinner mientras carga
- mostrar error cuando no se encuentre la persona
```

Si Copilot separa bien los estados de loading, error y éxito, vas por buen camino. Esa separación hace que la demo final sea mucho más clara.

### 6. Aplicar estilos globales

**Prompt sugerido:**

```text
Crea estilos globales SCSS para una app de workshop con:
- layout limpio y profesional
- cards
- botones primarios y secundarios
- formularios
- tabla o ficha de detalle
- colores institucionales azul y gris
- responsive design básico
```

No necesitas una UI compleja. Para esta actividad, prioriza legibilidad, orden visual y una experiencia fluida para la demostración.

### Resultado esperado

- SPA Angular creada.
- Servicio HTTP listo.
- Formulario de búsqueda implementado.
- Vista de detalle conectada al resultado del BFF.

---

## ✅ Paso 5. Integrar y validar la app

En este último tramo, la meta es comprobar que todo lo que construiste conversa correctamente entre capas.

### Prompt sugerido para validación con Copilot

```text
Revisa esta aplicación fullstack y explícame el flujo completo desde el formulario Angular hasta la API Quarkus, incluyendo el rol del BFF en Spring Boot y la transformación de datos. Utiliza algunos de estos comandos, en cada una de las carpetas indicadas, si lo crees necesario:

para "/api": mvn clean package
para "/middle": mvn clean package
para "/frontend": npm install
```

Necesitamos utilizarlo final de la práctica para reforzar el entendimiento técnico del grupo, no solo para validar que “funciona”.

### Escenario funcional esperado

1. El usuario ingresa un `idTipo` y un `idValor` en Angular.
2. Angular llama al BFF en `/middle/personas`.
3. Spring Boot consulta a Quarkus en `/api/personas/search`.
4. El BFF transforma la respuesta a camelCase.
5. Angular renderiza la persona encontrada o un mensaje de error.

Si este flujo se cumple, la actividad hands-on está lograda.

---

## 🎓 Tópicos Avanzados

Después de construir la aplicación funcional, explora estos tópicos para profundizar en el uso de GitHub Copilot y mejorar la calidad del código.

### 6.1 Desarrollo Guiado por Comentarios

Esta técnica aprovecha el poder de Copilot para generar código a partir de comentarios descriptivos. Es especialmente útil cuando necesitas que el código sea legible y autodocumentado.

**Concepto:**
Añade comentarios claros y descriptivos en tu código. Copilot los leerá y propondrá implementaciones que se alineen con tu descripción.

**Ejemplo en PersonaResource (Quarkus):**

```java
// Buscar una persona por tipo y número de identificación
// Si no encuentra la persona, retorna 404
// Si hay error de base de datos, retorna 500
public Response searchPersona(@QueryParam("idTipo") String idTipo, @QueryParam("idValor") String idValor) {
    // Copilot generará la lógica aquí basándose en el comentario anterior
}
```

**Ventajas:**
- Código autodocumentado
- Especificaciones claras para Copilot

---

### 6.2 GitHub Copilot CLI

La Copilot CLI permite usar Copilot directamente desde la terminal. Úsala para generar comandos, explicar errores, o sugerir mejoras sin abandonar la línea de comandos.

**Instalación:**

```powershell
npm install -g @github-copilot/cli
```

**Comandos útiles:**

#### Generar un comando shell

```powershell
copilot explain "¿Cómo compilo un proyecto Maven con soporte para PostgreSQL?"
```

Copilot te sugerirá algo como:

```powershell
mvn clean package -DskipTests -Dquarkus.package.type=uber-jar
```

#### Explicar un error de compilación

Si tu compilación falla:

```powershell
copilot explain "ERROR: Package com.forum.workshop.entity not found"
```

Copilot puede sugerirte que faltan dependencias en el pom.xml.

#### Generar un comando npm

```powershell
copilot explain "¿Cómo instalo las dependencias del BFF y corro el servidor en modo desarrollo?"
```

Sugerencia:

```powershell
npm install && npm run dev
```

#### Explicar un error de Angular

```powershell
copilot explain "ERROR in ./src/app/app.component.ts: Cannot find module '@angular/forms'"
```

Copilot puede indicarte que necesitas importar FormsModule en el componente.

**Caso de uso:**

Cuando los alguno de los participantes encuentren errores durante la construcción, pueden usar Copilot CLI para obtener explicaciones rápidas sin pausar su trabajo.

---

### 6.3 Refactorización y Optimización

Después de que el código "funciona", mejorarlo es un paso natural. Copilot puede sugerir optimizaciones de rendimiento, legibilidad y mantenibilidad.

**Ejemplo: Optimizar el controlador de Spring Boot**

**Código original (sin optimizar):**

```java
@RestController
@RequestMapping("/middle/personas")
public class MiddleController {
    @GetMapping
    public ResponseEntity<MiddlePersonaResponse> search(
            @RequestParam String idTipo,
            @RequestParam String idValor) {
        try {
            QuarkusPersonaResponse response = gateway.search(idTipo, idValor);
            MiddlePersonaResponse transformed = new MiddlePersonaResponse(
                response.id,
                response.nombres + " " + response.apellidos,
                response.idTipo,
                response.idValor,
                response.email,
                response.telefono,
                response.fechaNacimiento
            );
            return ResponseEntity.ok(transformed);
        } catch (Exception ex) {
            return ResponseEntity.status(500).body(null);
        }
    }
}
```

**Prompt sugerido para Copilot:**

```text
Tengo este controlador Spring Boot que busca personas. Sugiere mejoras para:
1. Evitar repetición de código en la transformación de datos
2. Mejorar el manejo de errores (diferenciar 404, 400, 503)
3. Agregar validación de parámetros con @NotBlank
4. Usar un servicio separado para la transformación
5. Hacer el código más legible y mantenible

[pega el código o haz una referencia al archivo y lineas de codigo]
```

**Resultado esperado:**
Copilot sugerirá:
- Mover la transformación a un método en PersonaGatewayService
- Usar @NotBlank y @Validated
- Usar @RestControllerAdvice para manejo centralizado de errores
- Separar lógica de negocio en capas (Controller → Service → Gateway)
- Agregar logging con SLF4J

---

### 6.4 Pruebas Unitarias

No vamos a ejecutar pruebas en este workshop, pero generarlas con Copilot es una excelente forma de entender la cobertura de código necesaria y la estructura de pruebas.

**Ejemplo: Generar pruebas para PersonaService (Angular)**

**Prompt sugerido:**

```text
Genera pruebas unitarias para este servicio Angular:

[pega PersonaService o haz una referencia al archivo y lineas de codigo]

Las pruebas deben:
1. Verificar que buscarPersona() llama al endpoint correcto
2. Verificar que la respuesta se mapea a la interfaz Persona correctamente
3. Verificar el manejo de errores cuando el servidor retorna 404
4. Verificar el manejo de errores cuando hay timeout

Usa jasmine y karma.
```

**Ejemplo: Generar pruebas para PersonaResource (Quarkus)**

**Prompt sugerido:**

```text
Genera pruebas unitarias para este recurso Quarkus:

[pega PersonaResource o haz una referencia al archivo y lineas de codigo]

Las pruebas deben:
1. Verificar que GET /api/personas/search con parámetros válidos retorna 200
2. Verificar que GET /api/personas/search sin parámetros retorna 400
3. Verificar que GET /api/personas/search con DNI inexistente retorna 404
4. Verificar que POST /api/personas crea una nueva persona

Usa JUnit 5 y Quarkus @QuarkusTest.
```

**Ventaja educativa:**
- Aprendes qué casos de prueba son importantes
- Entiendes la estructura de pruebas sin ejecutarlas
- Identificas gaps en la cobertura de código

---

### 6.5 Detección y Mitigación de Vulnerabilidades

Copilot puede ayudarte a identificar vulnerabilidades de seguridad comunes y sugerir mitigaciones. Este es un paso crítico antes de llevar la app a producción.

**Ejemplo: Auditar el middleware de Spring Boot**

**Prompt sugerido:**

```text
Revisa el código del controlador del middle (Spring Boot) y detecta vulnerabilidades de seguridad:

Específicamente:
1. ¿Hay protección contra inyección de SQL?
2. ¿Hay validación de entrada?
3. ¿Está habilitada la compresión?
4. ¿Hay límites de rate limiting?
5. ¿Los headers de seguridad HTTP están configurados?
6. ¿Se logean errores sensibles?
```

**Mitigaciones típicas que Copilot puede sugerir:**

```java
// 1. Validación de parámetros de entrada
@GetMapping("/middle/personas")
public ResponseEntity<?> search(
    @RequestParam @NotBlank String idTipo,
    @RequestParam @NotBlank String idValor) {
  // ...
}

// 2. No exponer detalles de errores internos
@ExceptionHandler(Exception.class)
public ResponseEntity<Map<String, String>> handleAny(Exception ex) {
  return ResponseEntity.status(500).body(Map.of("error", "Error interno del servidor"));
}
```

**Ejemplo: Auditar la entidad Persona (Quarkus)**

**Prompt sugerido:**

```text
Revisa la entidad Persona JPA y detecta vulnerabilidades de seguridad:

[pega Persona.java o haz una referencia al archivo]

Específicamente:
1. ¿Hay validación de campos (NotNull, Size, etc.)?
2. ¿Se valida el email?
3. ¿Se valida el rango de fechaNacimiento?
4. ¿Hay protección contra inyección SQL (usando Panache)?
5. ¿Los campos sensibles están marcados con @JsonIgnore si es necesario?
```

**Validaciones que Copilot sugiere agregar:**

```java
import jakarta.validation.constraints.*;

@Entity
public class Persona extends PanacheEntity {
  @NotBlank(message = "idTipo es requerido")
  @Pattern(regexp = "DNI|RUT|Pasaporte")
  public String idTipo;
  
  @NotBlank(message = "idValor es requerido")
  @Size(min = 3, max = 20)
  public String idValor;
  
  @NotBlank(message = "nombres es requerido")
  @Size(min = 2, max = 100)
  public String nombres;
  
  @Email(message = "email debe ser válido")
  public String email;
  
  @Past(message = "fechaNacimiento debe ser en el pasado")
  public LocalDate fechaNacimiento;
}
```

---

## 💡 Prompts sugeridos

Estos prompts sirven como apoyo rápido durante el workshop. Podemos utilizarlos tal cual o ajustarlos según sea necesario.

### Prompt para mejorar backend (Quarkus)

```text
Revisa mi clase PersonaResource y sugiéreme mejoras para:
1. Manejo de errores con códigos HTTP correctos
2. Validación de parámetros de entrada
3. Legibilidad del código
4. Respuestas HTTP consistentes
```

### Prompt para mejorar BFF (Spring Boot)

```text
Revisa mi controlador MiddleController y servicio PersonaGatewayService y sugiere mejoras para:
1. Transformación de datos consistente
2. Manejo de errores centralizado
3. Validación de entrada
4. Logging y debugging
```

### Prompt para mejorar frontend

```text
Revisa mi AppComponent y mis componentes Angular para que la búsqueda muestre estados de loading, éxito y error de manera clara y profesional.
```

---

<div align="center">

**La meta de esta sesión hands-on es construir una app real, entender cómo se conectan sus capas, aprender a trabajar con GitHub Copilot de forma práctica, y explorar técnicas avanzadas para código de mayor calidad.**

</div>


