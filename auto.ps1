Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "       DIAGNOSTICO DE INTERNET" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

#  verifico el adaptador de re
Write-Host "Verificando adaptador de red..."

$ip = Get-NetIPAddress -AddressFamily IPv4 |
      Where-Object {
          $_.IPAddress -notlike "127.*" -and
          $_.IPAddress -notlike "169.254.*"
      }

if ($ip) {
    Write-Host "[OK] Adaptador de red detectado" -ForegroundColor Green
}
else {
    Write-Host "[ERROR] No se detecto una direccion IPv4" -ForegroundColor Red
    exit
}

Write-Host ""

# 2. obtengo gateway
Write-Host "Verificando Gateway..."

$gateway = Get-NetRoute -DestinationPrefix "0.0.0.0/0" |
           Select-Object -First 1 -ExpandProperty NextHop

if ($gateway) {

    $pingGateway = Test-Connection $gateway -Count 2 -Quiet

    if ($pingGateway) {
        Write-Host "[OK] Gateway responde" -ForegroundColor Green
    }
    else {
        Write-Host "[ERROR] Gateway no responde" -ForegroundColor Red

        Write-Host ""
        Write-Host "DIAGNOSTICO:" -ForegroundColor Yellow
        Write-Host "La computadora no puede comunicarse con el router."

        exit
    }
}
else {
    Write-Host "[ERROR] No se encontro Gateway" -ForegroundColor Red
    exit
}

Write-Host ""

# verificar Internet sin utilizar DNS
Write-Host "Verificando conexion a Internet..."

$internet = Test-Connection "8.8.8.8" -Count 2 -Quiet

if ($internet) {
    Write-Host "[OK] Conexion a Internet disponible" -ForegroundColor Green
}
else {
    Write-Host "[ERROR] Conexion a Internet no disponible" -ForegroundColor Red

    Write-Host ""
    Write-Host "DIAGNOSTICO:" -ForegroundColor Yellow
    Write-Host "El Gateway responde pero no hay comunicacion con Internet"

    exit
}

Write-Host ""

# 4. Verificar DNS utilizando Resolve-DnsName
Write-Host "....... -- Verificando resolucion DNS..."

try {

    Resolve-DnsName "google.com" -ErrorAction Stop | Out-Null

    Write-Host "[OK] Resolucion DNS funcionando" -ForegroundColor Green

}
catch {

    Write-Host "[ERROR] Resolucion DNS fallida" -ForegroundColor Red
    Write-Host ""
    Write-Host ""
    Write-Host "------------------------------------------"
    Write-Host "DIAGNOSTICO" -ForegroundColor Red
    Write-Host "------------------------------------------"
    Write-Host ""
    Write-Host ""

    Write-Host "La computadora tiene conexion a Internet,"
    Write-Host "pero existe un problema con el servicio DNS."

    Write-Host ""
    Write-Host "Recomendacion:"
    Write-Host "- Ejecutar: ipconfig /flushdns"
    Write-Host "- Verificar configuracion DNS"
    Write-Host "- Probar DNS 8.8.8.8"
    Write-Host "- Reiniciar el adaptador de red"

    exit
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "      DIAGNOSTICO COMPLETADO" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green