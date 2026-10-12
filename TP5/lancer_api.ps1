# ==============================================================================
# TP5 - Lancement de l'API sécurisée (https://localhost:8443)
# ==============================================================================

$env:JAVA_HOME = "$env:USERPROFILE\.jdks\corretto-23.0.2"
$jar = Join-Path $PSScriptRoot "tp-securite-api\target\tp-securite-api-0.0.1-SNAPSHOT.jar"

& "$env:JAVA_HOME\bin\java.exe" -jar $jar
