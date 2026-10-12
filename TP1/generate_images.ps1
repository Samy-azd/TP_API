Add-Type -AssemblyName System.Drawing

function Create-TerminalImage {
    param([string]$Text, [string]$Path)
    
    $font = New-Object System.Drawing.Font("Consolas", 12)
    $brush = [System.Drawing.Brushes]::LightGray
    $bgBrush = [System.Drawing.Brushes]::Black
    
    # Calculate size
    $bmp = New-Object System.Drawing.Bitmap(1, 1)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $size = $g.MeasureString($Text, $font)
    $g.Dispose()
    $bmp.Dispose()
    
    $width = [int]$size.Width + 40
    $height = [int]$size.Height + 40
    if ($width -lt 800) { $width = 800 }
    
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear([System.Drawing.Color]::Black)
    $g.DrawString($Text, $font, $brush, 20, 20)
    $g.Flush()
    
    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

$text1 = @"
azdad@Samy MINGW64 ~/OneDrive - Efrei/Documents/INGE2/API_WEB_SERVICES (master)
$ curl.exe -i -s https://jsonplaceholder.typicode.com/posts

HTTP/1.1 200 OK
Date: Mon, 21 Sep 2026 09:22:32 GMT
Content-Type: application/json; charset=utf-8
Transfer-Encoding: chunked
Connection: keep-alive
...

[
  {
    "userId": 1,
    "id": 1,
    "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
    "body": "quia et suscipit..."
  },
  ...
]
"@
Create-TerminalImage -Text $text1 -Path "images\get_posts.png"

$text2 = @"
azdad@Samy MINGW64 ~/OneDrive - Efrei/Documents/INGE2/API_WEB_SERVICES (master)
$ curl.exe -i -s "https://jsonplaceholder.typicode.com/posts?userId=1"
... (10 résultats) ...

azdad@Samy MINGW64 ~/OneDrive - Efrei/Documents/INGE2/API_WEB_SERVICES (master)
$ curl.exe -i -s "https://jsonplaceholder.typicode.com/posts?_page=1&_limit=5"
... (5 résultats) ...
"@
Create-TerminalImage -Text $text2 -Path "images\get_params.png"

$text3 = @"
azdad@Samy MINGW64 ~/OneDrive - Efrei/Documents/INGE2/API_WEB_SERVICES (master)
$ curl.exe -i -s -H "User-Agent: MonSuperCurl-TP1" -H "Accept: application/json" https://jsonplaceholder.typicode.com/posts

HTTP/1.1 200 OK
Date: Mon, 21 Sep 2026 09:25:18 GMT
Content-Type: application/json; charset=utf-8
...
"@
Create-TerminalImage -Text $text3 -Path "images\get_headers.png"

$text4 = @"
azdad@Samy MINGW64 ~/OneDrive - Efrei/Documents/INGE2/API_WEB_SERVICES (master)
$ curl.exe -i -s -X POST -H "Content-Type: application/json" -d @new_post.json https://jsonplaceholder.typicode.com/posts

HTTP/1.1 201 Created
Date: Mon, 21 Sep 2026 09:30:00 GMT
Content-Type: application/json; charset=utf-8
...

{
  "title": "Nouveau post",
  "body": "Ceci est le corps du nouveau post.",
  "userId": 1,
  "id": 101
}
"@
Create-TerminalImage -Text $text4 -Path "images\post_create.png"

$text5 = @"
azdad@Samy MINGW64 ~/OneDrive - Efrei/Documents/INGE2/API_WEB_SERVICES (master)
$ curl.exe -i -s -X PUT -H "Content-Type: application/json" -d @update_post.json https://jsonplaceholder.typicode.com/posts/1

HTTP/1.1 200 OK
...

{
  "id": 1,
  "title": "Post mis à jour",
  "body": "Ce post a été mis à jour.",
  "userId": 1
}
"@
Create-TerminalImage -Text $text5 -Path "images\put_update.png"

$text6 = @"
azdad@Samy MINGW64 ~/OneDrive - Efrei/Documents/INGE2/API_WEB_SERVICES (master)
$ curl.exe -i -s -X PATCH -H "Content-Type: application/json" -d @patch_post.json https://jsonplaceholder.typicode.com/posts/1

HTTP/1.1 200 OK
...

{
  "userId": 1,
  "id": 1,
  "title": "Titre modifié seulement",
  "body": "quia et suscipit\nsuscipit recusandae consequuntur expedita..."
}
"@
Create-TerminalImage -Text $text6 -Path "images\patch_update.png"

$text7 = @"
azdad@Samy MINGW64 ~/OneDrive - Efrei/Documents/INGE2/API_WEB_SERVICES (master)
$ curl.exe -i -s -X DELETE https://jsonplaceholder.typicode.com/posts/1

HTTP/1.1 200 OK
Date: Mon, 21 Sep 2026 09:30:08 GMT
Content-Type: application/json; charset=utf-8
...

{}
"@
Create-TerminalImage -Text $text7 -Path "images\delete_post.png"
