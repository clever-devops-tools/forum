# Middle (Spring Boot BFF)

Capa intermedia entre Angular y Quarkus.

## Archivos principales

- pom.xml: dependencias de Spring Boot.
- src/main/resources/application.properties: puerto 3000, URL/timeout de API.
- src/main/java/.../controller/PersonaController.java: endpoints del BFF.
- src/main/java/.../service/PersonaService.java: orquestacion y reglas.
- src/main/java/.../client/ApiClient.java: cliente HTTP hacia Quarkus.
- src/main/java/.../dto/: request/response para frontend.
- src/main/java/.../mapper/: transformaciones snake_case -> camelCase.
- src/test/java/...: pruebas de controladores y servicios.
