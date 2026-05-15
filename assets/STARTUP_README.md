# Scripts de Arranque del Workshop (Windows)

Este documento explica los prerequisitos y el uso de los scripts de [startup.ps1](startup.ps1) y [shutdown.ps1](shutdown.ps1) para levantar y apagar el ambiente local del workshop con un solo comando.

## Prerequisitos para asistentes (instalar antes del workshop)

Instala y valida esto con anticipacion:

1. Docker Desktop (con motor Docker Compose habilitado)
- Descarga: https://www.docker.com/products/docker-desktop
- Validacion:

```powershell
docker --version
docker compose version
```

2. Git
- Descarga: https://git-scm.com/download/win
- Validacion:

```powershell
git --version
```

3. Node.js LTS (recomendado v20+)
- Descarga: https://nodejs.org/
- Validacion:

```powershell
node -v
npm -v
```

4. Java 21
- Recomendado: Amazon Corretto 21
- Validacion:

```powershell
java -version
```

5. Maven (solo si el repo no trae mvnw.cmd en api o middle)
- Validacion:

```powershell
mvn -version
```

6. PowerShell con permisos para scripts
- Si aparece error de execution policy:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Estructura esperada del repositorio

Los scripts estan alineados a esta estructura:

- [nuevosrepos/docker/docker-compose.yml](nuevosrepos/docker/docker-compose.yml)
- [nuevosrepos/docker/init/01-schema-and-seed.sql](nuevosrepos/docker/init/01-schema-and-seed.sql)
- Carpeta api en la raiz del repo (opcional)
- Carpeta middle en la raiz del repo (opcional)
- Carpeta frontend en la raiz del repo (opcional)

Nota: si api, middle o frontend aun no existen, startup levanta igualmente PostgreSQL y continua sin fallar.

## Levantar todo con un comando

Desde la carpeta assets ejecuta:

```powershell
.\startup.ps1
```

Que hace startup:

1. Valida Docker y docker compose.
2. Levanta PostgreSQL desde [nuevosrepos/docker/docker-compose.yml](nuevosrepos/docker/docker-compose.yml).
3. Espera estado healthy de postgres-app.
4. Si existe api, inicia Quarkus en job forum-api.
5. Si existe middle, inicia Spring Boot en job forum-middle.
6. Si existe frontend, instala dependencias si hace falta e inicia Angular en job forum-frontend.

## Apagar todo con un comando

Desde la carpeta assets ejecuta:

```powershell
.\shutdown.ps1
```

Que hace shutdown:

1. Detiene jobs forum-api, forum-middle y forum-frontend.
2. Libera puertos 4200, 3000 y 8080.
3. Ejecuta docker compose down en [nuevosrepos/docker](nuevosrepos/docker).

## Verificacion rapida de base de datos

La base se inicializa automaticamente con [nuevosrepos/docker/init/01-schema-and-seed.sql](nuevosrepos/docker/init/01-schema-and-seed.sql).

Credenciales:

- Host: localhost
- Puerto: 5432
- Base: personasdb
- Usuario: appuser
- Password: apppass

Consulta de verificacion:

```powershell
docker exec postgres-app psql -U appuser -d personasdb -c "SELECT id_tipo, id_valor, nombres, apellidos FROM personas ORDER BY id_tipo, id_valor;"
```

## Monitoreo de logs

```powershell
Get-Job -Name forum-api | Receive-Job -Keep
Get-Job -Name forum-middle | Receive-Job -Keep
Get-Job -Name forum-frontend | Receive-Job -Keep
```

## Troubleshooting corto

1. Docker no responde
- Abre Docker Desktop y espera que este en estado Running.

2. Puerto ocupado
- Ejecuta [shutdown.ps1](shutdown.ps1) y vuelve a iniciar.

3. API/Middle no arrancan
- Verifica Java 21 y Maven o wrapper mvnw.cmd.

4. Frontend no arranca
- Verifica Node y npm.

5. Reintento limpio

```powershell
.\shutdown.ps1
.\startup.ps1
```
