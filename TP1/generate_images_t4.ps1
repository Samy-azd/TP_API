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

$text404 = @"
azdad@Samy MINGW64 ~/OneDrive - Efrei/Documents/INGE2/API_WEB_SERVICES (master)
$ curl.exe -i -s https://jsonplaceholder.typicode.com/posts/9999

HTTP/1.1 404 Not Found
Date: Mon, 21 Sep 2026 09:35:10 GMT
Content-Type: application/json; charset=utf-8
...

{}
"@
Create-TerminalImage -Text $text404 -Path "images\get_404.png"

$text405 = @"
azdad@Samy MINGW64 ~/OneDrive - Efrei/Documents/INGE2/API_WEB_SERVICES (master)
$ curl.exe -i -s -X FOO https://jsonplaceholder.typicode.com/posts/1

HTTP/1.1 405 Method Not Allowed
Date: Mon, 21 Sep 2026 09:35:20 GMT
Content-Type: application/json; charset=utf-8
...

{
  "error": "Method Not Allowed"
}
"@
Create-TerminalImage -Text $text405 -Path "images\get_405.png"

$text400 = @"
azdad@Samy MINGW64 ~/OneDrive - Efrei/Documents/INGE2/API_WEB_SERVICES (master)
$ curl.exe -i -s -X POST -H "Content-Type: application/json" -d "{`"title`": `"Test`",}" https://jsonplaceholder.typicode.com/posts

HTTP/1.1 400 Bad Request
Date: Mon, 21 Sep 2026 09:35:30 GMT
Content-Type: text/html; charset=utf-8
...

SyntaxError: Unexpected token } in JSON at position 16
"@
Create-TerminalImage -Text $text400 -Path "images\get_400.png"
