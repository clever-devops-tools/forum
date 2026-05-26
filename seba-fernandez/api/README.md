# API (Quarkus)

Backend REST para Personas.

## Archivos principales

- pom.xml: dependencias y build de Quarkus.
- src/main/resources/application.properties: puerto, datasource PostgreSQL, CORS.
- src/main/java/.../domain/Persona.java: entidad JPA/Panache.
- src/main/java/.../resource/PersonaResource.java: endpoints CRUD + search + health.
- src/main/java/.../dto/: contratos de entrada/salida.
- src/test/java/...: pruebas de recursos y repositorios.
