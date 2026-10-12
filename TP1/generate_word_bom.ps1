$ErrorActionPreference = "Stop"

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $word.Documents.Add()
$selection = $word.Selection
$selection.Font.Name = "Calibri"
$selection.Font.Size = 11

function Write-Heading($text, $level) {
    $selection.Font.Size = if ($level -eq 1) { 24 } else { 16 }
    $selection.Font.Bold = $true
    $selection.TypeText($text)
    $selection.TypeParagraph()
    $selection.Font.Size = 11
    $selection.Font.Bold = $false
}

function Write-Normal($text) {
    $selection.TypeText($text)
    $selection.TypeParagraph()
}

function Write-Image($path) {
    $absPath = (Resolve-Path $path).Path
    $selection.InlineShapes.AddPicture($absPath, $false, $true) | Out-Null
    $selection.TypeParagraph()
}

Write-Heading "Rapport TP1" 1

Write-Heading "Tâche 1 - URLs et GET" 2
Write-Normal "Requête GET simple :"
Write-Image "images\get_posts.png"
Write-Normal "- Code de statut : 200 OK (requête réussie)."
Write-Normal "- Nombre d'éléments : 100 posts."
Write-Normal "- Structure : C'est une liste d'objets JSON avec les clés userId, id, title et body."
Write-Normal ""
Write-Normal "Paramètres de requête :"
Write-Image "images\get_params.png"
Write-Normal "- Résultats : 10 posts avec userId=1, et 5 posts avec _limit=5."
Write-Normal "- Intérêt : Ça permet de filtrer ou paginer sans devoir créer une route serveur pour chaque cas."
Write-Normal ""

Write-Heading "Tâche 2 - En-têtes HTTP" 2
Write-Image "images\get_headers.png"
Write-Normal "- L'en-tête de requête est envoyé par le client pour dire ce qu'il veut, l'en-tête de réponse est renvoyé par le serveur pour décrire ce qu'il donne."
Write-Normal "- Accept = ce que le client veut recevoir. Content-Type = le format réel envoyé."
Write-Normal ""

Write-Heading "Tâche 3 - POST, PUT, PATCH, DELETE" 2
Write-Normal "Créer (POST) :"
Write-Image "images\post_create.png"
Write-Normal "Remplacer (PUT) :"
Write-Image "images\put_update.png"
Write-Normal "Modifier (PATCH) :"
Write-Image "images\patch_update.png"
Write-Normal "- PUT remplace toute la ressource, PATCH modifie juste les champs donnés (ici le titre est modifié et le reste est gardé)."
Write-Normal ""
Write-Normal "Supprimer (DELETE) :"
Write-Image "images\delete_post.png"
Write-Normal "- La réponse 204 No Content a un corps vide. C'est normal car la ressource est supprimée, le serveur n'a plus rien à renvoyer à part confirmer le succès."
Write-Normal ""

Write-Heading "Tâche 4 - Erreurs" 2
Write-Normal "404 Not Found :"
Write-Image "images\get_404.png"
Write-Normal "405 Method Not Allowed :"
Write-Image "images\get_405.png"
Write-Normal "400 Bad Request :"
Write-Image "images\get_400.png"
Write-Normal "- Dans ces 3 cas (classe 4xx), l'erreur vient du client car il s'est trompé dans l'URL, la méthode ou le JSON envoyé. Les erreurs du serveur sont en 5xx."
Write-Normal ""

Write-Heading "Tâche 5 - Tests" 2
Write-Image "images\run_tests.png"
Write-Normal "- C'est plus fiable qu'à l'oeil nu car ça évite les erreurs d'inattention et c'est automatique."
Write-Normal "- C'est indispensable en intégration continue (CI/CD) pour vérifier qu'on ne casse rien avant une mise en prod."
Write-Normal ""

Write-Heading "Tâche 6 - Jeton" 2
Write-Image "images\auth_bearer.png"
Write-Normal "- Syntaxe : Authorization: Bearer <jeton>"
Write-Normal "- Le HTTPS est obligatoire pour chiffrer le token, sinon il passe en clair sur le réseau et peut être volé."
Write-Normal ""

Write-Heading "Tâche 7 - Documentation" 2
Write-Normal "- La doc Postman sert de contrat d'API : elle liste les routes et les formats attendus pour que le client puisse l'utiliser sans regarder le code serveur."
Write-Normal ""

Write-Heading "Récapitulatif et Réflexion" 2
Write-Normal "GET /posts -> 200 OK (Liste des posts récupérée)"
Write-Normal "POST /posts -> 201 Created (Post créé)"
Write-Normal "PUT /posts/1 -> 200 OK (Post remplacé)"
Write-Normal "PATCH /posts/1 -> 200 OK (Titre modifié)"
Write-Normal "DELETE /posts/1 -> 200 OK (Post supprimé)"
Write-Normal ""
Write-Normal "Le protocole HTTP permet de faire des API propres et uniformes grâce à ses méthodes (GET, POST...) et ses codes de retour clairs (200, 404...). Ça rend le système logique."
Write-Normal "L'ajout de tests automatisés (Tâche 5) permet de sécuriser l'application. Sur un projet, on ne peut pas tester chaque route à la main à chaque changement. Les tests s'assurent que les modifications de code ne créent pas de bugs sur l'API existante."

$outputPath = "$pwd\rapport_TP1.docx"
if (Test-Path $outputPath) { Remove-Item $outputPath }
$doc.SaveAs([ref]$outputPath, [ref]16)
$doc.Close()
$word.Quit()
Write-Host "DOCX created successfully at $outputPath"
