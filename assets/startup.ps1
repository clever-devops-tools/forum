#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Levanta el ambiente completo del Workshop Fullstack - Forum App (Windows)
.DESCRIPTION
    Script que inicia todos los servicios necesarios:
    - PostgreSQL (Docker)
    - Quarkus API (puerto 8080)
    - Spring Boot Middle (puerto 3000)
    - Angular Frontend (puerto 4200)
.EXAMPLE
    .\startup.ps1
#>

param(
    [switch]$NoWait = $false  # Si $true, no espera a que se complete cada servicio
)

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

Write-Host "
╔═══════════════════════════════════════════════════════════════╗
║         FORUM WORKSHOP - STARTUP LOCAL ENVIRONMENT           ║
║                    Fullstack App (Spring Boot)               ║
╚═══════════════════════════════════════════════════════════════╝
" -ForegroundColor Cyan

# Rutas
$rootDir = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
$infraDir = Join-Path $rootDir "infra"
$apiDir = Join-Path $rootDir "api"
$middleDir = Join-Path $rootDir "middle"
$frontendDir = Join-Path $rootDir "frontend"

# Java & Maven
$javaHome = "C:\Program Files\Amazon Corretto\jdk21.0.11_10"
$mvnCmd = "C:\Program Files\JetBrains\IntelliJ IDEA 2024.2.4\plugins\maven\lib\maven3\bin\mvn.cmd"

Write-Host "`n[1/4] Verificando herramientas necesarias..." -ForegroundColor Yellow

# Verificar docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "✗ Docker no encontrado. Instálalo desde https://www.docker.com/" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Docker disponible" -ForegroundColor Green

# Verificar node/npm
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "✗ Node.js no encontrado. Instálalo desde https://nodejs.org/" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Node.js disponible ($(node -v))" -ForegroundColor Green

# Verificar Java
if (-not (Test-Path $javaHome)) {
    Write-Host "✗ Java 21 no encontrado en $javaHome" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Java 21 disponible" -ForegroundColor Green

# Verificar Maven
if (-not (Test-Path $mvnCmd)) {
    Write-Host "✗ Maven no encontrado en $mvnCmd" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Maven disponible" -ForegroundColor Green

# Variables de entorno
$env:JAVA_HOME = $javaHome
$env:Path = "$javaHome\bin;$env:Path"

Write-Host "`n[2/4] Iniciando servicios de infraestructura (Docker)..." -ForegroundColor Yellow

Set-Location $infraDir
$dockerStatus = & docker compose ps --format "{{.Names}},{{.Status}}" 2>/dev/null | Select-String "postgres-app"

if ($dockerStatus) {
    $isRunning = $dockerStatus -match "running"
    if ($isRunning) {
        Write-Host "✓ PostgreSQL ya está corriendo" -ForegroundColor Green
    } else {
        Write-Host "Iniciando PostgreSQL..." -ForegroundColor Cyan
        & docker compose up -d postgres-app postgres-bitbucket 2>&1 | Where-Object { $_ -match "Up|running" }
        Start-Sleep -Seconds 5
        Write-Host "✓ PostgreSQL iniciado" -ForegroundColor Green
    }
} else {
    Write-Host "Iniciando PostgreSQL..." -ForegroundColor Cyan
    & docker compose up -d postgres-app postgres-bitbucket 2>&1 | Where-Object { $_ -match "Up|running|created" }
    Start-Sleep -Seconds 10
    Write-Host "✓ PostgreSQL iniciado" -ForegroundColor Green
}

Write-Host "`n[3/4] Iniciando Quarkus API..." -ForegroundColor Yellow
Set-Location $apiDir

$apiJob = Start-Job -ScriptBlock {
    param($javaHome, $mvnCmd, $apiDir)
    $env:JAVA_HOME = $javaHome
    $env:Path = "$javaHome\bin;$env:Path"
    Set-Location $apiDir
    & $mvnCmd quarkus:dev 2>&1
} -ArgumentList $javaHome, $mvnCmd, $apiDir

Write-Host "  ⧖ Quarkus iniciando en background..." -ForegroundColor Cyan

# Esperar a que Quarkus esté listo
$maxWait = 120
$waited = 0
while ($waited -lt $maxWait) {
    $apiReady = $false
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/q/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $apiReady = $true
        }
    } catch { }
    
    if ($apiReady) {
        Write-Host "✓ Quarkus API activa (http://localhost:8080)" -ForegroundColor Green
        break
    }
    Start-Sleep -Seconds 2
    $waited += 2
}

if (-not $apiReady) {
    Write-Host "⚠ Quarkus tardó más de 2 minutos en iniciar. Revisa logs en otra ventana." -ForegroundColor Yellow
}

Write-Host "`n[4/4] Iniciando Spring Boot Middle y Angular Frontend..." -ForegroundColor Yellow

# Middle Spring Boot
$middleJob = Start-Job -ScriptBlock {
    param($javaHome, $mvnCmd, $middleDir)
    $env:JAVA_HOME = $javaHome
    $env:Path = "$javaHome\bin;$env:Path"
    Set-Location $middleDir
    & $mvnCmd spring-boot:run 2>&1
} -ArgumentList $javaHome, $mvnCmd, $middleDir

Write-Host "  ⧖ Spring Boot Middle iniciando en background..." -ForegroundColor Cyan

# Esperar a que Middle esté listo
$maxWait = 60
$waited = 0
while ($waited -lt $maxWait) {
    $middleReady = $false
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $middleReady = $true
        }
    } catch { }
    
    if ($middleReady) {
        Write-Host "✓ Spring Boot Middle activo (http://localhost:3000)" -ForegroundColor Green
        break
    }
    Start-Sleep -Seconds 2
    $waited += 2
}

if (-not $middleReady) {
    Write-Host "⚠ Middle tardó más de 1 minuto en iniciar. Revisa logs en otra ventana." -ForegroundColor Yellow
}

# Frontend Angular
Set-Location $frontendDir
Write-Host "  ⧖ Instalando dependencias del frontend..." -ForegroundColor Cyan
if (-not (Test-Path "node_modules")) {
    & npm install 2>&1 | Out-Null
}

$frontJob = Start-Job -ScriptBlock {
    param($frontendDir)
    Set-Location $frontendDir
    & npm start 2>&1
} -ArgumentList $frontendDir

Write-Host "  ⧖ Angular iniciando en background..." -ForegroundColor Cyan

# Esperar a que Angular esté listo
$maxWait = 60
$waited = 0
while ($waited -lt $maxWait) {
    $frontReady = $false
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:4200" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $frontReady = $true
        }
    } catch { }
    
    if ($frontReady) {
        Write-Host "✓ Angular Frontend activo (http://localhost:4200)" -ForegroundColor Green
        break
    }
    Start-Sleep -Seconds 2
    $waited += 2
}

if (-not $frontReady) {
    Write-Host "⚠ Frontend tardó más de 1 minuto en iniciar. Revisa logs en otra ventana." -ForegroundColor Yellow
}

Write-Host "`n
╔═══════════════════════════════════════════════════════════════╗
║                   ✓ AMBIENTE LISTO                           ║
╚═══════════════════════════════════════════════════════════════╝
" -ForegroundColor Green

Write-Host "
URLs de acceso:
  📱 Frontend:       http://localhost:4200
  🔌 API Quarkus:    http://localhost:8080
  🌉 Middle (BFF):   http://localhost:3000
  🗄️  PostgreSQL:     localhost:5432 (appuser/apppass)

Endpoints principales:
  🔍 Búsqueda:  http://localhost:3000/middle/personas?idTipo=DNI&idValor=12345678
  💚 Health:    http://localhost:3000/health

Procesos activos:
" -ForegroundColor Cyan

Get-Job | Format-Table -Property Id, Name, State -AutoSize

Write-Host "`nPara detener los servicios, ejecuta en otra terminal:" -ForegroundColor Yellow
Write-Host "  .\shutdown.ps1" -ForegroundColor White

Write-Host "`nPara ver logs en tiempo real:" -ForegroundColor Yellow
Write-Host "  - Quarkus:    Get-Job -Name *Quarkus* | Receive-Job -Keep" -ForegroundColor Cyan
Write-Host "  - Middle:     Get-Job -Name *Middle* | Receive-Job -Keep" -ForegroundColor Cyan
Write-Host "  - Frontend:   Get-Job -Name *Frontend* | Receive-Job -Keep" -ForegroundColor Cyan

Write-Host "`n✓ Script completado. Los servicios seguirán corriendo en background." -ForegroundColor Green
Write-Host "  Presiona Ctrl+C para volver al prompt (los procesos continuarán activos)." -ForegroundColor Gray

Read-Host "`nPresiona Enter para mantener esta ventana abierta o ciérala para continuar"
