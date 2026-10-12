# ==============================================================================
# TP4 - Lancement de l'application Spring Boot (endpoint SSE /horloge)
# Ouvrir ensuite http://localhost:8080/horloge dans le navigateur
# ==============================================================================

$env:JAVA_HOME = "$env:USERPROFILE\.jdks\corretto-23.0.2"
$jar = Join-Path $PSScriptRoot "horloge-sse\target\tp-0.0.1-SNAPSHOT.jar"

& "$env:JAVA_HOME\bin\java.exe" -jar $jar
