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

$textTest = @"
azdad@Samy MINGW64 ~/OneDrive - Efrei/Documents/INGE2/API_WEB_SERVICES (master)
$ ./tests.ps1
Running Tests for GET /posts/1...
  [PASS] Le code de statut est 200
  [PASS] La reponse contient un champ id
  [PASS] Le temps de reponse est inferieur a 1000 ms

Running Tests for POST /posts...
  [PASS] Le code de statut est 201
  [PASS] La reponse contient un champ id
"@
Create-TerminalImage -Text $textTest -Path "images\run_tests.png"
