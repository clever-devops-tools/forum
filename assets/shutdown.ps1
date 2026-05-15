#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Detiene todos los servicios del Workshop Fullstack
.DESCRIPTION
    Script que detiene:
    - Procesos Java (Quarkus, Spring Boot)
    - Docker containers (PostgreSQL)
.EXAMPLE
    .\shutdown.ps1
#>

Write-Host "
╔═══════════════════════════════════════════════════════════════╗
║         FORUM WORKSHOP - SHUTDOWN LOCAL ENVIRONMENT          ║
╚═══════════════════════════════════════════════════════════════╝
" -ForegroundColor Yellow

Write-Host "`n[1/3] Deteniendo procesos de background jobs..." -ForegroundColor Cyan
Get-Job | ForEach-Object {
    Write-Host "  Eliminando job: $($_.Name)" -ForegroundColor Gray
    Stop-Job -Job $_ -ErrorAction SilentlyContinue
    Remove-Job -Job $_ -ErrorAction SilentlyContinue
}

Write-Host "`n[2/3] Liberando puertos (matando procesos Java en 3000 y 8080)..." -ForegroundColor Cyan

# Middle en puerto 3000
$middle = Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($middle) {
    $pid = $middle.OwningProcess
    $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Host "  Parando Spring Boot Middle (PID: $pid)" -ForegroundColor Gray
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
}

# API en puerto 8080
$api = Get-NetTCPConnection -LocalPort 8080 -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($api) {
    $pid = $api.OwningProcess
    $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
    if ($proc) {
        Write-Host "  Parando Quarkus API (PID: $pid)" -ForegroundColor Gray
        Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
}

Write-Host "`n[3/3] Deteniendo Docker containers..." -ForegroundColor Cyan

$infraDir = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$infraDir = Join-Path $infraDir "infra"

if (Test-Path $infraDir) {
    Set-Location $infraDir
    Write-Host "  Ejecutando: docker compose down" -ForegroundColor Gray
    & docker compose down 2>&1 | Where-Object { $_ -match "postgres|removed|Stopping" }
    Write-Host "  ✓ Containers detenidos" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Carpeta infra no encontrada en $infraDir" -ForegroundColor Yellow
}

Write-Host "`n
╔═══════════════════════════════════════════════════════════════╗
║                 ✓ SERVICIOS DETENIDOS                        ║
╚═══════════════════════════════════════════════════════════════╝
" -ForegroundColor Green

Write-Host "`nProcesos activos restantes:" -ForegroundColor Cyan
Get-Job -ErrorAction SilentlyContinue | Format-Table -Property Id, Name, State -AutoSize

Write-Host "`nPara reiniciar el ambiente, ejecuta:" -ForegroundColor Yellow
Write-Host "  .\startup.ps1" -ForegroundColor White

Write-Host "`n✓ Shutdown completado." -ForegroundColor Green
