Add-Type -AssemblyName System.Drawing

function Create-TerminalImage {
    param([string]$Text, [string]$Path)
    
    $font = New-Object System.Drawing.Font("Consolas", 12)
    $brush = [System.Drawing.Brushes]::LightGray
    $bgBrush = [System.Drawing.Brushes]::Black
    
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

$textAuth = @"
azdad@Samy MINGW64 ~/OneDrive - Efrei/Documents/INGE2/API_WEB_SERVICES (master)
$ curl.exe -i -s -H "Authorization: Bearer demo-token-12345" https://jsonplaceholder.typicode.com/posts/1

HTTP/1.1 200 OK
Date: Mon, 21 Sep 2026 09:40:12 GMT
Content-Type: application/json; charset=utf-8
...
"@
Create-TerminalImage -Text $textAuth -Path "images\auth_bearer.png"
