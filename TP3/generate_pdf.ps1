# ==============================================================================
# TP3 - Générateur de Rapport Word (.docx) et PDF (.pdf)
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
        $selection.TypeParagraph()
        if ($caption) {
            $selection.Font.Size = 9
            $selection.Font.Italic = $true
            $selection.Font.Color = [int]0x666666
            $selection.TypeText("Illustration : $caption")
            $selection.TypeParagraph()
            Set-DefaultFont
        }
    }
}

try {
    Write-Host "Creation du document Word et PDF..."
    
    Write-Title "Rapport TP 3" "AZDAD Samy - BENHADDYA Loqmann"
    
    # PARTIE 1
    Write-Heading1 "Partie 1 - Formats de Donnees (Chapitre 3)"
    
    Write-Heading2 "Tache 1 - Identifier les types JSON dans une reponse reelle"
    Write-Paragraph "Requete GET vers https://jsonplaceholder.typicode.com/users/1 pour analyser les types JSON natifs (RFC 8259)."
    Write-Image "images\tache1_get_users.png" "Requete GET et reponse JSON de l'utilisateur"
    Write-Paragraph "Identification des 6 types JSON vus en cours :"
    Write-Bullet "string : Present. Exemple : 'name': 'Leanne Graham', 'email': 'Sincere@april.biz'."
    Write-Bullet "number : Present. Exemple : 'id': 1. (Remarque : lat et lng sont encodes en chaines de caracteres)."
    Write-Bullet "boolean : Absent. Aucune valeur booleenne true ou false n'apparait dans ce profil."
    Write-Bullet "null : Absent. Aucun champ n'a la valeur nulle."
    Write-Bullet "object : Present. Exemple : 'address': { ... }, 'geo': { ... }, 'company': { ... }."
    Write-Bullet "array : Absent. Aucun tableau indexe [...] n'est present dans cette ressource unitaire."
    Write-Paragraph ""

    Write-Heading2 "Tache 2 - Convertir du JSON en XML"
    Write-Paragraph "Transcription du JSON en document XML valide (fichier user.xml) respectant une racine unique, l'imbrication d'address et geo, et une modelisation rigoureuse :"
    Write-Image "images\tache2_xml_user.png" "Document XML complet transcrit"
    Write-Paragraph "Question a consigner (Choix pour le champ id) :"
    Write-Paragraph "Le champ id a ete modelise comme un ATTRIBUT de la racine (<user id='1'>). Selon les criteres vus en cours, les attributs sont reserves aux metadonnees techniques et identifiants uniques qui qualifient l'element sans faire partie de son contenu textuel metier propre. Les elements enfants (<name>, <email>, <address>) sont reserves aux donnees metier affichables, extensibles et composees."
    Write-Paragraph ""

    Write-Heading2 "Tache 3 - Negociation de contenu et codes d'erreur"
    Write-Paragraph "Tests sur httpbin.org pour observer le comportement de la negociation de contenu :"
    Write-Image "images\tache3_status_406.png" "Statut HTTP 406 Not Acceptable"
    Write-Image "images\tache3_status_415.png" "Statut HTTP 415 Unsupported Media Type"
    Write-Image "images\tache3_post_anything.png" "POST sur /anything avec Content-Type: application/xml repercute dans les en-tetes"
    Write-Paragraph "Question a consigner (Sens des codes 406 et 415) :"
    Write-Bullet "Code 406 (Not Acceptable) : Le serveur renvoie cette erreur lorsque le format reclame par le client via l'en-tete Accept (ex: Accept: application/xml) ne peut pas etre produit par le serveur."
    Write-Bullet "Code 415 (Unsupported Media Type) : Le serveur renvoie cette erreur lorsqu'il refuse de traiter le corps de la requete parce que le format transmis via l'en-tete Content-Type (ex: XML) n'est pas pris en charge par l'endpoint cible."
    Write-Paragraph ""

    # PARTIE 2
    Write-Heading1 "Partie 2 - REST et SOAP (Chapitre 4)"
    
    Write-Heading2 "Tache 4 - Concevoir des URLs RESTful"
    Write-Paragraph "Conception de l'API REST d'une bibliotheque en ligne (ressources au pluriel, pas de verbe dans l'URI, query string pour le filtrage) :"
    Write-Paragraph ""
    
    $table4 = $doc.Tables.Add($selection.Range, 7, 4)
    $table4.Borders.Enable = 1
    
    $headers4 = @("Action metier", "Methode", "URL RESTful", "Justification REST")
    for ($c = 1; $c -le 4; $c++) {
        $cell = $table4.Cell(1, $c)
        $cell.Range.Text = $headers4[$c-1]
        $cell.Range.Bold = $true
        $cell.Range.Shading.BackgroundPatternColor = [int]0xEFEFEF
    }
    
    $data4 = @(
        @("Lister tous les livres", "GET", "/livres", "Collection au pluriel, action de lecture"),
        @("Recuperer le livre d'ID 42", "GET", "/livres/42", "Identification directe par ID dans le chemin"),
        @("Lister livres disponibles", "GET", "/livres?disponible=true", "Filtrage par query string sans alterer l'URI"),
        @("Emprunter livre 42", "POST", "/emprunts", "Creation de la ressource emprunt (body: {livreId:42})"),
        @("Livres de l'auteur 7", "GET", "/auteurs/7/livres", "Sous-ressource imbriquee exprimant la relation"),
        @("Mettre fin a l'emprunt 15", "PATCH", "/emprunts/15", "Cloture de l'emprunt (ou DELETE pour suppression)")
    )
    
    for ($r = 0; $r -lt $data4.Count; $r++) {
        for ($c = 0; $c -lt 4; $c++) {
            $table4.Cell($r + 2, $c + 1).Range.Text = $data4[$r][$c]
        }
    }
    
    $selection.SetRange($table4.Range.End, $table4.Range.End)
    $selection.TypeParagraph()
    Write-Paragraph ""

    Write-Heading2 "Tache 5 - Tester la non-idempotence de POST"
    Write-Paragraph "Deux requetes POST consecutives executees avec le meme corps sur https://jsonplaceholder.typicode.com/posts :"
    Write-Image "images\tache5_post_idempotence.png" "Deux envois POST successifs renvoyant id: 101"
    Write-Paragraph "Question a consigner (Analyse et idempotence) :"
    Write-Paragraph "Les deux reponses sont superficiellement identiques (id: 101) car JSONPlaceholder est un mock statique. Mais sur un serveur reel, reiterer POST entraine la creation successive de deux ressources distinctes (id=101 puis id=102). Cela demontre concretement que la methode POST n'est PAS idempotente : elle produit des effets de bord cumulatifs a chaque execution."
    Write-Paragraph ""

    Write-Heading2 "Tache 6 - Interroger un vrai service SOAP"
    Write-Paragraph "Appel au service SOAP http://www.dneonline.com/calculator.asmx pour effectuer l'addition (4 + 7 = 11) :"
    Write-Image "images\tache6_soap_calculator.png" "Reponse XML SOAP avec AddResult = 11"
    Write-Paragraph "Questions a consigner :"
    Write-Bullet "Identification : L'Envelope (<soap:Envelope>) delimite le conteneur du message et ses namespaces ; le Body (<soap:Body>) contient les donnees metier (<AddResponse> et <AddResult>11</AddResult>)."
    Write-Bullet "Verbe HTTP : Toutes les requetes SOAP utilisent invariablement POST, quelle que soit l'action (Add, Subtract...). Contrairement a REST qui s'appuie sur la richesse des verbes HTTP (GET, POST, PUT, DELETE), SOAP utilise HTTP comme un simple tunnel aveugle (RPC tunneling)."
    Write-Bullet "Localisation de l'operation : Le nom de l'operation (Add) apparait dans le corps XML et l'en-tete SOAPAction, jamais dans l'URL. Cela confirme que REST est oriente ressources alors que SOAP est oriente operations / procedures distantes (RPC)."
    Write-Paragraph ""

    # PARTIE 3
    Write-Heading1 "Partie 3 - GraphQL et gRPC (Chapitre 5)"
    
    Write-Heading2 "Tache 7 - Ecrire une requete GraphQL contre une vraie API"
    Write-Paragraph "Execution d'une requete sur l'API Rick and Morty (personnage 1 + ses 51 episodes) :"
    Write-Image "images\tache7_graphql_underfetching.png" "Requete GraphQL combinant character et 51 episodes"
    Write-Paragraph "Question a consigner (REST vs GraphQL et under-fetching) :"
    Write-Paragraph "Avec une API REST classique (GET /character/1), l'appel ne renverrait que la liste des URLs des episodes. Pour obtenir le nom et la date de diffusion de chacun, le client devrait faire 51 requetes supplementaires, soit 52 requetes HTTP au total (probleme du N+1). L'under-fetching designe cette insuffisance de donnees dans un endpoint REST obligeant a multiplier les allers-retours reseau. GraphQL le resout en permettant d'extraire tout le graphe lie en un unique appel."
    Write-Paragraph ""

    Write-Heading2 "Tache 8 - Modifier la requete pour observer l'over-fetching"
    Write-Paragraph "Execution de la meme requete allegee pour ne demander que le nom :"
    Write-Image "images\tache8_graphql_overfetching.png" "Requete GraphQL ciblee : 49 octets seulement"
    Write-Paragraph "Question a consigner (Comparaison de taille et over-fetching) :"
    Write-Paragraph "La reponse detaillee (Tache 7) pese 3 537 octets alors que la requete ciblee (Tache 8) ne pese que 49 octets. En REST, l'endpoint renvoie systematiquement la totalite des 16 champs du personnage meme si le client n'en veut qu'un seul (over-fetching). GraphQL elimine ce gaspillage en laissant le client choisir exactement les champs dont il a besoin."
    Write-Paragraph ""

    Write-Heading2 "Tache 9 - Concevoir un schema GraphQL"
    Write-Paragraph "Schema complet modelise dans schema.graphql pour la bibliotheque :"
    $schemaCode = @'
type Livre {
  id: ID!
  titre: String!
  isbn: String!
  disponible: Boolean!
  auteur: Auteur!
  emprunts(enCoursSeulement: Boolean = true): [Emprunt!]!
}
type Auteur {
  id: ID!
  nom: String!
  livres: [Livre!]!
}
type Emprunt {
  id: ID!
  dateEmprunt: String!
  dateRetourPrevue: String!
  enCours: Boolean!
  livre: Livre!
  utilisateur: Utilisateur!
}
type Utilisateur {
  id: ID!, nom: String!, email: String!
}
type Query {
  livre(id: ID!): Livre
  livres(disponible: Boolean): [Livre!]!
  auteur(id: ID!): Auteur
}
'@
    Write-CodeBlock $schemaCode
    Write-Paragraph "Justifications : Typage strict avec ID! et non-nullite (!), argument de filtrage enCoursSeulement sur la relation des emprunts pour eviter les transferts superflus, et relations bidirectionnelles navigables."
    Write-Paragraph ""

    Write-Heading2 "Tache 10 - Concevoir un service gRPC"
    Write-Paragraph "Definition Protocol Buffers proto3 dans bibliotheque.proto :"
    $protoCode = @'
syntax = "proto3";
package bibliotheque;

message LivreRequest {
  int32 id = 1;
}
message LivreResponse {
  int32 id = 1;
  string titre = 2;
  string auteur = 3;
  bool disponible = 4;
}
message StreamEmpruntsRequest {
  string categorie_filtre = 1;
}
message EmpruntNotification {
  int32 emprunt_id = 1;
  int32 livre_id = 2;
  string titre_livre = 3;
  string timestamp = 4;
}
service LivreService {
  rpc GetLivre (LivreRequest) returns (LivreResponse);
  rpc SuivreEmpruntsEnTempsReel (StreamEmpruntsRequest) returns (stream EmpruntNotification);
}
'@
    Write-CodeBlock $protoCode
    Write-Paragraph "Justifications des modes de streaming :"
    Write-Bullet "Methode GetLivre -> Mode Unaire (Unary RPC) : La consultation ponctuelle d'un livre correspond au paradigme classique 1 requete -> 1 reponse. C'est le mode le plus direct et le plus performant pour une lecture unitaire."
    Write-Bullet "Tableau de bord des emprunts en continu -> Mode Server Streaming : Le client ouvre une connexion initiale d'ecoute et le serveur maintient la connexion HTTP/2 ouverte pour pousser (push) les evenements au fil de l'eau (stream). Contrairement au mode unaire qui ferme la connexion apres une seule reponse, le server streaming etablit un flux persistant temps reel sans polling."
    Write-Paragraph ""

    # SYNTHESE
    Write-Heading1 "Synthese Comparative Globale"
    
    $tableSynth = $doc.Tables.Add($selection.Range, 6, 5)
    $tableSynth.Borders.Enable = 1
    
    $headersS = @("Critere", "SOAP", "REST", "GraphQL", "gRPC")
    for ($c = 1; $c -le 5; $c++) {
        $cell = $tableSynth.Cell(1, $c)
        $cell.Range.Text = $headersS[$c-1]
        $cell.Range.Bold = $true
        $cell.Range.Shading.BackgroundPatternColor = [int]0xEFEFEF
    }
    
    $dataS = @(
        @("Transport", "HTTP (tunnel aveugle)", "HTTP/1.1 ou 2", "HTTP (POST)", "HTTP/2 (binaire)"),
        @("Format", "XML (Enveloppe rigide)", "JSON / XML", "JSON personnalise", "Protobuf (Binaire)"),
        @("Paradigme", "RPC (Procedures)", "Ressources (CRUD)", "Graphe declaratif", "RPC Type rapide"),
        @("Under-fetching", "Selon methode", "Frequent (N+1)", "Resolu", "Gere par messages"),
        @("Over-fetching", "Payloads rigides", "Frequent", "Resolu", "Compact / Binaire")
    )
    
    for ($r = 0; $r -lt $dataS.Count; $r++) {
        for ($c = 0; $c -lt 5; $c++) {
            $tableSynth.Cell($r + 2, $c + 1).Range.Text = $dataS[$r][$c]
        }
    }
    
    $selection.SetRange($tableSynth.Range.End, $tableSynth.Range.End)
    $selection.TypeParagraph()

    # Sauvegarde DOCX et PDF
    $docxPath = "$PSScriptRoot\RAPPORT_TP3.docx"
    $pdfPath = "$PSScriptRoot\RAPPORT_TP3.pdf"
    
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
