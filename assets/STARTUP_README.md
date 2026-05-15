# 🚀 Scripts de Levantamiento del Ambiente - Forum Workshop

Scripts PowerShell para levantar/detener rápidamente todo el ambiente del workshop fullstack en **Windows 11**.

## Requisitos Previos

Asegúrate de tener instalado:

- ✅ **Docker Desktop** (con WSL2) → https://www.docker.com/products/docker-desktop
- ✅ **Node.js 20+** → https://nodejs.org/
- ✅ **Java 21** (Amazon Corretto) → instalado en `C:\Program Files\Amazon Corretto\jdk21.0.11_10`
- ✅ **Maven** (bundled en IntelliJ) → `C:\Program Files\JetBrains\IntelliJ IDEA 2024.2.4\plugins\maven\lib\maven3\bin\mvn.cmd`
- ✅ **Git** → https://git-scm.com/

## Uso Rápido

### 1. **Levantar Ambiente (PRIMER VEZ)**

```powershell
cd C:\Users\<tu-usuario>\forumcopilot\assets
.\startup.ps1
```

**¿Qué hace?**
1. Verifica herramientas necesarias (Docker, Node, Java, Maven)
2. Inicia PostgreSQL en Docker
3. Inicia Quarkus API (puerto 8080)
4. Inicia Spring Boot Middle (puerto 3000)
5. Instala y inicia Angular Frontend (puerto 4200)

### 2. **Acceder a los Servicios**

Una vez que el script termina, abre en tu navegador:

| Componente | URL | Descripción |
|------------|-----|-------------|
| **Frontend** | http://localhost:4200 | Interfaz de usuario Angular |
| **API Quarkus** | http://localhost:8080 | Backend REST con datos |
| **Middle (BFF)** | http://localhost:3000 | Backend for Frontend (Spring Boot) |
| **Búsqueda** | http://localhost:3000/middle/personas?idTipo=DNI&idValor=12345678 | Endpoint de ejemplo |
| **Health** | http://localhost:3000/health | Estado del middleware |

### 3. **Detener Ambiente**

```powershell
cd C:\Users\<tu-usuario>\forumcopilot\assets
.\shutdown.ps1
```

**¿Qué hace?**
- Detiene todos los procesos Java en background
- Libera puertos 3000, 8080, 4200
- Detiene Docker containers (PostgreSQL)

## Troubleshooting

### ❌ "Docker not found"
- Instala Docker Desktop desde https://www.docker.com/products/docker-desktop
- Reinicia PowerShell después de instalar

### ❌ "Java 21 not found"
- Verifica que esté instalado en `C:\Program Files\Amazon Corretto\jdk21.0.11_10`
- Si está en otra ruta, edita `startup.ps1` línea `$javaHome = "..."`

### ❌ "Maven not found"
- Instala IntelliJ IDEA o actualiza la ruta en `startup.ps1` línea `$mvnCmd = "..."`

### ❌ "Port 3000/8080 already in use"
- Ejecuta `.\shutdown.ps1` para liberar puertos
- O ejecuta en terminal: `netstat -ano | findstr :3000`

### ❌ "Scripts disabled" error
Si PowerShell no permite ejecutar scripts, abre PowerShell como **Administrador** y ejecuta:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Luego reintenta:
```powershell
.\startup.ps1
```

## Monitoreo en Tiempo Real

### Ver logs de Quarkus
```powershell
Get-Job -Name *api* | Receive-Job -Keep
```

### Ver logs de Middle (Spring Boot)
```powershell
Get-Job -Name *middle* | Receive-Job -Keep
```

### Ver logs de Frontend (Angular)
```powershell
Get-Job -Name *frontend* | Receive-Job -Keep
```

### Listar todos los jobs activos
```powershell
Get-Job
```

### Matar un job específico (si falla algo)
```powershell
Stop-Job -Name "<job-name>"
Remove-Job -Name "<job-name>"
```

## Configuración de Base de Datos

| Parámetro | Valor |
|-----------|-------|
| Host | localhost |
| Puerto | 5432 |
| Base de datos | personasdb |
| Usuario | appuser |
| Contraseña | apppass |

Para conectarse manualmente con psql:
```bash
psql -h localhost -U appuser -d personasdb
```

## Flujo de Datos (End-to-End)

```
┌─────────────────────────────────────────────────────────┐
│ Angular Frontend (http://localhost:4200)                │
│  "Buscar personas por DNI"                              │
└────────────────┬────────────────────────────────────────┘
                 │ GET /middle/personas?idTipo=DNI&idValor=...
                 ↓
┌─────────────────────────────────────────────────────────┐
│ Spring Boot Middle (http://localhost:3000)              │
│  - Recibe parámetros                                    │
│  - Transforma camelCase (idTipo → idType)               │
│  - Llama a Quarkus API                                  │
└────────────────┬────────────────────────────────────────┘
                 │ GET /api/personas/search?idTipo=DNI&idValor=...
                 ↓
┌─────────────────────────────────────────────────────────┐
│ Quarkus API (http://localhost:8080)                     │
│  - Consulta PostgreSQL                                  │
│  - Retorna JSON                                         │
└────────────────┬────────────────────────────────────────┘
                 │
                 ↓
┌─────────────────────────────────────────────────────────┐
│ PostgreSQL (localhost:5432)                             │
│  - Tabla: persona                                       │
│  - Registros: 3 personas de ejemplo                     │
└─────────────────────────────────────────────────────────┘
```

## Ejemplo de Búsqueda

1. Abre http://localhost:4200 en el navegador
2. Ingresa:
   - **Tipo ID**: DNI
   - **Valor**: 12345678
3. El frontend llama a `/middle/personas?idTipo=DNI&idValor=12345678`
4. Se devuelve:
```json
{
  "id": 1,
  "fullName": "Juan Perez",
  "idType": "DNI",
  "idValue": "12345678",
  "email": "juan@forum.cl",
  "phone": "+56912345678",
  "birthDate": "1990-05-10"
}
```

## Notas Importantes

- Los scripts usan **PowerShell 5.0+** (PowerShell Core no es necesario)
- Deben ejecutarse como **Administrador** (requerido para Docker)
- Los servicios se inician en **background jobs** (no bloquean la terminal)
- Para ver todos los logs juntos, abre 3 ventanas PowerShell separadas y en cada una corre:
  ```powershell
  Get-Job -Name "*api*" | Receive-Job -Keep -Wait
  ```

## Stack Tecnológico

| Capa | Tecnología | Puerto |
|------|-----------|--------|
| Frontend | Angular 18 + TypeScript | 4200 |
| BFF (Middle) | Spring Boot 3.3.2 | 3000 |
| API | Quarkus 3.8.1 | 8080 |
| Base de Datos | PostgreSQL 15 | 5432 |
| Orquestación | Docker Compose | - |

## Soporte

Si algo falla:
1. Revisa los logs (ver sección "Monitoreo en Tiempo Real")
2. Ejecuta `.\shutdown.ps1` y limpia
3. Reintenta `.\startup.ps1`
4. Si persiste, verifica que Docker esté corriendo: `docker ps`

---

**Creado**: Mayo 2026  
**Stack**: Spring Boot Migration (Express → Spring Boot)  
**Autor**: Forum Workshop Team
