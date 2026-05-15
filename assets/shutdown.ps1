<#
.SYNOPSIS
    Detiene todos los servicios del Workshop Fullstack.
.DESCRIPTION
    Detiene:
    - Jobs iniciados por startup.ps1 (forum-api, forum-middle, forum-frontend)
    - Procesos remanentes en puertos 4200, 3000 y 8080
    - PostgreSQL en Docker Compose
.EXAMPLE
    .\shutdown.ps1
#>

$ErrorActionPreference = "Continue"

function Stop-PortProcess {
    param(
        [int]$Port,
        [string]$Label
    )

    $listener = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $listener) {
        return
    }

    $owningPid = $listener.OwningProcess
    $proc = Get-Process -Id $owningPid -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Host "  Parando $Label (PID: $owningPid)" -ForegroundColor Gray
        Stop-Process -Id $owningPid -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║         FORUM WORKSHOP - SHUTDOWN LOCAL ENVIRONMENT          ║" -ForegroundColor Yellow
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow

Write-Host "`n[1/3] Deteniendo jobs del workshop..." -ForegroundColor Cyan

$jobNames = @("forum-api", "forum-middle", "forum-frontend")
foreach ($name in $jobNames) {
    $job = Get-Job -Name $name -ErrorAction SilentlyContinue
    if ($job) {
        Write-Host "  Eliminando job: $name" -ForegroundColor Gray
        Stop-Job -Name $name -ErrorAction SilentlyContinue
        Remove-Job -Name $name -ErrorAction SilentlyContinue
    }
}

Write-Host "`n[2/3] Liberando puertos de servicios locales..." -ForegroundColor Cyan
Stop-PortProcess -Port 4200 -Label "Angular Frontend"
Stop-PortProcess -Port 3000 -Label "Spring Boot Middle"
Stop-PortProcess -Port 8080 -Label "Quarkus API"

Write-Host "`n[3/3] Deteniendo PostgreSQL en Docker Compose..." -ForegroundColor Cyan

$assetsDir = $PSScriptRoot
$dockerDir = Join-Path $assetsDir "nuevosrepos\docker"

if (Test-Path $dockerDir) {
    Set-Location $dockerDir
    & docker compose down | Out-Host
    Write-Host "  ✓ Containers detenidos" -ForegroundColor Green
} else {
    Write-Host "  ⚠ No se encontró carpeta docker esperada: $dockerDir" -ForegroundColor Yellow
}

Write-Host "`n╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                 ✓ SERVICIOS DETENIDOS                        ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`nPara volver a levantar todo:" -ForegroundColor Yellow
Write-Host "  .\startup.ps1"
