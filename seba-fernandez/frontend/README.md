# Frontend (Angular)

SPA para busqueda de personas.

## Ejecutar

1. `npm install`
2. `npm start`

La app levanta con Angular standalone y consulta el middle en `http://localhost:3000/middle/personas`.

## Archivos principales

- package.json: scripts y dependencias.
- angular.json, tsconfig.json: configuracion del proyecto.
- src/main.ts: bootstrap de la app.
- src/app/app.component.ts: contenedor principal.
- src/app/core/services/persona.service.ts: consumo de BFF.
- src/app/features/personas/models/persona.model.ts: modelo de dominio.
- src/app/features/personas/components/search-form.component.ts: formulario de busqueda.
- src/app/features/personas/components/persona-detail.component.ts: visualizacion de resultado.
