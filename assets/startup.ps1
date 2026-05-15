<#
.SYNOPSIS
    Levanta el ambiente completo del Workshop Fullstack - Forum App (Windows).
.DESCRIPTION
    Inicia PostgreSQL por Docker Compose y, si existen, también:
    - Quarkus API (puerto 8080)
    - Spring Boot Middle (puerto 3000)
    - Angular Frontend (puerto 4200)

    Diseñado para la estructura actual del repo:
    - assets/nuevosrepos/docker/docker-compose.yml
    - api/
    - middle/
    - frontend/
.EXAMPLE
    .\startup.ps1
#>

param(
    [switch]$NoWait = $false
)

$ErrorActionPreference = "Stop"

function Test-Tool {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Wait-HttpReady {
    param(
        [string]$Url,
        [int]$MaxWaitSeconds = 90
    )

    $elapsed = 0
    while ($elapsed -lt $MaxWaitSeconds) {
        try {
            $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
            if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500) {
                return $true
            }
        } catch {
            # Sigue esperando hasta timeout.
        }
        Start-Sleep -Seconds 2
        $elapsed += 2
    }

    return $false
}

function Start-ServiceJob {
    param(
        [string]$JobName,
        [string]$ServiceDir,
        [string]$Command,
        [string[]]$Arguments
    )

    $existing = Get-Job -Name $JobName -ErrorAction SilentlyContinue
    if ($existing) {
        Stop-Job -Name $JobName -ErrorAction SilentlyContinue
        Remove-Job -Name $JobName -ErrorAction SilentlyContinue
    }

    return Start-Job -Name $JobName -ScriptBlock {
        param($Dir, $Exe, $Args)
        Set-Location $Dir
        & $Exe @Args 2>&1
    } -ArgumentList $ServiceDir, $Command, $Arguments
}

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         FORUM WORKSHOP - STARTUP LOCAL ENVIRONMENT           ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Rutas basadas en la estructura actual del repositorio.
$assetsDir = $PSScriptRoot
$repoRoot = Split-Path -Parent $assetsDir
$dockerDir = Join-Path $assetsDir "nuevosrepos\docker"
$apiDir = Join-Path $repoRoot "api"
$middleDir = Join-Path $repoRoot "middle"
$frontendDir = Join-Path $repoRoot "frontend"

Write-Host "`n[1/4] Validando prerequisitos..." -ForegroundColor Yellow

if (-not (Test-Tool -Name "docker")) {
    Write-Host "✗ Docker no encontrado. Instálalo desde https://www.docker.com/products/docker-desktop" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $dockerDir)) {
    Write-Host "✗ No se encontró la carpeta Docker esperada: $dockerDir" -ForegroundColor Red
    exit 1
}

try {
    $null = & docker compose version
} catch {
    Write-Host "✗ docker compose no está disponible. Revisa tu instalación de Docker Desktop." -ForegroundColor Red
    exit 1
}

Write-Host "✓ Docker y docker compose disponibles" -ForegroundColor Green

Write-Host "`n[2/4] Iniciando PostgreSQL (Docker Compose)..." -ForegroundColor Yellow
Set-Location $dockerDir

try {
    & docker compose up -d postgres-app | Out-Host
} catch {
    Write-Host "⚠ Falló el primer intento de levantar postgres-app. Reintentando..." -ForegroundColor Yellow
    & docker compose up -d postgres-app | Out-Host
}

if (-not $NoWait) {
    $status = ""
    $tries = 0
    while ($tries -lt 30) {
        try {
            $status = (& docker inspect -f "{{.State.Health.Status}}" postgres-app 2>$null).Trim()
        } catch {
            $status = ""
        }

        if ($status -eq "healthy") {
            break
        }

        Start-Sleep -Seconds 2
        $tries++
    }

    if ($status -eq "healthy") {
        Write-Host "✓ PostgreSQL healthy" -ForegroundColor Green
    } else {
        Write-Host "⚠ PostgreSQL no reportó estado healthy a tiempo. Revisa: docker compose ps" -ForegroundColor Yellow
    }
}

Write-Host "`n[3/4] Iniciando API y Middle (si existen)..." -ForegroundColor Yellow

if (Test-Path $apiDir) {
    $apiMvnw = Join-Path $apiDir "mvnw.cmd"
    if (Test-Path $apiMvnw) {
        Start-ServiceJob -JobName "forum-api" -ServiceDir $apiDir -Command $apiMvnw -Arguments @("quarkus:dev") | Out-Null
        Write-Host "✓ Job forum-api iniciado" -ForegroundColor Green
    } elseif (Test-Tool -Name "mvn") {
        Start-ServiceJob -JobName "forum-api" -ServiceDir $apiDir -Command "mvn" -Arguments @("quarkus:dev") | Out-Null
        Write-Host "✓ Job forum-api iniciado" -ForegroundColor Green
    } else {
        Write-Host "⚠ Se encontró api/, pero no mvnw.cmd ni mvn en PATH. API no iniciada." -ForegroundColor Yellow
    }

    if (-not $NoWait) {
        if (Wait-HttpReady -Url "http://localhost:8080/q/health" -MaxWaitSeconds 120) {
            Write-Host "✓ API disponible en http://localhost:8080" -ForegroundColor Green
        } else {
            Write-Host "⚠ API no respondió en /q/health dentro del tiempo esperado." -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "ℹ Carpeta api/ no existe todavía. Se omite arranque de Quarkus." -ForegroundColor Cyan
}

if (Test-Path $middleDir) {
    try {
        & docker compose up -d middle-app | Out-Host
    } catch {
        Write-Host "⚠ Falló el primer intento de levantar middle-app. Reintentando..." -ForegroundColor Yellow
        & docker compose up -d middle-app | Out-Host
    }

    if (-not $NoWait) {
        if (Wait-HttpReady -Url "http://localhost:3000/health" -MaxWaitSeconds 120) {
            Write-Host "✓ Middle disponible en http://localhost:3000" -ForegroundColor Green
        } else {
            Write-Host "⚠ Middle no respondió en /health dentro del tiempo esperado." -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "ℹ Carpeta middle/ no existe todavía. Se omite arranque de Spring Boot." -ForegroundColor Cyan
}

Write-Host "`n[4/4] Iniciando Frontend (si existe)..." -ForegroundColor Yellow

if (Test-Path $frontendDir) {
    try {
        & docker compose up -d frontend-app | Out-Host
    } catch {
        Write-Host "⚠ Falló el primer intento de levantar frontend-app. Reintentando..." -ForegroundColor Yellow
        & docker compose up -d frontend-app | Out-Host
    }

    if (-not $NoWait) {
        if (Wait-HttpReady -Url "http://localhost:4200" -MaxWaitSeconds 120) {
            Write-Host "✓ Frontend disponible en http://localhost:4200" -ForegroundColor Green
        } else {
            Write-Host "⚠ Frontend no respondió en http://localhost:4200 dentro del tiempo esperado." -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "ℹ Carpeta frontend/ no existe todavía. Se omite arranque de Angular." -ForegroundColor Cyan
}

Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                   ✓ AMBIENTE LEVANTADO                       ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nURLs esperadas:" -ForegroundColor Cyan
Write-Host "  Frontend:     http://localhost:4200"
Write-Host "  API Quarkus:  http://localhost:8080"
Write-Host "  Middle:       http://localhost:3000"
Write-Host "  PostgreSQL:   localhost:5432 (appuser/apppass)"

Write-Host "`nJobs activos:" -ForegroundColor Cyan
Get-Job -Name "forum-*" -ErrorAction SilentlyContinue | Format-Table -Property Id, Name, State -AutoSize

Write-Host "`nPara apagar todo:" -ForegroundColor Yellow
Write-Host "  .\shutdown.ps1"

Write-Host "`nPara ver logs:" -ForegroundColor Yellow
Write-Host "  Get-Job -Name forum-api | Receive-Job -Keep"
Write-Host "  Get-Job -Name forum-middle | Receive-Job -Keep"
Write-Host "  Get-Job -Name forum-frontend | Receive-Job -Keep"
