# ==============================================================================
# TP5 - Générateur de Rapport Word (.docx) et PDF (.pdf)
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

    Write-Title "Rapport TP 5 - Sécurisation d'une API REST avec Spring Boot" "AZDAD Samy - BENHADDYA Loqmann"

    # ==========================================================================
    # EXERCICE 1
    # ==========================================================================
    Write-Heading1 "Exercice 1 - Authentification par clé API"

    Write-Question "1. Pourquoi est-ce faiblement sécurisé ?"
    Write-Paragraph "La clé est unique, statique et codée en dur : tous les clients la partagent, elle n'expire jamais et n'identifie personne. Si elle est interceptée (par exemple sans HTTPS), elle donne un accès total jusqu'à ce qu'on la change dans le code."

    Write-Question "2. Comment la renforcer ?"
    Write-Paragraph "Imposer HTTPS, sortir la clé du code (variable d'environnement), donner une clé par client stockée hachée et révocable, avec une expiration et une rotation régulière."
    Write-Paragraph ""

    # ==========================================================================
    # EXERCICE 2
    # ==========================================================================
    Write-Heading1 "Exercice 2 - JWT et rôles"

    Write-Image "images\ex2_login_admin.png" "POST /auth/login (admin / admin123) : JWT avec le rôle admin"

    Write-Question "1. Token signé ou chiffré ?"
    Write-Paragraph "Un token signé (JWS, notre cas) est lisible par tous, mais sa signature empêche toute modification sans la clé : il garantit l'intégrité. Un token chiffré (JWE) est illisible sans la clé : il garantit aussi la confidentialité."

    Write-Question "2. Pourquoi pas de données sensibles dans un JWT ?"
    Write-Paragraph "Son contenu est seulement encodé en Base64 : n'importe qui peut le décoder (le nôtre contient en clair le username et le rôle). Il circule aussi dans les en-têtes et les logs, et reste valable jusqu'à son expiration."
    Write-Paragraph ""

    # ==========================================================================
    # EXERCICE 3
    # ==========================================================================
    Write-Heading1 "Exercice 3 - XSS et injections"

    Write-Question "1. Injection SQL ou injection XSS ?"
    Write-Paragraph "L'injection SQL vise la base de données : l'entrée est exécutée comme du SQL (ex. ' OR 1=1 --). On s'en protège avec des requêtes préparées. Le XSS vise les autres utilisateurs : un script stocké s'exécute dans leur navigateur. On s'en protège en échappant le HTML (escapeHtml4)."

    Write-Question "2. Pourquoi la validation côté client ne suffit-elle pas ?"
    Write-Paragraph "L'attaquant contrôle le client : il peut désactiver JavaScript ou appeler l'API directement avec Postman ou curl. Seule la validation côté serveur est fiable."
    Write-Paragraph ""

    # ==========================================================================
    # EXERCICE 4
    # ==========================================================================
    Write-Heading1 "Exercice 4 - Rate limiting"

    Write-Question "1. Pourquoi cela améliore-t-il la disponibilité ?"
    Write-Paragraph "Un client abusif (bot, force brute, déni de service) est bloqué par un 429 avant tout traitement coûteux. Il ne peut donc pas saturer le serveur au détriment des autres utilisateurs."

    Write-Question "2. Et avec plusieurs instances ?"
    Write-Paragraph "Une Map locale compte séparément sur chaque instance. Il faut un compteur partagé, par exemple dans Redis (ou Bucket4j avec Redis), ou appliquer la limite dans une API Gateway."
    Write-Paragraph ""

    # ==========================================================================
    # EXERCICE 5
    # ==========================================================================
    Write-Heading1 "Exercice 5 - HTTPS et gestion des erreurs"

    Write-Question "En quoi HTTPS protège-t-il la clé API et le JWT ?"
    Write-Paragraph "TLS chiffre toute la requête, y compris l'en-tête Authorization : la clé et le token ne peuvent être ni lus ni rejoués par quelqu'un qui écoute le réseau. Le certificat authentifie le serveur, ce qui empêche une attaque de l'homme du milieu."

    Write-Image "images\ex5_erreur_validation.png" "Gestion centralisée des erreurs : 400 au format JSON uniforme"
    Write-Paragraph ""

    # ==========================================================================
    # EXERCICE 6
    # ==========================================================================
    Write-Heading1 "Exercice 6 - Tests"

    Write-Image "images\ex6_1_sans_cle.png" "1 - Sans clé API : 401"
    Write-Image "images\ex6_2_cle_valide.png" "2 - Clé API valide : 200"
    Write-Image "images\ex6_3_jwt_user_user.png" "3 - JWT user sur /utilisateurs/user : 200"
    Write-Image "images\ex6_4_jwt_user_admin.png" "4 - JWT user sur /utilisateurs/admin : 403"
    Write-Image "images\ex6_5_jwt_admin_admin.png" "5 - JWT admin sur /utilisateurs/admin : 200"
    Write-Image "images\ex6_6_rate_limit.png" "6 - Plus de 5 requêtes par minute : 429"
    Write-Image "images\ex6_7_xss_a.png" "7a - Description contenant <script> : balises échappées"
    Write-Image "images\ex6_7_xss_b.png" "7b - Donnée stockée neutralisée"
    Write-Image "images\ex6_8_http.png" "8 - Requête en http:// : refusée"

    Write-Question "1. Authentification ou autorisation ?"
    Write-Paragraph "L'authentification vérifie qui est le client (en cas d'échec : 401). L'autorisation vérifie ce qu'il a le droit de faire selon son rôle (en cas de refus : 403)."

    Write-Question "2. Rôle du chiffrement dans HTTPS"
    Write-Paragraph "Le chiffrement asymétrique du handshake TLS authentifie le serveur et établit une clé de session. Le chiffrement symétrique (AES) protège ensuite la confidentialité et l'intégrité de tous les échanges."

    Write-Question "3. Réflexion finale : pourquoi combiner plusieurs mécanismes ?"
    Write-Paragraph "Aucun mécanisme ne couvre à lui seul toutes les menaces : c'est le principe de défense en profondeur. L'authentification identifie le client mais ne dit rien de ses droits : c'est le rôle de l'autorisation. Un utilisateur authentifié et autorisé peut tout de même envoyer des données malveillantes : le filtrage et la validation des entrées bloquent alors les injections et le XSS. Un client légitime ou un bot peut aussi saturer l'API de requêtes, ce que seul le rate limiting empêche. Enfin, tous ces contrôles reposent sur des secrets (clé API, JWT) qui seraient interceptés et rejoués sans HTTPS. Chaque couche compense donc les faiblesses des autres : si l'une est contournée ou mal configurée, les suivantes limitent les dégâts. Dans notre API, une requête traverse successivement HTTPS, le rate limiting, la clé API ou le JWT, le contrôle des rôles, puis la validation des données : un attaquant doit les déjouer toutes pour réussir."
    Write-Paragraph ""

    # Sauvegarde DOCX et PDF
    $docxPath = "$PSScriptRoot\RAPPORT_TP5.docx"
    $pdfPath = "$PSScriptRoot\RAPPORT_TP5.pdf"

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
