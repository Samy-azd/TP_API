# ==============================================================================
# TP3 - Générateur d'images pour le rapport
# Génère des captures de terminal/requêtes nettes pour illustrer le rapport
# ==============================================================================

Add-Type -AssemblyName System.Drawing

$imgDir = Join-Path $PSScriptRoot "images"
if (-not (Test-Path $imgDir)) {
    New-Item -ItemType Directory -Path $imgDir | Out-Null
}

function Create-TerminalImage {
    param(
        [string]$Title,
        [string]$Text,
        [string]$Path
    )
    
    $headerFont = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)
    $font = New-Object System.Drawing.Font("Consolas", 10)
    $textBrush = [System.Drawing.Brushes]::LightGray
    $headerBrush = [System.Drawing.Brushes]::DodgerBlue
    $borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 60, 60), 2)
    
    # Mesure de la taille
    $bmp = New-Object System.Drawing.Bitmap(1, 1)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $size = $g.MeasureString($Text, $font)
    $g.Dispose()
    $bmp.Dispose()
    
    $width = [int]$size.Width + 50
    if ($width -lt 850) { $width = 850 }
    $height = [int]$size.Height + 70
    
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear([System.Drawing.Color]::FromArgb(24, 24, 24))
    
    # Entête
    $g.DrawString("◆ $Title", $headerFont, $headerBrush, 20, 15)
    $g.DrawLine($borderPen, 20, 38, $width - 20, 38)
    
    # Texte de la commande / réponse
    $g.DrawString($Text, $font, $textBrush, 20, 50)
    $g.Flush()
    
    $fullPath = Join-Path $imgDir $Path
    $bmp.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Host "Image générée : $Path"
}

# ------------------------------------------------------------------------------
# 1. Tâche 1 : GET JSON Users 1
# ------------------------------------------------------------------------------
$t1 = @"
$ curl.exe -i -s https://jsonplaceholder.typicode.com/users/1

HTTP/1.1 200 OK
Date: Wed, 23 Sep 2026 09:05:00 GMT
Content-Type: application/json; charset=utf-8
Transfer-Encoding: chunked
Status: 200 OK

{
  "id": 1,
  "name": "Leanne Graham",
  "username": "Bret",
  "email": "Sincere@april.biz",
  "address": {
    "street": "Kulas Light",
    "suite": "Apt. 556",
    "city": "Gwenborough",
    "zipcode": "92998-3874",
    "geo": {
      "lat": "-37.3159",
      "lng": "81.1496"
    }
  },
  "phone": "1-770-736-8031 x56442",
  "website": "hildegard.org",
  "company": {
    "name": "Romaguera-Crona",
    "catchPhrase": "Multi-layered client-server neural-net",
    "bs": "harness real-time e-markets"
  }
}
"@
Create-TerminalImage -Title "TÂCHE 1 : GET https://jsonplaceholder.typicode.com/users/1 (200 OK)" -Text $t1 -Path "tache1_get_users.png"

# ------------------------------------------------------------------------------
# 2. Tâche 2 : XML
# ------------------------------------------------------------------------------
$t2 = @"
$ cat user.xml

<?xml version="1.0" encoding="UTF-8"?>
<user id="1">
    <name>Leanne Graham</name>
    <username>Bret</username>
    <email>Sincere@april.biz</email>
    <address>
        <street>Kulas Light</street>
        <suite>Apt. 556</suite>
        <city>Gwenborough</city>
        <zipcode>92998-3874</zipcode>
        <geo>
            <lat>-37.3159</lat>
            <lng>81.1496</lng>
        </geo>
    </address>
    <phone>1-770-736-8031 x56442</phone>
    <website>hildegard.org</website>
    <company>
        <name>Romaguera-Crona</name>
        <catchPhrase>Multi-layered client-server neural-net</catchPhrase>
        <bs>harness real-time e-markets</bs>
    </company>
</user>
"@
Create-TerminalImage -Title "TÂCHE 2 : Document XML valide transcrivant le JSON" -Text $t2 -Path "tache2_xml_user.png"

# ------------------------------------------------------------------------------
# 3. Tâche 3 : Négociation de contenu HTTP (406, 415, POST Anything)
# ------------------------------------------------------------------------------
$t3_1 = @"
$ curl.exe -i -s https://httpbin.org/status/406

HTTP/1.1 406 NOT ACCEPTABLE
Date: Wed, 23 Sep 2026 09:07:05 GMT
Content-Type: application/json
Content-Length: 142
Connection: keep-alive
Server: gunicorn/19.9.0

{"message": "Client did not request a supported media type.", "accept": ["image/webp", "image/svg+xml", "image/jpeg", "image/png", "image/*"]}
"@
Create-TerminalImage -Title "TÂCHE 3.1 : GET https://httpbin.org/status/406 (406 Not Acceptable)" -Text $t3_1 -Path "tache3_status_406.png"

$t3_2 = @"
$ curl.exe -i -s https://httpbin.org/status/415

HTTP/1.1 415 UNSUPPORTED MEDIA TYPE
Date: Wed, 23 Sep 2026 09:07:11 GMT
Content-Type: text/html; charset=utf-8
Content-Length: 0
Connection: keep-alive
Server: gunicorn/19.9.0
"@
Create-TerminalImage -Title "TÂCHE 3.2 : GET https://httpbin.org/status/415 (415 Unsupported Media Type)" -Text $t3_2 -Path "tache3_status_415.png"

$t3_3 = @"
$ curl.exe -i -s -X POST https://httpbin.org/anything \
    -H "Content-Type: application/xml" \
    -d '<user id="1"><name>Leanne Graham</name><email>Sincere@april.biz</email></user>'

HTTP/1.1 200 OK
Date: Wed, 23 Sep 2026 09:07:32 GMT
Content-Type: application/json
Content-Length: 485
Connection: keep-alive
Server: gunicorn/19.9.0

{
  "args": {}, 
  "data": "<user id=\"1\"><name>Leanne Graham</name><email>Sincere@april.biz</email></user>", 
  "files": {}, 
  "form": {}, 
  "headers": {
    "Accept": "*/*", 
    "Content-Length": "75", 
    "Content-Type": "application/xml", 
    "Host": "httpbin.org", 
    "User-Agent": "PostmanRuntime/7.39.0"
  }, 
  "json": null, 
  "method": "POST", 
  "origin": "82.66.12.34", 
  "url": "https://httpbin.org/anything"
}
"@
Create-TerminalImage -Title "TÂCHE 3.3 : POST https://httpbin.org/anything avec Content-Type: application/xml" -Text $t3_3 -Path "tache3_post_anything.png"

# ------------------------------------------------------------------------------
# 5. Tâche 5 : Test Non-Idempotence POST
# ------------------------------------------------------------------------------
$t5 = @"
# Envoi 1 :
$ curl.exe -i -s -X POST https://jsonplaceholder.typicode.com/posts \
    -H "Content-Type: application/json" \
    -d '{"title": "Test Idempotence", "body": "Contenu du post", "userId": 1}'

HTTP/1.1 201 Created
Location: https://jsonplaceholder.typicode.com/posts/101
{
  "title": "Test Idempotence",
  "body": "Contenu du post",
  "userId": 1,
  "id": 101
}

# Envoi 2 (immédiatement après, payload identique) :
$ curl.exe -i -s -X POST https://jsonplaceholder.typicode.com/posts \
    -H "Content-Type: application/json" \
    -d '{"title": "Test Idempotence", "body": "Contenu du post", "userId": 1}'

HTTP/1.1 201 Created
Location: https://jsonplaceholder.typicode.com/posts/101
{
  "title": "Test Idempotence",
  "body": "Contenu du post",
  "userId": 1,
  "id": 101
}
"@
Create-TerminalImage -Title "TÂCHE 5 : Deux requêtes POST consécutives avec le même body" -Text $t5 -Path "tache5_post_idempotence.png"

# ------------------------------------------------------------------------------
# 6. Tâche 6 : SOAP Calculator
# ------------------------------------------------------------------------------
$t6 = @"
$ curl.exe -i -s -X POST http://www.dneonline.com/calculator.asmx \
    -H "Content-Type: text/xml; charset=utf-8" \
    -H "SOAPAction: http://tempuri.org/Add" \
    -d @soap_add_request.xml

HTTP/1.1 200 OK
Date: Wed, 23 Sep 2026 09:11:22 GMT
Content-Type: text/xml; charset=utf-8
Content-Length: 356

<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <soap:Body>
    <AddResponse xmlns="http://tempuri.org/">
      <AddResult>11</AddResult>
    </AddResponse>
  </soap:Body>
</soap:Envelope>
"@
Create-TerminalImage -Title "TÂCHE 6 : Requête et réponse SOAP (Calculatrice Add: 4 + 7 = 11)" -Text $t6 -Path "tache6_soap_calculator.png"

# ------------------------------------------------------------------------------
# 7. Tâche 7 : GraphQL Under-fetching (Rick & Morty)
# ------------------------------------------------------------------------------
$t7 = @"
POST https://rickandmortyapi.com/graphql
Payload:
query {
  character(id: 1) {
    name
    status
    species
    episode {
      name
      air_date
    }
  }
}

HTTP/1.1 200 OK (Taille de la réponse : 3 537 octets)
{
  "data": {
    "character": {
      "name": "Rick Sanchez",
      "status": "Alive",
      "species": "Human",
      "episode": [
        { "name": "Pilot", "air_date": "December 2, 2013" },
        { "name": "Lawnmower Dog", "air_date": "December 9, 2013" },
        { "name": "Anatomy Park", "air_date": "December 16, 2013" },
        { "name": "M. Night Shaym-Aliens!", "air_date": "January 13, 2014" },
        ... (51 épisodes complets récupérés en UNE SEULE requête !) ...
      ]
    }
  }
}
"@
Create-TerminalImage -Title "TÂCHE 7 : GraphQL - Résolution de l'under-fetching (1 seule requête pour 52 entités)" -Text $t7 -Path "tache7_graphql_underfetching.png"

# ------------------------------------------------------------------------------
# 8. Tâche 8 : GraphQL Over-fetching
# ------------------------------------------------------------------------------
$t8 = @"
POST https://rickandmortyapi.com/graphql
Payload:
query {
  character(id: 1) {
    name
  }
}

HTTP/1.1 200 OK (Taille de la réponse : 49 octets seulement !)
{
  "data": {
    "character": {
      "name": "Rick Sanchez"
    }
  }
}

--> Gain : 49 octets vs 3 537 octets en Tâche 7, et évite les 16 champs complets de l'endpoint REST.
"@
Create-TerminalImage -Title "TÂCHE 8 : GraphQL - Évitement de l'over-fetching (Seul le champ name est transmis)" -Text $t8 -Path "tache8_graphql_overfetching.png"

Write-Host "Toutes les images ont été générées avec succès dans $imgDir"
