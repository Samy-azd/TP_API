# ==============================================================================
# TP4 - Générateur de Rapport Word (.docx) et PDF (.pdf)
# Placer les captures dans .\images puis lancer : powershell -File generate_pdf.ps1
# ==============================================================================

$ErrorActionPreference = "Stop"

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0

$doc = $word.Documents.Add()
$selection = $word.Selection

# Configuration des marges
$doc.PageSetup.TopMargin = 40
$doc.PageSetup.BottomMargin = 40
$doc.PageSetup.LeftMargin = 45
$doc.PageSetup.RightMargin = 45

function Set-DefaultFont {
    $selection.Font.Name = "Calibri"
    $selection.Font.Size = 10.5
    $selection.Font.Color = [int]0x222222
    $selection.Font.Bold = $false
    $selection.Font.Italic = $false
}

function Write-Title($text, $subtitle) {
    $selection.ParagraphFormat.Alignment = 1 # Centered
    $selection.Font.Name = "Calibri"
    $selection.Font.Size = 22
    $selection.Font.Bold = $true
    $selection.Font.Color = [int]0x803000
    $selection.TypeText($text)
    $selection.TypeParagraph()

    if ($subtitle) {
        $selection.Font.Size = 12
        $selection.Font.Bold = $false
        $selection.Font.Italic = $true
        $selection.Font.Color = [int]0x555555
        $selection.TypeText($subtitle)
        $selection.TypeParagraph()
    }

    $selection.ParagraphFormat.Alignment = 0 # Left
    $selection.TypeParagraph()
    Set-DefaultFont
}

function Write-Heading1($text) {
    $selection.Font.Name = "Calibri"
    $selection.Font.Size = 16
    $selection.Font.Bold = $true
    $selection.Font.Color = [int]0x803000
    $selection.TypeText($text)
    $selection.TypeParagraph()
    Set-DefaultFont
}

function Write-Heading2($text) {
    $selection.Font.Name = "Calibri"
    $selection.Font.Size = 13
    $selection.Font.Bold = $true
    $selection.Font.Color = [int]0x333333
    $selection.TypeText($text)
    $selection.TypeParagraph()
    Set-DefaultFont
}

function Write-Paragraph($text) {
    Set-DefaultFont
    $selection.TypeText($text)
    $selection.TypeParagraph()
}

function Write-Question($text) {
    Set-DefaultFont
    $selection.Font.Bold = $true
    $selection.Font.Color = [int]0x803000
    $selection.TypeText($text)
    $selection.TypeParagraph()
    Set-DefaultFont
}

function Write-Bullet($text) {
    Set-DefaultFont
    $selection.TypeText("  * $text")
    $selection.TypeParagraph()
}

function Write-CodeBlock($text) {
    $selection.Font.Name = "Consolas"
    $selection.Font.Size = 9
    $selection.Font.Color = [int]0x111111
    $selection.TypeText($text)
    $selection.TypeParagraph()
    Set-DefaultFont
}

function Write-Image($relPath, $caption) {
    $absPath = Join-Path $PSScriptRoot $relPath
    if (Test-Path $absPath) {
        $shape = $selection.InlineShapes.AddPicture($absPath, $false, $true)
        if ($shape.Width -gt 480) {
            $ratio = 480.0 / $shape.Width
            $shape.Width = 480
            $shape.Height = [int]($shape.Height * $ratio)
        }
        if ($shape.Height -gt 430) {
            $ratio = 430.0 / $shape.Height
            $shape.Height = 430
            $shape.Width = [int]($shape.Width * $ratio)
        }
        $shape.Range.ParagraphFormat.Alignment = 1 # Centered
        $selection.TypeParagraph()
        if ($caption) {
            $selection.Font.Size = 9
            $selection.Font.Italic = $true
            $selection.Font.Color = [int]0x666666
            $selection.TypeText("Illustration : $caption")
            $selection.TypeParagraph()
            Set-DefaultFont
        }
        $selection.ParagraphFormat.Alignment = 0 # Left
    } else {
        Write-Host "  [!] Capture manquante : $relPath"
        $selection.Font.Size = 9
        $selection.Font.Italic = $true
        $selection.Font.Color = [int]0x0000C0
        $selection.TypeText("[Capture à ajouter : $relPath]")
        $selection.TypeParagraph()
        Set-DefaultFont
    }
}

function Write-Table($headers, $rows) {
    $nCols = $headers.Count
    $table = $doc.Tables.Add($selection.Range, $rows.Count + 1, $nCols)
    $table.Borders.Enable = 1
    $table.Range.Font.Size = 9.5

    for ($c = 1; $c -le $nCols; $c++) {
        $cell = $table.Cell(1, $c)
        $cell.Range.Text = $headers[$c-1]
        $cell.Range.Bold = $true
        $cell.Range.Shading.BackgroundPatternColor = [int]0xEFEFEF
    }
    for ($r = 0; $r -lt $rows.Count; $r++) {
        for ($c = 0; $c -lt $nCols; $c++) {
            $table.Cell($r + 2, $c + 1).Range.Text = $rows[$r][$c]
        }
    }

    $selection.SetRange($table.Range.End, $table.Range.End)
    $selection.TypeParagraph()
}

try {
    Write-Host "Creation du document Word et PDF..."

    Write-Title "Rapport TP 4 - API Temps Réel et Événementielles" "AZDAD Samy - BENHADDYA Loqmann"

    # ==========================================================================
    # PARTIE 1
    # ==========================================================================
    Write-Heading1 "Partie 1 - WebSockets"

    Write-Heading2 "Tâches 1 et 2 - Connexion et échange de messages"
    Write-Image "images\tache1_websocket_connexion.png" "Handshake : requête GET avec Upgrade: websocket, réponse 101 Switching Protocols"
    Write-Image "images\tache1_websocket_connexion_2.png" "En-têtes de réponse du handshake"
    Write-Image "images\tache2_websocket_messages.png" "Premier message envoyé (↑) et renvoyé par le serveur (↓)"
    Write-Image "images\tache2_websocket_message_2.png" "Second message sur la même connexion"

    Write-Question "Tâche 1 - Code de statut"
    Write-Paragraph "Le code affiché est 101 Switching Protocols. Le client envoie un GET HTTP avec Upgrade: websocket et Connection: Upgrade, et le serveur accepte la bascule en répondant 101 (avec Sec-WebSocket-Accept). La connexion ne parle alors plus HTTP mais WebSocket."

    Write-Question "Tâche 2 - Connexion persistante"
    Write-Paragraph "Non, il n'a fallu ni rouvrir de connexion, ni renvoyer l'URL ou une authentification : le handshake n'a eu lieu qu'une fois. La connexion reste ouverte et les messages circulent dans les deux sens sur le même canal. En REST, chaque échange est une nouvelle requête indépendante qui doit renvoyer URL, en-têtes et authentification, et seul le client peut lancer l'échange."

    Write-Heading2 "Tâche 3 - Limites"
    Write-Image "images\tache3_websocket_reconnexion.png" "Nouvelle connexion : aucun message de la session précédente"
    Write-Question "Historique et contournement"
    Write-Paragraph "L'historique est perdu : une connexion WebSocket ne stocke rien, chaque nouvelle connexion repart de zéro."
    Write-Paragraph "Dans le projet de messagerie, chaque message est enregistré en base de données côté serveur. À l'ouverture d'une conversation, l'historique est chargé par une requête REST (GET /conversations/{id}/messages), et le WebSocket ne sert qu'à recevoir les nouveaux messages en direct."
    Write-Paragraph ""

    # ==========================================================================
    # PARTIE 2
    # ==========================================================================
    Write-Heading1 "Partie 2 - Server-Sent Events (SSE)"

    Write-Heading2 "Tâche 4 - Flux SSE Wikimedia"
    Write-Image "images\tache4_sse_wikimedia.png" "Sortie de curl -N https://stream.wikimedia.org/v2/stream/recentchange | head -n 15"
    Write-Question "Structure et fermeture"
    Write-Paragraph "Chaque événement suit la structure vue en cours : une ligne event: message, une ligne id: [...], une ligne data: contenant l'objet JSON, puis une ligne vide qui termine l'événement."
    Write-Paragraph "La connexion ne s'est pas fermée après le premier événement : les événements arrivent en continu sur la même requête, et c'est head -n 15 qui a arrêté la commande."
    Write-Paragraph ""

    Write-Heading2 "Tâche 5 - Endpoint SSE Spring Boot"
    Write-Image "images\tache5_horloge_navigateur.png" "http://localhost:8080/horloge dans le navigateur : une ligne par seconde"
    Write-Question "Effet du timeout"
    Write-Paragraph "Si le timeout était atteint, le serveur fermerait la connexion et l'heure s'arrêterait de défiler avant la fin des 20 événements. Avec SSE, un client EventSource se reconnecte automatiquement et renvoie l'en-tête Last-Event-ID, ce qui permet au serveur de reprendre le flux là où il s'était arrêté. Ici, notre code n'envoie pas d'id : il recommencerait donc le flux depuis le début."
    Write-Paragraph ""

    # ==========================================================================
    # PARTIE 3
    # ==========================================================================
    Write-Heading1 "Partie 3 - Webhooks"

    Write-Heading2 "Tâches 6 et 7 - Webhook sur webhook.site"
    Write-Image "images\tache6_webhook_postman.png" "Réponse 200 OK reçue dans Postman"
    Write-Image "images\tache7_webhook_site.png" "Requête reçue sur webhook.site"

    Write-Question "Tâche 6 - Mise à jour en direct"
    Write-Paragraph "Oui, la requête apparaît instantanément sans rafraîchir la page. webhook.site garde une connexion WebSocket ouverte avec le navigateur et y pousse chaque nouvelle requête reçue."

    Write-Question "Tâche 7 - Décomposition de la requête"
    Write-Table @("Élément", "Valeur observée") @(
        @("Méthode", "POST"),
        @("En-têtes", "content-type: application/json, content-length: 86, user-agent: PostmanRuntime/2.7.0, host: webhook.site, accept: */*"),
        @("Corps", "{ ""evenement"": ""paiement.reussi"", ""montant"": 49.90, ""transactionId"": ""tx_8827"" }")
    )
    Write-Paragraph "On retrouve une méthode, des en-têtes et un corps JSON, comme dans n'importe quelle requête HTTP : un Webhook est bien une requête HTTP ordinaire. Ce qui change, c'est seulement que c'est le serveur émetteur qui l'envoie quand l'événement se produit."
    Write-Paragraph ""

    # ==========================================================================
    # PARTIE 4
    # ==========================================================================
    Write-Heading1 "Partie 4 - Conception pub/sub"

    Write-Heading2 "Tâche 8 - Architecture pub/sub"

    Write-Question "1. Nom du topic"
    Write-Paragraph "bibliotheque.livre.emprunte"

    Write-Question "2. Producteur et consommateurs"
    Write-Paragraph "Catalogue, Notifications et Statistiques sont tous les trois des consommateurs : ils réagissent à l'emprunt. Le producteur est le service qui enregistre l'emprunt (service Emprunts) et publie l'événement."

    Write-Question "3. Ajout du service de recommandation"
    Write-Paragraph "Le producteur publie dans le topic sans savoir qui le lit. Il suffit d'abonner le nouveau service au topic existant (avec son propre groupe de consommateurs) : le service qui publie l'emprunt n'a pas à être modifié."

    Write-Question "4. Panne du service Statistiques pendant 2 heures"
    Write-Paragraph "Avec Kafka, les événements sont conservés sur disque pendant la durée de rétention, même s'ils n'ont pas été lus. Au redémarrage, Statistiques reprend à son dernier offset et traite les événements des deux heures manquées : rien n'est perdu. Avec un simple Webhook, les requêtes envoyées pendant la panne échouent et les événements sont perdus."

    # Sauvegarde DOCX et PDF
    $docxPath = "$PSScriptRoot\RAPPORT_TP4.docx"
    $pdfPath = "$PSScriptRoot\RAPPORT_TP4.pdf"

    if (Test-Path $docxPath) { Remove-Item $docxPath -Force }
    if (Test-Path $pdfPath) { Remove-Item $pdfPath -Force }

    $doc.SaveAs([ref]$docxPath, [ref]16)
    Write-Host "DOCX genere : $docxPath"

    $doc.SaveAs([ref]$pdfPath, [ref]17)
    Write-Host "PDF genere : $pdfPath"

} catch {
    Write-Error "Erreur lors de la generation : $_"
} finally {
    $doc.Close([ref]0)
    $word.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($doc) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null
}
