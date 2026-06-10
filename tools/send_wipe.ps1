# Envía un Data Message de borrado remoto vía FCM HTTP v1.
#
# Requisitos:
#   - Google Cloud SDK instalado (comando `gcloud`).
#   - Una clave de cuenta de servicio del proyecto (JSON).
#
# Uso:
#   .\tools\send_wipe.ps1 -Token "<FCM_TOKEN>" -Clave "<PALABRA_CLAVE>" `
#       -ServiceAccount ".\tools\service-account.json"

param(
    [Parameter(Mandatory = $true)] [string] $Token,
    [Parameter(Mandatory = $true)] [string] $Clave,
    [string] $ServiceAccount = ".\tools\service-account.json",
    [string] $ProjectId = "visionprice-f756e"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ServiceAccount)) {
    throw "No se encuentra la clave de servicio: $ServiceAccount"
}

# 1. Autentica la cuenta de servicio y obtiene un access token OAuth2.
Write-Host "Autenticando cuenta de servicio..." -ForegroundColor Cyan
gcloud auth activate-service-account --key-file="$ServiceAccount" | Out-Null
$accessToken = (gcloud auth print-access-token).Trim()

# 2. Construye el Data Message (SIN bloque notification: data-only).
$body = @{
    message = @{
        token = $Token
        data  = @{
            accion = "wipe"
            clave  = $Clave
        }
        android = @{
            priority = "high"
        }
    }
} | ConvertTo-Json -Depth 6

# 3. Envía la petición a la API HTTP v1.
$uri = "https://fcm.googleapis.com/v1/projects/$ProjectId/messages:send"
Write-Host "Enviando wipe a $uri ..." -ForegroundColor Cyan

$response = Invoke-RestMethod -Uri $uri -Method Post -Body $body `
    -ContentType "application/json; UTF-8" `
    -Headers @{ Authorization = "Bearer $accessToken" }

Write-Host "Respuesta de FCM:" -ForegroundColor Green
$response | ConvertTo-Json -Depth 6
